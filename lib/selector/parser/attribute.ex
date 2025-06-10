defmodule Selector.Parser.Attribute do
  @moduledoc false

  import Selector.Parser.Guards

  def parse(<<>>, _rule, _opts) do
    raise ArgumentError, "Expected closing bracket."
  end

  def parse(<<"]"::utf8, _selectors::binary>>, nil, _opts) do
    raise ArgumentError, "Expected attribute name."
  end

  def parse(<<"]"::utf8, selectors::binary>>, rule, _opts) do
    {rule, selectors}
  end

  def parse(<<char::utf8, selectors::binary>>, rule, opts) when is_whitespace(char) do
    parse(selectors, rule, opts)
  end

  def parse(<<"="::utf8, _selectors::binary>>, _rule, _opts) do
    raise ArgumentError, "Expected attribute name."
  end

  def parse(<<"|"::utf8, selectors::binary>>, nil, opts) do
    parse(selectors, nil, Keyword.put(opts, :namespace, ""))
  end

  def parse(<<"*"::utf8, selectors::binary>>, nil, opts) do
    {rule, selectors} = parse_wildcard_namespace_then_name(selectors, opts)

    parse(selectors, rule, opts)
  end

  def parse(<<char::utf8, selectors::binary>>, nil, opts) when is_attribute_name_start_char(char) do
    {rule, selectors} = parse_attribute_exists(selectors, [char], opts)

    parse(selectors, rule, opts)
  end

  def parse(<<"\\"::utf8, char::utf8, selectors::binary>>, {type, name, value, modifiers}, opts) when char in [?i, ?I] do
    rule = {type, name, value, Keyword.put(modifiers, :case_sensitive, false)}
    parse(selectors, rule, opts)
  end

  def parse(<<char::utf8, selectors::binary>>, {type, name, value, modifiers}, opts) when char in [?i, ?I] do
    rule = {type, name, value, Keyword.put(modifiers, :case_sensitive, false)}
    parse(selectors, rule, opts)
  end

  def parse(<<"\\"::utf8, char::utf8, selectors::binary>>, {type, name, value, modifiers}, opts) when char in [?s, ?S] do
    rule = {type, name, value, Keyword.put(modifiers, :case_sensitive, true)}
    parse(selectors, rule, opts)
  end

  def parse(<<char::utf8, selectors::binary>>, {type, name, value, modifiers}, opts) when char in [?s, ?S] do
    rule = {type, name, value, Keyword.put(modifiers, :case_sensitive, true)}
    parse(selectors, rule, opts)
  end

  def parse(_selectors, _rule, _opts) do
    raise ArgumentError, "Expected attribute name."
  end

  defp parse_attribute_exists(<<>>, _buffer, _opts) do
    raise ArgumentError, "Expected closing bracket."
  end

  defp parse_attribute_exists(<<"^="::utf8, selectors::binary>>, name, opts) do
    {value, selectors, opts} = parse_attribute_value_outter(selectors, opts)
    {{:prefix, name, value, extract_valid_opts(opts)}, selectors}
  end

  defp parse_attribute_exists(<<"$="::utf8, selectors::binary>>, name, opts) do
    {value, selectors, opts} = parse_attribute_value_outter(selectors, opts)
    {{:suffix, name, value, extract_valid_opts(opts)}, selectors}
  end

  defp parse_attribute_exists(<<"*="::utf8, selectors::binary>>, name, opts) do
    {value, selectors, opts} = parse_attribute_value_outter(selectors, opts)
    {{:substring, name, value, extract_valid_opts(opts)}, selectors}
  end

  defp parse_attribute_exists(<<"~="::utf8, selectors::binary>>, name, opts) do
    {value, selectors, opts} = parse_attribute_value_outter(selectors, opts)
    {{:includes, name, value, extract_valid_opts(opts)}, selectors}
  end

  defp parse_attribute_exists(<<"|="::utf8, selectors::binary>>, name, opts) do
    {value, selectors, opts} = parse_attribute_value_outter(selectors, opts)
    {{:dash_match, name, value, extract_valid_opts(opts)}, selectors}
  end

  defp parse_attribute_exists(<<"="::utf8, selectors::binary>>, name, opts) do
    {value, selectors, opts} = parse_attribute_value_outter(selectors, opts)
    {{:equal, name, value, extract_valid_opts(opts)}, selectors}
  end

  defp parse_attribute_exists(<<char::utf8, selectors::binary>>, ~c"|", opts) do
    {name, selectors, opts} = parse_attribute_name(selectors, [char], Keyword.put(opts, :namespace, ""))
    parse_attribute_exists(selectors, name, opts)
  end

  defp parse_attribute_exists(<<char::utf8, selectors::binary>>, name, opts) when is_attribute_name_char(char) do
    {name, selectors, opts} = parse_attribute_name(selectors, [name, char], opts)
    parse_attribute_exists(selectors, name, opts)
  end

  defp parse_attribute_exists(selectors, buffer, opts) do
    {{:exists, buffer, nil, extract_valid_opts(opts)}, selectors}
  end

  defp parse_wildcard_namespace_then_name(<<char::utf8, selectors::binary>>, opts) when is_whitespace(char) do
    parse_wildcard_namespace_then_name(selectors, opts)
  end

  defp parse_wildcard_namespace_then_name(<<"|"::utf8, selectors::binary>>, opts) do
    parse_attribute_exists(selectors, [], Keyword.put(opts, :namespace, "*"))
  end

  defp parse_attribute_name(<<"|="::utf8, _selectors::binary>>, [], _opts) do
    raise ArgumentError, "Expected attributed name."
  end

  defp parse_attribute_name(<<"|="::utf8, _selectors::binary>> = selectors, name, opts) do
    {List.to_string(name), selectors, opts}
  end

  defp parse_attribute_name(<<"|"::utf8, selectors::binary>>, namespace, opts) do
    parse_attribute_name(selectors, [], Keyword.put(opts, :namespace, List.to_string(namespace)))
  end

  defp parse_attribute_name(<<"\\"::utf8, char::utf8, selectors::binary>>, name, opts) when is_escapable_char(char) do
    parse_attribute_name(selectors, [name, char], opts)
  end

  defp parse_attribute_name(<<char::utf8, selectors::binary>>, name, opts) when is_whitespace(char) do
    parse_attribute_name(selectors, name, opts)
  end

  defp parse_attribute_name(<<char::utf8, selectors::binary>>, name, opts) when is_attribute_name_char(char) do
    parse_attribute_name(selectors, [name, char], opts)
  end

  defp parse_attribute_name(selectors, name, opts) do
    {List.to_string(name), selectors, opts}
  end

  defp parse_attribute_value_outter(<<"]"::utf8, _selectors::binary>>, _opts) do
    raise ArgumentError, "Expected attribute value."
  end

  defp parse_attribute_value_outter(<<>>, _opts) do
    raise ArgumentError, "Expected closing bracket."
  end

  defp parse_attribute_value_outter(<<char::utf8, selectors::binary>>, opts) when is_attribute_value_char(char) do
    parse_attribute_value_inner(selectors, [char], ?\s, opts)
  end

  defp parse_attribute_value_outter(<<char::utf8, selectors::binary>>, opts) when char in [?', ?"] do
    parse_attribute_value_inner(selectors, [], char, opts)
  end

  defp parse_attribute_value_outter(<<char::utf8, selectors::binary>>, opts) when is_whitespace(char) do
    parse_attribute_value_outter(selectors, opts)
  end

  defp parse_attribute_value_inner(<<>>, _value, _delim, _opts) do
    raise ArgumentError, "Expected closing deliminator"
  end

  defp parse_attribute_value_inner(<<delim::utf8, selectors::binary>>, value, delim, opts) when delim in [?', ?", ?\s] do
    {List.to_string(value), selectors, opts}
  end

  defp parse_attribute_value_inner(<<char::utf8, selectors::binary>>, value, delim, opts) when is_whitespace(char) do
    parse_attribute_value_inner(selectors, value, delim, opts)
  end

  defp parse_attribute_value_inner(<<"\\"::utf8, char::utf8, selectors::binary>>, value, delim, opts) when is_hex_digit(char) do
    {hex, selectors} = Selector.Parser.Hex.parse(List.to_string([char, selectors]), opts)
    parse_attribute_value_inner(selectors, [value, hex], delim, opts)
  end

  defp parse_attribute_value_inner(<<"\\"::utf8, "\n"::utf8, selectors::binary>>, value, delim, opts) do
    parse_attribute_value_inner(selectors, value, delim, opts)
  end

  defp parse_attribute_value_inner(<<"\\"::utf8, char::utf8, selectors::binary>>, value, delim, opts) when is_escapable_char(char) do
    parse_attribute_value_inner(selectors, [value, char], delim, opts)
  end

  defp parse_attribute_value_inner(<<char::utf8, selectors::binary>>, value, delim, opts) when is_attribute_value_char(char) do
    parse_attribute_value_inner(selectors, [value, char], delim, opts)
  end

  defp parse_attribute_value_inner(<<"]"::utf8, _selectors::binary>>, [], _delim, _opts) do
    raise ArgumentError, "Expected attribute value."
  end

  defp parse_attribute_value_inner(selectors, value, _delim, opts) do
    {List.to_string(value), selectors, opts}
  end

  defp extract_valid_opts(opts) do
    Keyword.take(opts, [
      :case_sensitive,
      :namespace,
    ])
  end
end
