import gleam/list
import gleam/set.{Set}

pub type Pos =
  #(Int, Int)

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

pub fn neighbours8(pos: Pos) -> Set(Pos) {
  directions8
  |> list.map(with: add(pos, _))
  |> set.from_list
}
