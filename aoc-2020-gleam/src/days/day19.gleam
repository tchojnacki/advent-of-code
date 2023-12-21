import gleam/io
import gleam/list
import gleam/bool
import gleam/string as str
import gleam/dict.{type Dict}
import ext/listx
import ext/resultx as resx
import util/input_util
import util/parser as p

type Rule {
  Literal(String)
  Reference(List(List(Int)))
}

type Ruleset =
  Dict(Int, Rule)

fn parse_input(input: String) -> #(Ruleset, List(String)) {
  let rule_parser =
    p.int()
    |> p.skip(p.literal(": "))
    |> p.then(
      p.literal("\"")
      |> p.proceed(with: p.any_gc())
      |> p.skip(p.literal("\""))
      |> p.map(with: Literal)
      |> p.or(
        otherwise: p.int()
        |> p.sep1(by: p.literal(" "))
        |> p.sep1(by: p.literal(" | "))
        |> p.map(with: Reference),
      ),
    )
    |> p.labeled(with: "rule")

  let input_parser =
    rule_parser
    |> p.sep1(by: p.nl())
    |> p.map(with: dict.from_list)
    |> p.skip(p.nlnl())
    |> p.then(
      p.str1_until_ws()
      |> p.sep1(by: p.nl()),
    )
    |> p.skip_ws()

  input
  |> p.parse_entire(with: input_parser)
  |> resx.assert_unwrap
}

fn matches(
  gc_queue: List(String),
  rule_queue: List(Int),
  ruleset: Ruleset,
) -> Bool {
  case #(gc_queue, rule_queue) {
    #([gc, ..rest], [rule_id, ..rule_queue]) -> {
      let assert Ok(rule) = dict.get(ruleset, rule_id)
      case rule {
        Literal(expected) -> {
          use <- bool.guard(when: gc != expected, return: False)
          matches(rest, rule_queue, ruleset)
        }
        Reference(alternatives) ->
          alternatives
          |> list.any(satisfying: fn(expanded) {
            matches(gc_queue, list.append(expanded, rule_queue), ruleset)
          })
      }
    }
    #([], []) -> True
    _ -> False
  }
}

fn solve(for messages: List(String), under ruleset: Ruleset) -> Int {
  messages
  |> listx.count(satisfying: fn(message) {
    matches(str.to_graphemes(message), [0], ruleset)
  })
}

fn part1(input: String) -> Int {
  let #(ruleset, messages) = parse_input(input)

  solve(for: messages, under: ruleset)
}

fn part2(input: String) -> Int {
  let #(ruleset, messages) = parse_input(input)
  let ruleset =
    ruleset
    |> dict.insert(for: 8, insert: Reference([[42], [42, 8]]))
    |> dict.insert(for: 11, insert: Reference([[42, 31], [42, 11, 31]]))

  solve(for: messages, under: ruleset)
}

pub fn main() -> Nil {
  let testing = input_util.read_text("test19")
  let assert 3 = part1(testing)
  let assert 12 = part2(testing)

  let input = input_util.read_text("day19")
  io.debug(part1(input))
  io.debug(part2(input))

  Nil
}
