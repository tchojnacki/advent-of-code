import gleam/string
import gleam/list
import gleam/function
import gleam/pair
import gleam/result
import ext/intx

// Heavily inspired by https://fsharpforfunandprofit.com/posts/understanding-parser-combinators/

const eof = "end of input"

pub type ParseError {
  InvalidInput(expected: String, found: String)
  InvalidParser
}

type ParseResult(a) =
  Result(#(a, String), ParseError)

pub opaque type Parser(a) {
  Parser(function: fn(String) -> ParseResult(a), label: String)
}

fn create(function: fn(String) -> ParseResult(a)) {
  Parser(function, "unknown")
}

fn run(parser: Parser(a), on input: String) -> ParseResult(a) {
  parser.function(input)
}

pub fn labeled(parser: Parser(a), with label: String) -> Parser(a) {
  Parser(
    fn(input) {
      run(parser, on: input)
      |> result.map_error(with: fn(error) {
        case error {
          InvalidInput(_, found) -> InvalidInput(label, found)
          other -> other
        }
      })
    },
    label: label,
  )
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
  let quot = fn(string) { "\"" <> string <> "\"" }
  case parse_partial(input, with: parser) {
    Ok(#(value, "")) -> Ok(value)
    Ok(#(_, rest)) -> Error(InvalidInput(expected: eof, found: quot(rest)))
    Error(error) -> Error(error)
  }
}

pub fn any_grapheme() -> Parser(String) {
  create(fn(input) {
    input
    |> string.pop_grapheme
    |> result.replace_error(InvalidInput("", found: eof))
  })
  |> labeled(with: "any grapheme")
}

pub fn grapheme_literal(expected: String) -> Parser(String) {
  let quot = fn(grapheme) { "'" <> grapheme <> "'" }
  create(fn(input) {
    case run(any_grapheme(), on: input) {
      Ok(#(value, _)) as ok if value == expected -> ok
      Ok(#(value, _)) -> Error(InvalidInput("", found: quot(value)))
      Error(_) -> Error(InvalidInput("", found: eof))
    }
  })
  |> labeled(with: quot(expected))
}

pub fn then(first: Parser(a), second: Parser(b)) -> Parser(#(a, b)) {
  create(fn(input) {
    use parsed1 <- result.then(run(first, on: input))
    let #(value1, remaining1) = parsed1

    use parsed2 <- result.then(run(second, on: remaining1))
    let #(value2, remaining2) = parsed2

    Ok(#(#(value1, value2), remaining2))
  })
  |> labeled(with: first.label <> " then " <> second.label)
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
  create(fn(input) {
    first
    |> run(on: input)
    |> result.or(run(second, on: input))
  })
  |> labeled(with: "(" <> first.label <> " or " <> second.label <> ")")
}

pub fn any(of parsers: List(Parser(a))) -> Parser(a) {
  parsers
  |> list.reduce(with: or)
  |> result.unwrap(or: failing(with: InvalidParser))
  |> labeled(
    "(any of [" <> {
      parsers
      |> list.map(with: fn(p) { p.label })
      |> string.join(with: ", ")
    } <> "])",
  )
}

pub fn digit() -> Parser(String) {
  "0123456789"
  |> string.to_graphemes
  |> list.map(with: grapheme_literal)
  |> any
  |> labeled(with: "digit")
}

pub fn map(parser: Parser(a), with mapper: fn(a) -> b) -> Parser(b) {
  create(fn(input) {
    use parsed <- result.then(run(parser, on: input))
    let #(value, remaining) = parsed
    Ok(#(mapper(value), remaining))
  })
  |> labeled(with: parser.label)
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
  create(fn(input) { Ok(#(value, input)) })
}

fn failing(with error: ParseError) -> Parser(a) {
  create(fn(_) { Error(error) })
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
  |> labeled(
    with: "(sequence of [" <> {
      parsers
      |> list.map(with: fn(p) { p.label })
      |> string.join(", ")
    } <> "])",
  )
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
  create(fn(input) { Ok(do_zero_or_more(input, with: parser)) })
  |> labeled(with: "(at least zero of " <> parser.label <> ")")
}

pub fn many1(of parser: Parser(a)) -> Parser(List(a)) {
  create(fn(input) {
    use parsed <- result.then(run(parser, on: input))
    let #(value, rest) = parsed
    let #(previous, rest) = do_zero_or_more(rest, with: parser)
    Ok(#([value, ..previous], rest))
  })
  |> labeled(with: "(at least one of " <> parser.label <> ")")
}

pub fn int() -> Parser(Int) {
  digit()
  |> many1
  |> map(with: function.compose(string.concat, intx.force_parse))
  |> labeled(with: "int")
}

pub fn any_string() -> Parser(String) {
  any_grapheme()
  |> many
  |> map(with: string.concat)
  |> labeled(with: "any string")
}

pub fn string_literal(expected: String) -> Parser(String) {
  expected
  |> string.to_graphemes()
  |> list.map(with: grapheme_literal)
  |> sequence
  |> map(with: string.concat)
  |> labeled(with: "\"" <> expected <> "\"")
}
