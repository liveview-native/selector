defmodule Selector.Parser.Pseudo.Direction do
  @moduledoc false

  @directions ~w{
    ltr
    rtl
  }

  for direction <- @directions do
    def parse(<<unquote(direction)::utf8, selectors::binary>>, _opts) do
      {unquote(direction), selectors}
    end
  end

  def parse(_selectors, _opts) do
    raise ArgumentError, "Invalid argument for Direction."
  end
end


