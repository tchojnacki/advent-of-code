import gleam/io
import gleam/int
import gleam/list
import gleam/result
import ext/resultx
import util/input_util

fn solve(numbers: List(Int), n: Int) -> Int {
  numbers
  |> list.combinations(by: n)
  |> list.find(one_that: fn(p) { int.sum(p) == 2020 })
  |> result.map(with: int.product)
  |> resultx.force_unwrap()
}

fn part1(numbers: List(Int)) -> Int {
  solve(numbers, 2)
}

fn part2(numbers: List(Int)) -> Int {
  solve(numbers, 3)
}

pub fn run() -> Nil {
  let test = input_util.read_numbers("test01")
  assert 514_579 = part1(test)
  assert 241_861_950 = part2(test)

  let input = input_util.read_numbers("day01")
  io.debug(part1(input))
  io.debug(part2(input))

  Nil
}
