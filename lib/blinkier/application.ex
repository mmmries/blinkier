defmodule Blinkier.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Blinkier.Supervisor]
    children =
      [

      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  def children(:host) do
    [
    ]
  end

  def children(_target) do
    [
      {Blinkier.Painter, "i2c-1"}
    ]
  end

  def target() do
    Application.get_env(:blinkier, :target)
  end
end
