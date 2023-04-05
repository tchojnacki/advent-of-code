import gleam/io
import gleam/list
import gleam/bool
import gleam/string as str
import ext/listx
import ext/intx
import ext/genericx as genx
import ext/resultx as resx
import util/input_util
import util/parser as p

type Policy {
  Policy(min: Int, max: Int, grapheme: String)
}

type Line {
  Line(policy: Policy, password: String)
}

fn parse_line(string: String) -> Line {
  let policy_parser =
    p.int()
    |> p.skip(p.literal("-"))
    |> p.then(p.int())
    |> p.skip(p.literal(" "))
    |> p.then_3rd(p.any_gc())
    |> p.skip(p.literal(": "))
    |> p.map3(with: Policy)
    |> p.labeled(with: "policy")

  let password_parser = p.labeled(p.any_str_greedy(), with: "password")

  let line_parser =
    policy_parser
    |> p.then(password_parser)
    |> p.map2(with: Line)
    |> p.labeled(with: "line")

  let assert Ok(policy) = p.parse_entire(string, with: line_parser)
  policy
}

fn solve(lines: List(String), predicate: fn(Line) -> Bool) -> Int {
  lines
  |> list.map(with: parse_line)
  |> listx.count(satisfying: predicate)
}

fn part1(lines: List(String)) -> Int {
  solve(
    lines,
    fn(line) {
      line.password
      |> str.to_graphemes
      |> listx.count(satisfying: genx.equals(_, line.policy.grapheme))
      |> intx.is_between(line.policy.min, and: line.policy.max)
    },
  )
}

fn part2(lines: List(String)) -> Int {
  solve(
    lines,
    fn(line) {
      let grapheme_matches = fn(index) {
        line.password
        |> str.to_graphemes
        |> list.at(index - 1)
        |> resx.assert_unwrap
        |> genx.equals(line.policy.grapheme)
      }
      bool.exclusive_or(
        grapheme_matches(line.policy.min),
        grapheme_matches(line.policy.max),
      )
    },
  )
}

pub fn main() -> Nil {
  let test = input_util.read_lines("test02")
  let assert 2 = part1(test)
  let assert 1 = part2(test)

  let input = input_util.read_lines("day02")
  io.debug(part1(input))
  io.debug(part2(input))

  Nil
}
