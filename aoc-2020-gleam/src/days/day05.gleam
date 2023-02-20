import gleam/io
import gleam/int
import gleam/string
import gleam/list
import gleam/set
import gleam/iterator as iter
import ext/resultx
import util/input_util

fn get_seat_id(pass: String) -> Int {
  pass
  |> string.to_graphemes
  |> list.map(with: fn(grapheme) {
    case grapheme {
      "F" | "L" -> "0"
      "B" | "R" -> "1"
    }
  })
  |> string.concat
  |> int.base_parse(2)
  |> resultx.force_unwrap
}

fn part1(lines: List(String)) -> Int {
  lines
  |> list.map(with: get_seat_id)
  |> list.reduce(with: int.max)
  |> resultx.force_unwrap
}

fn part2(lines: List(String)) -> Int {
  let seat_ids =
    lines
    |> list.map(with: get_seat_id)
    |> set.from_list

  let occupied = fn(id) { set.contains(in: seat_ids, this: id) }

  iter.find(
    in: iter.range(from: 1, to: 1023),
    one_that: fn(id) { occupied(id - 1) && !occupied(id) && occupied(id + 1) },
  )
  |> resultx.force_unwrap
}

pub fn run() -> Nil {
  let test = input_util.read_lines("test05")
  assert 820 = part1(test)

  let input = input_util.read_lines("day05")
  io.debug(part1(input))
  io.debug(part2(input))

  Nil
}
