import gleam/io
import gleam/bool
import gleam/list
import gleam/set.{type Set}
import ext/setx
import ext/resultx as resx
import util/input_util
import util/parser as p
import util/hex.{type Hex}

fn parse_flips(lines: List(String)) -> List(Hex) {
  let tile_parser =
    [
      p.replace(p.literal("e"), with: hex.e),
      p.replace(p.literal("se"), with: hex.se),
      p.replace(p.literal("sw"), with: hex.sw),
      p.replace(p.literal("w"), with: hex.w),
      p.replace(p.literal("nw"), with: hex.nw),
      p.replace(p.literal("ne"), with: hex.ne),
    ]
    |> p.any
    |> p.many1
    |> p.map(with: list.fold(over: _, from: hex.zero, with: hex.add))

  list.map(lines, with: fn(line) {
    line
    |> p.parse_entire(with: tile_parser)
    |> resx.assert_unwrap
  })
}

fn get_black_tiles(flips: List(Hex)) -> Set(Hex) {
  list.fold(over: flips, from: set.new(), with: setx.toggle)
}

fn cycle(prev: Set(Hex), times: Int) -> Set(Hex) {
  use <- bool.guard(when: times == 0, return: prev)

  prev
  |> setx.flat_map(with: hex.neighbours7)
  |> set.fold(from: set.new(), with: fn(acc, tile) {
    let was_black = set.contains(in: prev, this: tile)
    let adjacent =
      tile
      |> hex.neighbours6
      |> set.intersection(prev)
      |> set.size

    case #(was_black, adjacent) {
      #(True, 1) | #(_, 2) -> set.insert(into: acc, this: tile)
      _ -> acc
    }
  })
  |> cycle(times - 1)
}

fn part1(lines: List(String)) -> Int {
  lines
  |> parse_flips
  |> get_black_tiles
  |> set.size
}

fn part2(lines: List(String)) -> Int {
  lines
  |> parse_flips
  |> get_black_tiles
  |> cycle(100)
  |> set.size
}

pub fn main() -> Nil {
  let testing = input_util.read_lines("test24")
  let assert 10 = part1(testing)
  let assert 2208 = part2(testing)

  let input = input_util.read_lines("day24")
  io.debug(part1(input))
  io.debug(part2(input))

  Nil
}
