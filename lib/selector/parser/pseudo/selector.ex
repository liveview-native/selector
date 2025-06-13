defmodule Selector.Parser.Pseudo.Selector do
  @moduledoc false

  def parse(selectors, opts) do
    case Selector.Parser.Selector.parse(selectors, [], opts) do
      {[param], selectors} -> {[param], selectors}
      {[_ | _], _selectors} -> raise ArgumentError, "Pseudo type only accepts a single selector as a param."
    end
  end
end
