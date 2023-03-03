import gleam/iterator.{Iterator} as iter

pub fn length(iterator: Iterator(a)) -> Int {
  iterator
  |> iter.fold(from: 0, with: fn(c, _) { c + 1 })
}

pub fn count(iterator: Iterator(a), satisfying predicate: fn(a) -> Bool) -> Int {
  iterator
  |> iter.filter(for: predicate)
  |> length
}

pub fn filter_map(
  iterator: Iterator(a),
  with mapper: fn(a) -> Result(b, c),
) -> Iterator(b) {
  iterator
  |> iter.flat_map(with: fn(elem) {
    case mapper(elem) {
      Ok(new) -> iter.single(new)
      Error(_) -> iter.empty()
    }
  })
}
