defmodule Selector do
  @moduledoc """
  A CSS selector parser and renderer for Elixir.

  This library provides functionality to parse CSS selector strings into an
  Abstract Syntax Tree (AST) and render them back to CSS strings. It supports
  CSS Selectors Level 1, 2, and 3 completely, with partial support for stable
  CSS Selectors Level 4 features.

  ## Features

  - Parse CSS selectors into a structured AST
  - Render AST back to CSS selector strings
  - Support for all CSS3 selectors and many CSS4 features
  - Namespace support for XML/SVG elements
  - Strict and non-strict parsing modes

  ## Basic Usage

      # Parse a CSS selector
      ast = Selector.parse("div#main > p.text")
      
      # Render AST back to CSS
      css = Selector.render(ast)

  ## Supported Selectors

  - Type selectors: `div`, `span`, `p`
  - Class selectors: `.class`, `.multiple.classes`
  - ID selectors: `#id`
  - Universal selector: `*`
  - Attribute selectors: `[attr]`, `[attr=value]`, `[attr^=prefix]`
  - Pseudo-classes: `:hover`, `:nth-child(2n+1)`, `:not(.active)`
  - Pseudo-elements: `::before`, `::after`, `::first-line`
  - Combinators: descendant (` `), child (`>`), adjacent (`+`), general sibling (`~`), column (`||`)
  - Namespaces: `svg|rect`, `*|*`, `|div`

  See the README for comprehensive documentation and examples.
  """

  alias Selector.{
    Parser,
    Renderer
  }

  @doc """
  Parses a CSS selector string into an Abstract Syntax Tree (AST).

  ## Parameters

    * `selector` - A CSS selector string to parse
    * `opts` - Optional keyword list of parsing options (default: `[]`)

  ## Options

    * `:strict` - When `true` (default), enforces strict CSS parsing rules.
      When `false`, allows some non-standard but commonly used patterns like 
      identifiers starting with double hyphens (`--`).

  ## Returns

  Returns a tuple `{:selectors, [selector_groups]}` representing the parsed selector AST.
  Each selector group is `{:rules, [rules]}` and each rule has the format 
  `{:rule, selectors, options}` where:

    * `selectors` is a list of selector components (tags, classes, IDs, etc.)
    * `options` is a keyword list containing combinator information

  ## Examples

  Basic selectors:

      iex> Selector.parse("div")
      {:selectors, [{:rules, [{:rule, [{:tag_name, "div", []}], []}]}]}

      iex> Selector.parse("#header")
      {:selectors, [{:rules, [{:rule, [{:id, "header"}], []}]}]}

      iex> Selector.parse(".button")
      {:selectors, [{:rules, [{:rule, [{:class, "button"}], []}]}]}

  Complex selectors:

      iex> Selector.parse("div#main.container[data-role='navigation']")
      {:selectors, [{:rules, [{:rule, [
        {:tag_name, "div", []},
        {:id, "main"},
        {:class, "container"},
        {:attribute, {:equal, "data-role", "navigation", []}}
      ], []}]}]}

  Multiple selectors:

      iex> Selector.parse("h1, h2, h3")
      {:selectors, [
        {:rules, [{:rule, [{:tag_name, "h1", []}], []}]},
        {:rules, [{:rule, [{:tag_name, "h2", []}], []}]},
        {:rules, [{:rule, [{:tag_name, "h3", []}], []}]}
      ]}

  Combinators:

      iex> Selector.parse("article > p")
      {:selectors, [{:rules, [
        {:rule, [{:tag_name, "article", []}], []},
        {:rule, [{:tag_name, "p", []}], combinator: ">"}
      ]}]}

  Pseudo-classes with arguments:

      iex> Selector.parse(":nth-child(2n+1)")
      {:selectors, [{:rules, [{:rule, [{:pseudo_class, {"nth-child", [[a: 2, b: 1]]}}], []}]}]}

      iex> Selector.parse(":not(.active)")
      {:selectors, [{:rules, [{:rule, [{:pseudo_class, {"not", [
        [{:rules, [{:rule, [{:class, "active"}], []}]}]
      ]}}], []}]}]}

  With options:

      iex> Selector.parse("#--custom-id", strict: false)
      {:selectors, [{:rules, [{:rule, [{:id, "--custom-id"}], []}]}]}

  ## Error Handling

  Raises `ArgumentError` for invalid CSS selectors:

      iex> Selector.parse(".")
      ** (ArgumentError) Expected class name.

      iex> Selector.parse("#")
      ** (ArgumentError) Expected identifier.

      iex> Selector.parse("div >")
      ** (ArgumentError) Expected rule but end of input reached.

  ## Supported CSS Features

  This parser supports CSS Selectors Level 3 completely and many stable 
  features from CSS Selectors Level 4:

    * Basic selectors: type, class, ID, universal (`*`)
    * Attribute selectors with all operators and case-sensitivity flags
    * All combinators including the column combinator (`||`)
    * Pseudo-classes including `:is()`, `:where()`, `:has()`, `:not()`
    * Pseudo-elements with both `::` and legacy `:` syntax
    * Namespaced selectors
    * Complex nested selectors
    * Escaped characters and Unicode

  See the project README for comprehensive examples and use cases.
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
