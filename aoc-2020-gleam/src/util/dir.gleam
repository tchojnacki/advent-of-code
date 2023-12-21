import gleam/int
import gleam/iterator as iter
import ext/resultx as resx
import ext/iteratorx as iterx
import util/pos2.{type Pos2}

pub type Dir {
  North
  East
  South
  West
}

pub fn offset(direction: Dir) -> Pos2 {
  case direction {
    North -> #(0, 1)
    East -> #(1, 0)
    South -> #(0, -1)
    West -> #(-1, 0)
  }
}

pub fn degree_to_turn(degree: Int) -> Int {
  resx.assert_unwrap(int.modulo(degree / 90, by: 4))
}

fn rotate_clockwise_once(direction: Dir) -> Dir {
  case direction {
    North -> East
    East -> South
    South -> West
    West -> North
  }
}

pub fn rotate_clockwise(this direction: Dir, by times: Int) -> Dir {
  direction
  |> iterx.unfold_infinitely(with: rotate_clockwise_once)
  |> iter.at(times)
  |> resx.assert_unwrap
}
