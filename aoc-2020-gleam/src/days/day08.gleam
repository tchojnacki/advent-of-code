import gleam/io
import gleam/int
import gleam/list
import gleam/bool
import gleam/result as res
import gleam/set.{type Set}
import gleam/iterator.{type Iterator} as iter
import gleam/option.{type Option, None, Some} as opt
import ext/listx
import ext/resultx as resx
import util/input_util
import util/parser as p

type Instr {
  Acc(increment: Int)
  Jmp(offset: Int)
  Nop(unused: Int)
}

type Program =
  List(Instr)

type Cpu {
  Cpu(acc: Int, pc: Int)
}

const initial_cpu = Cpu(acc: 0, pc: 0)

type ExecutionResult {
  InfiniteLoop(acc_before_second: Int)
  Termination(acc_after: Int)
}

fn parse_program(lines: List(String)) -> Program {
  let argument_parser =
    p.any(of: [
      p.replace(p.literal("+"), with: 1),
      p.replace(p.literal("-"), with: -1),
    ])
    |> p.then(p.int())
    |> p.map2(with: int.multiply)

  let instr_parser =
    p.any(of: [
      p.literal("acc ")
      |> p.proceed(with: argument_parser)
      |> p.map(with: Acc),
      p.literal("jmp ")
      |> p.proceed(with: argument_parser)
      |> p.map(with: Jmp),
      p.literal("nop ")
      |> p.proceed(with: argument_parser)
      |> p.map(with: Nop),
    ])

  lines
  |> list.map(with: fn(line) {
    line
    |> p.parse_entire(with: instr_parser)
    |> resx.assert_unwrap
  })
}

fn fetch(from program: Program, with cpu: Cpu) -> Option(Instr) {
  program
  |> list.at(cpu.pc)
  |> opt.from_result
}

fn execute(instr: Instr, on cpu: Cpu) -> Cpu {
  case instr {
    Acc(increment) -> Cpu(cpu.acc + increment, cpu.pc + 1)
    Jmp(offset) -> Cpu(cpu.acc, cpu.pc + offset)
    Nop(_) -> Cpu(cpu.acc, cpu.pc + 1)
  }
}

fn execution_result_helper(
  program: Program,
  cpu: Cpu,
  visited: Set(Int),
) -> ExecutionResult {
  use <- bool.guard(
    when: set.contains(visited, cpu.pc),
    return: InfiniteLoop(acc_before_second: cpu.acc),
  )

  case fetch(from: program, with: cpu) {
    None -> Termination(acc_after: cpu.acc)
    Some(instr) ->
      execution_result_helper(
        program,
        execute(instr, on: cpu),
        set.insert(visited, cpu.pc),
      )
  }
}

fn execution_result(program: Program) -> ExecutionResult {
  execution_result_helper(program, initial_cpu, set.new())
}

fn halts(program: Program) -> Bool {
  case execution_result(program) {
    Termination(_) -> True
    _ -> False
  }
}

fn all_program_mutations(of program: Program) -> Iterator(Program) {
  let undo_corruption = fn(instr) {
    case instr {
      Nop(offset) -> Jmp(offset)
      Jmp(unused) -> Nop(unused)
      other -> other
    }
  }

  program
  |> iter.from_list
  |> iter.index
  |> iter.flat_map(fn(elem) {
    let #(instr, index) = elem
    case instr {
      Acc(_) -> iter.empty()
      _ ->
        program
        |> listx.set(undo_corruption(instr), at: index)
        |> iter.single
    }
  })
}

fn part1(lines: List(String)) -> Int {
  let assert InfiniteLoop(acc) =
    lines
    |> parse_program
    |> execution_result

  acc
}

fn part2(lines: List(String)) -> Int {
  let assert Ok(Termination(acc)) =
    lines
    |> parse_program
    |> all_program_mutations
    |> iter.find(one_that: halts)
    |> res.map(with: execution_result)

  acc
}

pub fn main() -> Nil {
  let testing = input_util.read_lines("test08")
  let assert 5 = part1(testing)
  let assert 8 = part2(testing)

  let input = input_util.read_lines("day08")
  io.debug(part1(input))
  io.debug(part2(input))

  Nil
}
