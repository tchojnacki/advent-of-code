import gleam/int
import gleam/result as res
import gleam/dict.{type Dict}
import gleam/iterator.{type Iterator, Next} as iter

pub fn count(iterator: Iterator(a), satisfying predicate: fn(a) -> Bool) -> Int {
  iterator
  |> iter.filter(keeping: predicate)
  |> iter.length
}

pub fn counts(iterator: Iterator(a)) -> Dict(a, Int) {
  iterator
  |> iter.fold(from: dict.new(), with: fn(acc, value) {
    acc
    |> dict.insert(
      value,
      dict.get(acc, value)
      |> res.unwrap(or: 0)
      |> int.add(1),
    )
  })
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
  iter.unfold(from: state, with: fn(s) { Next(element: s, accumulator: fun(s)) })
}
