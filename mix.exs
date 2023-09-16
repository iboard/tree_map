defmodule TreeMap.MixProject do
  use Mix.Project

  def project do
    [
      app: :tree_map,
      version: "0.1.0",
      elixir: "~> 1.15",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        main: "readme",
        homepage_url: "https://github.com/iboard/tree_map",
        source_url: "https://github.com/iboard/tree_map",
        extras: ["README.md", "LICENSE.md", "CHANGELOG.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description() do
    "Manage a tree of key, value, children struct"
  end

  defp package() do
    [
      files: ~w(lib test .formatter.exs mix.exs README* LICENSE*
                CHANGELOG*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/iboard/tree_map"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
