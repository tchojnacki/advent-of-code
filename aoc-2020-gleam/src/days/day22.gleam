import gleam/io
import gleam/int
import gleam/list
import gleam/bool
import gleam/string as str
import gleam/function as fun
import gleam/order.{Eq, Gt, Lt}
import ext/resultx as resx
import util/input_util

type GameState {
  GameState(player1: List(Int), player2: List(Int))
}

fn parse_game_state(input: String) -> GameState {
  let assert [player1, player2] =
    input
    |> str.trim()
    |> str.split("\n\n")
    |> list.map(with: fn(part) {
      part
      |> str.split("\n")
      |> list.rest
      |> resx.assert_unwrap
      |> list.map(with: fun.compose(int.parse, resx.assert_unwrap))
    })

  GameState(player1, player2)
}

fn score(deck: List(Int)) -> Int {
  deck
  |> list.reverse
  |> list.index_fold(
    from: 0,
    with: fn(sum, card, index) { sum + card * { index + 1 } },
  )
}

fn play_combat_round(previous: GameState) -> Result(GameState, Int) {
  let assert [top1, ..rest1] = previous.player1
  let assert [top2, ..rest2] = previous.player2

  let #(new1, new2) = case int.compare(top1, top2) {
    Lt -> #(rest1, list.append(rest2, [top2, top1]))
    Eq -> panic
    Gt -> #(list.append(rest1, [top1, top2]), rest2)
  }

  use <- bool.guard(when: new1 == [], return: Error(score(new2)))
  use <- bool.guard(when: new2 == [], return: Error(score(new1)))

  Ok(GameState(new1, new2))
}

fn play_combat_game(initial: GameState) -> Int {
  case play_combat_round(initial) {
    Ok(next) -> play_combat_game(next)
    Error(score) -> score
  }
}

fn part1(input: String) -> Int {
  input
  |> parse_game_state
  |> play_combat_game
  |> int.absolute_value
}

pub fn main() -> Nil {
  let test = input_util.read_text("test22")
  let assert 306 = part1(test)
  // let assert 291 = part2(test)

  let input = input_util.read_text("day22")
  io.debug(part1(input))
  // io.debug(part2(input))

  Nil
}
