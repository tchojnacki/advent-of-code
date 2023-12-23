import gleam/list
import gleam/set.{type Set}
import gleam/iterator as iter
import ext/iteratorx as iterx

pub fn count(s: Set(a), satisfying predicate: fn(a) -> Bool) -> Int {
  s
  |> set.to_list
  |> iter.from_list
  |> iterx.count(satisfying: predicate)
}

pub fn map(s: Set(a), with fun: fn(a) -> b) -> Set(b) {
  s
  |> set.to_list
  |> list.map(with: fun)
  |> set.from_list
}

pub fn toggle(in s: Set(a), this value: a) -> Set(a) {
  s
  |> case set.contains(in: s, this: value) {
    True -> set.delete(from: _, this: value)
    False -> set.insert(into: _, this: value)
  }
}
