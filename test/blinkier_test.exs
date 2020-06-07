defmodule BlinkierTest do
  use ExUnit.Case
  doctest Blinkier

  test "greets the world" do
    assert Blinkier.hello() == :world
  end
end
