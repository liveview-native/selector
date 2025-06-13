defmodule Selector.Parser.Pseudo.Name do
  @moduledoc false
  import Selector.Parser.Guards

  def parse(<<char::utf8, selectors::binary>>, [], opts) when is_identifier_start_char(char) do
    parse(selectors, [char], opts)
  end

  def parse(<<char::utf8, selectors::binary>>, name, opts) when is_identifier_start_char(char) do
    parse(selectors, [name, char], opts)
  end

  def parse(selectors, name, _opts) do
    {List.to_string(name), selectors}
  end
end
