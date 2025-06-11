defmodule Selector.Parser.Pseudo.SelectorList do
  @moduledoc false

  def parse(selectors, name, _opts) do
    case Selector.Parser.parse(selectors) do
      {params, selectors} when is_list(params) -> {params, selectors}
      _ -> raise ArgumentError, "Pseudo #{name} only accepts a selectors as param."
    end
  end
end
