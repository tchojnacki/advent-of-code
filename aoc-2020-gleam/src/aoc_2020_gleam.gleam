import gleam/io
import util/runner
import days/day01

pub fn main() -> Nil {
  use day <- runner.with_day()
  case day {
    1 -> day01.run()
    _ -> io.println("Day not found!")
  }
}
