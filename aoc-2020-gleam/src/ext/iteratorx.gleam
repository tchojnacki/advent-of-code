import gleam/iterator.{Iterator} as iter
import gleam/list

pub fn length(iterator: Iterator(a)) -> Int {
  iterator
  |> iter.to_list
  |> list.length
}

pub fn count(iterator: Iterator(a), satisfying predicate: fn(a) -> Bool) -> Int {
  iterator
  |> iter.filter(for: predicate)
  |> length
}
