import gleam/io
import gleam/int
import gleam/list
import gleam/pair
import gleam/result as res
import gleam/iterator as iter
import ext/listx
import ext/iteratorx as iterx
import ext/resultx as resx
import util/input_util

fn satisfies_two_sum(numbers: List(Int), sum: Int) -> Bool {
  numbers
  |> list.combination_pairs
  |> list.filter(fn(two) { pair.first(two) != pair.second(two) })
  |> list.any(satisfying: fn(two) { pair.first(two) + pair.second(two) == sum })
}

fn part1(numbers: List(Int), preamble_length: Int) -> Int {
  numbers
  |> list.window(by: preamble_length + 1)
  |> iter.from_list
  |> iter.drop_while(satisfying: fn(window) {
    let assert [sum, ..numbers] = list.reverse(window)
    satisfies_two_sum(numbers, sum)
  })
  |> iter.first
  |> resx.assert_unwrap
  |> list.last
  |> resx.assert_unwrap
}

fn part2(numbers: List(Int), preamble_length: Int) -> Int {
  let sum = part1(numbers, preamble_length)
  numbers
  |> iter.from_list
  |> iter.index
  |> iterx.filter_map(with: fn(step) {
    let #(index, _) = step
    let sublist = list.drop(from: numbers, up_to: index)

    sublist
    |> list.scan(from: 0, with: int.add)
    |> list.drop(up_to: 1)
    |> list.take_while(satisfying: fn(s) { s <= sum })
    |> listx.index_of(sum)
    |> res.map(with: fn(offset) { list.take(from: sublist, up_to: offset + 2) })
  })
  |> iter.first
  |> resx.assert_unwrap
  |> fn(set) {
    let assert Ok(min) = list.reduce(set, with: int.min)
    let assert Ok(max) = list.reduce(set, with: int.max)
    min + max
  }
}

pub fn main() -> Nil {
  let test = input_util.read_numbers("test09")
  let assert 127 = part1(test, 5)
  let assert 62 = part2(test, 5)

  let input = input_util.read_numbers("day09")
  io.debug(part1(input, 25))
  io.debug(part2(input, 25))

  Nil
}
