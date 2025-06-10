defmodule Selector.Parser.Utils do
  import Selector.Parser.Guards

  def burn_whitespace(<<char::utf8, selectors::binary>>) when is_whitespace(char) do
    selectors
  end

  def burn_whitespace(selectors),
    do: selectors
end
