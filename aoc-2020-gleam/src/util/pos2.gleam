import gleam/int
import gleam/list
import gleam/set.{type Set}
import ext/setx

pub type Pos2 =
  #(Int, Int)

pub const zero = #(0, 0)

pub fn x(pos: Pos2) -> Int {
  pos.0
}

pub fn y(pos: Pos2) -> Int {
  pos.1
}

fn directions9() -> Set(Pos2) {
  set.from_list({
    use x <- list.flat_map([-1, 0, 1])
    use y <- list.map([-1, 0, 1])
    #(x, y)
  })
}

pub fn directions8() -> Set(Pos2) {
  set.delete(from: directions9(), this: zero)
}

pub fn add(p1: Pos2, p2: Pos2) -> Pos2 {
  #(p1.0 + p2.0, p1.1 + p2.1)
}

pub fn sub(p1: Pos2, p2: Pos2) -> Pos2 {
  #(p1.0 - p2.0, p1.1 - p2.1)
}

pub fn mul(p: Pos2, by scalar: Int) -> Pos2 {
  #(p.0 * scalar, p.1 * scalar)
}

pub fn neighbours8(p: Pos2) -> Set(Pos2) {
  setx.map(directions8(), with: add(p, _))
}

pub fn manhattan_dist(from p1: Pos2, to p2: Pos2) -> Int {
  int.absolute_value(p1.0 - p2.0) + int.absolute_value(p1.1 - p2.1)
}

pub fn rotate_around_origin(this p: Pos2, by times: Int) -> Pos2 {
  let assert Ok(sin) = list.at([0, -1, 0, 1], times)
  let assert Ok(cos) = list.at([1, 0, -1, 0], times)
  #(p.0 * cos - p.1 * sin, p.0 * sin + p.1 * cos)
}
