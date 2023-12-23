import gleam/io
import gleam/bool
import util/input_util

const mod = 20_201_227

const init_subject = 7

fn forward_transform(value: Int, subject: Int, loop: Int) -> Int {
  use <- bool.guard(when: loop == 0, return: value)
  forward_transform({ value * subject } % mod, subject, loop - 1)
}

fn backward_transform(value: Int, subject: Int, loop: Int, result: Int) -> Int {
  use <- bool.guard(when: value == result, return: loop)
  backward_transform({ value * subject } % mod, subject, loop + 1, result)
}

fn find_result(subject: Int, loop: Int) -> Int {
  forward_transform(1, subject, loop)
}

fn find_loop(subject: Int, result: Int) -> Int {
  backward_transform(1, subject, 0, result)
}

fn part1(keys: List(Int)) -> Int {
  let assert [card_key, door_key] = keys

  let card_loop = find_loop(init_subject, card_key)
  let card_result = find_result(door_key, card_loop)

  let door_loop = find_loop(init_subject, door_key)
  let door_result = find_result(card_key, door_loop)

  let assert True = card_result == door_result
  card_result
}

pub fn main() -> Nil {
  let testing = input_util.read_numbers("test25")
  let assert 14_897_079 = part1(testing)

  let input = input_util.read_numbers("day25")
  io.debug(part1(input))

  Nil
}
