import gleam/io
import gleam/list
import gleam/function as fun
import gleam/result as res
import gleam/map.{Map}
import ext/listx
import ext/intx
import ext/resultx as resx
import util/input_util
import util/parser as p

const allowed_fields = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid", "cid"]

const required_fields = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]

const eye_colors = ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]

type Passport {
  Passport(fields: Map(String, String))
}

fn parse_passports(from text: String) -> List(Passport) {
  let key_parser =
    p.any_str_of_len(3)
    |> p.labeled(with: "key")
  let value_parser =
    p.str1_until_ws()
    |> p.labeled(with: "value")
  let field_parser =
    key_parser
    |> p.skip(p.literal(":"))
    |> p.then(value_parser)
    |> p.labeled(with: "field")
  let passport_parser =
    field_parser
    |> p.sep1(by: p.ws_gc())
    |> p.map(with: fun.compose(map.from_list, Passport))
    |> p.labeled(with: "passport")
  let input_parser =
    passport_parser
    |> p.sep1(by: p.literal("\n\n"))
    |> p.skip_ws
    |> p.labeled(with: "input")

  text
  |> p.parse_entire(with: input_parser)
  |> resx.assert_unwrap
}

fn is_valid1(passport: Passport) -> Bool {
  let has_only_allowed_keys =
    map.keys(passport.fields)
    |> list.all(satisfying: list.contains(allowed_fields, _))

  let has_all_required_keys =
    required_fields
    |> list.all(satisfying: list.contains(map.keys(passport.fields), _))

  has_only_allowed_keys && has_all_required_keys
}

fn is_valid2(passport: Passport) -> Bool {
  let int_between = fn(min, max) {
    p.int()
    |> p.satisfying(rule: intx.is_between(_, min, and: max))
    |> p.ignore
  }

  let validators = [
    #("byr", int_between(1920, 2002)),
    #("iyr", int_between(2010, 2020)),
    #("eyr", int_between(2020, 2030)),
    #(
      "hgt",
      p.or(
        int_between(150, 193)
        |> p.then(p.literal("cm")),
        int_between(59, 76)
        |> p.then(p.literal("in")),
      )
      |> p.ignore,
    ),
    #(
      "hcl",
      p.literal("#")
      |> p.then(
        p.gc_in(range: "0123456789abcdef")
        |> p.repeat(times: 6),
      )
      |> p.ignore,
    ),
    #(
      "ecl",
      eye_colors
      |> list.map(with: p.literal)
      |> p.any
      |> p.ignore,
    ),
    #(
      "pid",
      p.digit()
      |> p.str_of_len(9)
      |> p.ignore,
    ),
  ]

  is_valid1(passport) && list.all(
    validators,
    satisfying: fn(validator) {
      let #(key, parser) = validator
      passport.fields
      |> map.get(key)
      |> res.then(apply: fn(value) {
        value
        |> p.parse_entire(with: parser)
        |> res.replace_error(Nil)
      })
      |> res.is_ok
    },
  )
}

fn part1(text: String) -> Int {
  text
  |> parse_passports
  |> listx.count(satisfying: is_valid1)
}

fn part2(text: String) -> Int {
  text
  |> parse_passports
  |> listx.count(satisfying: is_valid2)
}

pub fn run() -> Nil {
  let test = input_util.read_text("test04")
  let assert 2 = part1(test)
  let assert 2 = part2(test)

  let input = input_util.read_text("day04")
  io.debug(part1(input))
  io.debug(part2(input))

  Nil
}
