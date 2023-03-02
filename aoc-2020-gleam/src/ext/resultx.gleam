pub fn assert_unwrap(result: Result(t, _)) -> t {
  let assert Ok(value) = result
  value
}
