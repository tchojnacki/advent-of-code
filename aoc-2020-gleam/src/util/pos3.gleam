import gleam/list
import gleam/bool
import gleam/set.{Set}

pub type Pos3 =
  #(Int, Int, Int)

pub const zero = #(0, 0, 0)

fn directions26() -> Set(Pos3) {
  set.from_list({
    use x <- list.flat_map(over: [-1, 0, 1])
    use y <- list.flat_map(over: [-1, 0, 1])
    use z <- list.flat_map(over: [-1, 0, 1])
    let pos = #(x, y, z)
    use <- bool.guard(when: pos == zero, return: [])
    [pos]
  })
}

pub fn add(p1: Pos3, p2: Pos3) -> Pos3 {
  #(p1.0 + p2.0, p1.1 + p2.1, p1.2 + p2.2)
}

pub fn neighbours26(p: Pos3) -> Set(Pos3) {
  directions26()
  |> set.to_list
  |> list.map(with: add(p, _))
  |> set.from_list
}
