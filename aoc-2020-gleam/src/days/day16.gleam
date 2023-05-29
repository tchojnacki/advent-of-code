import gleam/io
import gleam/int
import gleam/list
import gleam/bool
import gleam/pair
import gleam/string as str
import gleam/map.{Map}
import ext/resultx as resx
import ext/genericx as genx
import util/input_util
import util/parser as p

type Range {
  Range(min: Int, max: Int)
}

type Rule =
  List(Range)

type Ticket =
  List(Int)

type Notes {
  Notes(
    fields: Map(String, Rule),
    your_ticket: Ticket,
    nearby_tickets: List(Ticket),
  )
}

fn parse_notes(input: String) -> Notes {
  let range_parser =
    p.int()
    |> p.skip(p.literal("-"))
    |> p.then(p.int())
    |> p.map2(with: Range)
    |> p.labeled(with: "range")

  let rule_parser =
    range_parser
    |> p.sep1(by: p.literal(" or "))
    |> p.labeled(with: "rule")

  let field_parser =
    p.str_of_many1(of: p.gc_not_in(":"))
    |> p.skip(p.literal(": "))
    |> p.then(rule_parser)
    |> p.labeled(with: "field")

  let ticket_parser =
    p.int()
    |> p.sep1(by: p.literal(","))
    |> p.labeled(with: "ticket")

  let notes_parser =
    field_parser
    |> p.sep1(by: p.nl())
    |> p.map(with: map.from_list)
    |> p.skip(p.nlnl())
    |> p.skip(p.literal("your ticket:"))
    |> p.skip(p.nl())
    |> p.then(ticket_parser)
    |> p.skip(p.nlnl())
    |> p.skip(p.literal("nearby tickets:"))
    |> p.skip(p.nl())
    |> p.then_3rd(p.sep1(ticket_parser, by: p.nl()))
    |> p.skip_ws()
    |> p.map3(with: Notes)
    |> p.labeled(with: "notes")

  input
  |> p.parse_entire(with: notes_parser)
  |> resx.assert_unwrap
}

fn satisfies_range(value: Int, range: Range) -> Bool {
  range.min <= value && value <= range.max
}

fn satisfies_rule(value: Int, rule: Rule) -> Bool {
  list.any(in: rule, satisfying: satisfies_range(value, _))
}

type Column {
  Collapsed(String)
  Pending(List(String))
}

fn collapse_columns(columns: List(Column)) -> List(String) {
  case
    list.find_map(
      in: columns,
      with: fn(column) {
        case column {
          Pending([name]) -> Ok(name)
          _ -> Error(Nil)
        }
      },
    )
  {
    Ok(target) ->
      columns
      |> list.map(with: fn(column) {
        case column {
          Collapsed(name) -> Collapsed(name)
          Pending([_]) -> Collapsed(target)
          Pending(names) ->
            names
            |> list.filter(for: genx.different(_, than: target))
            |> Pending
        }
      })
      |> collapse_columns
    Error(Nil) ->
      list.map(
        columns,
        with: fn(column) {
          let assert Collapsed(name) = column
          name
        },
      )
  }
}

fn part1(input: String) -> Int {
  let notes = parse_notes(input)

  notes.nearby_tickets
  |> list.flatten
  |> list.filter(for: fn(value) {
    notes.fields
    |> map.values
    |> list.any(satisfying: satisfies_rule(value, _))
    |> bool.negate
  })
  |> int.sum
}

fn part2(input: String) -> Int {
  let notes = parse_notes(input)

  [notes.your_ticket, ..notes.nearby_tickets]
  |> list.filter(for: fn(ticket) {
    list.all(
      in: ticket,
      satisfying: fn(value) {
        notes.fields
        |> map.values
        |> list.any(satisfying: satisfies_rule(value, _))
      },
    )
  })
  |> list.transpose
  |> list.map(with: fn(column) {
    notes.fields
    |> map.to_list
    |> list.filter_map(with: fn(entry) {
      let #(name, rule) = entry
      case list.all(in: column, satisfying: satisfies_rule(_, rule)) {
        True -> Ok(name)
        False -> Error(Nil)
      }
    })
    |> Pending
  })
  |> collapse_columns
  |> list.strict_zip(notes.your_ticket)
  |> resx.assert_unwrap
  |> list.filter(fn(entry) {
    let #(column, _) = entry
    str.starts_with(column, "departure")
  })
  |> list.map(with: pair.second)
  |> int.product
}

pub fn main() -> Nil {
  let test = input_util.read_text("test16")
  let assert 71 = part1(test)
  let assert 1 = part2(test)

  let input = input_util.read_text("day16")
  io.debug(part1(input))
  io.debug(part2(input))

  Nil
}
