import gleam/io
import gleam/int
import gleam/list
import gleam/bool
import ext/listx
import ext/pairx
import ext/genericx as genx
import ext/resultx as resx
import util/input_util
import util/cache.{Cache}

const outlet_joltage = 0

const max_increase = 3

fn process_adapters(numbers: List(Int)) -> List(Int) {
  let numbers = list.sort(numbers, by: int.compare)

  let device_joltage =
    numbers
    |> list.last
    |> resx.assert_unwrap
    |> int.add(max_increase)

  list.flatten([[outlet_joltage], numbers, [device_joltage]])
}

fn part1(numbers: List(Int)) -> Int {
  let adapters = process_adapters(numbers)
  let diffs =
    adapters
    |> list.window_by_2
    |> list.map(with: pairx.difference)

  let ones = listx.count(diffs, satisfying: genx.equals(_, 1))
  let threes = listx.count(diffs, satisfying: genx.equals(_, 3))
  ones * threes
}

fn arrangements(number: Int, adapters: List(Int), cache: Cache(Int, Int)) -> Int {
  use <- bool.guard(when: number == 0, return: 1)
  use <- bool.guard(when: !list.contains(adapters, number), return: 0)
  use <- cache.memoize(with: cache, this: number)

  list.range(from: 1, to: max_increase)
  |> list.map(with: fn(j) { arrangements(number - j, adapters, cache) })
  |> int.sum
}

fn part2(numbers: List(Int)) -> Int {
  let adapters = process_adapters(numbers)
  let assert Ok(device_joltage) = list.last(adapters)
  use cache <- cache.create()
  arrangements(device_joltage, adapters, cache)
}

pub fn main() -> Nil {
  let test = input_util.read_numbers("test10")
  let assert 220 = part1(test)
  let assert 19_208 = part2(test)

  let input = input_util.read_numbers("day10")
  io.debug(part1(input))
  io.debug(part2(input))

  Nil
}
