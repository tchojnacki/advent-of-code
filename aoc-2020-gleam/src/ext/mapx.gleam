import gleam/map.{Map}
import gleam/iterator.{Iterator} as iter

pub fn from_iter(iterator: Iterator(#(k, v))) -> Map(k, v) {
  iter.fold(
    over: iterator,
    from: map.new(),
    with: fn(acc, cur) { map.insert(acc, cur.0, cur.1) },
  )
}

pub fn to_iter(map: Map(k, v)) -> Iterator(#(k, v)) {
  map
  |> map.to_list
  |> iter.from_list
}
