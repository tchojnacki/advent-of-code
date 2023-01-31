import gleam/string
import gleam/list
import gleam/function
import gleam/pair
import ext/resultx
import ext/intx

// Heavily inspired by https://fsharpforfunandprofit.com/posts/understanding-parser-combinators/

pub type ParseResult(a) =
  Result(#(a, String), String)

pub opaque type Parser(a) {
  Parser(parser: fn(String) -> ParseResult(a))
}

pub fn run(parser: Parser(a), on input: String) -> ParseResult(a) {
  assert Parser(function) = parser
  function(input)
}

pub fn any_grapheme() -> Parser(String) {
  let inner = fn(input) {
    case string.pop_grapheme(input) {
      Ok(#(first, rest)) -> Ok(#(first, rest))
      _ -> Error("Error!")
    }
  }
  Parser(inner)
}

pub fn grapheme(expected: String) -> Parser(String) {
  let inner = fn(input) {
    case string.pop_grapheme(input) {
      Ok(#(first, rest)) if first == expected -> Ok(#(expected, rest))
      _ -> Error("Error!")
    }
  }
  Parser(inner)
}

pub fn and_then(parser1: Parser(a), parser2: Parser(b)) -> Parser(#(a, b)) {
  let inner = fn(input) {
    let result1 = run(parser1, on: input)
    case result1 {
      Error(err) -> Error(err)
      Ok(#(value1, remaining1)) -> {
        let result2 = run(parser2, on: remaining1)
        case result2 {
          Error(err) -> Error(err)
          Ok(#(value2, remaining2)) -> {
            let new_value = #(value1, value2)
            Ok(#(new_value, remaining2))
          }
        }
      }
    }
  }
  Parser(inner)
}

pub fn then_skip(parser1: Parser(a), parser2: Parser(b)) -> Parser(a) {
  parser1
  |> and_then(parser2)
  |> map(with: pair.first)
}

pub fn or_else(parser1: Parser(a), parser2: Parser(a)) -> Parser(a) {
  let inner = fn(input) {
    let result1 = run(parser1, on: input)
    case result1 {
      Ok(_result) -> result1
      Error(_err) -> {
        let result2 = run(parser2, on: input)
        result2
      }
    }
  }
  Parser(inner)
}

pub fn choice(from parsers: List(Parser(a))) -> Parser(a) {
  list.reduce(over: parsers, with: or_else)
  |> resultx.force_unwrap
}

pub fn any_of(given graphemes: List(String)) -> Parser(String) {
  graphemes
  |> list.map(with: grapheme)
  |> choice
}

pub fn lowercase() -> Parser(String) {
  "abcdefghijklmnopqrstuvwxyz"
  |> string.to_graphemes
  |> any_of
}

pub fn digit() -> Parser(String) {
  "0123456789"
  |> string.to_graphemes
  |> any_of
}

pub fn map(parser: Parser(a), with mapper: fn(a) -> b) -> Parser(b) {
  let inner = fn(input) {
    let result = run(parser, on: input)
    case result {
      Ok(#(value, remaining)) -> {
        let new_value = mapper(value)
        Ok(#(new_value, remaining))
      }
      Error(err) -> Error(err)
    }
  }
  Parser(inner)
}

fn return(x: a) -> Parser(a) {
  let inner = fn(input) { Ok(#(x, input)) }
  Parser(inner)
}

fn apply(fp: Parser(fn(a) -> b), xp: Parser(a)) -> Parser(b) {
  and_then(fp, xp)
  |> map(fn(p) {
    let #(f, x) = p
    f(x)
  })
}

fn lift2(f: fn(a, b) -> c) -> fn(Parser(a), Parser(b)) -> Parser(c) {
  let inner = fn(xp, yp) {
    let fc = function.curry2(f)
    apply(apply(return(fc), xp), yp)
  }
  inner
}

pub fn sequence(of parsers: List(Parser(a))) -> Parser(List(a)) {
  let cons_p = lift2(list.prepend)
  case parsers {
    [] -> return([])
    [head, ..tail] -> cons_p(sequence(tail), head)
  }
}

fn parse_zero_or_more(parser: Parser(a), input: String) -> #(List(a), String) {
  let first_result = run(parser, on: input)
  case first_result {
    Error(_err) -> #([], input)
    Ok(#(first_value, input_after_first_parse)) -> {
      let #(subsequent_values, remaining_input) =
        parse_zero_or_more(parser, input_after_first_parse)
      let values = [first_value, ..subsequent_values]
      #(values, remaining_input)
    }
  }
}

pub fn many(parser: Parser(a)) -> Parser(List(a)) {
  let inner = fn(input) { Ok(parse_zero_or_more(parser, input)) }
  Parser(inner)
}

pub fn many1(parser: Parser(a)) -> Parser(List(a)) {
  let inner = fn(input) {
    let first_result = run(parser, on: input)
    case first_result {
      Error(err) -> Error(err)
      Ok(#(first_value, input_after_first_parse)) -> {
        let #(subsequent_values, remaining_input) =
          parse_zero_or_more(parser, input_after_first_parse)
        let values = [first_value, ..subsequent_values]
        Ok(#(values, remaining_input))
      }
    }
  }
  Parser(inner)
}

pub fn int() -> Parser(Int) {
  digit()
  |> many1
  |> map(with: function.compose(string.concat, intx.force_parse))
}

pub fn all_remaining() -> Parser(String) {
  any_grapheme()
  |> many
  |> map(with: string.concat)
}
