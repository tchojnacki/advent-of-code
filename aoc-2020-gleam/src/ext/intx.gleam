import gleam/int
import gleam/order.{Eq, Gt, Lt}

pub fn is_between(number: Int, min: Int, and max: Int) {
  min <= number && number <= max
}

pub fn ceil_divide(dividend: Int, by divisor: Int) -> Int {
  { dividend + divisor - 1 } / divisor
}

fn gcd(a: Int, b: Int) -> Int {
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
