import gleam/io
import gleam/int
import gleam/list
import gleam/bool
import gleam/pair
import gleam/result as res
import gleam/dict.{type Dict}
import gleam/set.{type Set}
import gleam/function as fun
import gleam/iterator as iter
import ext/intx
import ext/setx
import ext/listx
import ext/resultx as resx
import ext/genericx as genx
import ext/iteratorx as iterx
import util/grid
import util/input_util
import util/dir.{type Dir, East, North, South, West}
import util/pos2.{type Pos2}
import util/parser as p

const tile_size = 10

const monster_pattern = "..................#.\n#....##....##....###\n.#..#..#..#..#..#..."

const monster_side = 20

const monster_area = 15

type Tile {
  Tile(id: Int, filled: Set(Pos2))
}

type Layout =
  Dict(Pos2, Tile)

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
        |> grid.parse_grid(with: pair.new),
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

fn socket_at(tile: Tile, dir: Dir) -> Int {
  let #(filter_fn, filter_eq, map_fn) = case dir {
    North -> #(pos2.y, 0, pos2.x)
    East -> #(pos2.x, tile_size - 1, pos2.y)
    South -> #(pos2.y, tile_size - 1, pos2.x)
    West -> #(pos2.x, 0, pos2.y)
  }

  tile.filled
  |> set.to_list
  |> list.filter(keeping: fn(pos) { filter_fn(pos) == filter_eq })
  |> list.map(with: fn(pos) { int.bitwise_shift_left(1, map_fn(pos)) })
  |> int.sum
}

fn edge_ids(tile: Tile) -> List(Int) {
  let dedup = fn(socket) {
    int.min(socket, intx.reverse_bits(socket, tile_size))
  }

  [
    socket_at(tile, North),
    socket_at(tile, East),
    socket_at(tile, South),
    socket_at(tile, West),
  ]
  |> list.map(with: dedup)
}

fn corners(tiles: List(Tile)) -> Set(Int) {
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
  |> set.from_list
}

fn flip_pos(pos: Pos2, side: Int) -> Pos2 {
  let #(x, y) = pos
  #({ side - 1 } - x, y)
}

fn rotate_pos(pos: Pos2, side: Int) -> Pos2 {
  let #(x, y) = pos
  #({ side - 1 } - y, x)
}

fn shape_variants(
  from s0: s,
  and side: Int,
  with map: fn(s, fn(Pos2) -> Pos2) -> s,
) -> List(s) {
  let s1 = map(s0, rotate_pos(_, side))
  let s2 = map(s1, rotate_pos(_, side))
  let s3 = map(s2, rotate_pos(_, side))
  let f0 = map(s0, flip_pos(_, side))
  let f1 = map(f0, rotate_pos(_, side))
  let f2 = map(f1, rotate_pos(_, side))
  let f3 = map(f2, rotate_pos(_, side))
  [s0, s1, s2, s3, f0, f1, f2, f3]
}

fn find_layout(
  side: Int,
  corners: Set(Int),
  layout: Layout,
  free: List(Tile),
) -> Result(Layout, Nil) {
  let selected = dict.size(layout)
  use <- bool.guard(when: selected == side * side, return: Ok(layout))
  let #(row, col) = #(selected / side, selected % side)

  let required_top =
    layout
    |> dict.get(#(col, row - 1))
    |> res.map(with: socket_at(_, South))

  let required_left =
    layout
    |> dict.get(#(col - 1, row))
    |> res.map(with: socket_at(_, East))

  free
  |> list.filter(keeping: fn(candidate) {
    case { row == 0 || row == side - 1 } && { col == 0 || col == side - 1 } {
      True -> set.contains(corners, candidate.id)
      False -> True
    }
  })
  |> list.filter(keeping: fn(candidate) {
    res.is_error(required_top)
    || Ok(socket_at(candidate, North)) == required_top
  })
  |> list.filter(keeping: fn(candidate) {
    res.is_error(required_left)
    || Ok(socket_at(candidate, West)) == required_left
  })
  |> list.filter_map(with: fn(candidate) {
    find_layout(
      side,
      corners,
      dict.insert(into: layout, for: #(col, row), insert: candidate),
      list.filter(free, keeping: fn(tile) { tile.id != candidate.id }),
    )
  })
  |> list.first
}

fn flatten_layout(layout: Layout) -> Set(Pos2) {
  layout
  |> dict.to_list
  |> list.flat_map(with: fn(entry) {
    let #(#(tx, ty), tile) = entry
    tile.filled
    |> set.to_list
    |> list.flat_map(with: fn(pos) {
      let #(x, y) = pos
      case x == 0 || x == tile_size - 1 || y == 0 || y == tile_size - 1 {
        True -> []
        False -> [
          #(tx * { tile_size - 2 } + x - 1, ty * { tile_size - 2 } + y - 1),
        ]
      }
    })
  })
  |> set.from_list
}

fn count_monsters(positions: Set(Pos2)) -> Int {
  let monster_variants =
    monster_pattern
    |> grid.parse_grid(with: pair.new)
    |> shape_variants(and: monster_side, with: setx.map)

  let x_bound =
    positions
    |> setx.map(pos2.x)
    |> set.fold(0, int.max)

  let y_bound =
    positions
    |> setx.map(pos2.y)
    |> set.fold(0, int.max)

  let counts =
    monster_variants
    |> list.map(with: fn(variant) {
      iter.range(-monster_side, y_bound + monster_side)
      |> iter.flat_map(with: fn(y) {
        iter.range(-monster_side, x_bound + monster_side)
        |> iter.map(with: fn(x) {
          variant
          |> setx.map(with: pos2.add(_, #(x, y)))
          |> set.intersection(and: positions)
          |> set.size
          == monster_area
        })
      })
      |> iterx.count(satisfying: fun.identity)
    })

  list.fold(over: counts, from: 0, with: int.max)
}

fn part1(input: String) -> Int {
  input
  |> parse_tiles
  |> corners
  |> set.to_list
  |> int.product
}

fn part2(input: String) -> Int {
  let tiles = parse_tiles(input)
  let side = intx.sqrt(list.length(tiles))
  let assert Ok(layout) =
    find_layout(
      side,
      corners(tiles),
      dict.new(),
      list.flat_map(tiles, with: fn(t0) {
        use tile, transform <- shape_variants(from: t0, and: tile_size)
        Tile(tile.id, setx.map(tile.filled, with: transform))
      }),
    )
  let positions = flatten_layout(layout)

  set.size(positions) - count_monsters(positions) * monster_area
}

pub fn main() -> Nil {
  let testing = input_util.read_text("test20")
  let assert 20_899_048_083_289 = part1(testing)
  let assert 273 = part2(testing)

  let input = input_util.read_text("day20")
  io.debug(part1(input))
  io.debug(part2(input))

  Nil
}
