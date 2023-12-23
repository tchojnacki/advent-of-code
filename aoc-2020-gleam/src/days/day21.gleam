import gleam/io
import gleam/int
import gleam/list
import gleam/pair
import gleam/string as str
import gleam/set.{type Set}
import gleam/dict.{type Dict}
import ext/setx
import ext/boolx
import ext/resultx as resx
import util/input_util
import util/parser as p

type Ingredient =
  String

type Allergen =
  String

type Food {
  Food(ingredients: Set(Ingredient), some_allergens: Set(Allergen))
}

type Candidates =
  Dict(Allergen, Set(Ingredient))

fn parse_food(text: String) -> Food {
  let food_parser =
    p.alpha1()
    |> p.sep1(by: p.ws_gc())
    |> p.map(with: set.from_list)
    |> p.skip(p.literal(" (contains "))
    |> p.then(
      p.alpha1()
      |> p.sep1(by: p.literal(", "))
      |> p.map(with: set.from_list),
    )
    |> p.skip(p.literal(")"))
    |> p.map2(with: Food)

  text
  |> p.parse_entire(with: food_parser)
  |> resx.assert_unwrap
}

fn allergen_candidates(foods: List(Food)) -> Candidates {
  foods
  |> list.map(fn(f) { f.some_allergens })
  |> setx.arbitrary_union
  |> set.to_list
  |> list.map(with: fn(allergen) {
    #(
      allergen,
      foods
      |> list.filter(keeping: fn(f) {
        set.contains(in: f.some_allergens, this: allergen)
      })
      |> list.map(with: fn(f) { f.ingredients })
      |> setx.arbitrary_intersection,
    )
  })
  |> dict.from_list
}

fn stabilize(candidates: Candidates) -> Dict(Allergen, Ingredient) {
  let is_stable = fn(s) { set.size(s) == 1 }

  use <- boolx.guard_lazy(
    when: candidates
    |> dict.values
    |> list.all(satisfying: is_stable),
    return: fn() {
      candidates
      |> dict.map_values(with: fn(_, ingredients) {
        let assert [ingredient] = set.to_list(ingredients)
        ingredient
      })
    },
  )

  let stable_set =
    candidates
    |> dict.to_list
    |> list.filter_map(with: fn(entry) {
      let #(_, ingredients) = entry
      case set.to_list(ingredients) {
        [stable] -> Ok(stable)
        _ -> Error(Nil)
      }
    })
    |> set.from_list

  candidates
  |> dict.map_values(with: fn(_, ingredients) {
    case is_stable(ingredients) {
      True -> ingredients
      False -> setx.subtract(from: ingredients, given: stable_set)
    }
  })
  |> stabilize
}

fn part1(lines: List(String)) -> Int {
  let foods = list.map(lines, with: parse_food)

  let all_ingredients =
    foods
    |> list.map(fn(f) { f.ingredients })
    |> setx.arbitrary_union

  let candidates = allergen_candidates(foods)

  let suspicious_ingredients =
    candidates
    |> dict.values
    |> setx.arbitrary_union

  let safe_ingredients =
    setx.subtract(from: all_ingredients, given: suspicious_ingredients)

  foods
  |> list.map(with: fn(f) {
    setx.count(f.ingredients, satisfying: set.contains(safe_ingredients, _))
  })
  |> int.sum
}

fn part2(lines: List(String)) -> String {
  lines
  |> list.map(with: parse_food)
  |> allergen_candidates
  |> stabilize
  |> dict.to_list
  |> list.sort(by: fn(a, b) { str.compare(pair.first(a), pair.first(b)) })
  |> list.map(with: pair.second)
  |> str.join(",")
}

pub fn main() -> Nil {
  let testing = input_util.read_lines("test21")
  let assert 5 = part1(testing)
  let assert "mxmxvkd,sqjhc,fvjkl" = part2(testing)

  let input = input_util.read_lines("day21")
  io.debug(part1(input))
  io.println(part2(input))

  Nil
}
