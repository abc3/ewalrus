defmodule EwalrusTest do
  use ExUnit.Case
  doctest Ewalrus

  test "greets the world" do
    assert Ewalrus.hello() == :world
  end
end
