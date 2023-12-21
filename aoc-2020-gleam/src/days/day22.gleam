import gleam/io
import gleam/int
import gleam/list
import gleam/bool
import gleam/string as str
import gleam/function as fun
import gleam/set.{type Set}
import gleam/order.{Eq, Gt, Lt}
import gleam/option.{type Option, None, Some}
import ext/boolx
import ext/resultx as resx
import util/input_util

type Player {
  P1
  P2
}

type Game {
  Game(p1: List(Int), p2: List(Int))
}

fn parse_game(input: String) -> Game {
  let assert [p1, p2] =
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

  Game(p1, p2)
}

fn score(deck: List(Int)) -> Int {
  deck
  |> list.reverse
  |> list.index_fold(from: 0, with: fn(sum, card, index) {
    sum + card * { index + 1 }
  })
}

fn outcome(game: Game) -> Option(Int) {
  use <- bool.guard(when: game.p2 == [], return: Some(score(game.p1)))
  use <- bool.guard(when: game.p1 == [], return: Some(-score(game.p2)))
  None
}

fn get_winner(score: Int) -> Player {
  case int.compare(score, 0) {
    Lt -> P2
    Eq -> panic
    Gt -> P1
  }
}

fn play_combat_game(game: Game) -> Int {
  use <- option.lazy_unwrap(outcome(game))

  let assert Game([top1, ..rest1], [top2, ..rest2]) = game

  play_combat_game(case int.compare(top1, top2) {
    Lt -> Game(rest1, list.append(rest2, [top2, top1]))
    Eq -> panic
    Gt -> Game(list.append(rest1, [top1, top2]), rest2)
  })
}

fn part1(input: String) -> Int {
  input
  |> parse_game
  |> play_combat_game
  |> int.absolute_value
}

fn play_recursive_combat(game: Game, seen: Set(Game)) -> Int {
  use <- option.lazy_unwrap(outcome(game))
  use <- bool.guard(when: set.contains(seen, game), return: score(game.p1))

  let assert Game([top1, ..rest1], [top2, ..rest2]) = game
  let seen = set.insert(seen, game)

  let winner = {
    use <- boolx.guard_lazy(
      when: list.length(rest1) >= top1
      && list.length(rest2) >= top2,
      return: fn() {
        Game(list.take(rest1, top1), list.take(rest2, top2))
        |> play_recursive_combat(set.new())
        |> get_winner
      },
    )

    case int.compare(top1, top2) {
      Lt -> P2
      Eq -> panic
      Gt -> P1
    }
  }

  play_recursive_combat(
    case winner {
      P1 -> Game(list.append(rest1, [top1, top2]), rest2)
      P2 -> Game(rest1, list.append(rest2, [top2, top1]))
    },
    seen,
  )
}

fn part2(input: String) -> Int {
  input
  |> parse_game
  |> play_recursive_combat(set.new())
  |> int.absolute_value
}

pub fn main() -> Nil {
  let testing = input_util.read_text("test22")
  let assert 306 = part1(testing)
  let assert 291 = part2(testing)

  let input = input_util.read_text("day22")
  io.debug(part1(input))
  io.debug(part2(input))

  Nil
}
