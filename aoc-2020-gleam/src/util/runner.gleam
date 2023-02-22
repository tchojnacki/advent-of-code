import gleam/list
import gleam/int
import gleam/io
import gleam/result as res
import gleam/erlang.{start_arguments}

fn get_day(handler: fn(Int) -> Nil) -> Result(Nil, String) {
  let args = start_arguments()

  use first <- res.then(
    args
    |> list.first()
    |> res.replace_error("Pass the day as first argument!"),
  )

  use day <- res.then(
    first
    |> int.parse()
    |> res.replace_error("The day argument must be a number!"),
  )

  handler(day)

  Ok(Nil)
}

pub fn with_day(handler: fn(Int) -> Nil) -> Nil {
  handler
  |> get_day
  |> res.map_error(io.println)
  |> res.unwrap(or: Nil)
}
