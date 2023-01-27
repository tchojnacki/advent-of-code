defmodule Aoc2019Elixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :aoc_2019_elixir,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: []
    ]
  end
end
