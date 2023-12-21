import gleam/io
import gleam/int
import gleam/dict.{type Dict}
import gleam/list
import gleam/pair
import gleam/string as str
import gleam/iterator as iter
import ext/resultx as resx
import util/input_util
import util/graph
import util/parser as p

const bits: Int = 36

type Instr {
  SetMem(address: String, value: Int)
  ChangeMask(mask: String)
}

type Program =
  List(Instr)

type Memory =
  Dict(String, Int)

type State =
  #(Memory, String)

fn parse_program(input: List(String)) -> Program {
  let instr_parser =
    p.or(
      p.literal("mask = ")
      |> p.proceed(with: p.any_str_greedy())
      |> p.map(with: ChangeMask),
      p.literal("mem[")
      |> p.proceed(with: p.int())
      |> p.map(with: fn(address) {
        address
        |> int.to_base_string(2)
        |> resx.assert_unwrap
      })
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

fn apply_mask(value: Int, mask: String) -> Int {
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
  |> int.bitwise_or(or_mask)
  |> int.bitwise_and(and_mask)
}

fn execute_program(
  program: Program,
  interpreter: fn(State, Instr) -> State,
) -> Int {
  list.fold(
    over: program,
    from: #(dict.new(), "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"),
    with: interpreter,
  )
  |> pair.first
  |> dict.values
  |> int.sum
}

fn memory_locations(from address: String, with mask: String) -> List(String) {
  let address =
    address
    |> str.pad_left(to: bits, with: "0")
    |> str.to_graphemes
    |> list.zip(str.to_graphemes(mask))
    |> list.map(with: fn(pair) {
      let #(a, m) = pair
      case m {
        "0" -> a
        "1" -> "1"
        "X" -> "X"
        _ -> panic
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
          _ -> panic
        }
    }
  })
  |> iter.map(with: pair.first)
  |> iter.filter(keeping: fn(res) { str.length(res) == bits })
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
          memory
          |> dict.insert(for: address, insert: apply_mask(value, mask)),
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
          |> list.fold(from: memory, with: fn(memory, address) {
            dict.insert(into: memory, for: address, insert: value)
          }),
          mask,
        )
      }
      ChangeMask(new_mask) -> #(memory, new_mask)
    }
  })
}

pub fn main() -> Nil {
  let testing = input_util.read_lines("test14")
  let assert 51 = part1(testing)
  let assert 208 = part2(testing)

  let input = input_util.read_lines("day14")
  io.debug(part1(input))
  io.debug(part2(input))

  Nil
}
