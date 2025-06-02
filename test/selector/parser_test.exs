defmodule Selector.ParserTest do
  use ExUnit.Case

  describe "parse/1" do
    test "parses a regular valid identifier" do
      assert Selector.parse("#id") == [{:rule, [{:id, "id"}], []}]
    end

    test "parses an identifier starting with a hyphen" do
      assert Selector.parse("#-id") == [{:rule, [{:id, "-id"}], []}]
    end

    test "parses an identifier with hex-encoded characters" do
      ast_selector = [{:rule, [{:id, "hello\nworld"}], []}]

      for selector <- ["#hello\\aworld", "#hello\\a world", "#hello\\a\tworld", "#hello\\a\fworld",
                       "#hello\\a\nworld", "#hello\\a\rworld", "#hello\\a\r\nworld", "#hello\\00000aworld"] do
        assert Selector.parse(selector) == ast_selector
      end
    end

    test "fails on an identifier starting with multiple hyphens" do
      assert_raise ArgumentError, "Identifiers cannot start with two hyphens with strict mode on.", fn ->
        Selector.parse("#--id")
      end
    end

    test "fails on an identifier consisting of a single hyphen" do
      assert_raise ArgumentError, "Identifiers cannot consist of a single hyphen.", fn ->
        Selector.parse("#-")
      end
    end

    test "parses an identifier starting with multiple hyphens in non-strict mode" do
      assert Selector.parse("#--id", strict: false) == [{:rule, [{:id, "--id"}], []}]
    end

    test "fails on an identifier starting with a hyphen and followed with a digit" do
      assert_raise ArgumentError, "Identifiers cannot start with hyphens followed by digits.", fn ->
        Selector.parse("#-1")
      end

      assert_raise ArgumentError, "Identifiers cannot start with hyphens followed by digits.", fn ->
        Selector.parse("#--1", strict: false)
      end
    end

    test "parses an identifier consisting unicode characters" do
      assert Selector.parse("#ÈÈ") == [{:rule, [{:id, "ÈÈ"}], []}]
    end

    test "parses a tag name" do
      assert Selector.parse("div") == [{:rule, [{:tag_name, "div"}], []}]
    end

    test "parses a wildcard tag name" do
      assert Selector.parse("*") == [{:rule, [{:wildcard_tag}], []}]
    end

    test "parses an escaped star" do
      assert Selector.parse("\\*") == [{:rule, [{:tag_name, "*"}], []}]
    end

    test "parses multiple rules" do
      assert Selector.parse("div,.class") == [
          {:rule, [{:tag_name, "div"}], []},
          {:rule, [{:class, "class"}], []}
        ]
    end

    test "parses multiple rules with whitespace" do
      assert Selector.parse("  div  ,  .class  ") == [
          {:rule, [{:tag_name, "div"}], []},
          {:rule, [{:class, "class"}], []}
        ]
    end

    test "parses nested rules" do
      assert Selector.parse("div .class") == [
          {:rule, [{:tag_name, "div"}], []},
          {:rule, [{:class, "class"}], []}
        ]
    end

    test "parses nested rules with combinator" do
      assert Selector.parse("div>.class") == [
          {:rule, [{:tag_name, "div"}], []},
          {:rule, [{:class, "class"}], combinator: ">"}
        ]
    end

    test "parses nested rules with combinator and whitespace" do
      assert Selector.parse("   div   >   .class   ") == [
          {:rule, [{:tag_name, "div"}], []},
          {:rule, [{:class, "class"}], combinator: ">"}
        ]
    end

    test "parses nested rules with multichar combinator" do
      assert Selector.parse("div||.class") == [
          {:rule, [{:tag_name, "div"}], []},
          {:rule, [{:class, "class"}], combinator: "||"}
        ]
    end

    test "parses nested rules with multichar combinator and whitespace" do
      assert Selector.parse("   div   ||   .class   ") == [
          {:rule, [{:tag_name, "div"}], []},
          {:rule, [{:class, "class"}], combinator: "||"}
        ]
    end

    test "fails when no combinators are defined" do
      assert_raise ArgumentError, ~s(Expected rule but ">" found.), fn ->
        Selector.parse("div>span", syntax: %{combinators: false})
      end
    end

    test "parses pseudo-classes" do
      assert Selector.parse("div :first-child") == [{:rule, [{:tag_name, "div"}, {:pseudo_class, {:first_child, []}}], []}]
    end

    test "parses pseudo-elements" do
      assert Selector.parse("div::before") == [{:rule, [{:tag_name, "div"}, {:pseudo_element, {:before, []}}], []}]
    end

    test "parses attribute selectors" do
      assert Selector.parse("div[attr=value]") == [{:rule, [{:tag_name, "div"}, {:attribute, {:equal, "attr", "value"}}], []}]
    end

    test "parses complex selectors" do
      assert Selector.parse("div.class1.class2#id[attr=value]:first-child") == [{:rule, [{:tag_name, "div"}, {:class, "class1"}, {:class, "class2"}, {:id, "id"},
           {:attribute, {:equal, "attr", "value"}}, {:pseudo_class, {:first_child, []}}], []}]
    end

    test "parses namespace selectors" do
      assert Selector.parse("ns|div") == [{:rule, [{:tag_name, "div", namespace: "ns"}], []}]

      assert Selector.parse("|div") == [{:rule, [{:tag_name, "div", namespace: ""}], []}]

      assert Selector.parse("*|div") == [{:rule, [{:tag_name, "div", namespace: "*"}], []}]
    end

    test "parses universal selectors" do
      assert Selector.parse("*") == [{:rule, [{:universal}], []}]

      assert Selector.parse("ns|*") == [{:rule, [{:universal, namespace: "ns"}], []}]
    end

    test "parses complex combinators" do
      assert Selector.parse("div > .class + span ~ p") == [
          {:rule, [{:tag_name, "div"}], []},
          {:rule, [{:class, "class"}], combinator: ">"},
          {:rule, [{:tag_name, "span"}], combinator: "+"},
          {:rule, [{:tag_name, "p"}], combinator: "~"}
        ]
    end

    test "fails on invalid selectors" do
      assert_raise ArgumentError, ~s(Expected rule but "$" found.), fn ->
        Selector.parse("div, .class, $")
      end

      assert_raise ArgumentError, ~s(Expected rule but end of input reached.), fn ->
        Selector.parse("div, .class,")
      end
    end
  end
end
