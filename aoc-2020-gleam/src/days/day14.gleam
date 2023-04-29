import gleam/io
import gleam/int
import gleam/map.{Map}
import gleam/list
import gleam/pair
import gleam/string as str
import gleam/iterator as iter
import gleam/bitwise as bit
import ext/resultx as resx
import util/input_util
import util/graph
import util/parser as p

const bits: Int = 36

type Instr {
  SetMem(address: Int, value: Int)
  ChangeMask(mask: String)
}

type Program =
  List(Instr)

type Memory =
  Map(Int, Int)

type Mask =
  String

type State =
  #(Memory, Mask)

fn parse_program(input: List(String)) -> Program {
  let instr_parser =
    p.or(
      p.literal("mask = ")
      |> p.proceed(with: p.any_str_greedy())
      |> p.map(with: ChangeMask),
      p.literal("mem[")
      |> p.proceed(with: p.int())
      |> p.skip(p.literal("] = "))
      |> p.then(p.int())
      |> p.map2(with: SetMem),
    )

  input
  |> list.map(with: fn(line) {
    line
    |> p.parse_entire(with: instr_parser)
    |> resx.assert_unwrap
  })
}

fn apply_mask(value: Int, mask: Mask) -> Int {
  let or_mask =
    mask
    |> str.replace(each: "X", with: "0")
    |> int.base_parse(2)
    |> resx.assert_unwrap

  let and_mask =
    mask
    |> str.replace(each: "X", with: "1")
    |> int.base_parse(2)
    |> resx.assert_unwrap

  value
  |> bit.or(or_mask)
  |> bit.and(and_mask)
}

fn execute_program(
  program: Program,
  interpreter: fn(State, Instr) -> State,
) -> Int {
  list.fold(
    over: program,
    from: #(map.new(), "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"),
    with: interpreter,
  )
  |> pair.first
  |> map.values
  |> int.sum
}

fn memory_locations(from address: Int, with mask: String) -> List(Int) {
  let address =
    address
    |> int.to_base_string(2)
    |> resx.assert_unwrap
    |> str.pad_left(to: bits, with: "0")
    |> str.to_graphemes
    |> list.zip(str.to_graphemes(mask))
    |> list.map(with: fn(pair) {
      let #(a, m) = pair
      case m {
        "0" -> a
        "1" -> "1"
        "X" -> "X"
      }
    })
    |> str.concat

  #("", address)
  |> graph.dfs(with: fn(prev) {
    let #(done, queue) = prev
    case str.pop_grapheme(queue) {
      Error(Nil) -> iter.empty()
      Ok(#(head, rest)) ->
        case head {
          "0" | "1" -> iter.single(#(done <> head, rest))
          "X" -> iter.from_list([#(done <> "0", rest), #(done <> "1", rest)])
        }
    }
  })
  |> iter.map(with: pair.first)
  |> iter.filter(for: fn(res) { str.length(res) == bits })
  |> iter.map(with: fn(res) {
    res
    |> int.base_parse(2)
    |> resx.assert_unwrap
  })
  |> iter.to_list
}

fn part1(input: List(String)) -> Int {
  input
  |> parse_program
  |> execute_program(fn(acc, instr) {
    let #(memory, mask) = acc
    case instr {
      SetMem(address, value) -> {
        #(
          map.insert(
            into: memory,
            for: address,
            insert: apply_mask(value, mask),
          ),
          mask,
        )
      }
      ChangeMask(new_mask) -> #(memory, new_mask)
    }
  })
}

fn part2(input: List(String)) -> Int {
  input
  |> parse_program
  |> execute_program(fn(acc, instr) {
    let #(memory, mask) = acc
    case instr {
      SetMem(address, value) -> {
        #(
          memory_locations(from: address, with: mask)
          |> list.fold(
            from: memory,
            with: fn(memory, address) {
              map.insert(into: memory, for: address, insert: value)
            },
          ),
          mask,
        )
      }
      ChangeMask(new_mask) -> #(memory, new_mask)
    }
  })
}

pub fn main() -> Nil {
  let test = input_util.read_lines("test14")
  let assert 51 = part1(test)
  let assert 208 = part2(test)

  let input = input_util.read_lines("day14")
  io.debug(part1(input))
  io.debug(part2(input))

  Nil
}
