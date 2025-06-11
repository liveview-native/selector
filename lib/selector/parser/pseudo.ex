defmodule Selector.Parser.Pseudo do
  @moduledoc false

  import Selector.Parser.Guards

  alias Selector.Parser.Pseudo.{
    LanguageCode,
    Name,
    Nth,
    Selector,
    SelectorList
  }

  @pseudo_classes [
    "active",
    "checked",
    "disabled",
    "enabled",
    "focus",
    "focus-visible",
    "focus-within",
    "hover",
    "invalid",
    "read-only",
    "read-write",
    "required",
    "valid",
    "visited",
    "first-child",
    "last-child",
    "only-child",
    "nth-child",
    "nth-last-child",
    "first-of-type",
    "last-of-type",
    "only-of-type",
    "nth-of-type",
    "nth-last-of-type",
    "lang",
    "empty",
    "target",
    "in-2viewport",
    "has",
    "is",
    "where",
    "not",
    "link",
    "first-child",  # Obsolete
    "last-child",   # Obsolete
    "autofill",
    "placeholder-shown",
    "default",
    "indeterminate",
    "-webkit-full-screen",
    "-moz-focusring",
    "-moz-placeholder",
    "-ms-input-placeholder"
  ]

  def classes, do: @pseudo_classes

  @pseudo_elements [
    "first-letter",
    "first-line",
    "selection",
    "before",
    "after",
    "marker",
    "placeholder",
    "autofill",
    "file-selector-button",
    "spelling-error",
    "grammar-error",
    "first-letter",  # Obsolete
    "first-line",    # Obsolete
    "before",        # Obsolete
    "after",         # Obsolete
    "-webkit-scrollbar",
    "-webkit-scrollbar-thumb",
    "-webkit-scrollbar-track",
    "-moz-focus-inner",
    "-ms-clear",
    "-ms-reveal"
  ]

  def elements, do: @pseudo_elements

  def parse(<<char::utf8, rest::binary>>, opts) when is_pseudo_start_char(char) do
    parse_name(rest, [char], opts)
  end

  defp parse_name(<<"("::utf8, selectors::binary>>, name, opts) do
    name = List.to_string(name)
    {params, selectors} = parse_params(selectors, name, [], opts)
    
    {{name, params}, selectors}
  end

  defp parse_name(<<char::utf8, selectors::binary>>, name, opts) when is_pseudo_char(char) do
    parse_name(selectors, [name, char], opts)
  end

  defp parse_name(selectors, name, _opts) do
    {{List.to_string(name), []}, selectors}
  end
  
  defp parse_params(<<")"::utf8, selectors::binary>>, _name, params, _opts) do
    {params, selectors}
  end

  defp parse_params(<<char::utf8, selectors::binary>>, name, params, opts) when name in ~w(nth-child nth-last-child nth-of-type nth-last-of-type nth-line nth-col) do
    {params, selectors} = Nth.parse(selectors, [char], name, opts)
    parse_params(selectors, name, params, opts)
  end

  defp parse_params(<<char::utf8, selectors::binary>>, name, params, opts) when name in ~w(not has slotted) do
    {params, selectors} = Selector.parse(selectors, name, opts)
    parse_params(selectors, name, params, opts)
  end

  defp parse_params(<<char::utf8, selectors::binary>>, name, params, opts) when name in ~w(is where) do
    {params, selectors} = SelectorList.parse(selectors, name, opts)
    parse_params(selectors, name, params, opts)
  end

  defp parse_params(<<char::utf8, selectors::binary>>, name, params, opts) when name in ~w(lang) do
    {params, selectors} = LanguageCode.parse(selectors, name, opts)
    parse_params(selectors, name, params, opts)
  end

  defp parse_params(<<char::utf8, selectors::binary>>, name, params, opts) when name in ~w(part) do
    {params, selectors} = Name.parse(selectors, name, opts)
    parse_params(selectors, name, params, opts)
  end

  defp parse_params(_selectors, name, _params, _opts) do
    raise ArgumentError, "Pseudo #{name} cannot take params"
  end
end
