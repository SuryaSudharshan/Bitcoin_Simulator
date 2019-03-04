defmodule Blockchain.MixProject do
  use Mix.Project

  def project do
    [
      app: :blockchain,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {Blockchain.AppStart, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:shorter_maps, "~> 2.0"}
    ]
  end
end
