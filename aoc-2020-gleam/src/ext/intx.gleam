import gleam/int
import ext/resultx

pub fn force_parse(string: String) -> Int {
  string
  |> int.parse()
  |> resultx.force_unwrap()
}
