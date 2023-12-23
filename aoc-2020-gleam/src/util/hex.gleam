import gleam/bool
import gleam/list
import gleam/set.{type Set}
import ext/setx

pub opaque type Hex {
  Hex(q: Int, r: Int, s: Int)
}

pub const zero = Hex(q: 0, r: 0, s: 0)

pub const e = Hex(q: 1, r: 0, s: -1)

pub const se = Hex(q: 0, r: 1, s: -1)

pub const sw = Hex(q: -1, r: 1, s: 0)

pub const w = Hex(q: -1, r: 0, s: 1)

pub const nw = Hex(q: 0, r: -1, s: 1)

pub const ne = Hex(q: 1, r: -1, s: 0)

pub fn add(a: Hex, b: Hex) -> Hex {
  Hex(q: a.q + b.q, r: a.r + b.r, s: a.s + b.s)
}

fn directions7() -> Set(Hex) {
  set.from_list({
    use q <- list.flat_map([-1, 0, 1])
    use r <- list.flat_map([-1, 0, 1])
    use s <- list.flat_map([-1, 0, 1])
    use <- bool.guard(when: q + r + s != 0, return: [])
    [Hex(q, r, s)]
  })
}

fn directions6() -> Set(Hex) {
  set.delete(from: directions7(), this: zero)
}

pub fn neighbours6(h: Hex) -> Set(Hex) {
  setx.map(directions6(), with: add(h, _))
}

pub fn neighbours7(h: Hex) -> Set(Hex) {
  setx.map(directions7(), with: add(h, _))
}
