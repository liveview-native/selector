defmodule Selector do
  alias Selector.{
    Parser,
    Renderer
  }

  @doc """
  Parses a CSS selector string into an AST.
  """
  def parse(selector, opts \\ []) do
    Parser.parse(selector, opts)
  end

  @doc """
  Renders a selector AST back to a CSS selector string.
  """
  def render(selectors, opts \\ []) do
    Renderer.render(selectors, opts)
  end
end
