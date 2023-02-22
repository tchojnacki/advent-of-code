import gleam/io
import gleam/list
import gleam/pair
import gleam/result as res
import gleam/function as fun
import gleam/map.{Map}
import gleam/iterator.{Iterator} as iter
import ext/resultx as resx
import ext/iteratorx as iterx
import util/graph
import util/input_util
import util/parser as p

const special_bag = "shiny gold"

type BagId =
  String

type BagEdge =
  #(BagId, Int)

type BagGraph =
  Map(BagId, List(BagEdge))

type BagNeighbourFun =
  fn(BagId) -> Iterator(BagId)

fn parse_graph(lines: List(String)) -> BagGraph {
  let bag_type_parser =
    [p.str1_until_ws(), p.ws_gc(), p.str1_until_ws()]
    |> p.str_of_seq
    |> p.labeled(with: "bag_type")

  let line_parser =
    bag_type_parser
    |> p.skip(p.literal(" bags contain "))
    |> p.then(p.or(
      p.int()
      |> p.skip_ws
      |> p.then(bag_type_parser)
      |> p.map(with: pair.swap)
      |> p.skip_ws
      |> p.skip(p.then(p.literal("bag"), p.opt(p.literal("s"))))
      |> p.sep1(by: p.literal(", ")),
      else: p.literal("no other bags")
      |> p.map(fun.constant([])),
    ))
    |> p.skip(p.literal("."))

  lines
  |> list.map(with: fun.compose(
    p.parse_entire(_, with: line_parser),
    resx.assert_unwrap,
  ))
  |> map.from_list
}

fn neighbour_fun(graph: BagGraph) -> BagNeighbourFun {
  fn(bag) {
    graph
    |> map.get(bag)
    |> resx.assert_unwrap
    |> list.map(with: pair.first)
    |> iter.from_list
  }
}

fn bag_count(of bag: BagId, in graph: BagGraph) -> Int {
  list.fold(
    over: graph
    |> map.get(bag)
    |> res.unwrap(or: []),
    from: 1,
    with: fn(sum, edge) {
      let #(next_bag, next_count) = edge
      sum + next_count * bag_count(of: next_bag, in: graph)
    },
  )
}

fn part1(lines: List(String)) -> Int {
  let graph = parse_graph(lines)
  let neighbours = neighbour_fun(graph)

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

fn part2(lines: List(String)) -> Int {
  bag_count(of: special_bag, in: parse_graph(lines)) - 1
}

pub fn run() -> Nil {
  let test = input_util.read_lines("test07")
  assert 4 = part1(test)
  assert 32 = part2(test)

  let input = input_util.read_lines("day07")
  io.debug(part1(input))
  io.debug(part2(input))

  Nil
}
