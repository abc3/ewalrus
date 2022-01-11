defmodule Ewalrus.MixProject do
  use Mix.Project

  def project do
    [
      app: :ewalrus,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Ewalrus.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.2"},
      {:postgrex, "~> 0.15"},
      {:uuid, "~> 1.1"},
      {:benchee, "~> 0.11.0", only: :bench},
      {:benchee_json, "~> 0.4.0", only: :bench}
    ]
  end
end
