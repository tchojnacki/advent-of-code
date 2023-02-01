import gleam/string
import gleam/list
import gleam/function
import gleam/pair
import gleam/result
import ext/intx

// Heavily inspired by https://fsharpforfunandprofit.com/posts/understanding-parser-combinators/

const eof: String = "end of input"

fn quoted(grapheme: String) -> String {
  "'" <> grapheme <> "'"
}

pub type ParseError {
  InvalidInput(expected: String, found: String)
  InvalidParser
}

type ParseResult(a) =
  Result(#(a, String), ParseError)

pub opaque type Parser(a) {
  Parser(function: fn(String) -> ParseResult(a))
}

fn run(parser: Parser(a), on input: String) -> ParseResult(a) {
  parser.function(input)
}

pub fn parse_partial(
  input: String,
  with parser: Parser(a),
) -> Result(#(a, String), ParseError) {
  run(parser, on: input)
}

pub fn parse_entire(
  input: String,
  with parser: Parser(a),
) -> Result(a, ParseError) {
  case parse_partial(input, with: parser) {
    Ok(#(value, "")) -> Ok(value)
    Ok(#(_, rest)) -> Error(InvalidInput(expected: eof, found: rest))
    Error(error) -> Error(error)
  }
}

pub fn any_grapheme() -> Parser(String) {
  Parser(fn(input) {
    input
    |> string.pop_grapheme
    |> result.replace_error(InvalidInput(expected: "any grapheme", found: eof))
  })
}

pub fn grapheme_literal(expected: String) -> Parser(String) {
  Parser(fn(input) {
    case run(any_grapheme(), on: input) {
      Ok(#(value, _)) as ok if value == expected -> ok
      Ok(#(value, _)) -> Error(InvalidInput(quoted(expected), found: value))
      Error(_) -> Error(InvalidInput(quoted(expected), found: eof))
    }
  })
}

pub fn then(first: Parser(a), second: Parser(b)) -> Parser(#(a, b)) {
  Parser(fn(input) {
    use parsed1 <- result.then(run(first, on: input))
    let #(value1, remaining1) = parsed1

    use parsed2 <- result.then(run(second, on: remaining1))
    let #(value2, remaining2) = parsed2

    Ok(#(#(value1, value2), remaining2))
  })
}

pub fn then_skip(first: Parser(a), second: Parser(b)) -> Parser(a) {
  first
  |> then(second)
  |> map(with: pair.first)
}

pub fn or(first: Parser(a), else second: Parser(a)) -> Parser(a) {
  Parser(fn(input) {
    first
    |> run(on: input)
    |> result.or(run(second, on: input))
  })
}

pub fn any(of parsers: List(Parser(a))) -> Parser(a) {
  parsers
  |> list.reduce(with: or)
  |> result.unwrap(or: failing(InvalidParser))
}

pub fn digit() -> Parser(String) {
  "0123456789"
  |> string.to_graphemes
  |> list.map(with: grapheme_literal)
  |> any
  // TODO: replace error
}

pub fn map(parser: Parser(a), with mapper: fn(a) -> b) -> Parser(b) {
  Parser(fn(input) {
    use parsed <- result.then(run(parser, on: input))
    let #(value, remaining) = parsed
    Ok(#(mapper(value), remaining))
  })
}

fn succeeding(value: a) -> Parser(a) {
  Parser(fn(input) { Ok(#(value, input)) })
}

fn failing(error: ParseError) -> Parser(a) {
  Parser(fn(_) { Error(error) })
}

fn apply(fn_parser: Parser(fn(a) -> b), value_parser: Parser(a)) -> Parser(b) {
  fn_parser
  |> then(value_parser)
  |> map(fn(pair) {
    let #(f, x) = pair
    f(x)
  })
}

fn lift2(func: fn(a, b) -> c) -> fn(Parser(a), Parser(b)) -> Parser(c) {
  fn(x_parser, y_parser) {
    func
    |> function.curry2
    |> succeeding
    |> apply(x_parser)
    |> apply(y_parser)
  }
}

pub fn sequence(of parsers: List(Parser(a))) -> Parser(List(a)) {
  let prepend_parser = lift2(list.prepend)
  case parsers {
    [] -> succeeding([])
    [head, ..tail] ->
      tail
      |> sequence
      |> prepend_parser(head)
  }
}

fn parse_zero_or_more(
  input: String,
  with parser: Parser(a),
) -> #(List(a), String) {
  case run(parser, on: input) {
    Ok(#(value, rest)) -> {
      let #(previous, rest) = parse_zero_or_more(rest, with: parser)
      #([value, ..previous], rest)
    }
    Error(_) -> #([], input)
  }
}

pub fn many(parser: Parser(a)) -> Parser(List(a)) {
  Parser(fn(input) { Ok(parse_zero_or_more(input, with: parser)) })
}

pub fn many1(parser: Parser(a)) -> Parser(List(a)) {
  Parser(fn(input) {
    use parsed <- result.then(run(parser, on: input))
    let #(value, rest) = parsed
    let #(previous, rest) = parse_zero_or_more(rest, with: parser)
    Ok(#([value, ..previous], rest))
  })
}

pub fn int() -> Parser(Int) {
  digit()
  |> many1
  |> map(with: function.compose(string.concat, intx.force_parse))
}

pub fn any_string() -> Parser(String) {
  any_grapheme()
  |> many
  |> map(with: string.concat)
}
