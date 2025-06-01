defmodule ExYUV.MixProject do
  use Mix.Project

  @version "0.2.0"

  @source_url "https://github.com/gBillal/ex_yuv"

  def project do
    [
      app: :ex_yuv,
      version: @version,
      elixir: "~> 1.14",
      compilers: [:elixir_make] ++ Mix.compilers(),
      name: "ExYUV",
      description:
        "Elixir binding for [libyub](https://chromium.googlesource.com/libyuv/libyuv/)",
      make_precompiler: {:nif, CCPrecompiler},
      make_precompiler_url:
        "https://github.com/gBillal/ex_yuv/releases/download/v#{@version}/@{artefact_filename}",
      make_precompiler_nif_versions: [
        versions: ["2.15", "2.16"]
      ],
      make_precompiler_filename: "yuv_nif",
      make_env: make_env(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      cc_precompiler: [
        only_listed_targets: false,
        cleanup: "clean_build"
      ]
    ]
  end

  defp make_env do
    fn ->
      case System.get_env("CC_PRECOMPILER_CURRENT_TARGET", "") |> String.split("-") do
        [arch, os, _abi] ->
          os = if os == "apple", do: "darwin", else: os

          %{
            "CMAKE_SYSTEM_NAME" => os,
            "CMAKE_SYSTEM_PROCESSOR" => arch
          }

        _other ->
          %{}
      end
    end
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elixir_make, "~> 0.9", runtime: false},
      {:cc_precompiler, "~> 0.1", runtime: false},
      {:ex_doc, "~> 0.38", only: [:dev], runtime: false}
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end

  defp package do
    [
      name: "ex_yuv",
      files: ~w(c_src lib mix.exs README.md Makefile LICENSE checksum.exs),
      licenses: ["Apache-2.0"],
      links: %{"Github" => @source_url}
    ]
  end
end
