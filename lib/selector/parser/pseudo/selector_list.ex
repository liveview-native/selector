defmodule Selector.Parser.Pseudo.SelectorList do
  @moduledoc false

  def parse(selectors, opts) do
    Selector.Parser.Selector.parse(selectors, [], opts)
  end
end
