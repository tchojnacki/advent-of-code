import gleam/io
import util/runner
import days/day01
import days/day02

pub fn main() -> Nil {
  use day <- runner.with_day()
  case day {
    1 -> day01.run()
    2 -> day02.run()
    _ -> io.println("Day not found!")
  }
}
