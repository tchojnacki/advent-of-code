import gleam/list
import gleam/iterator.{Iterator} as iter
import gleam/set.{Set}

fn dfs_helper(
  neighbours: fn(a) -> Iterator(a),
  stack stack: List(a),
  visited visited: Set(a),
  acc acc: List(a),
) -> List(a) {
  case stack {
    [node, ..stack] ->
      dfs_helper(
        neighbours,
        stack: node
        |> neighbours
        |> iter.filter(for: fn(n) { !set.contains(visited, n) })
        |> iter.to_list
        |> list.append(stack),
        visited: visited
        |> set.insert(node),
        acc: [node, ..acc],
      )
    [] -> list.reverse(acc)
  }
}

pub fn dfs(from start: a, with neighbours: fn(a) -> Iterator(a)) -> Iterator(a) {
  iter.from_list(dfs_helper(
    neighbours,
    stack: [start],
    visited: set.new(),
    acc: [],
  ))
}
