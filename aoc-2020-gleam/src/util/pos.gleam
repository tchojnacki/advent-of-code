import gleam/int
import gleam/list
import gleam/set.{Set}

pub type Pos =
  #(Int, Int)

pub const zero = #(0, 0)

pub const directions8 = [
  #(1, 0),
  #(1, 1),
  #(0, 1),
  #(-1, 1),
  #(-1, 0),
  #(-1, -1),
  #(0, -1),
  #(1, -1),
]

pub fn add(p1: Pos, p2: Pos) -> Pos {
  #(p1.0 + p2.0, p1.1 + p2.1)
}

pub fn sub(p1: Pos, p2: Pos) -> Pos {
  #(p1.0 - p2.0, p1.1 - p2.1)
}

pub fn mul(p: Pos, by scalar: Int) -> Pos {
  #(p.0 * scalar, p.1 * scalar)
}

pub fn neighbours8(p: Pos) -> Set(Pos) {
  directions8
  |> list.map(with: add(p, _))
  |> set.from_list
}

pub fn manhattan_dist(from p1: Pos, to p2: Pos) -> Int {
  int.absolute_value(p1.0 - p2.0) + int.absolute_value(p1.1 - p2.1)
}

pub fn rotate_around_origin(this p: Pos, by times: Int) -> Pos {
  let assert Ok(sin) = list.at([0, -1, 0, 1], times)
  let assert Ok(cos) = list.at([1, 0, -1, 0], times)
  #(p.0 * cos - p.1 * sin, p.0 * sin + p.1 * cos)
}
