import gleam/list
import gleam/bool
import gleam/set.{Set}

pub type Pos4 =
  #(Int, Int, Int, Int)

pub const zero = #(0, 0, 0, 0)

fn directions80() -> Set(Pos4) {
  set.from_list({
    use x <- list.flat_map(over: [-1, 0, 1])
    use y <- list.flat_map(over: [-1, 0, 1])
    use z <- list.flat_map(over: [-1, 0, 1])
    use w <- list.flat_map(over: [-1, 0, 1])
    let pos = #(x, y, z, w)
    use <- bool.guard(when: pos == zero, return: [])
    [pos]
  })
}

pub fn add(p1: Pos4, p2: Pos4) -> Pos4 {
  #(p1.0 + p2.0, p1.1 + p2.1, p1.2 + p2.2, p1.3 + p2.3)
}

pub fn neighbours80(p: Pos4) -> Set(Pos4) {
  directions80()
  |> set.to_list
  |> list.map(with: add(p, _))
  |> set.from_list
}
