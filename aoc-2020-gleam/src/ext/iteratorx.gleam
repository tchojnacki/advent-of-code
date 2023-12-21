import gleam/iterator.{type Iterator, Next} as iter

pub fn length(iterator: Iterator(a)) -> Int {
  iterator
  |> iter.fold(from: 0, with: fn(c, _) { c + 1 })
}

pub fn count(iterator: Iterator(a), satisfying predicate: fn(a) -> Bool) -> Int {
  iterator
  |> iter.filter(keeping: predicate)
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

pub fn unfold_infinitely(from state: a, with fun: fn(a) -> a) -> Iterator(a) {
  iter.unfold(
    from: state,
    with: fn(s) { Next(element: s, accumulator: fun(s)) },
  )
}
