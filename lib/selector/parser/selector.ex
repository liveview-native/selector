defmodule Selector.Parser.Selector do
  @moduledoc false

  alias Selector.Parser.{
    Attribute,
    Class,
    Combinator,
    ID,
    Pseudo,
    TagName
  }

  import Selector.Parser.Guards
  import Selector.Parser.Utils

  def parse(<<char::utf8, selectors::binary>>, selector_list, opts) when is_whitespace(char) do
    selectors = drain_whitespace(selectors)
    parse(selectors, selector_list, opts)
  end

  def parse(<<","::utf8, selectors::binary>>, selector_list, opts) do
    case drain_whitespace(selectors) do
      <<>> -> raise ArgumentError, "Expected selector but end of input reached."
      selectors -> parse(selectors, selector_list, opts)
    end
  end

  def parse(<<>>, selector_list, _opts) do
    {Enum.reverse(selector_list), ""}
  end

  def parse(<<char::utf8, _selectors::binary>> = selectors, selector_list, opts) when is_selector_start_char(char) do
    {selector, selectors} = parse_rules(selectors, [], opts)
    parse(selectors, [{:rules, selector} | selector_list], opts)
  end

  def parse(selectors, selector_list, _opts) do
    {Enum.reverse(selector_list), selectors}
  end
  
  defp parse_rules(<<>>, [], _opts) do
    raise ArgumentError, "Expected rule but end of input reached."
  end
  
  defp parse_rules(<<>>, rules, _opts) do
    {Enum.reverse(rules), ""}
  end

  defp parse_rules(<<char::utf8, selectors::binary>>, rules, _opts) when is_whitespace(char) do
    selectors = drain_whitespace(selectors)
    {Enum.reverse(rules), selectors}
  end

  defp parse_rules(<<char::utf8, _selectors::binary>> = selectors, rules, opts) when is_selector_start_char(char) do
    {rule, selectors} = parse_rule(selectors, [], opts)
    {combinator, opts} = Keyword.split(opts, [:combinator])

    {new_combinator, selectors} = Combinator.parse(selectors, opts)

    opts = Keyword.merge(opts, new_combinator)

    parse_rules(selectors, [{:rule, rule, combinator} | rules], opts)
  end

  defp parse_rules(selectors, rules, _opts) do
    {Enum.reverse(rules), selectors}
  end

  defp parse_rule(<<>>, rule, _opts) do
    {Enum.reverse(rule), ""}
  end

  defp parse_rule(<<"#"::utf8, selectors::binary>>, rule, opts) do
    {id, selectors} = ID.parse(selectors, [], opts)
    parse_rule(selectors, [{:id, id} | rule], opts)
  end

  defp parse_rule(<<"."::utf8, selectors::binary>>, rule, opts) do
    {class, selectors} = Class.parse(selectors, [], opts)
    parse_rule(selectors, [{:class, class} | rule], opts)
  end

  defp parse_rule(<<"*"::utf8, selectors::binary>>, rule, opts) do
    {tag_name, selectors, tag_opts} = TagName.parse(selectors, ["*"], opts)
    parse_rule(selectors, [{:tag_name, tag_name, tag_opts} | rule], opts)
  end

  defp parse_rule(<<"\\*"::utf8, selectors::binary>>, rule, opts) do
    {tag_name, selectors, tag_opts} = TagName.parse(selectors, ["*"], opts)
    parse_rule(selectors, [{:tag_name, tag_name, tag_opts} | rule], opts)
  end

  defp parse_rule(<<"|"::utf8, char::utf8, selectors::binary>>, rule, opts) when char != ?| do
    {tag_name, selectors, tag_opts} = TagName.parse(List.to_string([?|, List.to_string([char, selectors])]), [], opts)
    parse_rule(selectors, [{:tag_name, tag_name, tag_opts} | rule], opts)
  end

  defp parse_rule(<<"\\|"::utf8, selectors::binary>>, rule, opts) do
    {tag_name, selectors, tag_opts} = TagName.parse(List.to_string([~c"\\|", selectors]), [], opts)
    parse_rule(selectors, [{:tag_name, tag_name, tag_opts} | rule], opts)
  end

  defp parse_rule(<<char::utf8, selectors::binary>>, rule, opts) when is_tag_name_start_char(char) do
    {tag_name, selectors, tag_opts} = TagName.parse(selectors, [char], opts)
    parse_rule(selectors, [{:tag_name, tag_name, tag_opts} | rule], opts)
  end

  defp parse_rule(<<"["::utf8, selectors::binary>>, rule, opts) do
    {attribute, selectors} = Attribute.parse(selectors, nil, opts)
    parse_rule(selectors, [{:attribute, attribute} | rule], opts)
  end

  defp parse_rule(<<"::"::utf8, selectors::binary>>, rule, opts) do
    {{pseudo_name, _} = pseudo_element, remaining} = Pseudo.parse(selectors, opts)

    if pseudo_name not in Selector.Parser.Pseudo.elements() do
      raise ArgumentError, "Invalid pseudo-element syntax."
    end

    parse_rule(remaining, [{:pseudo_element, pseudo_element} | rule], opts)
  end

  # Legacy CSS Level 2 support for single-colon pseduo elements
 
  defp parse_rule(<<":before"::utf8, selectors::binary>>, rule, opts) do
    parse_rule(selectors, [{:pseudo_element, {"before", []}} | rule], opts)
  end
 
  defp parse_rule(<<":after"::utf8, selectors::binary>>, rule, opts) do
    parse_rule(selectors, [{:pseudo_element, {"after", []}} | rule], opts)
  end
 
  defp parse_rule(<<":first-line"::utf8, selectors::binary>>, rule, opts) do
    parse_rule(selectors, [{:pseudo_element, {"first-line", []}} | rule], opts)
  end
 
  defp parse_rule(<<":first-letter"::utf8, selectors::binary>>, rule, opts) do
    parse_rule(selectors, [{:pseudo_element, {"first-letter", []}} | rule], opts)
  end

  defp parse_rule(<<":-"::utf8, _selectors::binary>>, _rule, _opts) do
    raise ArgumentError, "Identifiers cannot consist of a single hyphen."
  end

  defp parse_rule(<<":"::utf8, selectors::binary>>, rule, opts) do
    {{pseudo_name, _} = pseudo_class, selectors} = Pseudo.parse(selectors, opts)

    if pseudo_name not in Selector.Parser.Pseudo.classes() do
      raise ArgumentError, "Invalid pseudo-class syntax."
    end

    parse_rule(selectors, [{:pseudo_class, pseudo_class} | rule], opts)
  end

  defp parse_rule(selectors, rule, _opts) do
    {Enum.reverse(rule), selectors}
  end
end

