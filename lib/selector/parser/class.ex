defmodule Selector.Parser.Class do
  import Selector.Parser.Guards

  def parse(<<"\\"::utf8, char::utf8, selectors::binary>>, class, opts) when is_escapable_char(char) do
    parse(selectors, [class, char], opts)
  end

  def parse(<<char::utf8, selectors::binary>>, [], opts) when is_class_start_char(char) do
    parse(selectors, [char], opts)
  end

  def parse(<<char::utf8, selectors::binary>>, class, opts) when class != [] and is_class_char(char) do
    parse(selectors, [class, char], opts)
  end

  def parse(_selectors, [], _opts) do
    raise ArgumentError, "Expected class name."
  end

  def parse(selectors, class, _opts) do
    {List.to_string(class), selectors}
  end
end
