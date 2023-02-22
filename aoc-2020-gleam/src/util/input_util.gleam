import gleam/int
import gleam/list
import gleam/bool
import gleam/string as str
import gleam/function as fun
import gleam/erlang/file
import ext/resultx as resx

pub fn read_text(filename: String) -> String {
  "data/" <> filename <> ".txt"
  |> file.read
  |> resx.assert_unwrap
}

pub fn read_lines(filename: String) -> List(String) {
  filename
  |> read_text
  |> str.split(on: "\n")
  |> list.map(with: str.trim)
  |> list.filter(for: fun.compose(str.is_empty, bool.negate))
}

pub fn read_numbers(filename: String) -> List(Int) {
  filename
  |> read_lines
  |> list.map(with: fun.compose(int.parse, resx.assert_unwrap))
}
