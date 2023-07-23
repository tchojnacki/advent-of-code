pub fn guard_lazy(
  when requirement: Bool,
  return consequence: fn() -> t,
  otherwise alternative: fn() -> t,
) -> t {
  case requirement {
    True -> consequence()
    False -> alternative()
  }
}
