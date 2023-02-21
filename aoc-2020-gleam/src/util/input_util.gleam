import gleam/int
import gleam/list
import gleam/string
import gleam/function
import gleam/bool
import gleam/erlang/file
import ext/resultx

pub fn read_text(filename: String) -> String {
  "data/" <> filename <> ".txt"
  |> file.read
  |> resultx.force_unwrap
}

pub fn read_lines(filename: String) -> List(String) {
  filename
  |> read_text
  |> string.split(on: "\n")
  |> list.map(with: string.trim)
  |> list.filter(for: function.compose(string.is_empty, bool.negate))
}

pub fn read_numbers(filename: String) -> List(Int) {
  filename
  |> read_lines
  |> list.map(with: function.compose(int.parse, resultx.force_unwrap))
}
