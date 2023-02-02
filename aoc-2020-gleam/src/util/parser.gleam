import gleam/string
import gleam/list
import gleam/function
import gleam/pair
import gleam/result
import ext/intx

// Heavily inspired by https://fsharpforfunandprofit.com/posts/understanding-parser-combinators/

const eof: String = "end of input"

fn quot(grapheme: String) -> String {
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
      Ok(#(value, _)) -> Error(InvalidInput(quot(expected), found: quot(value)))
      Error(_) -> Error(InvalidInput(quot(expected), found: eof))
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

pub fn then_third(two: Parser(#(a, b)), third: Parser(c)) -> Parser(#(a, b, c)) {
  two
  |> then(third)
  |> map(with: fn(tuple) {
    let #(#(p0, p1), p2) = tuple
    #(p0, p1, p2)
  })
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
  |> result.unwrap(or: failing(with: InvalidParser))
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

pub fn map2(parser: Parser(#(a, b)), with mapper: fn(a, b) -> c) -> Parser(c) {
  parser
  |> map(with: fn(args) { mapper(args.0, args.1) })
}

pub fn map3(
  parser: Parser(#(a, b, c)),
  with mapper: fn(a, b, c) -> d,
) -> Parser(d) {
  parser
  |> map(with: fn(args) { mapper(args.0, args.1, args.2) })
}

fn succeeding(with value: a) -> Parser(a) {
  Parser(fn(input) { Ok(#(value, input)) })
}

fn failing(with error: ParseError) -> Parser(a) {
  Parser(fn(_) { Error(error) })
}

fn lift2(function: fn(a, b) -> c) -> fn(Parser(a), Parser(b)) -> Parser(c) {
  fn(x_parser, y_parser) {
    function
    |> succeeding
    |> then(x_parser)
    |> then_third(y_parser)
    |> map3(with: fn(f, x, y) { f(x, y) })
  }
}

pub fn sequence(of parsers: List(Parser(a))) -> Parser(List(a)) {
  let prepend_parser = lift2(fn(x, xs) { [x, ..xs] })
  case parsers {
    [] -> succeeding(with: [])
    [head, ..tail] ->
      tail
      |> sequence
      |> prepend_parser(head, _)
  }
}

fn do_zero_or_more(input: String, with parser: Parser(a)) -> #(List(a), String) {
  case run(parser, on: input) {
    Ok(#(value, rest)) -> {
      let #(previous, rest) = do_zero_or_more(rest, with: parser)
      #([value, ..previous], rest)
    }
    Error(_) -> #([], input)
  }
}

pub fn many(of parser: Parser(a)) -> Parser(List(a)) {
  Parser(fn(input) { Ok(do_zero_or_more(input, with: parser)) })
}

pub fn many1(of parser: Parser(a)) -> Parser(List(a)) {
  Parser(fn(input) {
    use parsed <- result.then(run(parser, on: input))
    let #(value, rest) = parsed
    let #(previous, rest) = do_zero_or_more(rest, with: parser)
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

pub fn string_literal(expected: String) -> Parser(String) {
  expected
  |> string.to_graphemes()
  |> list.map(with: grapheme_literal)
  |> sequence
  |> map(with: string.concat)
}
