import gleam/io
import gleam/string as str
import gleam/iterator.{Next} as iter
import gleam/map.{Map}
import ext/mapx
import ext/setx
import ext/listx
import ext/resultx as resx
import ext/genericx as genx
import ext/iteratorx as iterx
import util/input_util
import util/pos.{Pos}

type Seat {
  Empty
  Occupied
}

type Grid {
  Grid(data: Map(Pos, Seat))
}

type Settings {
  Settings(threshold: Int, adjacent_counter: fn(Grid, Pos) -> Int)
}

fn build_grid(from input: String) -> Grid {
  input
  |> str.split(on: "\n")
  |> iter.from_list
  |> iter.map(with: str.trim)
  |> iter.index
  |> iter.flat_map(with: fn(line) {
    let #(row_index, row) = line
    row
    |> str.to_graphemes
    |> iter.from_list
    |> iter.index
    |> iter.flat_map(with: fn(elem) {
      let #(col_index, grapheme) = elem
      case grapheme == "L" {
        True -> iter.single(#(#(col_index, row_index), Empty))
        False -> iter.empty()
      }
    })
  })
  |> mapx.from_iter
  |> Grid
}

fn count_near_adjacent(grid: Grid, pos: Pos) -> Int {
  pos
  |> pos.neighbours8
  |> setx.count(satisfying: fn(n) {
    case map.get(grid.data, n) {
      Ok(seat) -> seat == Occupied
      Error(Nil) -> False
    }
  })
}

fn count_far_adjacent(grid: Grid, pos: Pos) -> Int {
  pos.directions8
  |> listx.count(satisfying: fn(d) {
    iter.unfold(
      from: pos.add(pos, d),
      with: fn(p) { Next(element: p, accumulator: pos.add(p, d)) },
    )
    // Bigger than the largest map size
    |> iter.take(up_to: 1000)
    |> iterx.filter_map(with: map.get(grid.data, _))
    |> iter.first
    |> genx.equals(Ok(Occupied))
  })
}

fn count_occupied(grid: Grid) -> Int {
  grid.data
  |> map.values
  |> listx.count(satisfying: genx.equals(_, Occupied))
}

fn step_grid(prev: Grid, settings: Settings) -> Grid {
  let Settings(threshold, adjacent_counter) = settings
  prev.data
  |> map.map_values(with: fn(pos, seat) {
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
  |> mapx.to_iter
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
  |> iter.unfold(with: fn(g) {
    Next(element: g, accumulator: step_grid(g, settings))
  })
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
  let test = input_util.read_text("test11")
  let assert 37 = part1(test)
  let assert 26 = part2(test)

  let input = input_util.read_text("day11")
  io.debug(part1(input))
  io.debug(part2(input))

  Nil
}
