# 🎯 Selector

A CSS selector parser library for Elixir. Parses CSS selector strings into an Abstract Syntax Tree (AST) that can be analyzed, manipulated, and rendered back to CSS.

## ✨ Features

- **CSS Selectors Level 1** - Complete support
- **CSS Selectors Level 2** - Complete support
- **CSS Selectors Level 3** - Complete support
- **CSS Selectors Level 4** - Extensive support for stable features

## 🎨 CSS Compatibility

### CSS Selectors Level 1

| Feature | Status | Example |
|---------|--------|---------|
| Type selectors | ✅ | `h1`, `p`, `div` |
| Class selectors | ✅ | `.warning`, `.note` |
| ID selectors | ✅ | `#header`, `#footer` |
| Descendant combinator | ✅ | `div p`, `ul li` |
| `:link` pseudo-class | ✅ | `a:link` |
| `:visited` pseudo-class | ✅ | `a:visited` |
| `:active` pseudo-class | ✅ | `a:active` |
| `::first-line` pseudo-element | ✅ | `p::first-line` |
| `::first-letter` pseudo-element | ✅ | `p::first-letter` |
| Multiple selectors (grouping) | ✅ | `h1, h2, h3` |

### CSS Selectors Level 2

| Feature | Status | Example |
|---------|--------|---------|
| Universal selector | ✅ | `*` |
| Attribute selectors | ✅ | `[title]`, `[class="example"]` |
| Attribute operators | ✅ | `[class~="warning"]`, `[lang\\|="en"]` |
| Child combinator | ✅ | `body > p` |
| Adjacent sibling combinator | ✅ | `h1 + p` |
| `:hover` pseudo-class | ✅ | `a:hover` |
| `:focus` pseudo-class | ✅ | `input:focus` |
| `:before` pseudo-element | ✅ | `p:before` (legacy syntax) |
| `:after` pseudo-element | ✅ | `p:after` (legacy syntax) |
| `:first-child` pseudo-class | ✅ | `li:first-child` |
| `:lang()` pseudo-class | ✅ | `:lang(fr)` |
| Multiple attribute selectors | ✅ | `input[type="text"][required]` |
| Descendant combinator with universal | ✅ | `div *` |

### CSS Selectors Level 3

| Feature | Status | Example |
|---------|--------|---------|
| Namespace selectors | ✅ | `svg\\|rect`, `*\\|*` |
| Substring matching attribute selectors | ✅ | `[href^="https"]`, `[src$=".png"]`, `[title*="hello"]` |
| General sibling combinator | ✅ | `h1 ~ p` |
| `:root` pseudo-class | ✅ | `:root` |
| `:nth-child()` pseudo-class | ✅ | `:nth-child(2n+1)` |
| `:nth-last-child()` pseudo-class | ✅ | `:nth-last-child(2)` |
| `:nth-of-type()` pseudo-class | ✅ | `p:nth-of-type(odd)` |
| `:nth-last-of-type()` pseudo-class | ✅ | `div:nth-last-of-type(2n)` |
| `:last-child` pseudo-class | ✅ | `li:last-child` |
| `:first-of-type` pseudo-class | ✅ | `p:first-of-type` |
| `:last-of-type` pseudo-class | ✅ | `h2:last-of-type` |
| `:only-child` pseudo-class | ✅ | `p:only-child` |
| `:only-of-type` pseudo-class | ✅ | `img:only-of-type` |
| `:empty` pseudo-class | ✅ | `div:empty` |
| `:target` pseudo-class | ✅ | `:target` |
| `:enabled` pseudo-class | ✅ | `input:enabled` |
| `:disabled` pseudo-class | ✅ | `input:disabled` |
| `:checked` pseudo-class | ✅ | `input:checked` |
| `:not()` pseudo-class | ✅ | `:not(.active)` |
| `::before` pseudo-element | ✅ | `div::before` |
| `::after` pseudo-element | ✅ | `div::after` |
| `::first-line` pseudo-element | ✅ | `p::first-line` |
| `::first-letter` pseudo-element | ✅ | `p::first-letter` |

### CSS Selectors Level 4

| Feature | Status | Example |
|---------|--------|---------|
| Case-sensitivity flag | ✅ | `[attr=value i]`, `[attr=value s]` |
| Column combinator | ✅ | `col \\|\\| td` |
| `:is()` pseudo-class | ✅ | `:is(h1, h2, h3)` |
| `:where()` pseudo-class | ✅ | `:where(article, section) p` |
| `:has()` pseudo-class | ✅ | `:has(> img)` |
| `:not()` with complex selectors | ✅ | `:not(div.active)` |
| `:matches()` pseudo-class | ✅ | `:matches(h1, h2, h3)` |
| `:focus-within` | ✅ | `:focus-within` |
| `:focus-visible` | ✅ | `:focus-visible` |
| `:any-link` | ✅ | `:any-link` |
| `:read-write` pseudo-class | ✅ | `input:read-write` |
| `:read-only` pseudo-class | ✅ | `input:read-only` |
| `:placeholder-shown` pseudo-class | ✅ | `input:placeholder-shown` |
| `:default` pseudo-class | ✅ | `option:default` |
| `:valid` pseudo-class | ✅ | `input:valid` |
| `:invalid` pseudo-class | ✅ | `input:invalid` |
| `:in-range` pseudo-class | ✅ | `input:in-range` |
| `:out-of-range` pseudo-class | ✅ | `input:out-of-range` |
| `:required` pseudo-class | ✅ | `input:required` |
| `:optional` pseudo-class | ✅ | `input:optional` |
| `::placeholder` pseudo-element | ✅ | `input::placeholder` |
| `::selection` pseudo-element | ✅ | `::selection` |
| `::backdrop` pseudo-element | ✅ | `dialog::backdrop` |
| `::marker` pseudo-element | ✅ | `li::marker` |
| `::cue` pseudo-element | ✅ | `::cue` |
| `::slotted()` pseudo-element | ✅ | `::slotted(span)` |
| Vendor-specific pseudo-elements | ✅ | `::-webkit-input-placeholder` |
| `:nth-child(An+B of S)` | ✅ | `:nth-child(2n of .important)` |
| `:nth-col()` | ✅ | `:nth-col(2n+1)` |
| `:nth-last-col()` | ✅ | `:nth-last-col(2n+1)` |
| Attribute namespace wildcards | ❌ | `[*\\|attr=value]` |
  
## 📦 Installation

Add `selector` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:selector, "~> 0.1.0"}
  ]
end
```

## 🚀 Usage

### 📝 Basic Parsing

Parse CSS selectors into an AST:

```elixir
# Simple tag selector
Selector.parse("div")
# => {:selectors, [{:rules, [{:rule, [{:tag_name, "div", []}], []}]}]}

# ID selector
Selector.parse("#header")
# => {:selectors, [{:rules, [{:rule, [{:id, "header"}], []}]}]}

# Class selector
Selector.parse(".button")
# => {:selectors, [{:rules, [{:rule, [{:class, "button"}], []}]}]}

# Multiple selectors
Selector.parse("div, .button")
# => {:selectors, [
#      {:rules, [{:rule, [{:tag_name, "div", []}], []}]},
#      {:rules, [{:rule, [{:class, "button"}], []}]}
#    ]}
```

### 🔧 Complex Selectors

```elixir
# Combined selectors
Selector.parse("div#main.container")
# => {:selectors, [{:rules, [{:rule, [{:tag_name, "div", []}, {:id, "main"}, {:class, "container"}], []}]}]}

# Attribute selectors
Selector.parse("input[type='text']")
# => {:selectors, [{:rules, [{:rule, [{:tag_name, "input", []}, {:attribute, {:equal, "type", "text", []}}], []}]}]}

# Pseudo-classes
Selector.parse("a:hover")
# => {:selectors, [{:rules, [{:rule, [{:tag_name, "a", []}, {:pseudo_class, {"hover", []}}], []}]}]}

# Pseudo-elements
Selector.parse("p::first-line")
# => {:selectors, [{:rules, [{:rule, [{:tag_name, "p", []}, {:pseudo_element, {"first-line", []}}], []}]}]}
```

### 🏷️ Namespaces

Namespaces are useful when working with XML documents or SVG elements within HTML:

```elixir
# Element with namespace prefix
Selector.parse("svg|rect")
# => {:selectors, [{:rules, [{:rule, [{:tag_name, "rect", namespace: "svg"}], []}]}]}

# Any namespace (wildcard)
Selector.parse("*|circle")
# => {:selectors, [{:rules, [{:rule, [{:tag_name, "circle", namespace: "*"}], []}]}]}

# No namespace (elements without namespace)
Selector.parse("|path")
# => {:selectors, [{:rules, [{:rule, [{:tag_name, "path", namespace: ""}], []}]}]}

# Default namespace with universal selector
Selector.parse("*|*")
# => {:selectors, [{:rules, [{:rule, [{:tag_name, "*", namespace: "*"}], []}]}]}

# Namespace in attribute selectors
Selector.parse("[xlink|href]")
# => {:selectors, [{:rules, [{:rule, [{:attribute, {:exists, "href", nil, namespace: "xlink"}}], []}]}]}

# Namespace with attribute value
Selector.parse("[xml|lang='en']")
# => {:selectors, [{:rules, [{:rule, [{:attribute, {:equal, "lang", "en", namespace: "xml"}}], []}]}]}

# Complex example with SVG
Selector.parse("svg|svg > svg|g svg|rect.highlight")
# => {:selectors, [{:rules, [
#      {:rule, [{:tag_name, "svg", namespace: "svg"}], []},
#      {:rule, [{:tag_name, "g", namespace: "svg"}], combinator: ">"},
#      {:rule, [{:tag_name, "rect", namespace: "svg"}, {:class, "highlight"}], []}
#    ]}]}

# MathML namespace example
Selector.parse("math|mrow > math|mi + math|mo")
# => {:selectors, [{:rules, [
#      {:rule, [{:tag_name, "mrow", namespace: "math"}], []},
#      {:rule, [{:tag_name, "mi", namespace: "math"}], combinator: ">"},
#      {:rule, [{:tag_name, "mo", namespace: "math"}], combinator: "+"}
#    ]}]}
```

### 🔗 Combinators

```elixir
# Descendant combinator (space)
Selector.parse("article p")
# => {:selectors, [{:rules, [
#      {:rule, [{:tag_name, "article", []}], []}, 
#      {:rule, [{:tag_name, "p", []}], []}
#    ]}]}

# Child combinator (>)
Selector.parse("ul > li")
# => {:selectors, [{:rules, [
#      {:rule, [{:tag_name, "ul", []}], []}, 
#      {:rule, [{:tag_name, "li", []}], combinator: ">"}
#    ]}]}

# Adjacent sibling combinator (+)
Selector.parse("h1 + p")
# => {:selectors, [{:rules, [
#      {:rule, [{:tag_name, "h1", []}], []}, 
#      {:rule, [{:tag_name, "p", []}], combinator: "+"}
#    ]}]}

# General sibling combinator (~)
Selector.parse("h1 ~ p")
# => {:selectors, [{:rules, [
#      {:rule, [{:tag_name, "h1", []}], []}, 
#      {:rule, [{:tag_name, "p", []}], combinator: "~"}
#    ]}]}

# Column combinator (||) - CSS Level 4
Selector.parse("col || td")
# => {:selectors, [{:rules, [
#      {:rule, [{:tag_name, "col", []}], []}, 
#      {:rule, [{:tag_name, "td", []}], combinator: "||"}
#    ]}]}
```

### 🏷️ Attribute Selectors

```elixir
# Existence
Selector.parse("[disabled]")
# => {:selectors, [{:rules, [{:rule, [{:attribute, {:exists, "disabled", nil, []}}], []}]}]}

# Exact match
Selector.parse("[type=submit]")
# => {:selectors, [{:rules, [{:rule, [{:attribute, {:equal, "type", "submit", []}}], []}]}]}

# Whitespace-separated list contains
Selector.parse("[class~=primary]")
# => {:selectors, [{:rules, [{:rule, [{:attribute, {:includes, "class", "primary", []}}], []}]}]}

# Dash-separated list starts with
Selector.parse("[lang|=en]")
# => {:selectors, [{:rules, [{:rule, [{:attribute, {:dash_match, "lang", "en", []}}], []}]}]}

# Starts with
Selector.parse("[href^='https://']")
# => {:selectors, [{:rules, [{:rule, [{:attribute, {:prefix, "href", "https://", []}}], []}]}]}

# Ends with
Selector.parse("[src$='.png']")
# => {:selectors, [{:rules, [{:rule, [{:attribute, {:suffix, "src", ".png", []}}], []}]}]}

# Contains substring
Selector.parse("[title*='important']")
# => {:selectors, [{:rules, [{:rule, [{:attribute, {:substring, "title", "important", []}}], []}]}]}

# Case-insensitive matching (CSS Level 4)
Selector.parse("[type=email i]")
# => {:selectors, [{:rules, [{:rule, [{:attribute, {:equal, "type", "email", case_sensitive: false}}], []}]}]}

# Case-sensitive matching (CSS Level 4)
Selector.parse("[class=Button s]")
# => {:selectors, [{:rules, [{:rule, [{:attribute, {:equal, "class", "Button", case_sensitive: true}}], []}]}]}
```

### 🎭 Pseudo-classes

```elixir
# Simple pseudo-classes
Selector.parse(":hover")
# => {:selectors, [{:rules, [{:rule, [{:pseudo_class, {"hover", []}}], []}]}]}

# Structural pseudo-classes
Selector.parse(":first-child")
# => {:selectors, [{:rules, [{:rule, [{:pseudo_class, {"first-child", []}}], []}]}]}

# :nth-child with various formulas
Selector.parse(":nth-child(2n+1)")
# => {:selectors, [{:rules, [{:rule, [{:pseudo_class, {"nth-child", [[a: 2, b: 1]]}}], []}]}]}

Selector.parse(":nth-child(odd)")
# => {:selectors, [{:rules, [{:rule, [{:pseudo_class, {"nth-child", [[a: 2, b: 1]]}}], []}]}]}

Selector.parse(":nth-child(even)")
# => {:selectors, [{:rules, [{:rule, [{:pseudo_class, {"nth-child", [[a: 2, b: 0]]}}], []}]}]}

Selector.parse(":nth-child(5)")
# => {:selectors, [{:rules, [{:rule, [{:pseudo_class, {"nth-child", [[a: 0, b: 5]]}}], []}]}]}

# Language pseudo-class
Selector.parse(":lang(en-US)")
# => {:selectors, [{:rules, [{:rule, [{:pseudo_class, {"lang", ["en-US"]}}], []}]}]}

# Negation pseudo-class
Selector.parse(":not(.disabled)")
# => {:selectors, [{:rules, [{:rule, [{:pseudo_class, {"not", [
#        [{:rules, [{:rule, [{:class, "disabled"}], []}]}]
#      ]}}], []}]}]}

# CSS Level 4 pseudo-classes
Selector.parse(":is(h1, h2, h3)")
# => {:selectors, [{:rules, [{:rule, [{:pseudo_class, {"is", [
#        [
#          {:rules, [{:rule, [{:tag_name, "h1", []}], []}]},
#          {:rules, [{:rule, [{:tag_name, "h2", []}], []}]},
#          {:rules, [{:rule, [{:tag_name, "h3", []}], []}]}
#        ]
#      ]}}], []}]}]}

Selector.parse(":where(article, section) > p")
# => {:selectors, [{:rules, [
#      {:rule, [{:pseudo_class, {"where", [
#        [
#          {:rules, [{:rule, [{:tag_name, "article", []}], []}]},
#          {:rules, [{:rule, [{:tag_name, "section", []}], []}]}
#        ]
#      ]}}], []},
#      {:rule, [{:tag_name, "p", []}], combinator: ">"}
#    ]}]}

Selector.parse(":has(> img)")
# => {:selectors, [{:rules, [{:rule, [{:pseudo_class, {"has", [
#        [{:rules, [{:rule, [{:tag_name, "img", []}], combinator: ">"}]}]
#      ]}}], []}]}]}
```

### 🎨 Pseudo-elements

```elixir
# Standard pseudo-elements
Selector.parse("::before")
# => {:selectors, [{:rules, [{:rule, [{:pseudo_element, {"before", []}}], []}]}]}

Selector.parse("::after")
# => {:selectors, [{:rules, [{:rule, [{:pseudo_element, {"after", []}}], []}]}]}

Selector.parse("::first-line")
# => {:selectors, [{:rules, [{:rule, [{:pseudo_element, {"first-line", []}}], []}]}]}

Selector.parse("::first-letter")
# => {:selectors, [{:rules, [{:rule, [{:pseudo_element, {"first-letter", []}}], []}]}]}

# CSS Level 4 pseudo-elements
Selector.parse("::placeholder")
# => {:selectors, [{:rules, [{:rule, [{:pseudo_element, {"placeholder", []}}], []}]}]}

Selector.parse("::selection")
# => {:selectors, [{:rules, [{:rule, [{:pseudo_element, {"selection", []}}], []}]}]}

# Pseudo-elements with parameters
Selector.parse("::slotted(span)")
# => {:selectors, [{:rules, [{:rule, [{:pseudo_element, {"slotted", [[{:rules, [{:rule, [{:tag_name, "span", []}], []}]}]]}}], []}]}]}

# Legacy single-colon syntax (still supported)
Selector.parse(":before")
# => {:selectors, [{:rules, [{:rule, [{:pseudo_element, {"before", []}}], []}]}]}

# Vendor-specific pseudo-elements
Selector.parse("::-webkit-input-placeholder")
# => {:selectors, [{:rules, [{:rule, [{:pseudo_element, {"-webkit-input-placeholder", []}}], []}]}]}
```

### 💪 Advanced Examples

```elixir
# Complex selector with multiple features
Selector.parse("article.post:not(.draft) > h1 + p:first-of-type")
# => [
#   {:rule, [
#     {:tag_name, "article", []},
#     {:class, "post"},
#     {:pseudo_class, {:not, [[{:rule, [{:class, "draft"}], []}]]}}
#   ], []},
#   {:rule, [{:tag_name, "h1", []}], combinator: ">"},
#   {:rule, [
#     {:tag_name, "p", []},
#     {:pseudo_class, {:first_of_type, []}}
#   ], combinator: "+"}
# ]

# Multiple attribute selectors
Selector.parse("input[type='email'][required][placeholder^='Enter']")
# => [{:rule, [
#   {:tag_name, "input", []},
#   {:attribute, {:equal, "type", "email", []}},
#   {:attribute, {:exists, "required", nil, []}},
#   {:attribute, {:prefix, "placeholder", "Enter", []}}
# ], []}]

# Nested pseudo-classes
Selector.parse(":not(:first-child):not(:last-child)")
# => [{:rule, [
#   {:pseudo_class, {:not, [[{:rule, [{:pseudo_class, {:first_child, []}}], []}]]}},
#   {:pseudo_class, {:not, [[{:rule, [{:pseudo_class, {:last_child, []}}], []}]]}}
# ], []}]
```

### 🔄 Rendering AST back to CSS

```elixir
ast = Selector.parse("div#main > p.text")
Selector.render(ast)
# => "div#main > p.text"
```

### ⚙️ Parser Options

```elixir
# Strict mode (default: true)
# Disables identifiers starting with double hyphens
Selector.parse("#--custom-id", strict: false)
# => {:selectors, [{:rules, [{:rule, [{:id, "--custom-id"}], []}]}]}
```

## 🌳 AST Structure

The parser generates an AST with the following structure:

- The top-level structure is `{:selectors, [selector_groups]}`
- Each selector group is `{:rules, [rules]}`
- Each rule is `{:rule, selectors, options}`
- Multiple selector groups (comma-separated) are returned as separate elements in the list
- Combinators are stored in the options of the following rule

### 🎯 Selector Types

- `{:tag_name, "div", []}` - Element selector
- `{:tag_name, "div", namespace: "svg"}` - Namespaced element
- `{:id, "header"}` - ID selector
- `{:class, "button"}` - Class selector
- `{:attribute, {operation, name, value, options}}` - Attribute selector
- `{:pseudo_class, {name, arguments}}` - Pseudo-class
- `{:pseudo_element, {name, arguments}}` - Pseudo-element

### 🔧 Attribute Operations

- `:exists` - `[attr]`
- `:equal` - `[attr=value]`
- `:includes` - `[attr~=value]`
- `:dash_match` - `[attr|=value]`
- `:prefix` - `[attr^=value]`
- `:suffix` - `[attr$=value]`
- `:substring` - `[attr*=value]`

## ⚠️ Error Handling

The parser raises `ArgumentError` for invalid selectors:

```elixir
try do
  Selector.parse(".")
rescue
  ArgumentError -> "Invalid selector"
end
# => "Invalid selector"
```

## 📄 License

MIT License - Copyright (c) 2024 DockYard, Inc. See [LICENSE.md](LICENSE.md) for details.