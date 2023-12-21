import gleam/io
import gleam/int
import gleam/list
import gleam/string as str
import util/input_util
import util/pos2.{type Pos2}
import util/dir.{type Dir, East, North, South, West}

type Instr {
  MoveIn(dir: Dir, by: Int)
  Turn(by: Int)
  MoveForward(by: Int)
}

fn parse_instr(line: String) -> Instr {
  let assert Ok(#(action, value)) = str.pop_grapheme(line)
  let assert Ok(value) = int.parse(value)
  case action {
    "N" -> MoveIn(dir: North, by: value)
    "E" -> MoveIn(dir: East, by: value)
    "S" -> MoveIn(dir: South, by: value)
    "W" -> MoveIn(dir: West, by: value)
    "L" -> Turn(by: dir.degree_to_turn(-value))
    "R" -> Turn(by: dir.degree_to_turn(value))
    "F" -> MoveForward(by: value)
    _ -> panic
  }
}

fn process_moves(
  lines: List(String),
  initial: a,
  execute: fn(a, Instr) -> a,
  locator: fn(a) -> Pos2,
) -> Int {
  lines
  |> list.map(with: parse_instr)
  |> list.fold(from: initial, with: execute)
  |> fn(s: a) { pos2.manhattan_dist(from: pos2.zero, to: locator(s)) }
}

type State1 {
  State1(pos: Pos2, dir: Dir)
}

const initial_state1 = State1(pos: pos2.zero, dir: East)

fn execute_instr1(prev: State1, instr: Instr) -> State1 {
  case instr {
    MoveIn(target, times) ->
      State1(
        ..prev,
        pos: target
        |> dir.offset
        |> pos2.mul(by: times)
        |> pos2.add(prev.pos),
      )
    Turn(times) ->
      State1(
        ..prev,
        dir: prev.dir
        |> dir.rotate_clockwise(by: times),
      )
    MoveForward(times) ->
      State1(
        ..prev,
        pos: prev.dir
        |> dir.offset
        |> pos2.mul(by: times)
        |> pos2.add(prev.pos),
      )
  }
}

fn part1(lines: List(String)) -> Int {
  process_moves(lines, initial_state1, execute_instr1, fn(s) { s.pos })
}

type State2 {
  State2(ship_pos: Pos2, anchor_pos: Pos2)
}

const initial_state2 = State2(ship_pos: pos2.zero, anchor_pos: #(10, 1))

fn execute_instr2(prev: State2, instr: Instr) -> State2 {
  case instr {
    MoveIn(target, times) ->
      State2(
        ..prev,
        anchor_pos: target
        |> dir.offset
        |> pos2.mul(by: times)
        |> pos2.add(prev.anchor_pos),
      )
    Turn(times) ->
      State2(
        ..prev,
        anchor_pos: pos2.rotate_around_origin(this: prev.anchor_pos, by: times),
      )
    MoveForward(times) ->
      State2(
        ..prev,
        ship_pos: prev.anchor_pos
        |> pos2.mul(by: times)
        |> pos2.add(prev.ship_pos),
      )
  }
}

fn part2(lines: List(String)) -> Int {
  process_moves(lines, initial_state2, execute_instr2, fn(s) { s.ship_pos })
}

pub fn main() -> Nil {
  let testing = input_util.read_lines("test12")
  let assert 25 = part1(testing)
  let assert 286 = part2(testing)

  let input = input_util.read_lines("day12")
  io.debug(part1(input))
  io.debug(part2(input))

  Nil
}
