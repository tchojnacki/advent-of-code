import gleam/iterator as iter
import ext/iteratorx as iterx

pub fn count(list: List(a), satisfying predicate: fn(a) -> Bool) -> Int {
  list
  |> iter.from_list
  |> iterx.count(satisfying: predicate)
}
