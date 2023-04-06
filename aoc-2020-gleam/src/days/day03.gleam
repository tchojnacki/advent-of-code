import gleam/list
import gleam/io
import gleam/int
import gleam/string as str
import gleam/function as fun
import gleam/iterator as iter
import gleam/set.{Set}
import ext/intx
import ext/resultx as resx
import ext/iteratorx as iterx
import util/input_util
import util/pos.{Pos}

const starting_pos = #(0, 0)

const base_slope = #(3, 1)

const all_slopes = [#(1, 1), base_slope, #(5, 1), #(7, 1), #(1, 2)]

type Area {
  Area(trees: Set(Pos), cycle: Int, height: Int)
}

fn parse_area(from text: String) -> Area {
  let lines = str.split(text, on: "\n")

  let trees =
    list.index_fold(
      over: lines,
      from: set.new(),
      with: fn(prev, line, y) {
        line
        |> str.to_graphemes
        |> list.index_map(with: fn(x, grapheme) {
          case grapheme {
            "#" -> Ok(#(x, y))
            _ -> Error(Nil)
          }
        })
        |> list.filter_map(with: fun.identity)
        |> set.from_list
        |> set.union(prev)
      },
    )
  let cycle =
    lines
    |> list.first
    |> resx.assert_unwrap
    |> str.length
  let height = list.length(lines)

  Area(trees, cycle, height)
}

fn has_tree(in area: Area, at pos: Pos) -> Bool {
  set.contains(area.trees, #(pos.0 % area.cycle, pos.1))
}

fn is_valid(pos: Pos, in area: Area) -> Bool {
  intx.is_between(pos.1, 0, and: area.height - 1)
}

fn tree_count(in area: Area, with slope: Pos) -> Int {
  starting_pos
  |> iter.iterate(with: pos.add(_, slope))
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
  let test = input_util.read_text("test03")
  let assert 7 = part1(test)
  let assert 336 = part2(test)

  let input = input_util.read_text("day03")
  io.debug(part1(input))
  io.debug(part2(input))

  Nil
}
