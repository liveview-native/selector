defmodule Selector.Parser.Pseudo.Name do
  @moduledoc false
  import Selector.Parser.Guards
  import Selector.Parser.Utils

  def parse(<<char::utf8, selectors::binary>>, name, opts) when is_whitespace(char) do
    selectors = drain_whitespace(selectors)
    parse(selectors, name, opts)
  end

  def parse(<<char::utf8, selectors::binary>>, name, opts) when is_identifier_char(char) do
    parse(selectors, [name, char], opts)
  end

  def parse(selectors, name, _opts) do
    {List.to_string(name), selectors}
  end
end
