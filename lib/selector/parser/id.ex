defmodule Selector.Parser.ID do
  @moduledoc false

  import Selector.Parser.Guards

  def parse(<<"-"::utf8, selectors::binary>>, [], opts) do
    {buffer, selectors} = parse_hyphen_identifier(selectors, ~c"-", opts)
    parse(selectors, buffer, opts)
  end

  def parse(<<char::utf8, selectors::binary>>, [], opts) when is_identifier_start_char(char) do
    parse(selectors, [char], opts)
  end

  def parse(<<char::utf8, selectors::binary>>, buffer, opts) when is_identifier_char(char) do
    parse(selectors, [buffer, char], opts)
  end

  def parse(<<"\\"::utf8, char::utf8, selectors::binary>>, buffer, opts) when is_hex_digit(char) do
    {hex_buffer, selectors} = Selector.Parser.Hex.parse(List.to_string([char, selectors]), opts)
    parse(selectors, [buffer, hex_buffer], opts)
  end

  def parse(<<"\\"::utf8, char::utf8, selectors::binary>>, buffer, opts) when is_escapable_char(char) do
    parse(selectors, [buffer, char], opts)
  end

  def parse(<<char::utf8, selectors::binary>>, buffer, opts) when is_whitespace(char) do
    parse(selectors, buffer, opts)
  end

  def parse(_selectors, ~c"-", _opts) do
    raise ArgumentError, "Identifiers cannot consist of a single hyphen."
  end

  def parse(_selectors, [], _opts) do
    raise ArgumentError, "Expected identifier."
  end

  def parse(selectors, buffer, _opts) do
    {List.to_string(buffer), selectors}
  end

  # This works because the default value passed in for `buffer` is always ~c"-"
  defp parse_hyphen_identifier(<<"-"::utf8, selectors::binary>>, buffer, opts) do
    case Keyword.get(opts, :strict, true) do
      true -> raise ArgumentError, "Identifiers cannot start with two hyphens with strict mode on."
      false -> parse_hyphen_identifier(selectors, [buffer, ?-], opts)
    end
  end

  defp parse_hyphen_identifier(<<number::utf8, _selectors::binary>>, _buffer, _opts) when is_utf8_digit(number) do
    raise ArgumentError, "Identifiers cannot start with hyphens followed by digits."
  end

  defp parse_hyphen_identifier(selectors, buffer, _opts) do
    {buffer, selectors}
  end

end
