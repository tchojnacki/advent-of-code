import gleam/list
import gleam/set.{type Set}
import ext/setx

pub type Pos3 =
  #(Int, Int, Int)

pub const zero = #(0, 0, 0)

fn directions27() -> Set(Pos3) {
  set.from_list({
    use x <- list.flat_map([-1, 0, 1])
    use y <- list.flat_map([-1, 0, 1])
    use z <- list.map([-1, 0, 1])
    #(x, y, z)
  })
}

fn directions26() -> Set(Pos3) {
  set.delete(from: directions27(), this: zero)
}

pub fn add(p1: Pos3, p2: Pos3) -> Pos3 {
  #(p1.0 + p2.0, p1.1 + p2.1, p1.2 + p2.2)
}

pub fn neighbours26(p: Pos3) -> Set(Pos3) {
  setx.map(directions26(), with: add(p, _))
}
