import gleam/list

pub fn count(list: List(a), satisfying predicate: fn(a) -> Bool) -> Int {
  list
  |> list.filter(for: predicate)
  |> list.length
}
