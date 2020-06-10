defmodule Blinkier.MixProject do
  use Mix.Project

  @app :blinkier
  @version "0.1.0"
  @all_targets [:rpi, :rpi3, :rpi3a]

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.9",
      archives: [nerves_bootstrap: "~> 1.8"],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      aliases: [loadconfig: [&bootstrap/1]],
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host]
    ]
  end

  # Starting nerves_bootstrap adds the required aliases to Mix.Project.config()
  # Aliases are only added if MIX_TARGET is set.
  def bootstrap(args) do
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Blinkier.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Dependencies for all targets
      {:nerves, "~> 1.6.0", runtime: false},
      {:shoehorn, "~> 0.6"},
      {:ring_logger, "~> 0.6"},
      {:toolshed, "~> 0.2"},
      {:sense_hat, path: "../sense_hat"},
      {:chameleon, "~> 2.2"},

      # Dependencies for all targets except :host
      {:input_event, "~> 0.4", targets: @all_targets},
      {:nerves_runtime, "~> 0.6", targets: @all_targets},
      {:nerves_pack, "~> 0.2", targets: @all_targets},

      # Dependencies for specific targets
      {:nerves_system_rpi, path: "../nerves_system_rpi", runtime: false, targets: :rpi, nerves: [compile: true]},
      {:nerves_system_rpi3, path: "../nerves_system_rpi3", runtime: false, targets: :rpi3, nerves: [compile: true]},
      {:nerves_system_rpi3a, path: "../nerves_system_rpi3a", runtime: false, targets: :rpi3a, nerves: [compile: true]},
    ]
  end

  def release do
    [
      overwrite: true,
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod
    ]
  end
end
