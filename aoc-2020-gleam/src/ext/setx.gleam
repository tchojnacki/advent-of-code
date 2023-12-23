import gleam/list
import gleam/set.{type Set}
import gleam/iterator as iter
import ext/iteratorx as iterx

pub fn count(set: Set(a), satisfying predicate: fn(a) -> Bool) -> Int {
  set
  |> set.to_list
  |> iter.from_list
  |> iterx.count(satisfying: predicate)
}

pub fn map(set: Set(a), with fun: fn(a) -> b) -> Set(b) {
  set
  |> set.to_list
  |> list.map(with: fun)
  |> set.from_list
}
