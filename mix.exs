defmodule StructyRecord.MixProject do
  use Mix.Project

  @version "0.2.0"
  @github "https://github.com/sunaku/structy_record"

  def project do
    [
      app: :structy_record,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      name: "StructyRecord",
      description: "Provides a Struct-like interface for your Records."
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      source_url: @github,
      extras: ["README.md", "CHANGELOG.md"],
      main: "readme"
    ]
  end

  defp package do
    [
      licenses: ["ISC"],
      links: %{"GitHub" => @github}
    ]
  end
end
