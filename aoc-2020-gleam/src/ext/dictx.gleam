import gleam/dict.{type Dict}
import gleam/iterator.{type Iterator} as iter

pub fn from_iter(iterator: Iterator(#(k, v))) -> Dict(k, v) {
  iter.fold(over: iterator, from: dict.new(), with: fn(acc, cur) {
    dict.insert(acc, cur.0, cur.1)
  })
}

pub fn to_iter(map: Dict(k, v)) -> Iterator(#(k, v)) {
  map
  |> dict.to_list
  |> iter.from_list
}
