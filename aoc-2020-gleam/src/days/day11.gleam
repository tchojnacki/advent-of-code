import gleam/io
import gleam/string as str
import gleam/iterator as iter
import gleam/dict.{type Dict}
import ext/dictx
import ext/setx
import ext/listx
import ext/resultx as resx
import ext/genericx as genx
import ext/iteratorx as iterx
import util/input_util
import util/pos2.{type Pos2}

type Seat {
  Empty
  Occupied
}

type Grid {
  Grid(data: Dict(Pos2, Seat))
}

type Settings {
  Settings(threshold: Int, adjacent_counter: fn(Grid, Pos2) -> Int)
}

fn build_grid(from input: String) -> Grid {
  input
  |> str.split(on: "\n")
  |> iter.from_list
  |> iter.map(with: str.trim)
  |> iter.index
  |> iter.flat_map(with: fn(line) {
    let #(row, row_index) = line
    row
    |> str.to_graphemes
    |> iter.from_list
    |> iter.index
    |> iter.flat_map(with: fn(elem) {
      let #(grapheme, col_index) = elem
      case grapheme == "L" {
        True -> iter.single(#(#(col_index, row_index), Empty))
        False -> iter.empty()
      }
    })
  })
  |> dictx.from_iter
  |> Grid
}

fn count_near_adjacent(grid: Grid, from start: Pos2) -> Int {
  start
  |> pos2.neighbours8
  |> setx.count(satisfying: fn(n) {
    case dict.get(grid.data, n) {
      Ok(seat) -> seat == Occupied
      Error(Nil) -> False
    }
  })
}

fn count_far_adjacent(grid: Grid, from start: Pos2) -> Int {
  pos2.directions8()
  |> setx.count(satisfying: fn(d) {
    start
    |> pos2.add(d)
    |> iterx.unfold_infinitely(pos2.add(_, d))
    |> iter.take(up_to: 1000)
    |> iterx.filter_map(with: dict.get(grid.data, _))
    |> iter.first
    |> genx.equals(Ok(Occupied))
  })
}

fn count_occupied(grid: Grid) -> Int {
  grid.data
  |> dict.values
  |> listx.count(satisfying: genx.equals(_, Occupied))
}

fn step_grid(prev: Grid, settings: Settings) -> Grid {
  let Settings(threshold, adjacent_counter) = settings
  prev.data
  |> dict.map_values(with: fn(pos, seat) {
    let adjacent = adjacent_counter(prev, pos)
    case seat {
      Empty if adjacent == 0 -> Occupied
      Occupied if adjacent >= threshold -> Empty
      other -> other
    }
  })
  |> Grid
}

fn is_stable(grid: Grid, settings: Settings) -> Bool {
  let Settings(threshold, adjacent_counter) = settings
  grid.data
  |> dictx.to_iter
  |> iter.all(satisfying: fn(entry) {
    let #(pos, seat) = entry
    let adjacent = adjacent_counter(grid, pos)
    case seat {
      Empty -> adjacent > 0
      Occupied -> adjacent < threshold
    }
  })
}

fn stabilized_occupied(input: String, settings: Settings) -> Int {
  input
  |> build_grid
  |> iterx.unfold_infinitely(with: step_grid(_, settings))
  |> iter.find(one_that: is_stable(_, settings))
  |> resx.assert_unwrap
  |> count_occupied
}

fn part1(input: String) -> Int {
  stabilized_occupied(input, Settings(4, count_near_adjacent))
}

fn part2(input: String) -> Int {
  stabilized_occupied(input, Settings(5, count_far_adjacent))
}

pub fn main() -> Nil {
  let testing = input_util.read_text("test11")
  let assert 37 = part1(testing)
  let assert 26 = part2(testing)

  let input = input_util.read_text("day11")
  io.debug(part1(input))
  io.debug(part2(input))

  Nil
}
