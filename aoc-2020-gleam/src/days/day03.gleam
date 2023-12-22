import gleam/list
import gleam/io
import gleam/int
import gleam/result as res
import gleam/string as str
import gleam/iterator as iter
import gleam/set.{type Set}
import ext/intx
import ext/iteratorx as iterx
import util/grid
import util/input_util
import util/pos2.{type Pos2}

const starting_pos = #(0, 0)

const base_slope = #(3, 1)

const all_slopes = [#(1, 1), base_slope, #(5, 1), #(7, 1), #(1, 2)]

type Area {
  Area(trees: Set(Pos2), cycle: Int, height: Int)
}

fn parse_area(from text: String) -> Area {
  let lines = str.split(text, on: "\n")

  let trees = grid.parse_grid(text, with: fn(x, y) { #(x, y) })
  let assert Ok(cycle) =
    lines
    |> list.first
    |> res.map(with: str.length)
  let height = list.length(lines)

  Area(trees, cycle, height)
}

fn has_tree(in area: Area, at t: Pos2) -> Bool {
  set.contains(area.trees, #(pos2.x(t) % area.cycle, pos2.y(t)))
}

fn is_valid(p: Pos2, in area: Area) -> Bool {
  intx.is_between(pos2.y(p), 0, and: area.height - 1)
}

fn tree_count(in area: Area, with slope: Pos2) -> Int {
  starting_pos
  |> iter.iterate(with: pos2.add(_, slope))
  |> iter.take_while(satisfying: is_valid(_, in: area))
  |> iterx.count(satisfying: has_tree(in: area, at: _))
}

fn part1(text: String) -> Int {
  text
  |> parse_area
  |> tree_count(with: base_slope)
}

fn part2(text: String) -> Int {
  let area = parse_area(from: text)

  all_slopes
  |> list.map(with: tree_count(in: area, with: _))
  |> int.product
}

pub fn main() -> Nil {
  let testing = input_util.read_text("test03")
  let assert 7 = part1(testing)
  let assert 336 = part2(testing)

  let input = input_util.read_text("day03")
  io.debug(part1(input))
  io.debug(part2(input))

  Nil
}
