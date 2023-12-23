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
