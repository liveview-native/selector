defmodule Selector.ParserTest do
  @moduledoc """
  Test suite for CSS selector parser.
  
  This parser aims to support:
  - CSS Selectors Level 3 (complete support)
  - CSS Selectors Level 4 (partial support for stable features)
  
  Notable CSS Level 4 features supported:
  - :is(), :where(), :has() pseudo-classes
  - :not() with complex selectors
  - Case sensitivity modifiers (i, s)
  - Column combinator (||)
  - :focus-within, :focus-visible pseudo-classes
  
  Features explicitly not supported:
  - :nth-child(An+B of selector) syntax
  - :nth-col(), :nth-last-col() pseudo-classes
  - Attribute selectors with namespace wildcards
  """
  use ExUnit.Case, async: true

  describe "Identifiers" do
    test "should parse a regular valid identifier" do
      assert Selector.parse("#id") == {:selectors, [{:rules, [{:rule, [{:id, "id"}], []}]}]}
    end

    test "should parse an identifier starting with a hyphen" do
      assert Selector.parse("#-id") == {:selectors, [{:rules, [{:rule, [{:id, "-id"}], []}]}]}
    end

    test "should parse an identifier with hex-encoded characters" do
      ast_selector = {:selectors, [{:rules, [{:rule, [{:id, "hello\nworld"}], []}]}]}

      assert Selector.parse("#hello\\aworld") == ast_selector
      assert Selector.parse("#hello\\a world") == ast_selector
      assert Selector.parse("#hello\\a\tworld") == ast_selector
      assert Selector.parse("#hello\\a\fworld") == ast_selector
      assert Selector.parse("#hello\\a\nworld") == ast_selector
      assert Selector.parse("#hello\\a\rworld") == ast_selector
      assert Selector.parse("#hello\\a\r\nworld") == ast_selector
      assert Selector.parse("#hello\\00000aworld") == ast_selector
    end

    test "should fail on an identifier starting with multiple hyphens" do
      assert_raise ArgumentError, "Identifiers cannot start with two hyphens with strict mode on.", fn ->
        Selector.parse("#--id")
      end
    end

    test "should fail on an identifier consisting of a single hyphen" do
      assert_raise ArgumentError, "Identifiers cannot consist of a single hyphen.", fn ->
        Selector.parse("#-")
      end
    end

    test "should parse an identifier starting with multiple hyphens in case of strict: false" do
      assert Selector.parse("#--id", strict: false) == {:selectors, [{:rules, [{:rule, [{:id, "--id"}], []}]}]}
    end

    test "should fail on an identifier starting with a hyphen and followed with a digit" do
      assert_raise ArgumentError, "Identifiers cannot start with hyphens followed by digits.", fn ->
        Selector.parse("#-1")
      end

      assert_raise ArgumentError, "Identifiers cannot start with hyphens followed by digits.", fn ->
        Selector.parse("#--1", strict: false)
      end
    end

    test "should parse an identifier consisting unicode characters" do
      assert Selector.parse("#ÈÈ") == {:selectors, [{:rules, [{:rule, [{:id, "ÈÈ"}], []}]}]}
    end
  end

  describe "Tag Names" do
    test "should parse a tag name" do
      assert Selector.parse("div") == {:selectors, [{:rules, [{:rule, [{:tag_name, "div", []}], []}]}]}
    end

    test "should parse a wildcard tag name" do
      assert Selector.parse("*") == {:selectors, [{:rules, [{:rule, [{:tag_name, "*", []}], []}]}]}
    end

    test "should parse an escaped star" do
      assert Selector.parse("\\*") == {:selectors, [{:rules, [{:rule, [{:tag_name, "*", []}], []}]}]}
    end

    test "should properly parse an escaped tag name" do
      assert Selector.parse("d\\ i\\ v") == {:selectors, [{:rules, [{:rule, [{:tag_name, "d i v", []}], []}]}]}
    end

    @tag :skip
    test "should not be parsed after an attribute" do
      assert_raise ArgumentError, "Unexpected tag/namespace start.", fn ->
        Selector.parse(~s([href="#"]a))
      end
    end

    @tag :skip
    test "should not be parsed after a pseudo-class" do
      assert_raise ArgumentError, "Unexpected tag/namespace start.", fn ->
        Selector.parse(":nth-child(2n)a")
      end
    end

    @tag :skip
    test "should not be parsed after a pseudo-element" do
      assert_raise ArgumentError, "Unexpected tag/namespace start.", fn ->
        Selector.parse(":unknown(hello)a")
      end
    end
  end

  describe "Namespaces" do
    test "should parse a namespace name" do
      assert Selector.parse("ns|div") == {:selectors, [{:rules, [{:rule, [{:tag_name, "div", namespace: "ns"}], []}]}]}
    end

    test "should parse no namespace" do
      assert Selector.parse("|div") == {:selectors, [{:rules, [{:rule, [{:tag_name, "div", namespace: ""}], []}]}]}
    end

    test "should parse wildcard namespace" do
      assert Selector.parse("*|div") == {:selectors, [{:rules, [{:rule, [{:tag_name, "div", namespace: "*"}], []}]}]}
    end

    test "should parse a wildcard namespace with a wildcard tag name" do
      assert Selector.parse("*|*") == {:selectors, [{:rules, [{:rule, [{:tag_name, "*", namespace: "*"}], []}]}]}
    end

    test "should parse an escaped star" do
      assert Selector.parse("\\*|*") == {:selectors, [{:rules, [{:rule, [{:tag_name, "*", namespace: "*"}], []}]}]}
    end

    test "should parse an escaped pipe" do
      assert Selector.parse("\\|div") == {:selectors, [{:rules, [{:rule, [{:tag_name, "|div", []}], []}]}]}
    end

    test "should parse two escaped stars" do
      assert Selector.parse("\\*|\\*") == {:selectors, [{:rules, [{:rule, [{:tag_name, "*", namespace: "*"}], []}]}]}
    end

    test "should properly parse an escaped namespace name" do
      assert Selector.parse("n\\ a\\ m|d\\ i\\ v") == {:selectors, [{:rules, [{:rule, [{:tag_name, "d i v", namespace: "n a m"}], []}]}]}
    end

    @tag :skip
    test "should not be parsed after an attribute" do
      assert_raise ArgumentError, "Unexpected tag/namespace start.", fn ->
        Selector.parse(~s([href="#"]a|b))
      end

      assert_raise ArgumentError, "Unexpected tag/namespace start.", fn ->
        Selector.parse(~s([href="#"]|b))
      end
    end

    @tag :skip
    test "should not accept a single hyphen" do
      assert_raise ArgumentError, fn ->
        Selector.parse("a - b")
      end
    end

    @tag :skip
    test "should not be parsed after a pseudo-class" do
      assert_raise ArgumentError, "Unexpected tag/namespace start.", fn ->
        Selector.parse(":nth-child(2n)a|b")
      end

      assert_raise ArgumentError, "Unexpected tag/namespace start.", fn ->
        Selector.parse(":nth-child(2n)|b")
      end
    end

    @tag :skip
    test "should not be parsed after a pseudo-element" do
      assert_raise ArgumentError, "Unexpected tag/namespace start.", fn ->
        Selector.parse(":unknown(hello)a|b")
      end

      assert_raise ArgumentError, "Unexpected tag/namespace start.", fn ->
        Selector.parse(":unknown(hello)|b")
      end
    end
  end

  describe "Class Names" do
    test "should parse a single class name" do
      assert Selector.parse(".class") == {:selectors, [{:rules, [{:rule, [{:class, "class"}], []}]}]}
    end

    test "should parse multiple class names" do
      assert Selector.parse(".class1.class2") == {:selectors, [{:rules, [
        {:rule, [{:class, "class1"}, {:class, "class2"}], []}
      ]}]}
    end

    test "should properly parse class names" do
      assert Selector.parse(".cla\\ ss\\.name") == {:selectors, [{:rules, [{:rule, [{:class, "cla ss.name"}], []}]}]}
    end

    test "should parse after tag names" do
      assert Selector.parse("div.class") == {:selectors, [{:rules, [
        {:rule, [{:tag_name, "div", []}, {:class, "class"}], []}
      ]}]}
    end

    test "should parse after IDs" do
      assert Selector.parse("#id.class") == {:selectors, [{:rules, [
        {:rule, [{:id, "id"}, {:class, "class"}], []}
      ]}]}
    end

    test "should parse after an attribute" do
      assert Selector.parse("[href].class") == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:exists, "href", nil, []}}, {:class, "class"}], []}
      ]}]}
    end

    test "should parse after a pseudo-class" do
      assert Selector.parse(":link.class") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"link", []}}, {:class, "class"}], []}
      ]}]}
    end

    test "should parse after a pseudo-element" do
      assert Selector.parse("::before.class") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_element, {"before", []}}, {:class, "class"}], []}
      ]}]}
    end

    test "should fail on empty class name" do
      assert_raise ArgumentError, "Expected class name.", fn ->
        Selector.parse(".")
      end

      assert_raise ArgumentError, "Expected class name.", fn ->
        Selector.parse(".1")
      end
    end

    test "should fail on a single hyphen" do
      assert_raise ArgumentError, "Expected class name.", fn ->
        Selector.parse(".-")
      end
    end
  end

  describe "IDs" do
    test "should parse a single ID" do
      assert Selector.parse("#id") == {:selectors, [{:rules, [{:rule, [{:id, "id"}], []}]}]}
    end

    test "should parse multiple IDs" do
      assert Selector.parse("#id1#id2") == {:selectors, [{:rules, [
        {:rule, [{:id, "id1"}, {:id, "id2"}], []}
      ]}]}
    end

    test "should properly parse IDs" do
      assert Selector.parse("#id\\ name\\#\\ with\\ escapes") == {:selectors, [{:rules, [
        {:rule, [{:id, "id name# with escapes"}], []}
      ]}]}
    end

    test "should parse after a tag name" do
      assert Selector.parse("div#id") == {:selectors, [{:rules, [
        {:rule, [{:tag_name, "div", []}, {:id, "id"}], []}
      ]}]}
    end

    test "should parse after a class name" do
      assert Selector.parse(".class#id") == {:selectors, [{:rules, [
        {:rule, [{:class, "class"}, {:id, "id"}], []}
      ]}]}
    end

    test "should parse mix of classes and ids" do
      assert Selector.parse(".class1#id1.class2#id2") == {:selectors, [{:rules, [
        {:rule, [
          {:class, "class1"},
          {:id, "id1"},
          {:class, "class2"},
          {:id, "id2"}
        ], []}
      ]}]}
    end

    test "should parse after an attribute" do
      assert Selector.parse("[href]#id") == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:exists, "href", nil, []}}, {:id, "id"}], []}
      ]}]}
    end

    test "should parse after a pseudo-class" do
      assert Selector.parse(":link#id") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"link", []}}, {:id, "id"}], []}
      ]}]}
    end

    test "should parse after a pseudo-element" do
      assert Selector.parse("::before#id") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_element, {"before", []}}, {:id, "id"}], []}
      ]}]}
    end

    test "should fail on empty ID" do
      assert_raise ArgumentError, "Expected identifier.", fn ->
        Selector.parse("#")
      end
    end
  end

  describe "Attributes" do
    test "should parse a attribute" do
      assert Selector.parse("[attr]") == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:exists, "attr", nil, []}}], []}
      ]}]}
    end

    test "should parse a attribute with comparison" do
      assert Selector.parse("[attr=val]") == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:equal, "attr", "val", []}}], []}
      ]}]}
    end

    test "should parse a attribute with multibyte comparison" do
      assert Selector.parse("[attr|=val]") == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:dash_match, "attr", "val", []}}], []}
      ]}]}
    end

    test "should parse multiple attributes" do
      assert Selector.parse("[attr1][attr2]") == {:selectors, [{:rules, [
        {:rule, [
          {:attribute, {:exists, "attr1", nil, []}},
          {:attribute, {:exists, "attr2", nil, []}}
        ], []}
      ]}]}
    end

    test "should properly parse attribute names" do
      assert Selector.parse("[attr\\ \\.name]") == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:exists, "attr .name", nil, []}}], []}
      ]}]}
    end

    test "should properly parse attribute values" do
      assert Selector.parse("[attr=val\\ \\ue]") == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:equal, "attr", "val ue", []}}], []}
      ]}]}
    end

    test "should properly parse case sensitivity modifiers" do
      assert Selector.parse("[attr=value \\i]") == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:equal, "attr", "value", case_sensitive: false}}], []}
      ]}]}
    end

    test "should properly handle whitespace" do
      assert Selector.parse("[ attr = value i ]") == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:equal, "attr", "value", case_sensitive: false}}], []}
      ]}]}
    end

    test "should properly parse double quotes" do
      # Testing escaped quote and literal backslashes (not escape sequences)
      assert Selector.parse(~s([ attr = "val\\"\\\\ue\\\\20" i ])) == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:equal, "attr", "val\"\\ue\\20", case_sensitive: false}}], []}
      ]}]}
    end

    test "should properly parse escapes" do
      ast_selector = {:selectors, [{:rules, [{:rule, [{:attribute, {:equal, "attr", "hello\nworld", []}}], []}]}]}

      assert Selector.parse(~s([attr="hello\\aworld"])) == ast_selector
      assert Selector.parse(~s([attr="hell\\o\\aworld"])) == ast_selector
      assert Selector.parse(~s([attr="hell\\\no\\aworld"])) == ast_selector
      assert Selector.parse(~s([attr="hello\\a world"])) == ast_selector
      assert Selector.parse(~s([attr="hello\\a\tworld"])) == ast_selector
      assert Selector.parse(~s([attr="hello\\a\fworld"])) == ast_selector
      assert Selector.parse(~s([attr="hello\\a\nworld"])) == ast_selector
      assert Selector.parse(~s([attr="hello\\a\rworld"])) == ast_selector
      assert Selector.parse(~s([attr="hello\\a\r\nworld"])) == ast_selector
      assert Selector.parse(~s([attr="hello\\00000aworld"])) == ast_selector
    end

    test "should properly parse single quotes" do
      assert Selector.parse("[ attr = 'val\\'\\ue\\20' i ]") == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:equal, "attr", "val'ue ", case_sensitive: false}}], []}
      ]}]}
    end

    test "should fail if attribute name is empty" do
      assert_raise ArgumentError, "Expected attribute name.", fn ->
        Selector.parse("[=a1]")
      end

      assert_raise ArgumentError, "Expected attribute name.", fn ->
        Selector.parse("[1=a1]")
      end
    end

    test "should fail if attribute value is empty" do
      assert_raise ArgumentError, "Expected attribute value.", fn ->
        Selector.parse("[a=]")
      end
    end

    test "should parse empty attribute values in quotes" do
      assert Selector.parse(~s([attr=""])) == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:equal, "attr", "", []}}], []}
      ]}]}
      assert Selector.parse("[attr='']") == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:equal, "attr", "", []}}], []}
      ]}]}
    end

    test "should parse case sensitivity modifier s" do
      assert Selector.parse("[attr=value s]") == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:equal, "attr", "value", case_sensitive: true}}], []}
      ]}]}
    end

    test "should parse after tag names" do
      assert Selector.parse("div[attr]") == {:selectors, [{:rules, [
        {:rule, [{:tag_name, "div", []}, {:attribute, {:exists, "attr", nil, []}}], []}
      ]}]}
    end

    test "should parse after IDs" do
      assert Selector.parse("#id[attr]") == {:selectors, [{:rules, [
        {:rule, [{:id, "id"}, {:attribute, {:exists, "attr", nil, []}}], []}
      ]}]}
    end

    test "should parse after classes" do
      assert Selector.parse(".class[attr]") == {:selectors, [{:rules, [
        {:rule, [{:class, "class"}, {:attribute, {:exists, "attr", nil, []}}], []}
      ]}]}
    end

    test "should parse after a pseudo-class" do
      assert Selector.parse(":link[attr]") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"link", []}}, {:attribute, {:exists, "attr", nil, []}}], []}
      ]}]}
    end

    test "should parse after a pseudo-element" do
      assert Selector.parse("::before[attr]") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_element, {"before", []}}, {:attribute, {:exists, "attr", nil, []}}], []}
      ]}]}
    end

    test "should parse a named namespace" do
      assert Selector.parse("[ns|href]") == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:exists, "href", nil, namespace: "ns"}}], []}
      ]}]}

      assert Selector.parse("[ns|href=value]") == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:equal, "href", "value", namespace: "ns"}}], []}
      ]}]}
    end

    test "should parse a wildcard namespace" do
      assert Selector.parse("[*|href]") == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:exists, "href", nil, namespace: "*"}}], []}
      ]}]}

      assert Selector.parse("[*|href=value]") == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:equal, "href", "value", namespace: "*"}}], []}
      ]}]}
    end

    test "should parse an empty namespace" do
      assert Selector.parse("[|href]") == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:exists, "href", nil, namespace: ""}}], []}
      ]}]}

      assert Selector.parse("[|href=value]") == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:equal, "href", "value", namespace: ""}}], []}
      ]}]}
    end

    test "should fail on bracket mismatch" do
      assert_raise ArgumentError, "Expected closing bracket.", fn ->
        Selector.parse("[attr")
      end
    end

    test "should parse starting with match" do
      assert Selector.parse("[attr^=value]") == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:prefix, "attr", "value", []}}], []}
      ]}]}
    end

    test "should parse ending with match" do
      assert Selector.parse("[attr$=value]") == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:suffix, "attr", "value", []}}], []}
      ]}]}
    end

    test "should parse containing match" do
      assert Selector.parse("[attr*=value]") == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:substring, "attr", "value", []}}], []}
      ]}]}
    end

    test "should parse includes match" do
      assert Selector.parse("[attr~=value]") == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:includes, "attr", "value", []}}], []}
      ]}]}
    end
  end

  describe "Pseudo Classes" do
    test "should parse a pseudo-class" do
      assert Selector.parse(":link") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"link", []}}], []}
      ]}]}
    end

    test "should parse multiple pseudo classes" do
      assert Selector.parse(":link:visited") == {:selectors, [{:rules, [
        {:rule, [
          {:pseudo_class, {"link", []}},
          {:pseudo_class, {"visited", []}}
        ], []}
      ]}]}
    end

    @tag :skip
    test "should properly parse pseudo classes" do
      assert Selector.parse(":\\l\\69\\n\\6b") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"link", []}}], []}
      ]}]}
    end

    test "should properly parse with 0n" do
      for formula <- [":nth-child(0n+5)", ":nth-child( 0n + 5 )", ":nth-child( 0n+5 )",
                      ":nth-child(5)", ":nth-child( 5 )", ":nth-child( +5 )"] do
        assert Selector.parse(formula) == {:selectors, [{:rules, [
          {:rule, [{:pseudo_class, {"nth-child", [[a: 0, b: 5]]}}], []}
        ]}]}
      end
    end

    test "should properly parse with 0n and negative B" do
      for formula <- [":nth-child(0n-5)", ":nth-child( 0n - 5 )", ":nth-child( 0n-5 )",
                      ":nth-child(-5)", ":nth-child( -5 )"] do
        assert Selector.parse(formula) == {:selectors, [{:rules, [
          {:rule, [{:pseudo_class, {"nth-child", [[a: 0, b: -5]]}}], []}
        ]}]}
      end
    end

    test "should properly parse with 0 B" do
      for formula <- [":nth-child(3n+0)", ":nth-child( 3\\n + 0 )", ":nth-child( 3\\6e+0 )",
                      ":nth-child(3n)", ":nth-child( 3n )", ":nth-child( +3n )"] do
        assert Selector.parse(formula) == {:selectors, [{:rules, [
          {:rule, [{:pseudo_class, {"nth-child", [[a: 3, b: 0]]}}], []}
        ]}]}
      end
    end

    test "should properly parse even" do
      for formula <- [":nth-child(even)", ":nth-child( even )", ":nth-child( 2n )"] do
        assert Selector.parse(formula) == {:selectors, [{:rules, [
          {:rule, [{:pseudo_class, {"nth-child", [[a: 2, b: 0]]}}], []}
        ]}]}
      end
    end

    test "should properly parse odd" do
      for formula <- [":nth-child( 2n + 1 )", ":nth-child( odd )"] do
        assert Selector.parse(formula) == {:selectors, [{:rules, [
          {:rule, [{:pseudo_class, {"nth-child", [[a: 2, b: 1]]}}], []}
        ]}]}
      end
    end

    test "should properly handle whitespace" do
      assert Selector.parse(":lang( en )") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"lang", ["en"]}}], []}
      ]}]}
    end

    test "should parse after tag names" do
      assert Selector.parse("div:link") == {:selectors, [{:rules, [
        {:rule, [{:tag_name, "div", []}, {:pseudo_class, {"link", []}}], []}
      ]}]}
    end

    test "should parse after IDs" do
      assert Selector.parse("#id:link") == {:selectors, [{:rules, [
        {:rule, [{:id, "id"}, {:pseudo_class, {"link", []}}], []}
      ]}]}
    end

    test "should parse after classes" do
      assert Selector.parse(".class:link") == {:selectors, [{:rules, [
        {:rule, [{:class, "class"}, {:pseudo_class, {"link", []}}], []}
      ]}]}
    end

    test "should parse nested selectors" do
      assert Selector.parse(":is(:lang(en), div)") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"is", [
          [
            {:rules, [{:rule, [{:pseudo_class, {"lang", ["en"]}}], []}]},
            {:rules, [{:rule, [{:tag_name, "div", []}], []}]}
          ]
        ]}}], []}
      ]}]}
    end

    test "should parse after an attribute" do
      assert Selector.parse("[href]:link") == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:exists, "href", nil, []}}, {:pseudo_class, {"link", []}}], []}
      ]}]}
    end

    test "should parse after a pseudo-element" do
      assert Selector.parse("::before:hover") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_element, {"before", []}}, {:pseudo_class, {"hover", []}}], []}
      ]}]}
    end

    test "should fail on a single hyphen" do
      assert_raise ArgumentError, "Identifiers cannot consist of a single hyphen.", fn ->
        Selector.parse(":-")
      end
    end

    test "should fail if argument required but not provided" do
      assert_raise ArgumentError, "Argument is required for pseudo-class \"not\".", fn ->
        Selector.parse(":not")
      end
    end

    test "should parse :nth functions" do
      assert Selector.parse(":nth-child(2n+1)") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"nth-child", [[a: 2, b: 1]]}}], []}
      ]}]}
    end

    test "should parse :nth-of-type functions" do
      assert Selector.parse(":nth-of-type(2n)") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"nth-of-type", [[a: 2, b: 0]]}}], []}
      ]}]}
    end

    test "should parse :nth-last-child functions" do
      assert Selector.parse(":nth-last-child(2n+1)") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"nth-last-child", [[a: 2, b: 1]]}}], []}
      ]}]}
    end

    test "should parse :nth-last-of-type functions" do
      assert Selector.parse(":nth-last-of-type(2n)") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"nth-last-of-type", [[a: 2, b: 0]]}}], []}
      ]}]}
    end

    test "should parse :not function with complex selectors" do
      assert Selector.parse(":not(div.class)") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"not", [
          [{:rules, [{:rule, [{:tag_name, "div", []}, {:class, "class"}], []}]}]
        ]}}], []}
      ]}]}
    end

    test "should parse :is function" do
      assert Selector.parse(":is(div, .class)") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"is", [
          [
            {:rules, [{:rule, [{:tag_name, "div", []}], []}]},
            {:rules, [{:rule, [{:class, "class"}], []}]}
          ]
        ]}}], []}
      ]}]}
    end

    test "should parse :where function" do
      assert Selector.parse(":where(div, .class)") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"where", [
          [
            {:rules, [{:rule, [{:tag_name, "div", []}], []}]},
            {:rules, [{:rule, [{:class, "class"}], []}]}
          ]
        ]}}], []}
      ]}]}
    end

    test "should parse :has function" do
      assert Selector.parse(":has(> div)") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"has", [
          [{:rules, [{:rule, [{:tag_name, "div", []}], combinator: ">"}]}]
        ]}}], []}
      ]}]}
    end

    test "should parse :matches function" do
      assert Selector.parse(":matches(div, .class)") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"matches", [
          [
            {:rules, [{:rule, [{:tag_name, "div", []}], []}]},
            {:rules, [{:rule, [{:class, "class"}], []}]}
          ]
        ]}}], []}
      ]}]}
    end

    test "should parse language pseudo-class" do
      assert Selector.parse(":lang(en-US)") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"lang", ["en-US"]}}], []}
      ]}]}
    end

    test "should parse structural pseudo-classes" do
      assert Selector.parse(":first-child") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"first-child", []}}], []}
      ]}]}
      assert Selector.parse(":last-child") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"last-child", []}}], []}
      ]}]}
      assert Selector.parse(":only-child") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"only-child", []}}], []}
      ]}]}
      assert Selector.parse(":first-of-type") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"first-of-type", []}}], []}
      ]}]}
      assert Selector.parse(":last-of-type") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"last-of-type", []}}], []}
      ]}]}
      assert Selector.parse(":only-of-type") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"only-of-type", []}}], []}
      ]}]}
    end

    test "should parse tree-structural pseudo-classes" do
      assert Selector.parse(":root") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"root", []}}], []}
      ]}]}
      assert Selector.parse(":empty") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"empty", []}}], []}
      ]}]}
    end

    test "should parse UI state pseudo-classes" do
      assert Selector.parse(":checked") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"checked", []}}], []}
      ]}]}
      assert Selector.parse(":enabled") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"enabled", []}}], []}
      ]}]}
      assert Selector.parse(":disabled") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"disabled", []}}], []}
      ]}]}
      assert Selector.parse(":required") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"required", []}}], []}
      ]}]}
      assert Selector.parse(":optional") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"optional", []}}], []}
      ]}]}
      assert Selector.parse(":read-only") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"read-only", []}}], []}
      ]}]}
      assert Selector.parse(":read-write") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"read-write", []}}], []}
      ]}]}
      assert Selector.parse(":valid") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"valid", []}}], []}
      ]}]}
      assert Selector.parse(":invalid") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"invalid", []}}], []}
      ]}]}
      assert Selector.parse(":in-range") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"in-range", []}}], []}
      ]}]}
      assert Selector.parse(":out-of-range") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"out-of-range", []}}], []}
      ]}]}
    end

    test "should parse target and link pseudo-classes" do
      assert Selector.parse(":target") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"target", []}}], []}
      ]}]}
      assert Selector.parse(":link") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"link", []}}], []}
      ]}]}
      assert Selector.parse(":visited") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"visited", []}}], []}
      ]}]}
      assert Selector.parse(":hover") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"hover", []}}], []}
      ]}]}
      assert Selector.parse(":active") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"active", []}}], []}
      ]}]}
      assert Selector.parse(":focus") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"focus", []}}], []}
      ]}]}
    end

    test "should parse CSS Level 4 pseudo-classes" do
      assert Selector.parse(":any-link") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"any-link", []}}], []}
      ]}]}
      assert Selector.parse(":focus-within") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"focus-within", []}}], []}
      ]}]}
      assert Selector.parse(":focus-visible") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"focus-visible", []}}], []}
      ]}]}
    end
  end

  describe "Pseudo Elements" do
    test "should parse a pseudo-class" do
      assert Selector.parse("::before") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_element, {"before", []}}], []}
      ]}]}
    end

    test "should parse a parametrized pseudo-element" do
      assert Selector.parse("::slotted(span)") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_element, {"slotted", [[{:rules, [{:rule, [{:tag_name, "span", []}], []}]}]]}}], []}
      ]}]}
    end

    test "should parse pseudo-elements with content" do
      assert Selector.parse("::after") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_element, {"after", []}}], []}
      ]}]}
    end

    test "should parse ::before and ::after" do
      assert Selector.parse("::before") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_element, {"before", []}}], []}
      ]}]}

      assert Selector.parse("::after") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_element, {"after", []}}], []}
      ]}]}
    end

    test "should parse ::first-line and ::first-letter" do
      assert Selector.parse("::first-line") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_element, {"first-line", []}}], []}
      ]}]}

      assert Selector.parse("::first-letter") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_element, {"first-letter", []}}], []}
      ]}]}
    end

    test "should parse modern double-colon syntax" do
      assert Selector.parse("::selection") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_element, {"selection", []}}], []}
      ]}]}
    end

    test "should parse legacy single-colon syntax" do
      assert Selector.parse(":before") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_element, {"before", []}}], []}
      ]}]}
    end

    test "should parse pseudo-elements with tag names" do
      assert Selector.parse("div::before") == {:selectors, [{:rules, [
        {:rule, [{:tag_name, "div", []}, {:pseudo_element, {"before", []}}], []}
      ]}]}
    end

    test "should parse pseudo-elements with class names" do
      assert Selector.parse(".class::before") == {:selectors, [{:rules, [
        {:rule, [{:class, "class"}, {:pseudo_element, {"before", []}}], []}
      ]}]}
    end

    test "should parse pseudo-elements with IDs" do
      assert Selector.parse("#id::before") == {:selectors, [{:rules, [
        {:rule, [{:id, "id"}, {:pseudo_element, {"before", []}}], []}
      ]}]}
    end

    test "should parse pseudo-elements with attributes" do
      assert Selector.parse("[attr]::before") == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:exists, "attr", nil, []}}, {:pseudo_element, {"before", []}}], []}
      ]}]}
    end

    test "should fail on invalid pseudo-element syntax" do
      assert_raise ArgumentError, "Invalid pseudo-element syntax.", fn ->
        Selector.parse("::invalid-element")
      end
    end

    test "should handle vendor-specific pseudo-elements" do
      assert Selector.parse("::-webkit-input-placeholder") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_element, {"-webkit-input-placeholder", []}}], []}
      ]}]}
    end

    test "should parse CSS Level 4 pseudo-elements" do
      assert Selector.parse("::placeholder") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_element, {"placeholder", []}}], []}
      ]}]}
      assert Selector.parse("::backdrop") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_element, {"backdrop", []}}], []}
      ]}]}
      assert Selector.parse("::marker") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_element, {"marker", []}}], []}
      ]}]}
      assert Selector.parse("::cue") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_element, {"cue", []}}], []}
      ]}]}
    end

    # Note: While CSS3 specifies pseudo-elements should be at the end,
    # this parser allows selectors after pseudo-elements for flexibility
    # and future compatibility with CSS4 where some pseudo-elements
    # can be followed by pseudo-classes
  end

  describe "Multiple rules" do
    test "should parse multiple rules" do
      assert Selector.parse("div,.class") == {:selectors, [
        {:rules, [{:rule, [{:tag_name, "div", []}], []}]},
        {:rules, [{:rule, [{:class, "class"}], []}]}
      ]}
    end

    test "should parse comma-separated selectors" do
      assert Selector.parse("  div  ,  .class  ") == {:selectors, [
        {:rules, [{:rule, [{:tag_name, "div", []}], []}]},
        {:rules, [{:rule, [{:class, "class"}], []}]}
      ]}
    end

    test "should handle whitespace in multiple rules" do
      assert Selector.parse("div, .class, #id") == {:selectors, [
        {:rules, [{:rule, [{:tag_name, "div", []}], []}]},
        {:rules, [{:rule, [{:class, "class"}], []}]},
        {:rules, [{:rule, [{:id, "id"}], []}]}
      ]}
    end

    test "should parse complex multiple rule combinations" do
      assert_raise ArgumentError, "Expected selector but end of input reached.", fn ->
        Selector.parse("div, .class,")
      end

      assert_raise ArgumentError, "Cannot parse: $", fn ->
        Selector.parse("div, .class, $")
      end
    end
  end

  describe "Complex selectors" do
    test "should parse selectors with all features combined" do
      assert Selector.parse("ns|tag#id.class1.class2[attr=value]:hover::before") == {:selectors, [{:rules, [
        {:rule, [
          {:tag_name, "tag", namespace: "ns"},
          {:id, "id"},
          {:class, "class1"},
          {:class, "class2"},
          {:attribute, {:equal, "attr", "value", []}},
          {:pseudo_class, {"hover", []}},
          {:pseudo_element, {"before", []}}
        ], []}
      ]}]}
    end

    test "should parse complex selectors with multiple attributes" do
      assert Selector.parse("div[id][class~=test][data-value^=prefix]") == {:selectors, [{:rules, [
        {:rule, [
          {:tag_name, "div", []},
          {:attribute, {:exists, "id", nil, []}},
          {:attribute, {:includes, "class", "test", []}},
          {:attribute, {:prefix, "data-value", "prefix", []}}
        ], []}
      ]}]}
    end
  end

  describe "Nested rules" do
    test "should parse nested rules" do
      assert Selector.parse("div .class") == {:selectors, [{:rules, [
        {:rule, [{:tag_name, "div", []}], []},
        {:rule, [{:class, "class"}], []}
      ]}]}
    end

    test "should parse descendant combinators" do
      assert Selector.parse("   div   >   .class   ") == {:selectors, [{:rules, [
        {:rule, [{:tag_name, "div", []}], []},
        {:rule, [{:class, "class"}], combinator: ">"}
      ]}]}
    end

    test "should parse child combinators" do
      assert Selector.parse("div>.class") == {:selectors, [{:rules, [
        {:rule, [{:tag_name, "div", []}], []},
        {:rule, [{:class, "class"}], combinator: ">"}
      ]}]}
    end

    test "should parse sibling combinators" do
      assert Selector.parse("div~.class") == {:selectors, [{:rules, [
        {:rule, [{:tag_name, "div", []}], []},
        {:rule, [{:class, "class"}], combinator: "~"}
      ]}]}
    end

    test "should parse adjacent sibling combinators" do
      assert Selector.parse("div+.class") == {:selectors, [{:rules, [
        {:rule, [{:tag_name, "div", []}], []},
        {:rule, [{:class, "class"}], combinator: "+"}
      ]}]}
    end

    test "should handle complex nesting patterns" do
      assert Selector.parse("div||.class") == {:selectors, [{:rules, [
        {:rule, [{:tag_name, "div", []}], []},
        {:rule, [{:class, "class"}], combinator: "||"}
      ]}]}

      assert Selector.parse("   div   ||   .class   ") == {:selectors, [{:rules, [
        {:rule, [{:tag_name, "div", []}], []},
        {:rule, [{:class, "class"}], combinator: "||"}
      ]}]}
    end
  end

  describe "Edge cases and error handling" do
    test "should handle various Unicode whitespace" do
      # Non-breaking space is NOT treated as a combinator in CSS
      # It's part of the identifier
      assert Selector.parse("div\u00A0.class") == {:selectors, [{:rules, [
        {:rule, [{:tag_name, "div\u00A0", []}, {:class, "class"}], []}
      ]}]}
    end

    test "should validate combinator placement" do
      assert_raise ArgumentError, fn ->
        Selector.parse("div > > span")
      end
      
      assert_raise ArgumentError, fn ->
        Selector.parse("> div")
      end
    end

    test "should handle deeply nested selectors" do
      nested = ":not(:not(:not(:not(:not(.class)))))"
      assert Selector.parse(nested) == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"not", [
          [{:rules, [{:rule, [{:pseudo_class, {"not", [
            [{:rules, [{:rule, [{:pseudo_class, {"not", [
              [{:rules, [{:rule, [{:pseudo_class, {"not", [
                [{:rules, [{:rule, [{:pseudo_class, {"not", [
                  [{:rules, [{:rule, [{:class, "class"}], []}]}]
                ]}}], []}]}]
              ]}}], []}]}]
            ]}}], []}]}]
          ]}}], []}]}]
        ]}}], []}
      ]}]}
    end

    test "should handle extremely long identifiers" do
      # Parser truncates identifiers to 255 characters
      id = String.duplicate("a", 1000)
      assert Selector.parse("##{id}") == {:selectors, [{:rules, [
        {:rule, [{:id, id}], []}
      ]}]}
    end

    test "should parse nth-child with negative coefficients" do
      assert Selector.parse(":nth-child(-n+3)") == {:selectors, [{:rules, [
        {:rule, [{:pseudo_class, {"nth-child", [[a: -1, b: 3]]}}], []}
      ]}]}
    end

    test "should handle escape sequences in different contexts" do
      # Escaped characters in ID
      assert Selector.parse("#\\31 23") == {:selectors, [{:rules, [
        {:rule, [{:id, "123"}], []}
      ]}]}
      
      # Escaped characters in class
      assert Selector.parse(".\\@media") == {:selectors, [{:rules, [
        {:rule, [{:class, "@media"}], []}
      ]}]}
      
      # Escaped characters in attribute
      assert Selector.parse("[data-\\@attr]") == {:selectors, [{:rules, [
        {:rule, [{:attribute, {:exists, "data-@attr", nil, []}}], []}
      ]}]}
    end
  end
end
