import gleam/io
import gleam/int
import gleam/string
import gleam/list
import gleam/set.{Set}
import ext/resultx
import util/parser as p
import util/input_util

type Answers =
  Set(String)

type Group =
  List(Answers)

type Input =
  List(Group)

fn alphabet() -> Set(String) {
  set.from_list(string.to_graphemes("abcdefghijklmnopqrstuvwxyz"))
}

fn parse_input(text: String) -> Input {
  let answers_parser =
    p.string1_until_whitespace()
    |> p.map(fn(answer_string) {
      answer_string
      |> string.to_graphemes
      |> set.from_list
    })
    |> p.labeled(with: "answers")

  let group_parser =
    answers_parser
    |> p.separated1(by: p.whitespace_grapheme())
    |> p.labeled(with: "group")

  let input_parser =
    group_parser
    |> p.separated1(by: p.string_literal("\n\n"))
    |> p.then_skip(p.optional(p.whitespace_grapheme()))
    |> p.labeled(with: "input")

  text
  |> p.parse_entire(with: input_parser)
  |> resultx.force_unwrap
}

fn fold_group(
  over group: Group,
  from initial: Set(String),
  with fun: fn(Set(String), Set(String)) -> Set(String),
) -> Int {
  group
  |> list.fold(from: initial, with: fun)
  |> set.size
}

fn answered_by_anyone(in group: Group) -> Int {
  fold_group(over: group, from: set.new(), with: set.union)
}

fn answered_by_everyone(in group: Group) -> Int {
  fold_group(over: group, from: alphabet(), with: set.intersection)
}

fn solve(text: String, with folder: fn(Group) -> Int) -> Int {
  text
  |> parse_input
  |> list.map(with: folder)
  |> int.sum
}

fn part1(text: String) -> Int {
  solve(text, with: answered_by_anyone)
}

fn part2(text: String) -> Int {
  solve(text, with: answered_by_everyone)
}

pub fn run() -> Nil {
  let test = input_util.read_text("test06")
  assert 11 = part1(test)
  assert 6 = part2(test)

  let input = input_util.read_text("day06")
  io.debug(part1(input))
  io.debug(part2(input))

  Nil
}
