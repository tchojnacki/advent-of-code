import gleam/io
import gleam/int
import gleam/list
import gleam/dict
import gleam/string as str
import gleam/function as fun
import gleam/iterator as iter
import ext/resultx as resx
import ext/iteratorx as iterx

fn solve(input: String, nth: Int) -> Int {
  let starting =
    input
    |> str.split(on: ",")
    |> list.map(with: fun.compose(int.parse, resx.assert_unwrap))

  let history =
    starting
    |> list.index_map(fn(number, index) { #(number, index + 1) })
    |> dict.from_list
  let turn = list.length(starting)
  let assert Ok(last) = list.last(starting)

  iterx.unfold_infinitely(from: #(history, turn, last), with: fn(state) {
    let #(history, turn, last) = state
    #(
      dict.insert(into: history, for: last, insert: turn),
      turn
      + 1,
      case dict.get(history, last) {
        Ok(previous) -> turn - previous
        Error(Nil) -> 0
      },
    )
  })
  |> iter.filter(fn(state) { state.1 == nth })
  |> iter.map(fn(state) { state.2 })
  |> iter.first
  |> resx.assert_unwrap
}

fn part1(input: String) -> Int {
  solve(input, 2020)
}

fn part2(input: String) -> Int {
  solve(input, 30_000_000)
}

pub fn main() -> Nil {
  let assert 436 = part1("0,3,6")
  let assert 1 = part1("1,3,2")
  let assert 27 = part1("1,2,3")
  let assert 78 = part1("2,3,1")
  let assert 438 = part1("3,2,1")
  let assert 1836 = part1("3,1,2")

  let input = "12,20,0,6,1,17,7"
  io.debug(part1(input))
  io.debug(part2(input))

  Nil
}
