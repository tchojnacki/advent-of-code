import gleam/set.{Set}
import gleam/iterator as iter
import ext/iteratorx as iterx

pub fn count(set: Set(a), satisfying predicate: fn(a) -> Bool) -> Int {
  set
  |> set.to_list
  |> iter.from_list
  |> iterx.count(satisfying: predicate)
}
