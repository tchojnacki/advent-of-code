import gleam/io
import gleam/list
import gleam/function as fun
import gleam/pair
import gleam/iterator as iter
import gleam/map.{Map}
import ext/resultx as resx
import ext/iteratorx as iterx
import util/graph
import util/input_util
import util/parser as p

const special_bag = "shiny gold"

type BagEdge =
  #(String, Int)

type BagGraph =
  Map(String, List(BagEdge))

fn parse_graph(lines: List(String)) -> BagGraph {
  let bag_type_parser =
    [p.str1_until_ws(), p.ws_gc(), p.str1_until_ws()]
    |> p.str_of_seq
    |> p.labeled(with: "bag_type")

  let line_parser =
    bag_type_parser
    |> p.then_skip(p.literal(" bags contain "))
    |> p.then(p.or(
      p.int()
      |> p.then_skip(p.ws_gc())
      |> p.then(bag_type_parser)
      |> p.map(with: pair.swap)
      |> p.then_skip(p.ws_gc())
      |> p.then_skip(p.then(p.literal("bag"), p.opt(p.literal("s"))))
      |> p.sep1(by: p.literal(", ")),
      else: p.literal("no other bags")
      |> p.map(fun.constant([])),
    ))
    |> p.then_skip(p.literal("."))

  lines
  |> list.map(with: fun.compose(
    p.parse_entire(_, with: line_parser),
    resx.force_unwrap,
  ))
  |> map.from_list
}

fn part1(lines: List(String)) -> Int {
  let graph = parse_graph(lines)
  let neighbours = fn(bag) {
    graph
    |> map.get(bag)
    |> resx.force_unwrap
    |> list.map(with: pair.first)
    |> iter.from_list
  }

  graph
  |> map.keys
  |> iter.from_list
  |> iter.filter(for: fn(bag) { bag != special_bag })
  |> iterx.count(satisfying: fn(start) {
    start
    |> graph.dfs(with: neighbours)
    |> iter.any(fn(bag) { bag == special_bag })
  })
}

pub fn run() -> Nil {
  let test = input_util.read_lines("test07")
  assert 4 = part1(test)

  let input = input_util.read_lines("day07")
  io.debug(part1(input))

  Nil
}
