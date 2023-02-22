import gleam/io
import util/runner
import days/day01
import days/day02
import days/day03
import days/day04
import days/day05
import days/day06
import days/day07
import days/day08

pub fn main() -> Nil {
  use day <- runner.with_day()
  case day {
    1 -> day01.run()
    2 -> day02.run()
    3 -> day03.run()
    4 -> day04.run()
    5 -> day05.run()
    6 -> day06.run()
    7 -> day07.run()
    8 -> day08.run()
    _ -> io.println("Day not found!")
  }
}
