import gleam/io
import gleam/int
import gleam/bool
import gleam/string as str
import gleam/function as fun
import gleam/iterator as iter
import gleam/map.{Map}
import gleam/list.{Continue, Stop}
import ext/resultx as resx
import ext/iteratorx as iterx

fn parse_input(input: String) -> List(Int) {
  input
  |> str.to_graphemes
  |> list.map(with: fun.compose(int.parse, resx.assert_unwrap))
}

fn play(input: String, bound: Int, moves: Int) -> Map(Int, Int) {
  let assert [first, ..tail] = parse_input(input)
  let assert Ok(second) = list.first(tail)

  tail
  |> list.append(case bound >= 10 {
    True -> list.range(from: 10, to: bound)
    False -> []
  })
  |> build_map(map.from_list([#(first, second)]), first)
  |> move(first, moves, bound)
}

fn move(
  cups: Map(Int, Int),
  current: Int,
  round: Int,
  bound: Int,
) -> Map(Int, Int) {
  use <- bool.guard(when: round == 0, return: cups)

  // Remove nodes from source
  let assert Ok(first) = map.get(cups, current)
  let assert Ok(second) = map.get(cups, first)
  let assert Ok(third) = map.get(cups, second)
  let assert Ok(rest) = map.get(cups, third)
  let cups = map.insert(into: cups, for: current, insert: rest)

  // Insert nodes at destination
  let assert Ok(before) =
    iter.iterate(from: current - 1, with: int.subtract(_, 1))
    |> iter.map(with: fn(n) { resx.assert_unwrap(int.modulo(n - 1, bound)) + 1 })
    |> iter.find(one_that: fn(key) {
      !list.contains([first, second, third], key)
    })
  let assert Ok(after) = map.get(cups, before)
  let cups =
    cups
    |> map.insert(for: before, insert: first)
    |> map.insert(for: third, insert: after)

  cups
  |> move(
    cups
    |> map.get(current)
    |> resx.assert_unwrap,
    round - 1,
    bound,
  )
}

fn build_map(list: List(Int), cups: Map(Int, Int), first: Int) -> Map(Int, Int) {
  case list {
    [] -> map.new()
    [head] -> map.insert(into: cups, for: head, insert: first)
    [head, ..tail] -> {
      let assert Ok(second) = list.first(tail)
      build_map(tail, map.insert(into: cups, for: head, insert: second), first)
    }
  }
}

fn to_result_string(cups: Map(Int, Int)) -> String {
  iterx.unfold_infinitely(
    from: 1,
    with: fn(key) { resx.assert_unwrap(map.get(cups, key)) },
  )
  |> iter.drop(1)
  |> iter.fold_until(
    from: "",
    with: fn(acc, key) {
      use <- bool.guard(when: key == 1, return: Stop(acc))
      Continue(acc <> int.to_string(key))
    },
  )
}

fn part1(input: String) -> String {
  input
  |> play(9, 100)
  |> to_result_string
}

fn part2(input: String) -> Int {
  let finished = play(input, 1_000_000, 10_000_000)
  let assert Ok(first) = map.get(finished, 1)
  let assert Ok(second) = map.get(finished, first)
  first * second
}

pub fn main() -> Nil {
  let test = "389125467"
  let assert "67384529" = part1(test)
  let assert 149_245_887_792 = part2(test)

  let input = "925176834"
  io.println(part1(input))
  io.debug(part2(input))

  Nil
}
