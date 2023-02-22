import gleam/iterator.{Iterator} as iter
import gleam/list

pub fn length(iterator: Iterator(a)) -> Int {
  iterator
  |> iter.fold(from: 0, with: fn(c, _) { c + 1 })
}

pub fn count(iterator: Iterator(a), satisfying predicate: fn(a) -> Bool) -> Int {
  iterator
  |> iter.filter(for: predicate)
  |> length
}
