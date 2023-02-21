import gleam/io
import gleam/list
import gleam/string
import gleam/bool
import ext/resultx
import ext/listx
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
    |> p.then_skip(p.literal("-"))
    |> p.then(p.int())
    |> p.then_skip(p.literal(" "))
    |> p.then_3rd(p.any_gc())
    |> p.then_skip(p.literal(": "))
    |> p.map3(with: fn(min, max, grapheme) { Policy(min, max, grapheme) })
    |> p.labeled(with: "policy")

  let password_parser = p.labeled(p.any_str_greedy(), with: "password")

  let line_parser =
    policy_parser
    |> p.then(password_parser)
    |> p.map2(fn(policy, password) { Line(policy, password) })
    |> p.labeled(with: "line")

  assert Ok(policy) = p.parse_entire(string, with: line_parser)
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
      |> string.to_graphemes
      |> listx.count(satisfying: fn(g) { g == line.policy.grapheme })
      |> fn(l) { line.policy.min <= l && l <= line.policy.max }
    },
  )
}

fn part2(lines: List(String)) -> Int {
  solve(
    lines,
    fn(line) {
      let graphemes = string.to_graphemes(line.password)
      let grapheme_matches = fn(idx) {
        list.at(in: graphemes, get: idx - 1)
        |> resultx.force_unwrap == line.policy.grapheme
      }
      bool.exclusive_or(
        grapheme_matches(line.policy.min),
        grapheme_matches(line.policy.max),
      )
    },
  )
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
