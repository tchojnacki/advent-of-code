import gleam/int
import gleam/bool
import gleam/float
import gleam/order.{Eq, Gt, Lt}
import ext/resultx as resx

pub fn is_between(number: Int, min: Int, and max: Int) {
  min <= number && number <= max
}

pub fn ceil_divide(dividend: Int, by divisor: Int) -> Int {
  { dividend + divisor - 1 } / divisor
}

pub fn gcd(a: Int, b: Int) -> Int {
  case b == 0 {
    True -> a
    False -> gcd(b, a % b)
  }
}

pub fn lcm(a: Int, b: Int) -> Int {
  case int.compare(a, b) {
    Gt | Eq -> { a / gcd(a, b) } * b
    Lt -> { b / gcd(a, b) } * a
  }
}

fn do_reverse_bits(val: Int, rev: Int, length: Int) -> Int {
  use <- bool.guard(when: length == 0, return: rev)
  let lsb = int.bitwise_and(val, 1)
  let val = int.bitwise_shift_right(val, 1)
  let rev = int.bitwise_shift_left(rev, 1)
  do_reverse_bits(val, int.bitwise_or(rev, lsb), length - 1)
}

pub fn reverse_bits(val: Int, length: Int) -> Int {
  do_reverse_bits(val, 0, length)
}

pub fn sqrt(x: Int) {
  x
  |> int.square_root
  |> resx.assert_unwrap
  |> float.round
}
