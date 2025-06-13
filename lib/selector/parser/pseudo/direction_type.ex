defmodule Selector.Parser.Pseudo.DirectionType do
  @moduledoc false

  @directions ~w{
    up
    down
    left
    right
    *
  }

  for direction <- @directions do
    def parse(<<unquote(direction)::utf8, selectors::binary>>, _opts) do
      {unquote(direction), selectors}
    end
  end

  def parse(_selectors, _opts) do
    raise ArgumentError, "Invalid argument for DirectionType."
  end
end

