import gleam/io
import gleam/list
import gleam/bool
import gleam/string as str
import gleam/set.{Set}
import util/input_util
import util/pos3
import util/pos4

fn parse_grid(input: String, with constructor: fn(Int, Int) -> a) -> Set(a) {
  input
  |> str.split(on: "\n")
  |> list.index_map(with: fn(y, line) {
    line
    |> str.to_graphemes
    |> list.index_map(with: fn(x, grapheme) {
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

fn cycle(
  grid: Set(a),
  with neighbours: fn(a) -> Set(a),
  by times: Int,
) -> Set(a) {
  use <- bool.guard(when: times == 0, return: grid)

  grid
  |> set.fold(
    from: set.new(),
    with: fn(acc, pos) {
      acc
      |> set.insert(pos)
      |> set.union(neighbours(pos))
    },
  )
  |> set.filter(for: fn(pos) {
    let active = set.contains(in: grid, this: pos)
    let count =
      pos
      |> neighbours
      |> set.intersection(grid)
      |> set.size

    case active, count {
      True, 2 -> True
      True, 3 -> True
      True, _ -> False
      False, 3 -> True
      False, _ -> False
    }
  })
  |> cycle(with: neighbours, by: times - 1)
}

fn part1(input: String) -> Int {
  input
  |> parse_grid(with: fn(x, y) { #(x, y, 0) })
  |> cycle(with: pos3.neighbours26, by: 6)
  |> set.size
}

fn part2(input: String) -> Int {
  input
  |> parse_grid(with: fn(x, y) { #(x, y, 0, 0) })
  |> cycle(with: pos4.neighbours80, by: 6)
  |> set.size
}

pub fn main() -> Nil {
  let test = input_util.read_text("test17")
  let assert 112 = part1(test)
  let assert 848 = part2(test)

  let input = input_util.read_text("day17")
  io.debug(part1(input))
  io.debug(part2(input))

  Nil
}
