defmodule Selector.ModulesTest do
  use ExUnit.Case

  describe "CSS Modules" do
    describe "css-position-1" do
      test "parses position-1 pseudo-classes when module is enabled" do
        assert Selector.parse(":static", modules: ["css-position-1"]) == [{
            {:rule, [{:pseudo_class, {:static, []}}], []}
          }]

        assert Selector.parse(":relative", modules: ["css-position-1"]) == [{
            {:rule, [{:pseudo_class, {:relative, []}}], []}
          }]

        assert Selector.parse(":absolute", modules: ["css-position-1"]) == [{
            {:rule, [{:pseudo_class, {:absolute, []}}], []}
          }]

        # Should reject fixed as it's not in position-1
        assert_raise ArgumentError, "Unknown pseudo-class: \"fixed\".", fn ->
          Selector.parse(":fixed", modules: ["css-position-1"], strict: true)
        end
      end
    end

    describe "css-position-2" do
      test "parses position-2 pseudo-classes when module is enabled" do
        assert Selector.parse(":fixed", modules: ["css-position-2"]) == [{
            {:rule, [{:pseudo_class, {:fixed, []}}], []}
          }]

        # Should reject sticky as it's not in position-2
        assert_raise ArgumentError, "Unknown pseudo-class: \"sticky\".", fn ->
          Selector.parse(":sticky", modules: ["css-position-2"], strict: true)
        end
      end
    end

    describe "css-position-3" do
      test "parses position pseudo-classes when module is enabled" do
        assert Selector.parse(":sticky", modules: ["css-position-3"]) == [{
            {:rule, [{:pseudo_class, {:sticky, []}}], []}
          }]

        assert Selector.parse(":fixed", modules: ["css-position-3"]) == [{
            {:rule, [{:pseudo_class, {:fixed, []}}], []}
          }]

        assert Selector.parse(":absolute", modules: ["css-position-3"]) == [{
            {:rule, [{:pseudo_class, {:absolute, []}}], []}
          }]
      end

      test "rejects position pseudo-classes when module is not enabled" do
        assert_raise ArgumentError, "Unknown pseudo-class: \"sticky\".", fn ->
          Selector.parse(":sticky", strict: true)
        end

        assert_raise ArgumentError, "Unknown pseudo-class: \"fixed\".", fn ->
          Selector.parse(":fixed", strict: true)
        end

        assert_raise ArgumentError, "Unknown pseudo-class: \"absolute\".", fn ->
          Selector.parse(":absolute", strict: true)
        end
      end
    end

    describe "css-pseudo-4" do
      test "parses pseudo-4 pseudo-elements when module is enabled" do
        assert Selector.parse("::marker", modules: ["css-pseudo-4"]) == [{
            {:rule, [{:pseudo_element, {:marker, []}}], []}
          }]
      end
    end

    describe "css-shadow-parts-1" do
      test "parses shadow-parts pseudo-elements when module is enabled" do
        assert Selector.parse("::part(button)", modules: ["css-shadow-parts-1"]) == [
          {:rule, [{:pseudo_element, {:part, [[{:rule, [{:tag_name, "button"}], []}]]}}], []}
        ]
      end
    end

    describe "Combining modules" do
      test "supports combining css-position and css-pseudo modules" do
        parse = fn selector ->
          Selector.parse(selector, modules: ["css-position-3", "css-pseudo-4"])
        end

        # Position pseudo-class
        assert parse.(":sticky") == [
          {:rule, [{:pseudo_class, {:sticky, []}}], []}
        ]

        # Pseudo-4 pseudo-element
        assert parse.("::marker") == [
          {:rule, [{:pseudo_element, {:marker, []}}], []}
        ]

        # Complex selector using both modules
        assert parse.("div:sticky:has(> img::marker)") == [
          {:rule, [
            {:tag_name, "div"},
            {:pseudo_class, {:sticky, []}},
            {:pseudo_class, {:has, [[{:rule, [{:tag_name, "img"}, {:pseudo_element, {:marker, []}}], combinator: ">"}]]}}
          ], []}
        ]
      end
    end

    describe "Syntax definition with modules" do
      test "supports modules defined in syntax definition" do
        parse = fn selector ->
          Selector.parse(selector, syntax: %{
            base_syntax: "selectors-3",
            pseudo_classes: %{unknown: "reject"},
            pseudo_elements: %{unknown: "reject"},
            modules: ["css-position-4", "css-shadow-parts-1"]
          })
        end

        # Should parse position-4 pseudo-classes
        assert parse.(":initial") == [
          {:rule, [{:pseudo_class, {:initial, []}}], []}
        ]

        # Should parse shadow-parts-1 pseudo-elements
        assert parse.("::part(button)") == [
          {:rule, [{:pseudo_element, {:part, [[{:rule, [{:tag_name, "button"}], []}]]}}], []}
        ]

        # Should reject pseudo-classes not in the modules
        assert_raise ArgumentError, "Unknown pseudo-class: \"focus-visible\".", fn ->
          parse.(":focus-visible")
        end
      end

      test "supports latest syntax with all latest modules" do
        parse = fn selector ->
          Selector.parse(selector, syntax: :latest)
        end

        # Should parse position-4 pseudo-classes
        assert parse.(":initial") == [
          {:rule, [{:pseudo_class, {:initial, []}}], []}
        ]

        # Should parse shadow-parts-1 pseudo-elements
        assert parse.("::part(button)") == [
          {:rule, [{:pseudo_element, {:part, [[{:rule, [{:tag_name, "button"}], []}]]}}], []}
        ]

        # Should parse pseudo-4 pseudo-elements
        assert parse.("::marker") == [
          {:rule, [{:pseudo_element, {:marker, []}}], []}
        ]

        # Should parse scoping-1 pseudo-classes
        assert parse.(":host") == [{
            {:rule, [{:pseudo_class, {:host, []}}], []}
          }]
      end

      test "provides helpful error messages with location information" do
        parse = fn selector ->
          Selector.parse(selector, syntax: %{
            pseudo_classes: %{unknown: "reject"},
            pseudo_elements: %{unknown: "reject"}
          })
        end

        # Test for pseudo-class defined in a CSS module
        assert_raise ArgumentError, ~r(Unknown pseudo-class: "sticky".*css-position-3), fn ->
          parse.(":sticky")
        end

        # Test for pseudo-element defined in a CSS module
        assert_raise ArgumentError, ~r(Unknown pseudo-element "part".*css-shadow-parts-1), fn ->
          parse.(":part(button)")
        end

        # Test for pseudo-class defined in a CSS level
        assert_raise ArgumentError, ~r(Unknown pseudo-class: "focus-visible".*selectors-4), fn ->
          parse.(":focus-visible")
        end
      end
    end

    describe "Module combinations" do
      test "supports combining multiple modules" do
        parse = fn selector ->
          Selector.parse(selector, modules: ["css-position-3", "css-pseudo-4", "css-shadow-parts-1"])
        end

        # Test combining all three modules
        assert parse.("div:sticky::marker::part(button)") == [{
            :rule,
            [{:tag_name, "div"}, {:pseudo_class, {:sticky, []}},
             {:pseudo_element, {:marker, []}},
             {:pseudo_element, {
               :part,
               [[{:rule, [{:tag_name, "button"}], []}]]
             }}]
          }]
      end
    end
  end
end
