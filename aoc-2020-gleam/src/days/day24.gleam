import gleam/io
import gleam/set
import gleam/list
import ext/setx
import ext/resultx as resx
import util/input_util
import util/parser as p
import util/hex.{type Hex}

fn parse_tiles(lines: List(String)) -> List(Hex) {
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

fn part1(lines: List(String)) -> Int {
  let tiles = parse_tiles(lines)
  let blacks = list.fold(over: tiles, from: set.new(), with: setx.toggle)
  set.size(blacks)
}

fn part2(lines: List(String)) -> Nil {
  Nil
}

pub fn main() -> Nil {
  let testing = input_util.read_lines("test24")
  let assert 10 = part1(testing)
  io.debug(part2(testing))

  let input = input_util.read_lines("day24")
  io.debug(part1(input))
  io.debug(part2(input))

  Nil
}
