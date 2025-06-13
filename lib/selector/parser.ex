defmodule Selector.Parser do
  @moduledoc """
  Parser for CSS selectors.
  """

  @doc """
  Parses a CSS selector string into an AST.
  Accepts an optional keyword list of options.
  """
  def parse(selectors, opts \\ []) when is_binary(selectors) do
    case Selector.Parser.Selector.parse(selectors, [], opts) do
      {selector_list, ""} -> selector_list
      {_selector_list, selectors} -> raise ArgumentError, "Cannot parse: #{selectors}"
    end
  end
end
