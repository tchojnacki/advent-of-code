import gleam/list
import gleam/set.{type Set}
import ext/setx

pub type Pos4 =
  #(Int, Int, Int, Int)

pub const zero = #(0, 0, 0, 0)

fn directions81() -> Set(Pos4) {
  set.from_list({
    use x <- list.flat_map([-1, 0, 1])
    use y <- list.flat_map([-1, 0, 1])
    use z <- list.flat_map([-1, 0, 1])
    use w <- list.map([-1, 0, 1])
    #(x, y, z, w)
  })
}

fn directions80() -> Set(Pos4) {
  set.delete(from: directions81(), this: zero)
}

pub fn add(p1: Pos4, p2: Pos4) -> Pos4 {
  #(p1.0 + p2.0, p1.1 + p2.1, p1.2 + p2.2, p1.3 + p2.3)
}

pub fn neighbours80(p: Pos4) -> Set(Pos4) {
  setx.map(directions80(), with: add(p, _))
}
