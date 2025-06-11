defmodule Selector.Parser do
  @moduledoc """
  Parser for CSS selectors.
  """

  alias Selector.Parser.{
    Attribute,
    Class,
    ID,
    Pseudo,
    TagName
  }

  import Selector.Parser.Guards
  import Selector.Parser.Utils

  @doc """
  Parses a CSS selector string into an AST.
  Accepts an optional keyword list of options.
  """
  def parse(selectors, opts \\ []) when is_binary(selectors) do
    selectors = drain_whitespace(selectors)
    parse_segment(selectors, [], opts)
  end

  # this is meant specifically to close out
  # nested segments within pseudo params
  defp parse_segment(<<")"::utf8, selectors::binary>>, segments, _opts) do
    {Enum.reverse(segments), selectors}
  end

  defp parse_segment(<<char::utf8, selectors::binary>>, segments, opts) when is_whitespace(char) do
    selectors = drain_whitespace(selectors)
    parse_segment(selectors, segments, opts)
  end
  
  defp parse_segment(",", _segments, _opts) do
    raise ArgumentError, "Expected rule but end of input reached."
  end

  defp parse_segment(<<","::utf8, selectors::binary>>, segments, opts) do
    selectors = drain_whitespace(selectors)
    parse_segment(selectors, segments, opts)
  end

  defp parse_segment(<<char::utf8, _selectors::binary>> = selectors, segments, opts) when is_selector_start_char(char) do
    {rules, selectors} = parse_rule(selectors, [], opts)

    parse_segment(selectors, [{:rule, rules, []} | segments], opts)
  end
  
  defp parse_segment(<<>>, [], _opts) do
    raise ArgumentError, "Expected rule but end of input reached."
  end
  
  defp parse_segment(<<>>, segments, _opts) do
    Enum.reverse(segments)
  end
  
  defp parse_segment(_selectors, _segments, _opts) do
    raise ArgumentError, "Expected rule but end of input reached."
  end

  defp parse_rule(<<>>, rules, _opts) do
    {Enum.reverse(rules), ""}
  end

  defp parse_rule(<<","::utf8, selectors::binary>>, rules, _opts) do
    case drain_whitespace(selectors) do
      <<>> -> raise ArgumentError, "Expected rule but end of input reached."
      selectors -> {Enum.reverse(rules), selectors}
    end
  end

  defp parse_rule(<<"#"::utf8, selectors::binary>>, rules, opts) do
    {id, selectors} = ID.parse(selectors, [], opts)
    parse_rule(selectors, [{:id, id} | rules], opts)
  end

  defp parse_rule(<<"."::utf8, selectors::binary>>, rules, opts) do
    {class, selectors} = Class.parse(selectors, [], opts)
    parse_rule(selectors, [{:class, class} | rules], opts)
  end

  defp parse_rule(<<"*"::utf8, selectors::binary>>, rules, opts) do
    {tag_name, selectors, tag_opts} = TagName.parse(selectors, ["*"], opts)
    parse_rule(selectors, [{:tag_name, tag_name, tag_opts} | rules], opts)
  end
LL
  defp parse_rule(<<"\\*"::utf8, selectors::binary>>, rules, opts) do
    {tag_name, selectors, tag_opts} = TagName.parse(selectors, ["*"], opts)
    parse_rule(selectors, [{:tag_name, tag_name, tag_opts} | rules], opts)
  end

  defp parse_rule(<<"|"::utf8, selectors::binary>>, rules, opts) do
    {tag_name, selectors, tag_opts} = TagName.parse(List.to_string([?|, selectors]), [], opts)
    parse_rule(selectors, [{:tag_name, tag_name, tag_opts} | rules], opts)
  end

  defp parse_rule(<<"\\|"::utf8, selectors::binary>>, rules, opts) do
    {tag_name, selectors, tag_opts} = TagName.parse(List.to_string([~c"\\|", selectors]), [], opts)
    parse_rule(selectors, [{:tag_name, tag_name, tag_opts} | rules], opts)
  end

  defp parse_rule(<<char::utf8, selectors::binary>>, rules, opts) when is_tag_name_start_char(char) do
    {tag_name, selectors, tag_opts} = TagName.parse(selectors, [char], opts)
    parse_rule(selectors, [{:tag_name, tag_name, tag_opts} | rules], opts)
  end

  defp parse_rule(<<"["::utf8, selectors::binary>>, rules, opts) do
    {attribute, selectors} = Attribute.parse(selectors, nil, opts)
    parse_rule(selectors, [{:attribute, attribute} | rules], opts)
  end

  defp parse_rule(<<"::"::utf8, selectors::binary>>, rules, opts) do
    {pseudo_element, remaining} = Pseudo.parse(selectors, opts)
    parse_rule(remaining, [{:pseudo_element, pseudo_element} | rules], opts)
  end

  # Legacy CSS Level 2 support for single-colon pseduo elements
 
  defp parse_rule(<<":before"::utf8, rest::binary>>, rules, opts) do
    {pseudo, remaining} = Pseudo.parse(rest, opts)
    parse_rule(remaining, [{:pseudo_element, pseudo} | rules], opts)
  end
 
  defp parse_rule(<<":after"::utf8, rest::binary>>, rules, opts) do
    {pseudo, remaining} = Pseudo.parse(rest, opts)
    parse_rule(remaining, [{:pseudo_element, pseudo} | rules], opts)
  end
 
  defp parse_rule(<<":first-line"::utf8, rest::binary>>, rules, opts) do
    {pseudo, remaining} = Pseudo.parse(rest, opts)
    parse_rule(remaining, [{:pseudo_element, pseudo} | rules], opts)
  end
 
  defp parse_rule(<<":first-letter"::utf8, rest::binary>>, rules, opts) do
    {pseudo, remaining} = Pseudo.parse(rest, opts)
    parse_rule(remaining, [{:pseudo_element, pseudo} | rules], opts)
  end

  defp parse_rule(<<":"::utf8, rest::binary>>, rules, opts) do
    {pseudo, remaining} = Pseudo.parse(rest, opts)
    parse_rule(remaining, [{:pseudo_class, pseudo} | rules], opts)
  end

  defp parse_rule(<<char::utf8, selectors::binary>>, rules, opts) when is_whitespace(char) do
    parse_rule(selectors, rules, opts)
  end

  defp parse_rule(_selectors, _rules, _opts) do
    raise ArgumentError, "Expected rule but end of input reached."
  end
end
