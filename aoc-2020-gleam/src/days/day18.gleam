import gleam/io
import gleam/int
import gleam/list
import gleam/string as str
import ext/resultx as resx
import util/input_util

type Expr {
  Add(Expr, Expr)
  Mul(Expr, Expr)
  Literal(Int)
}

// digit    = "0" | "1" | ... | "9" .
// op       = "+" | "*" .

// Part 1
// p_expr   = p_factor { op p_factor } .
// p_factor = "(" p_expr ")" | digit .

fn p_factor(text: String) -> #(Expr, String) {
  let assert Ok(#(grapheme, text)) = str.pop_grapheme(text)
  case grapheme {
    "(" -> {
      let #(expr, text) = p_expr(text)
      let assert Ok(#(")", text)) = str.pop_grapheme(text)
      #(expr, text)
    }
    digit -> #(Literal(resx.assert_unwrap(int.parse(digit))), text)
  }
}

fn p_expr_tail(head: Expr, text: String) -> #(Expr, String) {
  case str.pop_grapheme(text) {
    Error(Nil) | Ok(#(")", _)) -> #(head, text)
    Ok(#("+", text)) -> {
      let #(factor, text) = p_factor(text)
      p_expr_tail(Add(head, factor), text)
    }
    Ok(#("*", text)) -> {
      let #(factor, text) = p_factor(text)
      p_expr_tail(Mul(head, factor), text)
    }
    _ -> panic
  }
}

fn p_expr(text: String) -> #(Expr, String) {
  let #(factor, text) = p_factor(text)
  p_expr_tail(factor, text)
}

// Part 2
// p_mul  = p_add { "*" p_add } .
// p_add  = p_term { "+" p_term } .
// p_term = "(" p_mul ")" | digit .

fn p_term(text: String) -> #(Expr, String) {
  let assert Ok(#(grapheme, text)) = str.pop_grapheme(text)
  case grapheme {
    "(" -> {
      let #(expr, text) = p_mul(text)
      let assert Ok(#(")", text)) = str.pop_grapheme(text)
      #(expr, text)
    }
    digit -> #(Literal(resx.assert_unwrap(int.parse(digit))), text)
  }
}

fn p_add_tail(head: Expr, text: String) -> #(Expr, String) {
  case str.pop_grapheme(text) {
    Error(Nil) | Ok(#(")", _)) | Ok(#("*", _)) -> #(head, text)
    Ok(#("+", text)) -> {
      let #(term, text) = p_term(text)
      p_add_tail(Add(head, term), text)
    }
    _ -> panic
  }
}

fn p_add(text: String) -> #(Expr, String) {
  let #(term, text) = p_term(text)
  p_add_tail(term, text)
}

fn p_mul_tail(head: Expr, text: String) -> #(Expr, String) {
  case str.pop_grapheme(text) {
    Error(Nil) | Ok(#(")", _)) -> #(head, text)
    Ok(#("*", text)) -> {
      let #(add, text) = p_add(text)
      p_mul_tail(Mul(head, add), text)
    }
    _ -> panic
  }
}

fn p_mul(text: String) -> #(Expr, String) {
  let #(add, text) = p_add(text)
  p_mul_tail(add, text)
}

fn eval(expr: Expr) -> Int {
  case expr {
    Add(left, right) -> eval(left) + eval(right)
    Mul(left, right) -> eval(left) * eval(right)
    Literal(number) -> number
  }
}

fn solve(lines: List(String), parser: fn(String) -> #(Expr, String)) {
  lines
  |> list.map(with: fn(text) {
    let assert #(expr, "") =
      text
      |> str.replace(each: " ", with: "")
      |> parser

    eval(expr)
  })
  |> int.sum
}

fn part1(lines: List(String)) -> Int {
  solve(lines, p_expr)
}

fn part2(lines: List(String)) -> Int {
  solve(lines, p_mul)
}

pub fn main() -> Nil {
  let assert 71 = part1(["1 + 2 * 3 + 4 * 5 + 6"])
  let assert 51 = part1(["1 + (2 * 3) + (4 * (5 + 6))"])
  let assert 26 = part1(["2 * 3 + (4 * 5)"])
  let assert 437 = part1(["5 + (8 * 3 + 9 + 3 * 4 * 3)"])
  let assert 12_240 = part1(["5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))"])
  let assert 13_632 = part1(["((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"])

  let assert 231 = part2(["1 + 2 * 3 + 4 * 5 + 6"])
  let assert 51 = part2(["1 + (2 * 3) + (4 * (5 + 6))"])
  let assert 46 = part2(["2 * 3 + (4 * 5)"])
  let assert 1445 = part2(["5 + (8 * 3 + 9 + 3 * 4 * 3)"])
  let assert 669_060 = part2(["5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))"])
  let assert 23_340 = part2(["((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"])

  let input = input_util.read_lines("day18")
  io.debug(part1(input))
  io.debug(part2(input))

  Nil
}
