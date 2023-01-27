defmodule Util.Integer do
  @spec parse!(binary) :: integer
  def parse!(binary) do
    {integer, _remainder} = Integer.parse(binary)
    integer
  end
end

defmodule Util.Input do
  @spec read_text(binary) :: binary
  def read_text(filename) do
    File.read!("data/#{filename}.txt")
  end

  @spec read_lines(binary) :: [binary]
  def read_lines(filename) do
    filename |> read_text() |> String.split()
  end

  @spec read_numbers(binary) :: [integer]
  def read_numbers(filename) do
    filename
    |> read_lines()
    |> Enum.map(&Util.Integer.parse!/1)
  end
end
