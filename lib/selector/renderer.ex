defmodule Selector.Renderer do
  @moduledoc """
  Handles rendering of CSS selector ASTs back to CSS selector strings.
  """

  @doc """
  Renders a list of selector rules to a CSS selector string.

  ## Options

  * `:format` - The output format (not currently used)
  """
  def render(selectors, _opts \\ []) when is_list(selectors) do
    # Group selectors into comma-separated groups
    {groups, current} = selectors
    |> Enum.reduce({[], []}, fn
      # 2-tuple rule continues current selector chain
      {:rule, _, _} = rule, {groups, []} ->
        # Start of a new chain
        {groups, [rule]}
      {:rule, _} = rule, {groups, current} ->
        # Continue current chain
        {groups, current ++ [rule]}
      # 3-tuple rule starts a new selector group
      {:rule, _, _} = rule, {groups, current} when current != [] ->
        # End current chain and start new one
        {groups ++ [current], [rule]}
    end)
    
    # Add final group if exists
    all_groups = if current != [], do: groups ++ [current], else: groups
    
    # Render each group
    all_groups
    |> Enum.map(&render_selector_group/1)
    |> Enum.join(", ")
  end
  
  defp render_selector_group(rules) do
    rules
    |> Enum.with_index()
    |> Enum.map_join("", fn
      {{:rule, sel, opts}, 0} ->
        # First rule in group
        render_rule({:rule, sel, opts})
      {{:rule, sel}, _index} ->
        # Descendant selector (2-tuple)
        " " <> render_rule({:rule, sel, []})
      {{:rule, sel, opts}, _index} ->
        # Rule with combinator
        combinator = Keyword.get(opts, :combinator)
        case combinator do
          nil -> " " <> render_rule({:rule, sel, opts})
          ">" -> " > " <> render_rule({:rule, sel, opts})
          "+" -> " + " <> render_rule({:rule, sel, opts})
          "~" -> " ~ " <> render_rule({:rule, sel, opts})
          "||" -> " || " <> render_rule({:rule, sel, opts})
          _ -> " #{combinator} " <> render_rule({:rule, sel, opts})
        end
    end)
  end

  # Renders a single rule: {:rule, selectors, combinators}
  defp render_rule({:rule, selectors, []}) do
    selectors
    |> Enum.map_join("", &render_selector/1)
  end

  defp render_rule({:rule, selectors, [combinator: comb]}) do
    selectors
    |> Enum.map_join(" #{comb} ", &render_selector/1)
  end

  defp render_rule(other), do: inspect(other)


  # Renders individual selector components
  defp render_selector({:tag_name, name}) when is_binary(name) do
    if name == "*", do: "*", else: escape_name(name)
  end
  defp render_selector({:tag_name, name, namespace}) when is_binary(name) do
    # Don't escape * for wildcard namespace
    ns_part = if namespace == "*", do: "*", else: escape_name(namespace)
    name_part = if name == "*", do: "*", else: escape_name(name)
    "#{ns_part}|#{name_part}"
  end
  defp render_selector({:tag_name, name}) when is_list(name), do: escape_name(to_string(name))

  defp render_selector({:id, id}) when is_binary(id), do: "##{escape_id(id)}"
  defp render_selector({:class, class}) when is_binary(class), do: ".#{escape_class(class)}"
  defp render_selector({:class, class}) when is_list(class), do: ".#{escape_class(to_string(class))}"

  # Handle pseudo-classes
  defp render_selector({:pseudo_class, {name, []}}), do: ":#{atom_to_css_name(name)}"

  defp render_selector({:pseudo_class, {name, args}}) when is_list(args) do
    case args do
      [] -> ":#{name}"
      # Handle nth-child and similar with a/b notation
      [a: a_val, b: b_val] ->
        formatted = format_nth(a_val, b_val)
        ":#{atom_to_css_name(name)}(#{formatted})"
      # Handle string arguments (e.g., :lang)
      [arg] when is_binary(arg) ->
        # Escape closing parentheses in arguments
        escaped_arg = String.replace(arg, ")", "\\)")
        ":#{atom_to_css_name(name)}(#{escaped_arg})"
      # Handle multiple string arguments
      args when is_list(args) and is_binary(hd(args)) ->
        ":#{atom_to_css_name(name)}(#{Enum.join(args, " ")})"
      # Handle nested selectors
      _ ->
        ":#{atom_to_css_name(name)}(#{render_nested_rules(args)})"
    end
  end
  
  defp format_nth(0, b), do: "#{b}"
  defp format_nth(2, 0), do: "even"
  defp format_nth(2, 1), do: "odd"
  defp format_nth(a, 0) when a == 1, do: "n"
  defp format_nth(a, 0) when a == -1, do: "-n"
  defp format_nth(a, 0), do: "#{a}n"
  defp format_nth(a, b) when a == 1 and b > 0, do: "n+#{b}"
  defp format_nth(a, b) when a == 1 and b < 0, do: "n#{b}"
  defp format_nth(a, b) when a == -1 and b > 0, do: "-n+#{b}"
  defp format_nth(a, b) when a == -1 and b < 0, do: "-n#{b}"
  defp format_nth(a, b) when b > 0, do: "#{a}n+#{b}"
  defp format_nth(a, b), do: "#{a}n#{b}"

  # Handle pseudo-elements

  defp render_selector({:pseudo_element, {name, []}}), do: "::#{atom_to_css_name(name)}"
  
  defp render_selector({:pseudo_element, {name, [arg]}}) when is_binary(arg) do
    "::#{atom_to_css_name(name)}(#{arg})"
  end
  
  defp render_selector({:pseudo_element, {name, [nested_rules]}}) when is_list(nested_rules) do
    # Handle nested rules in pseudo-elements like ::part(button)
    inner = nested_rules
            |> List.flatten()
            |> Enum.map_join(" ", &render_rule/1)
    "::#{atom_to_css_name(name)}(#{String.trim(inner)})"
  end

  # Handle attribute selectors
  defp render_selector({:attribute, {:exists, name}}), do: "[#{escape_attr(name)}]"

  defp render_selector({:attribute, {op, name, value}}) do
    attr_op = case op do
      :equal -> "="
      :includes -> "~="
      :dash_match -> "|="
      :prefix -> "^="
      :suffix -> "$="
      :substring -> "*="
      _ -> "#{op}"
    end

    "[#{escape_attr(name)}#{attr_op}#{escape_attr_value(value)}]"
  end

  defp render_selector({:attribute, {op, name, value, opts}}) when is_list(opts) do
    attr_op = case op do
      :equal -> "="
      :includes -> "~="
      :dash_match -> "|="
      :prefix -> "^="
      :suffix -> "$="
      :substring -> "*="
      _ -> "#{op}"
    end

    # Extract case sensitivity flag
    case_flag = case Keyword.get(opts, :case_sensitive) do
      false -> " i"
      true -> " s"
      _ -> ""
    end

    "[#{escape_attr(name)}#{attr_op}#{escape_attr_value(value)}#{case_flag}]"
  end

  defp render_selector(other), do: inspect(other)

  # Helper functions
  # Define a function to check if a character needs escaping
  defp escape_char?(char) when char in ~w(! " # $ % & ' ( \) * + , . / ; < = > ? @ [ \\ ] ^ ` { | } ~), do: true
  defp escape_char?(":"), do: true
  defp escape_char?(_), do: false

  defp escape_name(name) when is_binary(name) do
    # Check if name starts with a digit or space - needs special escaping
    case name do
      <<digit, rest::binary>> when digit in ?0..?9 ->
        # Escape leading digit as hex with trailing space
        "\\3" <> <<digit>> <> " " <> escape_rest(rest)
      <<32, rest::binary>> ->
        # Escape leading space
        "\\20 " <> escape_rest(rest)
      _ ->
        if String.match?(name, ~r/^[a-zA-Z][a-zA-Z0-9_-]*$/) do
          name
        else
          # Escape special characters
          escape_rest(name)
        end
    end
  end
  
  defp escape_rest(str) do
    str
    |> String.graphemes()
    |> Enum.map_join(fn
      char -> if escape_char?(char), do: "\\#{char}", else: char
    end)
  end

  defp escape_id(id), do: escape_name(id)
  defp escape_class(class), do: escape_name(class)
  defp escape_attr(name), do: escape_name(name)

  defp escape_attr_value(value) when is_binary(value) do
    # Always use double quotes
    escaped = value
    |> String.replace("\\", "\\\\")
    |> String.replace("\"", "\\\"")
    "\"#{escaped}\""
  end

  defp render_nested_rule([rule]), do: render_nested_rule(rule)

  defp render_nested_rule({:rule, selectors, _}) do
    selectors
    |> Enum.map_join("", &render_selector/1)
  end

  defp render_nested_rule(other), do: inspect(other)
  
  defp render_nested_rules(rules) when is_list(rules) do
    rules
    |> Enum.map(fn
      [{:rule, _, _} | _] = group -> 
        # Handle groups - check if first rule has combinator
        case group do
          [{:rule, _, opts} | _] ->
            case Keyword.get(opts, :combinator) do
              nil -> render(group)
              comb -> "#{comb} #{render(group)}"
            end
          _ -> render(group)
        end
      {:rule, _, _} = rule -> render_rule(rule)
      other -> inspect(other)
    end)
    |> Enum.join(", ")
  end
  
  # Convert atom names to CSS names (underscores to hyphens)
  defp atom_to_css_name(atom) when is_atom(atom) do
    atom
    |> Atom.to_string()
    |> String.replace("_", "-")
  end
end
