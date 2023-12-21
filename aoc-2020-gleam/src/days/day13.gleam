import gleam/io
import gleam/int
import gleam/list
import gleam/pair
import gleam/string as str
import gleam/iterator as iter
import ext/intx
import ext/resultx as resx
import ext/iteratorx as iterx
import util/input_util

type Bus {
  Any
  Line(Int)
}

type Problem {
  Problem(timestamp: Int, buses: List(Bus))
}

fn parse_problem(input: String) -> Problem {
  let assert Ok(#(timestamp, buses)) =
    input
    |> str.trim
    |> str.split_once(on: "\n")
  let assert Ok(timestamp) = int.parse(timestamp)
  let buses =
    buses
    |> str.split(on: ",")
    |> list.map(with: fn(b) {
      case b == "x" {
        True -> Any
        False ->
          b
          |> int.parse
          |> resx.assert_unwrap
          |> Line
      }
    })
  Problem(timestamp, buses)
}

fn part1(input: String) -> Int {
  let problem = parse_problem(input)

  problem.buses
  |> list.filter_map(with: fn(b) {
    case b {
      Line(line) -> Ok(line)
      Any -> Error(Nil)
    }
  })
  |> list.map(with: fn(b) {
    #(b, b * intx.ceil_divide(problem.timestamp, by: b) - problem.timestamp)
  })
  |> list.reduce(with: fn(acc, cur) {
    case cur.1 < acc.1 {
      True -> cur
      False -> acc
    }
  })
  |> resx.assert_unwrap
  |> fn(res: #(Int, Int)) { res.0 * res.1 }
}

fn part2(input: String) -> Int {
  let problem = parse_problem(input)

  let buses =
    problem.buses
    |> iter.from_list
    |> iter.index
    |> iter.flat_map(fn(entry) {
      let #(b, i) = entry
      case b {
        Line(line) -> iter.single(#(line, i))
        Any -> iter.empty()
      }
    })
    |> iter.to_list

  let assert [#(timestamp, _), ..] = buses

  buses
  |> list.fold(from: #(timestamp, timestamp), with: fn(prev, entry) {
    let #(timestamp, period) = prev
    let #(id, i) = entry

    let assert Ok(timestamp) =
      timestamp
      |> iterx.unfold_infinitely(with: int.add(_, period))
      |> iter.find(one_that: fn(t) { { t + i } % id == 0 })
    let period = intx.lcm(period, id)

    #(timestamp, period)
  })
  |> pair.first
}

pub fn main() -> Nil {
  let testing = input_util.read_text("test13")
  let assert 295 = part1(testing)
  let assert 1_068_781 = part2(testing)

  let input = input_util.read_text("day13")
  io.debug(part1(input))
  io.debug(part2(input))

  Nil
}
