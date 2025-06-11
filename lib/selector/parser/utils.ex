defmodule Selector.Parser.Utils do
  @moduledoc false
  import Selector.Parser.Guards

  def drain_whitespace(<<char::utf8, selectors::binary>>) when is_whitespace(char),
    do: drain_whitespace(selectors)
  def drain_whitespace(selectors), do: selectors
end
