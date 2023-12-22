import gleam/list
import gleam/string as str
import gleam/set.{type Set}

pub fn parse_grid(lines: String, with constructor: fn(Int, Int) -> a) -> Set(a) {
  lines
  |> str.split("\n")
  |> list.index_map(with: fn(line, y) {
    line
    |> str.to_graphemes
    |> list.index_map(with: fn(grapheme, x) {
      case grapheme {
        "#" -> [constructor(x, y)]
        "." -> []
        _ -> panic
      }
    })
    |> list.flatten
  })
  |> list.flatten
  |> set.from_list
}
