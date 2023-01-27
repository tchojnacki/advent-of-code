pub fn force_unwrap(result: Result(t, _)) -> t {
  assert Ok(value) = result
  value
}
