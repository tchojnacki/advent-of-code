import gleam/io
import gleam/list
import gleam/string
import gleam/bool
import ext/resultx
import util/input_util
import util/parser as p

type Policy {
  Policy(min: Int, max: Int, grapheme: String)
}

type Line {
  Line(policy: Policy, password: String)
}

fn is_line_valid1(line: Line) -> Bool {
  line.password
  |> string.to_graphemes
  |> list.filter(for: fn(g) { g == line.policy.grapheme })
  |> list.length
  |> fn(l) { line.policy.min <= l && l <= line.policy.max }
}

fn is_line_valid2(line: Line) -> Bool {
  let graphemes = string.to_graphemes(line.password)
  let grapheme_matches = fn(idx) {
    list.at(in: graphemes, get: idx - 1)
    |> resultx.force_unwrap == line.policy.grapheme
  }
  bool.exclusive_or(
    grapheme_matches(line.policy.min),
    grapheme_matches(line.policy.max),
  )
}

fn parse_line(string: String) -> Line {
  let policy_parser =
    p.int()
    |> p.then_skip(p.grapheme_literal("-"))
    |> p.then(p.int())
    |> p.then_skip(p.grapheme_literal(" "))
    |> p.then_third(p.any_grapheme())
    |> p.then_skip(p.string_literal(": "))
    |> p.map3(with: fn(min, max, grapheme) { Policy(min, max, grapheme) })
    |> p.labeled(with: "policy")

  let password_parser = p.labeled(p.any_string(), with: "password")

  let line_parser =
    policy_parser
    |> p.then(password_parser)
    |> p.map2(fn(policy, password) { Line(policy, password) })
    |> p.labeled(with: "line")

  assert Ok(policy) = p.parse_entire(string, with: line_parser)
  policy
}

fn part1(lines: List(String)) -> Int {
  lines
  |> list.map(with: parse_line)
  |> list.filter(for: is_line_valid1)
  |> list.length
}

fn part2(lines: List(String)) -> Int {
  lines
  |> list.map(with: parse_line)
  |> list.filter(for: is_line_valid2)
  |> list.length
}

pub fn run() -> Nil {
  let test = input_util.read_lines("test02")
  assert 2 = part1(test)
  assert 1 = part2(test)

  let input = input_util.read_lines("day02")
  io.debug(part1(input))
  io.debug(part2(input))

  Nil
}
