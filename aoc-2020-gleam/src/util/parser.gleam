import gleam/string
import gleam/list
import gleam/function
import gleam/pair
import gleam/result
import gleam/int
import gleam/bool
import gleam/option.{None, Option, Some}

// Heavily inspired by https://fsharpforfunandprofit.com/posts/understanding-parser-combinators/

const eof = "end of input"

const whitespace_range = " \t\n"

fn q_s(string: String) -> String {
  "'" <> string <> "'"
}

fn q_d(string: String) -> String {
  "\"" <> string <> "\""
}

pub type ParseError {
  InvalidInput(expected: String, found: String)
  InvalidOperation(at: String)
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
  case parse_partial(input, with: parser) {
    Ok(#(value, "")) -> Ok(value)
    Ok(#(_, rest)) -> Error(InvalidInput(expected: eof, found: q_d(rest)))
    Error(error) -> Error(error)
  }
}

pub fn grapheme_satisfying(predicate) {
  create(fn(input) {
    case string.pop_grapheme(input) {
      Ok(#(value, remaining)) ->
        case predicate(value) {
          True -> Ok(#(value, remaining))
          False -> Error(InvalidInput("", found: q_s(value)))
        }
      Error(_) -> Error(InvalidInput("", found: eof))
    }
  })
}

pub fn any_grapheme() -> Parser(String) {
  grapheme_satisfying(function.constant(True))
  |> labeled(with: "any grapheme")
}

pub fn grapheme_literal(expected: String) -> Parser(String) {
  grapheme_satisfying(fn(g) { g == expected })
  |> labeled(with: q_s(expected))
}

pub fn grapheme_in(range allowed: String) -> Parser(String) {
  grapheme_satisfying(string.contains(allowed, _))
  |> labeled(with: "grapheme from set " <> q_d(allowed))
}

pub fn grapheme_not_in(range denied: String) -> Parser(String) {
  grapheme_satisfying(function.compose(string.contains(denied, _), bool.negate))
  |> labeled(with: "grapheme NOT from set " <> q_d(denied))
}

pub fn whitespace_grapheme() -> Parser(String) {
  grapheme_in(range: whitespace_range)
  |> labeled(with: "whitespace grapheme")
}

pub fn whitespaces() -> Parser(String) {
  string_of_many(of: whitespace_grapheme())
}

pub fn whitespaces1() -> Parser(String) {
  string_of_many1(of: whitespace_grapheme())
}

pub fn nonwhitespace_grapheme() -> Parser(String) {
  grapheme_not_in(range: whitespace_range)
  |> labeled(with: "nonwhitespace grapheme")
}

pub fn string_until_whitespace() -> Parser(String) {
  string_of_many(of: nonwhitespace_grapheme())
}

pub fn string1_until_whitespace() -> Parser(String) {
  string_of_many1(of: nonwhitespace_grapheme())
}

pub fn ignore(parser: Parser(a)) -> Parser(Nil) {
  parser
  |> map(function.constant(Nil))
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

pub fn ignore_and_then(first: Parser(a), second: Parser(b)) -> Parser(b) {
  first
  |> then(second)
  |> map(with: pair.second)
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

pub fn optional(parser: Parser(a)) -> Parser(Option(a)) {
  parser
  |> map(with: Some)
  |> or(else: succeeding(with: None))
  |> labeled(with: "optional " <> parser.label)
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
  grapheme_in(range: "0123456789")
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

pub fn string_of_sequence(of parsers: List(Parser(String))) -> Parser(String) {
  parsers
  |> sequence
  |> map(with: string.concat)
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

pub fn string_of_many(of parser: Parser(String)) -> Parser(String) {
  parser
  |> many
  |> map(with: string.concat)
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

pub fn string_of_many1(of parser: Parser(String)) -> Parser(String) {
  parser
  |> many1
  |> map(with: string.concat)
}

pub fn separated(parser: Parser(a), by separator: Parser(b)) -> Parser(List(a)) {
  parser
  |> then(many(of: ignore_and_then(separator, parser)))
  |> map2(with: fn(p, ps) { [p, ..ps] })
  |> labeled(
    with: "(at least zero of " <> parser.label <> " separated by " <> separator.label <> ")",
  )
}

pub fn separated1(parser: Parser(a), by separator: Parser(b)) -> Parser(List(a)) {
  parser
  |> separated(by: separator)
  |> or(else: succeeding(with: []))
  |> labeled(
    with: "(at least one of " <> parser.label <> " separated by " <> separator.label <> ")",
  )
}

pub fn int() -> Parser(Int) {
  let int_string_parser = string_of_many1(digit())
  create(fn(input) {
    use parsed <- result.then(run(int_string_parser, on: input))
    let #(int_string, remaining) = parsed

    int_string
    |> int.parse
    |> result.map(with: fn(int) { #(int, remaining) })
    |> result.replace_error(InvalidOperation(
      at: "int.parse(" <> int_string <> ")",
    ))
  })
  |> labeled(with: "int")
}

pub fn any_string_greedy() -> Parser(String) {
  any_grapheme()
  |> string_of_many
  |> labeled(with: "any string")
}

pub fn string_literal(expected: String) -> Parser(String) {
  expected
  |> string.to_graphemes()
  |> list.map(with: grapheme_literal)
  |> string_of_sequence
  |> labeled(with: q_d(expected))
}

pub fn string_of_exactly(
  parser: Parser(String),
  length length: Int,
) -> Parser(String) {
  parser
  |> list.repeat(times: length)
  |> string_of_sequence
  |> labeled(with: "string of length " <> int.to_string(length))
}

pub fn any_string_of_exactly(length length: Int) -> Parser(String) {
  string_of_exactly(any_grapheme(), length: length)
}

pub fn repeated(parser: Parser(a), times times: Int) -> Parser(List(a)) {
  parser
  |> list.repeat(times: times)
  |> sequence
  |> labeled(with: "exactly " <> int.to_string(times) <> " of " <> parser.label)
}

pub fn matching(parser: Parser(a), rule predicate: fn(a) -> Bool) -> Parser(a) {
  create(fn(input) {
    use parsed <- result.then(run(parser, on: input))
    let #(value, remaining) = parsed
    case predicate(value) {
      True -> Ok(parsed)
      False -> Error(InvalidOperation(at: string.inspect(predicate)))
    }
  })
}
