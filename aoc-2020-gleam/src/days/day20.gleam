import gleam/io
import gleam/int
import gleam/list
import gleam/dict
import gleam/set.{type Set}
import ext/intx
import ext/listx
import ext/resultx as resx
import ext/genericx as genx
import util/grid
import util/input_util
import util/pos2.{type Pos2}
import util/parser as p

const tile_size = 10

type Tile {
  Tile(id: Int, filled: Set(Pos2))
}

fn edge_ids(tile: Tile) -> List(Int) {
  let extract = fn(filter, map) {
    tile.filled
    |> set.to_list
    |> list.filter(keeping: filter)
    |> list.map(with: fn(pos) { int.bitwise_shift_left(1, map(pos)) })
    |> int.sum
  }

  let dedup = fn(edge_id) {
    int.min(
      edge_id,
      edge_id
      |> intx.reverse_bits(tile_size),
    )
  }

  [
    extract(fn(b) { pos2.y(b) == 0 }, pos2.x),
    extract(fn(b) { pos2.x(b) == 9 }, pos2.y),
    extract(fn(b) { pos2.y(b) == 9 }, pos2.x),
    extract(fn(b) { pos2.x(b) == 0 }, pos2.y),
  ]
  |> list.map(with: dedup)
}

fn parse_tiles(input: String) -> List(Tile) {
  let tile_parser =
    p.literal("Tile ")
    |> p.proceed(with: p.int())
    |> p.skip(p.literal(":\n"))
    |> p.then(p.any_str_of_len(tile_size * tile_size + { tile_size - 1 }))
    |> p.map2(fn(id, content) {
      Tile(
        id,
        content
        |> grid.parse_grid(with: fn(x, y) { #(x, y) }),
      )
    })

  let assert Ok(tiles) =
    input
    |> p.parse_entire(
      with: tile_parser
      |> p.sep1(by: p.nlnl())
      |> p.skip_ws,
    )
  tiles
}

fn part1(input: String) -> Int {
  let tiles = parse_tiles(input)

  let counts =
    tiles
    |> list.flat_map(with: edge_ids)
    |> listx.counts

  tiles
  |> list.filter(keeping: fn(tile) {
    tile
    |> edge_ids
    |> list.map(with: fn(edge_id) {
      counts
      |> dict.get(edge_id)
      |> resx.assert_unwrap
    })
    |> listx.count(satisfying: genx.equals(_, 1))
    |> genx.equals(2)
  })
  |> list.map(with: fn(tile) { tile.id })
  |> int.product
}

fn part2() -> Nil {
  todo
}

pub fn main() -> Nil {
  let testing = input_util.read_text("test20")
  let assert 20_899_048_083_289 = part1(testing)

  let input = input_util.read_text("day20")
  io.debug(part1(input))

  Nil
}
