defmodule Mix.Tasks.Firmware.Reload do
  use Mix.Task

  def run(_) do
    node_name = :"blinky@blinky.local"
    #{:ok, _} = Node.start(:"iex@host.local")
    #Node.set_cookie(:monster)
    true = Node.connect(node_name)
    for application <- [:blinkier, :sense_hat] do
      Application.load(application)
      {:ok, mods} = :application.get_key(application, :modules)
      for module <- mods do
        {:ok, [{^node_name, :loaded, ^module}]} = IEx.Helpers.nl([node_name], module)
      end
    end
  end
end
