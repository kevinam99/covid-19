defmodule Notifier.MixProject do
  use Mix.Project

  def project do
    [
      app: :notifier,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto],
      mod: {Notifier.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:broadway, "~> 0.6.0"},
      {:gen_stage, "~> 1.0.0"},
      {:mongodb_driver, "~> 0.6"}
    ]
  end
end
