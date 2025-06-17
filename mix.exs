defmodule Selector.MixProject do
  use Mix.Project

  def project do
    [
      app: :selector,
      version: "0.0.1",
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
    [
      {:ex_doc, "~> 0.38", only: :dev, runtime: false, warn_if_outdated: true},
    ]
  end
end
