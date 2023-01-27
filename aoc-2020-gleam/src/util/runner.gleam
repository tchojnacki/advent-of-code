import gleam/list
import gleam/int
import gleam/io
import gleam/result
import gleam/erlang.{start_arguments}

fn get_day(handler: fn(Int) -> Nil) -> Result(Nil, String) {
  let args = start_arguments()

  use first <- result.then(
    args
    |> list.first()
    |> result.replace_error("Pass the day as first argument!"),
  )

  use day <- result.then(
    first
    |> int.parse()
    |> result.replace_error("The day argument must be a number!"),
  )

  handler(day)

  Ok(Nil)
}

pub fn with_day(handler: fn(Int) -> Nil) -> Nil {
  handler
  |> get_day()
  |> result.map_error(io.println)
  |> result.unwrap(Nil)
}
