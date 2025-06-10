defmodule Selector.MixProject do
  use Mix.Project

  def project do
    [
      app: :selector,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: "CSS Selector Parsing"
    ]
  end

  defp package do
    [
      maintainers: ["Brian Cardarella"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/liveview-native/selector"}
    ]
  end

  def application do
    [
      extra_applications: [:logger],
    ]
  end

  defp deps do
    []
  end
end
