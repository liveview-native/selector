defmodule Selector.Parser.Pseudo.NthFormula do
  @moduledoc false

  import Selector.Parser.Guards
  import Selector.Parser.Utils

  def parse(<<"even"::utf8, selectors::binary>>, _opts) do
    {[a: 2, b: 0], selectors}
  end

  def parse(<<"odd"::utf8, selectors::binary>>, _opts) do
    {[a: 2, b: 1], selectors}
  end

  def parse(<<char::utf8, _selectors::binary>> = selectors, opts) when is_nth_formula_starting_char(char) do
    case parse_an_plus_b(selectors, opts) do
      # yes, it's a hack
      {[b: b, a: a], selectors} -> {[a: a, b: b], selectors}
      result -> result
    end
  end

  defp parse_an_plus_b(selectors, opts) do
    parse_coefficient(selectors, [a: 1, b: 0], opts)
  end

  defp parse_coefficient(selectors, formula, opts) do
    {formula, selectors} = parse_coefficient_sign(selectors, formula, opts)
    {formula, selectors} = parse_coefficient_number(selectors, formula,  opts)

    parse_variable(selectors, formula, opts)
  end

  defp parse_coefficient_sign(<<"+"::utf8, selectors::binary>>, formula, _opts) do
    {formula, selectors}
  end

  defp parse_coefficient_sign(<<"-"::utf8, selectors::binary>>, formula, _opts) do
    formula = Keyword.put(formula, :a, -1)
    {formula, selectors}
  end

  defp parse_coefficient_sign(selectors, formula, _opts) do
    {formula, selectors}
  end

  defp parse_coefficient_number(selectors, formula, opts) do
    {number, selectors} = parse_number(selectors, nil, opts)
    formula = Keyword.update(formula, :a, 1, &(&1 * (number || 1)))
    {formula, selectors}
  end

  defp parse_number(<<char::utf8, selectors::binary>>, number, opts) when char in ?0..?9 do
    number = (number || 0 * 10) + (char - ?0)
    parse_number(selectors, number, opts)
  end

  defp parse_number(selectors, number, _opts) do
    {number, selectors}
  end

  defp parse_variable(<<"n"::utf8, selectors::binary>>, formula, opts) do
    parse_operator(selectors, formula, opts)
  end

  defp parse_variable(selectors, formula, _opts) do
    formula = [a: 0, b: Keyword.get(formula, :a)]
    {formula, selectors}
  end

  defp parse_operator(<<char::utf8, selectors::binary>>, formula, opts) when is_whitespace(char) do
    selectors = drain_whitespace(selectors)
    parse_operator(selectors, formula, opts)
  end

  defp parse_operator(<<"+"::utf8, selectors::binary>>, formula, opts) do
    parse_offset(selectors, Keyword.put(formula, :b, 1), 0, opts)
  end

  defp parse_operator(<<"-"::utf8, selectors::binary>>, formula, opts) do
    parse_offset(selectors, Keyword.put(formula, :b, -1), 0, opts)
  end

  defp parse_operator(selectors, formula, opts) do
    parse_offset(selectors, formula, 0, opts)
  end

  defp parse_offset(<<char::utf8, selectors::binary>>, formula, offset, opts) when is_whitespace(char) do
    selectors = drain_whitespace(selectors)
    parse_offset(selectors, formula, offset, opts)
  end

  defp parse_offset(<<char::utf8, selectors::binary>>, formula, offset, opts) when char in ?0..?9 do
    offset = (offset * 10) + (char - ?0)
    parse_offset(selectors, formula, offset, opts)
  end

  defp parse_offset(selectors, formula, number, _opts) do
    formula = Keyword.update(formula, :b, 1, &(&1 * number))
    {formula, selectors}
  end
end
