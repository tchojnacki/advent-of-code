import gleam/io
import gleam/list
import gleam/string
import gleam/pair
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

fn parse_policy() -> p.Parser(Policy) {
  p.int()
  |> p.then_skip(p.grapheme("-"))
  |> p.and_then(p.int())
  |> p.then_skip(p.grapheme(" "))
  |> p.and_then(p.any_grapheme())
  |> p.then_skip(p.grapheme(":"))
  |> p.then_skip(p.grapheme(" "))
  |> p.map(with: fn(x) {
    let #(#(min, max), grapheme) = x
    Policy(min, max, grapheme)
  })
}

fn parse_line(string: String) -> Line {
  let line_parser =
    parse_policy()
    |> p.and_then(p.all_remaining())
    |> p.map(fn(t) { Line(pair.first(t), pair.second(t)) })

  assert Ok(#(policy, _)) = p.run(line_parser, on: string)
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
