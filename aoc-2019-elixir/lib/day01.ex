defmodule Day01 do
  @spec part1([integer]) :: integer
  def part1(input) do
    input
    |> Enum.map(&naive_fuel_requirement/1)
    |> Enum.sum()
  end

  @spec part2([integer]) :: integer
  def part2(input) do
    input
    |> Enum.map(&recursive_fuel_requirement/1)
    |> Enum.sum()
  end

  defp naive_fuel_requirement(mass), do: div(mass, 3) - 2

  defp recursive_fuel_requirement(mass) do
    fuel_mass = div(mass, 3) - 2

    case fuel_mass do
      n when n <= 0 -> 0
      _ -> fuel_mass + recursive_fuel_requirement(fuel_mass)
    end
  end
end

input = Util.Input.read_numbers("day01")
input |> Day01.part1() |> IO.inspect()
input |> Day01.part2() |> IO.inspect()
