import gleam/iterator as iter
import ext/iteratorx as iterx

pub fn count(list: List(a), satisfying predicate: fn(a) -> Bool) -> Int {
  list
  |> iter.from_list
  |> iterx.count(satisfying: predicate)
}

fn set_helper(list: List(a), value: a, index: Int, counter: Int) -> List(a) {
  case list {
    [] -> []
    [_, ..t] if counter == index -> [value, ..t]
    [h, ..t] -> [h, ..set_helper(t, value, index, counter + 1)]
  }
}

pub fn set(list: List(a), value: a, at index: Int) -> List(a) {
  set_helper(list, value, index, 0)
}
