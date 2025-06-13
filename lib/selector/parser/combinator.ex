defmodule Selector.Parser.Combinator do
  @moduledoc false

  import Selector.Parser.Guards
  import Selector.Parser.Utils

  def parse(<<char::utf8, selectors::binary>>, opts) when is_whitespace(char) do
    selectors = drain_whitespace(selectors)
    parse(selectors, opts)
  end

  def parse(<<"||"::utf8, selectors::binary>>, _opts) do
    {[combinator: "||"], drain_whitespace(selectors)}
  end

  def parse(<<char::utf8, selectors::binary>>, _opts) when is_combinator_char(char) do
    {[combinator: List.to_string([char])], drain_whitespace(selectors)}
  end

  def parse(selectors, _opts) do
    {[], selectors}
  end
end
