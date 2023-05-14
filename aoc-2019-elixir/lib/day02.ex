defmodule Day02 do
  @add_opcode 1
  @mul_opcode 2
  @ret_opcode 99
  @noun_address 1
  @verb_address 2

  @spec part1(binary) :: list
  def part1(input), do: run(input, 12, 2)

  @spec part2(binary) :: integer
  def part2(input) do
    for(
      n <- 0..100,
      v <- 0..100,
      do: {n, v, run(input, n, v)}
    )
    |> Enum.find(&(elem(&1, 2) == 19_690_720))
    |> then(fn {n, v, _} -> n * 100 + v end)
  end

  defp run(input, noun, verb) do
    input
    |> parse()
    |> List.replace_at(@noun_address, noun)
    |> List.replace_at(@verb_address, verb)
    |> execute()
    |> hd()
  end

  defp binary_op(program, op, a, b, out) do
    program |> List.replace_at(out, op.(Enum.at(program, a), Enum.at(program, b)))
  end

  defp execute(program, pc \\ 0) do
    instruction = program |> Enum.drop(pc) |> Enum.take(4)

    case instruction do
      [@add_opcode, a, b, out] ->
        program
        |> binary_op(&+/2, a, b, out)
        |> execute(pc + 4)

      [@mul_opcode, a, b, out] ->
        program
        |> binary_op(&*/2, a, b, out)
        |> execute(pc + 4)

      [@ret_opcode | _] ->
        program
    end
  end

  defp parse(input) do
    input
    |> String.split(",")
    |> Enum.map(&Util.Integer.parse!/1)
  end
end

input = Util.Input.read_text("day02")
input |> Day02.part1() |> IO.inspect()
input |> Day02.part2() |> IO.inspect()
