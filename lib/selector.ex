defmodule Selector do
  alias Selector.{
    Parser,
    Renderer
  }

  def parser(selector) do
    Parser.parse(selector)
  end

  def render(selectors) do
    Renderer.render(selectors)
  end
end
