defmodule Selector.Parser.Pseudo.Selector do
  @moduledoc false

  def parse(selectors, name, _opts) do
    case Selector.Parser.parse(selectors) do
      {[param], selectors} -> {[param], selectors}
      {[_ | _], _selectors} -> raise ArgumentError, "Pseudo #{name} only accepts a single selector as a param."
    end
  end
end
