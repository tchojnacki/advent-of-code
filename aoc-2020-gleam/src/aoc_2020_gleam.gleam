import gleam/io
import util/runner
import days/day01
import days/day02
import days/day03
import days/day04
import days/day05

pub fn main() -> Nil {
  use day <- runner.with_day()
  case day {
    1 -> day01.run()
    2 -> day02.run()
    3 -> day03.run()
    4 -> day04.run()
    5 -> day05.run()
    _ -> io.println("Day not found!")
  }
}
