defmodule Selector.Parser.GuardsTest do
  use ExUnit.Case, async: true
  import Selector.Parser.Guards

  describe "is_whitespace/1" do
    test "recognizes CSS whitespace characters" do
      assert is_whitespace(0x0009)  # Tab
      assert is_whitespace(0x000A)  # Line Feed
      assert is_whitespace(0x000C)  # Form Feed
      assert is_whitespace(0x000D)  # Carriage Return
      assert is_whitespace(0x0020)  # Space
    end

    test "rejects non-whitespace characters" do
      refute is_whitespace(?a)
      refute is_whitespace(?1)
      refute is_whitespace(?.)
      refute is_whitespace(0x00A0)  # Non-breaking space (not CSS whitespace)
    end
  end

  describe "is_identifier_start_char/1" do
    test "accepts ASCII letters" do
      assert is_identifier_start_char(?a)
      assert is_identifier_start_char(?z)
      assert is_identifier_start_char(?A)
      assert is_identifier_start_char(?Z)
    end

    test "accepts underscore" do
      assert is_identifier_start_char(?_)
    end

    test "accepts non-ASCII characters" do
      assert is_identifier_start_char(0x00C0)  # À
      assert is_identifier_start_char(0x4E2D)  # 中 (Chinese character)
    end

    test "accepts UTF-8 letters from various scripts" do
      assert is_identifier_start_char(0x00E9)  # é (Latin-1 Supplement)
      assert is_identifier_start_char(0x0391)  # Α (Greek)
      assert is_identifier_start_char(0x0410)  # А (Cyrillic)
      assert is_identifier_start_char(0x05D0)  # א (Hebrew)
      assert is_identifier_start_char(0x0627)  # ا (Arabic)
      assert is_identifier_start_char(0x3042)  # あ (Hiragana)
      assert is_identifier_start_char(0x30A2)  # ア (Katakana)
      assert is_identifier_start_char(0xAC00)  # 가 (Hangul)
    end

    test "rejects digits" do
      refute is_identifier_start_char(?0)
      refute is_identifier_start_char(?9)
      refute is_identifier_start_char(0x0660)  # Arabic-Indic digit
    end

    test "rejects hyphens" do
      refute is_identifier_start_char(?-)
    end

    test "rejects ASCII control characters" do
      refute is_identifier_start_char(0x001F)
    end
  end

  describe "is_identifier_char/1" do
    test "accepts identifier start characters" do
      assert is_identifier_char(?a)
      assert is_identifier_char(?_)
      assert is_identifier_char(0x00C0)
    end

    test "accepts UTF-8 digits" do
      assert is_identifier_char(?0)
      assert is_identifier_char(?5)
      assert is_identifier_char(?9)
      assert is_identifier_char(0x0660)  # Arabic-Indic digit
      assert is_identifier_char(0x06F0)  # Extended Arabic-Indic digit
      assert is_identifier_char(0x0966)  # Devanagari digit
      assert is_identifier_char(0xFF10)  # Fullwidth digit
    end

    test "accepts hyphens" do
      assert is_identifier_char(?-)
    end

    test "rejects special characters" do
      refute is_identifier_char(?.)
      refute is_identifier_char(?#)
      refute is_identifier_char(?@)
    end
  end

  describe "is_string_char/1" do
    test "accepts regular characters" do
      assert is_string_char(?a)
      assert is_string_char(?1)
      assert is_string_char(?!)
      assert is_string_char(0x00C0)
    end

    test "accepts UTF-8 characters" do
      assert is_string_char(0x4E2D)  # 中 (Chinese)
      assert is_string_char(0x0391)  # Α (Greek)
      assert is_string_char(0x0627)  # ا (Arabic)
    end

    test "rejects quote characters" do
      refute is_string_char(0x0022)  # Double quote
      refute is_string_char(0x0027)  # Single quote
    end

    test "rejects backslash" do
      refute is_string_char(0x005C)
    end

    test "rejects newlines including Unicode newlines" do
      refute is_string_char(0x000A)  # Line Feed
      refute is_string_char(0x000C)  # Form Feed
      refute is_string_char(0x000D)  # Carriage Return
      refute is_string_char(0x0085)  # Next Line (NEL)
      refute is_string_char(0x2028)  # Line Separator
      refute is_string_char(0x2029)  # Paragraph Separator
    end
  end

  describe "is_combinator_char/1" do
    test "recognizes single-character combinator characters" do
      assert is_combinator_char(0x003E)  # > (child combinator)
      assert is_combinator_char(0x002B)  # + (adjacent sibling combinator)
      assert is_combinator_char(0x007E)  # ~ (general sibling combinator)
    end

    test "rejects non-combinator characters" do
      refute is_combinator_char(?a)
      refute is_combinator_char(?1)
      refute is_combinator_char(0x0020)  # Space (descendant combinator handled separately)
      refute is_combinator_char(?|)      # Pipe (column combinator needs two ||)
    end

    test "rejects other special characters" do
      refute is_combinator_char(?.)
      refute is_combinator_char(?#)
      refute is_combinator_char(?:)
      refute is_combinator_char(?[)
      refute is_combinator_char(?])
      refute is_combinator_char(?=)
    end
  end

  describe "is_combinator/1 (backward compatibility)" do
    test "recognizes combinator characters" do
      assert is_combinator(0x003E)  # >
      assert is_combinator(0x002B)  # +
      assert is_combinator(0x007E)  # ~
    end

    test "rejects non-combinator characters" do
      refute is_combinator(?a)
      refute is_combinator(?1)
      refute is_combinator(0x0020)  # Space (descendant combinator handled separately)
    end
  end

  describe "is_delimiter/1" do
    test "recognizes delimiter characters" do
      assert is_delimiter(0x0023)  # #
      assert is_delimiter(0x002E)  # .
      assert is_delimiter(0x003A)  # :
      assert is_delimiter(0x005B)  # [
      assert is_delimiter(0x005D)  # ]
      assert is_delimiter(0x0028)  # (
      assert is_delimiter(0x0029)  # )
      assert is_delimiter(0x002C)  # ,
      assert is_delimiter(0x0022)  # "
      assert is_delimiter(0x0027)  # '
      assert is_delimiter(0x005C)  # \
    end

    test "rejects non-delimiter characters" do
      refute is_delimiter(?a)
      refute is_delimiter(?1)
      refute is_delimiter(?=)
    end
  end

  describe "is_attribute_operator_char/1" do
    test "recognizes attribute operator characters" do
      assert is_attribute_operator_char(0x003D)  # =
      assert is_attribute_operator_char(0x007E)  # ~
      assert is_attribute_operator_char(0x007C)  # |
      assert is_attribute_operator_char(0x005E)  # ^
      assert is_attribute_operator_char(0x0024)  # $
      assert is_attribute_operator_char(0x002A)  # *
    end

    test "rejects non-operator characters" do
      refute is_attribute_operator_char(?a)
      refute is_attribute_operator_char(?1)
      refute is_attribute_operator_char(?!)
    end
  end

  describe "is_hex_digit/1" do
    test "recognizes ASCII hexadecimal digits" do
      assert is_hex_digit(?0)
      assert is_hex_digit(?9)
      assert is_hex_digit(?a)
      assert is_hex_digit(?f)
      assert is_hex_digit(?A)
      assert is_hex_digit(?F)
    end

    test "rejects fullwidth hexadecimal digits" do
      refute is_hex_digit(0xFF10)  # Fullwidth 0
      refute is_hex_digit(0xFF19)  # Fullwidth 9
      refute is_hex_digit(0xFF21)  # Fullwidth A
      refute is_hex_digit(0xFF26)  # Fullwidth F
      refute is_hex_digit(0xFF41)  # Fullwidth a
      refute is_hex_digit(0xFF46)  # Fullwidth f
    end

    test "rejects non-hex characters" do
      refute is_hex_digit(?g)
      refute is_hex_digit(?G)
      refute is_hex_digit(?!)
    end
  end

  describe "is_escapable_char/1" do
    test "accepts most characters" do
      assert is_escapable_char(?a)
      assert is_escapable_char(?1)
      assert is_escapable_char(?!)
      assert is_escapable_char(?#)
      assert is_escapable_char(0x0020)  # Space
    end

    test "accepts UTF-8 characters" do
      assert is_escapable_char(0x4E2D)  # 中 (Chinese)
      assert is_escapable_char(0x0391)  # Α (Greek)
    end

    test "rejects newlines including Unicode newlines" do
      refute is_escapable_char(0x000A)  # Line Feed
      refute is_escapable_char(0x000C)  # Form Feed
      refute is_escapable_char(0x000D)  # Carriage Return
      refute is_escapable_char(0x0085)  # Next Line (NEL)
      refute is_escapable_char(0x2028)  # Line Separator
      refute is_escapable_char(0x2029)  # Paragraph Separator
    end
  end

  describe "id selector guards" do
    test "is_id_start_char/1 follows identifier start rules" do
      assert is_id_start_char(?a)
      assert is_id_start_char(?_)
      assert is_id_start_char(0x00C0)
      assert is_id_start_char(0x4E2D)  # 中 (Chinese)
      refute is_id_start_char(?1)
      refute is_id_start_char(?-)
    end

    test "is_id_char/1 follows identifier rules" do
      assert is_id_char(?a)
      assert is_id_char(?1)
      assert is_id_char(?-)
      assert is_id_char(?_)
      assert is_id_char(0x4E2D)  # 中 (Chinese)
      assert is_id_char(0x0660)  # Arabic-Indic digit
      refute is_id_char(?.)
      refute is_id_char(?#)
    end
  end

  describe "class selector guards" do
    test "is_class_start_char/1 follows identifier start rules" do
      assert is_class_start_char(?a)
      assert is_class_start_char(?_)
      assert is_class_start_char(0x0391)  # Α (Greek)
      refute is_class_start_char(?1)
      refute is_class_start_char(?-)
    end

    test "is_class_char/1 follows identifier rules" do
      assert is_class_char(?a)
      assert is_class_char(?1)
      assert is_class_char(?-)
      assert is_class_char(0x3042)  # あ (Hiragana)
      refute is_class_char(?.)
    end
  end

  describe "element selector guards" do
    test "is_tag_name_start_char/1 follows identifier start rules" do
      assert is_tag_name_start_char(?d)  # div
      assert is_tag_name_start_char(?s)  # span
      assert is_tag_name_start_char(0x30A2)  # ア (Katakana)
      refute is_tag_name_start_char(?1)
    end

    test "is_tag_name_char/1 follows identifier rules" do
      assert is_tag_name_char(?d)
      assert is_tag_name_char(?1)
      assert is_tag_name_char(?-)
      assert is_tag_name_char(0xAC00)  # 가 (Hangul)
    end
  end

  describe "attribute selector guards" do
    test "is_attribute_name_start_char/1 follows identifier start rules" do
      assert is_attribute_name_start_char(?c)  # class
      assert is_attribute_name_start_char(?d)  # data-*
      assert is_attribute_name_start_char(0x0627)  # ا (Arabic)
      refute is_attribute_name_start_char(?1)
    end

    test "is_attribute_name_char/1 follows identifier rules" do
      assert is_attribute_name_char(?c)
      assert is_attribute_name_char(?1)
      assert is_attribute_name_char(?-)  # data-attribute
      assert is_attribute_name_char(0x05D0)  # א (Hebrew)
    end
  end

  describe "pseudo selector guards" do
    test "is_pseudo_name_start_char/1 follows identifier start rules" do
      assert is_pseudo_name_start_char(?h)  # hover
      assert is_pseudo_name_start_char(?f)  # first-child
      assert is_pseudo_name_start_char(0x0410)  # А (Cyrillic)
      refute is_pseudo_name_start_char(?1)
    end

    test "is_pseudo_name_char/1 follows identifier rules" do
      assert is_pseudo_name_char(?h)
      assert is_pseudo_name_char(?1)
      assert is_pseudo_name_char(?-)  # first-child
      assert is_pseudo_name_char(0x4E2D)  # 中 (Chinese)
    end
  end

  describe "function guards" do
    test "is_function_name_start_char/1 follows identifier start rules" do
      assert is_function_name_start_char(?n)  # nth-child
      assert is_function_name_start_char(?u)  # url
      assert is_function_name_start_char(0x00E9)  # é
      refute is_function_name_start_char(?1)
    end

    test "is_function_name_char/1 follows identifier rules" do
      assert is_function_name_char(?n)
      assert is_function_name_char(?1)
      assert is_function_name_char(?-)  # nth-child
      assert is_function_name_char(0x0391)  # Α (Greek)
    end
  end

  describe "is_number_char/1" do
    test "accepts UTF-8 digits" do
      assert is_number_char(?0)
      assert is_number_char(?5)
      assert is_number_char(?9)
      assert is_number_char(0x0660)  # Arabic-Indic digit
      assert is_number_char(0x0966)  # Devanagari digit
      assert is_number_char(0xFF10)  # Fullwidth digit
    end

    test "accepts decimal point" do
      assert is_number_char(?.)
    end

    test "accepts signs" do
      assert is_number_char(?+)
      assert is_number_char(?-)
    end

    test "accepts scientific notation" do
      assert is_number_char(?e)
      assert is_number_char(?E)
    end

    test "rejects other characters" do
      refute is_number_char(?a)
      refute is_number_char(?!)
    end
  end

  describe "is_number_start_char/1" do
    test "accepts UTF-8 digits" do
      assert is_number_start_char(?0)
      assert is_number_start_char(?9)
      assert is_number_start_char(0x0660)  # Arabic-Indic digit
      assert is_number_start_char(0xFF10)  # Fullwidth digit
    end

    test "accepts decimal point" do
      assert is_number_start_char(?.)
    end

    test "accepts signs" do
      assert is_number_start_char(?+)
      assert is_number_start_char(?-)
    end

    test "rejects scientific notation at start" do
      refute is_number_start_char(?e)
      refute is_number_start_char(?E)
    end
  end

  describe "is_comment_char/1" do
    test "accepts most characters" do
      assert is_comment_char(?a)
      assert is_comment_char(?1)
      assert is_comment_char(?!)
      assert is_comment_char(0x0020)
    end

    test "accepts UTF-8 characters" do
      assert is_comment_char(0x4E2D)  # 中 (Chinese)
      assert is_comment_char(0x0391)  # Α (Greek)
    end

    test "accepts all characters (sequence detection happens at parser level)" do
      assert is_comment_char(0x002A)  # * (valid individually)
      assert is_comment_char(0x002F)  # / (valid individually)
      # Note: The parser must handle */ sequence detection
    end
  end

  describe "is_attribute_value_char/1" do
    test "accepts regular characters" do
      assert is_attribute_value_char(?a)
      assert is_attribute_value_char(?z)
      assert is_attribute_value_char(?A)
      assert is_attribute_value_char(?Z)
      assert is_attribute_value_char(?0)
      assert is_attribute_value_char(?9)
    end

    test "accepts special characters commonly used in attribute values" do
      assert is_attribute_value_char(?!)
      assert is_attribute_value_char(?@)
      assert is_attribute_value_char(?#)
      assert is_attribute_value_char(?$)
      assert is_attribute_value_char(?%)
      assert is_attribute_value_char(?^)
      assert is_attribute_value_char(?&)
      assert is_attribute_value_char(?*)
      assert is_attribute_value_char(?()
      assert is_attribute_value_char(?))
      assert is_attribute_value_char(?-)
      assert is_attribute_value_char(?_)
      assert is_attribute_value_char(?=)
      assert is_attribute_value_char(?+)
      assert is_attribute_value_char(?{)
      assert is_attribute_value_char(?})
      assert is_attribute_value_char(?[)
      assert is_attribute_value_char(?|)
      assert is_attribute_value_char(?;)
      assert is_attribute_value_char(?:)
      assert is_attribute_value_char(?<)
      assert is_attribute_value_char(?>)
      assert is_attribute_value_char(?.)
      assert is_attribute_value_char(?,)
      assert is_attribute_value_char(?/)
      assert is_attribute_value_char(??)
      assert is_attribute_value_char(?`)
      assert is_attribute_value_char(?~)
    end

    test "accepts UTF-8 characters" do
      assert is_attribute_value_char(0x00C0)  # À
      assert is_attribute_value_char(0x4E2D)  # 中 (Chinese)
      assert is_attribute_value_char(0x0391)  # Α (Greek)
      assert is_attribute_value_char(0x0410)  # А (Cyrillic)
      assert is_attribute_value_char(0x05D0)  # א (Hebrew)
      assert is_attribute_value_char(0x0627)  # ا (Arabic)
      assert is_attribute_value_char(0x3042)  # あ (Hiragana)
      assert is_attribute_value_char(0x30A2)  # ア (Katakana)
      assert is_attribute_value_char(0xAC00)  # 가 (Hangul)
    end

    test "rejects attribute selector end bracket" do
      refute is_attribute_value_char(0x005D)  # ]
    end

    test "rejects quote characters" do
      refute is_attribute_value_char(0x0022)  # " (double quote)
      refute is_attribute_value_char(0x0027)  # ' (single quote)
    end

    test "rejects backslash (needs escaping)" do
      refute is_attribute_value_char(0x005C)  # \
    end

    test "rejects newlines including Unicode newlines" do
      refute is_attribute_value_char(0x000A)  # Line Feed
      refute is_attribute_value_char(0x000C)  # Form Feed
      refute is_attribute_value_char(0x000D)  # Carriage Return
      refute is_attribute_value_char(0x0085)  # Next Line (NEL)
      refute is_attribute_value_char(0x2028)  # Line Separator
      refute is_attribute_value_char(0x2029)  # Paragraph Separator
    end

    test "rejects whitespace (for unquoted values)" do
      refute is_attribute_value_char(0x0009)  # Tab
      refute is_attribute_value_char(0x000A)  # Line Feed
      refute is_attribute_value_char(0x000C)  # Form Feed
      refute is_attribute_value_char(0x000D)  # Carriage Return
      refute is_attribute_value_char(0x0020)  # Space
    end
  end

  describe "is_selector_start_char/1" do
    test "accepts element name start characters" do
      assert is_selector_start_char(?d)  # div
      assert is_selector_start_char(?s)  # span
      assert is_selector_start_char(?_)  # custom elements
      assert is_selector_start_char(?|)  # ns
      assert is_selector_start_char(0x4E2D)  # 中 (Chinese element name)
    end

    test "accepts selector prefix characters" do
      assert is_selector_start_char(?.)  # .class
      assert is_selector_start_char(?#)  # #id
      assert is_selector_start_char(?[)  # [attr]
      assert is_selector_start_char(?:)  # :pseudo (including :is(), :not(), etc.)
      assert is_selector_start_char(?*)  # * (universal selector)
    end

    test "accepts colon for pseudo-class selectors" do
      # This is a specific test to ensure : works for selectors like :is(div)
      assert is_selector_start_char(?:)
    end

    test "accepts whitespace" do
      assert is_selector_start_char(0x0020)  # Space
      assert is_selector_start_char(0x0009)  # Tab
      assert is_selector_start_char(0x000A)  # Line Feed
    end

    test "rejects invalid start characters" do
      refute is_selector_start_char(?1)   # Numbers can't start selectors
      refute is_selector_start_char(?-)   # Hyphens can't start selectors
      refute is_selector_start_char(?!)   # Invalid characters
      refute is_selector_start_char(?=)   # Operators
    end
  end

  # UTF-8 utility guards are not implemented in the original code
  # describe "UTF-8 utility guards" do
  #   # These tests are commented out as the corresponding guards are not implemented
  #   # in the original code. If you need this functionality, you'll need to implement
  #   # the guards in Selector.Parser.Guards.
  # end

  describe "integration tests" do
    test "can validate common CSS selector patterns" do
      # Element selector: "div"
      assert is_selector_start_char(?d)
      assert is_tag_name_char(?i)
      assert is_tag_name_char(?v)

      # Class selector: ".my-class"
      assert is_selector_start_char(?.)
      assert is_class_start_char(?m)
      assert is_class_char(?y)
      assert is_class_char(?-)
      assert is_class_char(?c)

      # ID selector: "#user_123"
      assert is_selector_start_char(?#)
      assert is_id_start_char(?u)
      assert is_id_char(?s)
      assert is_id_char(?e)
      assert is_id_char(?r)
      assert is_id_char(?_)
      assert is_id_char(?1)

      # Pseudo-class: ":nth-child"
      assert is_selector_start_char(?:)
      assert is_pseudo_name_start_char(?n)
      assert is_pseudo_name_char(?t)
      assert is_pseudo_name_char(?h)
      assert is_pseudo_name_char(?-)
      assert is_pseudo_name_char(?c)

      # Attribute selector: "[data-value='test']"
      assert is_selector_start_char(?[)
      assert is_attribute_name_start_char(?d)
      assert is_attribute_name_char(?a)
      assert is_attribute_name_char(?t)
      assert is_attribute_name_char(?a)
      assert is_attribute_name_char(?-)
      assert is_attribute_operator_char(?=)
      assert is_string_char(?t)
      assert is_string_char(?e)
      assert is_string_char(?s)
      assert is_string_char(?t)
    end

    test "can validate international CSS selector patterns" do
      # Chinese element selector: "标题"
      assert is_selector_start_char(0x6807)  # 标
      assert is_tag_name_char(0x9898)    # 题

      # Greek class selector: ".Αλφα"
      assert is_selector_start_char(?.)
      assert is_class_start_char(0x0391)     # Α
      assert is_class_char(0x03BB)           # λ
      assert is_class_char(0x03C6)           # φ
      assert is_class_char(0x03B1)           # α

      # Arabic ID selector: "#مثال"
      assert is_selector_start_char(?#)
      assert is_id_start_char(0x0645)        # م
      assert is_id_char(0x062B)              # ث
      assert is_id_char(0x0627)              # ا
      assert is_id_char(0x0644)              # ل

      # Japanese attribute with Arabic-Indic numbers: "[データ-値='١٢٣']"
      assert is_selector_start_char(?[)
      assert is_attribute_name_start_char(0x30C7)  # デ
      assert is_attribute_name_char(0x30FC)        # ー
      assert is_attribute_name_char(0x30BF)        # タ
      assert is_attribute_name_char(?-)
      assert is_attribute_name_char(0x5024)        # 値
      assert is_attribute_operator_char(?=)
      assert is_string_char(0x0661)                # ١ (Arabic-Indic digit 1)
      assert is_string_char(0x0662)                # ٢ (Arabic-Indic digit 2)
      assert is_string_char(0x0663)                # ٣ (Arabic-Indic digit 3)
    end
  end

  describe "is_pseudo_start_char/1" do
    test "accepts ASCII letters as first character" do
      assert is_pseudo_start_char(?a)
      assert is_pseudo_start_char(?z)
      assert is_pseudo_start_char(?A)
      assert is_pseudo_start_char(?Z)
    end

    test "accepts underscore as first character" do
      assert is_pseudo_start_char(?_)
    end

    test "accepts hyphen as first character (for vendor prefixes)" do
      assert is_pseudo_start_char(?-)  # -webkit-scrollbar, -moz-placeholder, etc.
    end

    test "accepts non-ASCII characters as first character" do
      assert is_pseudo_start_char(0x00C0)  # À
      assert is_pseudo_start_char(0x4E2D)  # 中 (Chinese character)
      assert is_pseudo_start_char(0x30D2)  # ヒ (Katakana)
    end

    test "rejects digits as first character" do
      refute is_pseudo_start_char(?0)
      refute is_pseudo_start_char(?9)
    end

    test "rejects other special characters as first character" do
      refute is_pseudo_start_char(?()
      refute is_pseudo_start_char(?))
      refute is_pseudo_start_char(?\s)
      refute is_pseudo_start_char(?.)
      refute is_pseudo_start_char(?@)
    end
  end

  describe "is_pseudo_char/1" do
    test "accepts all valid start characters" do
      assert is_pseudo_char(?a)
      assert is_pseudo_char(?Z)
      assert is_pseudo_char(?-)
      assert is_pseudo_char(?_)
      assert is_pseudo_char(0x4E2D)  # 中 (Chinese character)
    end

    test "additionally accepts digits" do
      assert is_pseudo_char(?0)
      assert is_pseudo_char(?9)
    end

    test "rejects parentheses (not part of pseudo-class name)" do
      refute is_pseudo_char(?()
      refute is_pseudo_char(?))
    end

    test "rejects whitespace (not part of pseudo-class name)" do
      refute is_pseudo_char(?\s)
      refute is_pseudo_char(0x0009)  # Tab
    end

    test "rejects invalid characters" do
      refute is_pseudo_char(?@)
      refute is_pseudo_char(?[)
      refute is_pseudo_char(?])
      refute is_pseudo_char(?{)
      refute is_pseudo_char(?})
      refute is_pseudo_char(?=)
      refute is_pseudo_char(?~)
      refute is_pseudo_char(?+)  # Plus sign not part of name
    end
  end

  describe "pseudo-class examples" do
    test ":hover example" do
      assert is_pseudo_start_char(?h)
      assert is_pseudo_char(?o)
      assert is_pseudo_char(?v)
      assert is_pseudo_char(?e)
      assert is_pseudo_char(?r)
    end

    test ":nth-child(2n+1) example" do
      assert is_pseudo_start_char(?n)
      assert is_pseudo_char(?t)
      assert is_pseudo_char(?h)
      assert is_pseudo_char(?-)
      assert is_pseudo_char(?c)
      assert is_pseudo_char(?h)
      assert is_pseudo_char(?i)
      assert is_pseudo_char(?l)
      assert is_pseudo_char(?d)
      # Note: The parentheses and content are NOT part of the pseudo-class name
      # They would be parsed separately as functional notation
      refute is_pseudo_char(?()
      # The following would be parsed as part of the argument, not the name
      refute is_pseudo_char(?+)
      refute is_pseudo_char(?))
    end

    test ":lang(fr) example" do
      assert is_pseudo_start_char(?l)
      assert is_pseudo_char(?a)
      assert is_pseudo_char(?n)
      assert is_pseudo_char(?g)
      # Parentheses are not part of the pseudo-class name
      refute is_pseudo_char(?()
      refute is_pseudo_char(?))
    end
  end

  describe "is_lang_char/1" do
    test "accepts ASCII letters" do
      assert is_lang_char(?a)
      assert is_lang_char(?z)
      assert is_lang_char(?A)
      assert is_lang_char(?Z)
    end

    test "accepts ASCII digits" do
      assert is_lang_char(?0)
      assert is_lang_char(?9)
    end

    test "accepts hyphen as separator" do
      assert is_lang_char(?-)
    end

    test "rejects non-ASCII letters" do
      refute is_lang_char(0x00E9)  # é
      refute is_lang_char(0x4E2D)  # 中
      refute is_lang_char(0x0391)  # Α (Greek)
    end

    test "rejects non-ASCII digits" do
      refute is_lang_char(0x0660)  # Arabic-Indic digit
      refute is_lang_char(0xFF10)  # Fullwidth digit
    end

    test "rejects other characters" do
      refute is_lang_char(?_)
      refute is_lang_char(?.)
      refute is_lang_char(?@)
      refute is_lang_char(?!)
      refute is_lang_char(?\s)
    end
  end

  describe "is_lang_start_char/1" do
    test "accepts ASCII letters" do
      assert is_lang_start_char(?a)
      assert is_lang_start_char(?z)
      assert is_lang_start_char(?A)
      assert is_lang_start_char(?Z)
    end

    test "rejects digits" do
      refute is_lang_start_char(?0)
      refute is_lang_start_char(?9)
    end

    test "rejects hyphen" do
      refute is_lang_start_char(?-)
    end

    test "rejects non-ASCII characters" do
      refute is_lang_start_char(0x00E9)  # é
      refute is_lang_start_char(0x4E2D)  # 中
    end
  end

  describe "language tag examples" do
    test "simple language codes" do
      # "en"
      assert is_lang_start_char(?e)
      assert is_lang_char(?n)
      
      # "fr"
      assert is_lang_start_char(?f)
      assert is_lang_char(?r)
    end

    test "language with region codes" do
      # "en-US"
      assert is_lang_start_char(?e)
      assert is_lang_char(?n)
      assert is_lang_char(?-)
      assert is_lang_char(?U)
      assert is_lang_char(?S)
      
      # "pt-BR"
      assert is_lang_start_char(?p)
      assert is_lang_char(?t)
      assert is_lang_char(?-)
      assert is_lang_char(?B)
      assert is_lang_char(?R)
    end

    test "complex language tags" do
      # "zh-Hans-CN" (Chinese, Simplified script, China)
      for char <- String.to_charlist("zh-Hans-CN") do
        assert is_lang_char(char)
      end
      
      # "en-GB-oed" (English, Great Britain, Oxford English Dictionary spelling)
      for char <- String.to_charlist("en-GB-oed") do
        assert is_lang_char(char)
      end
    end
  end

  describe "is_selector_char/1" do
    test "accepts all identifier characters" do
      assert is_selector_char(?a)
      assert is_selector_char(?Z)
      assert is_selector_char(?0)
      assert is_selector_char(?9)
      assert is_selector_char(?_)
      assert is_selector_char(?-)
      assert is_selector_char(0x4E2D)  # 中 (Chinese)
      assert is_selector_char(0x0391)  # Α (Greek)
    end

    test "accepts all delimiter characters" do
      assert is_selector_char(?#)  # ID selector
      assert is_selector_char(?.)  # Class selector
      assert is_selector_char(?:)  # Pseudo-class/element
      assert is_selector_char(?[)  # Attribute start
      assert is_selector_char(?])  # Attribute end
      assert is_selector_char(?()  # Function start
      assert is_selector_char(?))  # Function end
      assert is_selector_char(?,)  # Selector separator
      assert is_selector_char(?")  # String delimiter
      assert is_selector_char(?')  # String delimiter
      assert is_selector_char(?\\) # Escape character
    end

    test "accepts all combinator characters" do
      assert is_selector_char(?>)  # Child combinator
      assert is_selector_char(?+)  # Adjacent sibling
      assert is_selector_char(?~)  # General sibling
    end

    test "accepts whitespace characters" do
      assert is_selector_char(0x0009)  # Tab
      assert is_selector_char(0x000A)  # Line Feed
      assert is_selector_char(0x000C)  # Form Feed
      assert is_selector_char(0x000D)  # Carriage Return
      assert is_selector_char(0x0020)  # Space
    end

    test "accepts attribute operator characters" do
      assert is_selector_char(?=)  # Equal
      assert is_selector_char(?~)  # Includes (~=)
      assert is_selector_char(?|)  # Dash match (|=)
      assert is_selector_char(?^)  # Prefix (^=)
      assert is_selector_char(?$)  # Suffix ($=)
      assert is_selector_char(?*)  # Substring (*=)
    end

    test "accepts special selector characters" do
      assert is_selector_char(?*)  # Universal selector
      assert is_selector_char(?|)  # Namespace separator
      assert is_selector_char(?!)  # For :not()
    end

    test "accepts common punctuation for attribute values and strings" do
      assert is_selector_char(?/)
      assert is_selector_char(??)
      assert is_selector_char(?&)
      assert is_selector_char(?%)
      assert is_selector_char(?@)
      assert is_selector_char(?;)
      assert is_selector_char(?{)
      assert is_selector_char(?})
      assert is_selector_char(?<)
      assert is_selector_char(?>)
      assert is_selector_char(?`)
    end

    test "accepts UTF-8 characters from various scripts" do
      assert is_selector_char(0x00E9)  # é (Latin-1 Supplement)
      assert is_selector_char(0x0410)  # А (Cyrillic)
      assert is_selector_char(0x05D0)  # א (Hebrew)
      assert is_selector_char(0x0627)  # ا (Arabic)
      assert is_selector_char(0x3042)  # あ (Hiragana)
      assert is_selector_char(0x30A2)  # ア (Katakana)
      assert is_selector_char(0xAC00)  # 가 (Hangul)
      assert is_selector_char(0x0660)  # ٠ (Arabic-Indic digit)
      assert is_selector_char(0xFF10)  # ０ (Fullwidth digit)
    end

    test "accepts printable ASCII characters" do
      for codepoint <- 0x0021..0x007E do
        assert is_selector_char(codepoint), "Failed for codepoint #{codepoint} (#{<<codepoint::utf8>>})"
      end
    end

    test "rejects null character" do
      refute is_selector_char(0x0000)
    end

    test "rejects control characters below space (except whitespace)" do
      refute is_selector_char(0x0001)
      refute is_selector_char(0x0002)
      refute is_selector_char(0x0007)  # Bell
      refute is_selector_char(0x0008)  # Backspace
      refute is_selector_char(0x000B)  # Vertical Tab (not CSS whitespace)
      refute is_selector_char(0x000E)
      refute is_selector_char(0x000F)
      refute is_selector_char(0x001F)
    end

    test "rejects DEL character" do
      refute is_selector_char(0x007F)
    end

    test "rejects surrogate codepoints" do
      refute is_selector_char(0xD800)
      refute is_selector_char(0xDBFF)
      refute is_selector_char(0xDC00)
      refute is_selector_char(0xDFFF)
    end

    test "accepts non-breaking space and other Unicode spaces" do
      assert is_selector_char(0x00A0)  # Non-breaking space
      assert is_selector_char(0x2000)  # En quad
      assert is_selector_char(0x3000)  # Ideographic space
    end

    test "is_nth_formula_char/1 accepts ASCII digits" do
      assert is_nth_formula_char(?0)
      assert is_nth_formula_char(?5)
      assert is_nth_formula_char(?9)
    end

    test "is_nth_formula_char/1 accepts variable n (case-insensitive)" do
      assert is_nth_formula_char(?n)
      assert is_nth_formula_char(?N)
    end

    test "is_nth_formula_char/1 accepts letters for odd/even keywords (case-insensitive)" do
      assert is_nth_formula_char(?o)  # odd
      assert is_nth_formula_char(?O)
      assert is_nth_formula_char(?d)  # odd  
      assert is_nth_formula_char(?D)
      assert is_nth_formula_char(?e)  # even
      assert is_nth_formula_char(?E)
      assert is_nth_formula_char(?v)  # even
      assert is_nth_formula_char(?V)
    end

    test "is_nth_formula_char/1 accepts operators and signs" do
      assert is_nth_formula_char(?+)
      assert is_nth_formula_char(?-)
    end

    test "is_nth_formula_char/1 accepts CSS whitespace" do
      assert is_nth_formula_char(0x0020)  # Space
      assert is_nth_formula_char(0x0009)  # Tab
      assert is_nth_formula_char(0x000A)  # Line Feed
      assert is_nth_formula_char(0x000C)  # Form Feed
      assert is_nth_formula_char(0x000D)  # Carriage Return
    end

    test "is_nth_formula_char/1 rejects other letters" do
      refute is_nth_formula_char(?a)
      refute is_nth_formula_char(?z)
      refute is_nth_formula_char(?A)
      refute is_nth_formula_char(?Z)
      refute is_nth_formula_char(?m)
      refute is_nth_formula_char(?x)
    end

    test "is_nth_formula_char/1 rejects special characters not in nth-formulas" do
      refute is_nth_formula_char(?.)
      refute is_nth_formula_char(?#)
      refute is_nth_formula_char(?*)
      refute is_nth_formula_char(?/)
      refute is_nth_formula_char(?=)
      refute is_nth_formula_char(?!)
      refute is_nth_formula_char(?()
      refute is_nth_formula_char(?))
    end

    test "is_nth_formula_char/1 rejects non-ASCII digits" do
      refute is_nth_formula_char(0x0660)  # Arabic-Indic digit
      refute is_nth_formula_char(0xFF10)  # Fullwidth digit
    end

    test "is_nth_formula_char/1 rejects Unicode letters" do
      refute is_nth_formula_char(0x00E9)  # é
      refute is_nth_formula_char(0x4E2D)  # 中
    end

    test "is_nth_formula_starting_char/1 accepts ASCII digits as starting characters" do
      assert is_nth_formula_starting_char(?0)
      assert is_nth_formula_starting_char(?1)
      assert is_nth_formula_starting_char(?9)
    end

    test "is_nth_formula_starting_char/1 accepts signs as starting characters" do
      assert is_nth_formula_starting_char(?+)  # +2n+1, +n
      assert is_nth_formula_starting_char(?-)  # -n+3, -2n
    end

    test "is_nth_formula_starting_char/1 accepts variable n as starting character (case-insensitive)" do
      assert is_nth_formula_starting_char(?n)  # n+1, n
      assert is_nth_formula_starting_char(?N)
    end

    test "is_nth_formula_starting_char/1 accepts keyword starting letters (case-insensitive)" do
      assert is_nth_formula_starting_char(?o)  # odd
      assert is_nth_formula_starting_char(?O)
      assert is_nth_formula_starting_char(?e)  # even
      assert is_nth_formula_starting_char(?E)
    end

    test "is_nth_formula_starting_char/1 accepts leading CSS whitespace" do
      assert is_nth_formula_starting_char(0x0020)  # Space
      assert is_nth_formula_starting_char(0x0009)  # Tab
      assert is_nth_formula_starting_char(0x000A)  # Line Feed
      assert is_nth_formula_starting_char(0x000C)  # Form Feed
      assert is_nth_formula_starting_char(0x000D)  # Carriage Return
    end

    test "is_nth_formula_starting_char/1 rejects letters that cannot start nth-formulas" do
      refute is_nth_formula_starting_char(?d)  # 'd' can appear in "odd" but not start
      refute is_nth_formula_starting_char(?v)  # 'v' can appear in "even" but not start
      refute is_nth_formula_starting_char(?a)
      refute is_nth_formula_starting_char(?z)
      refute is_nth_formula_starting_char(?m)
    end

    test "is_nth_formula_starting_char/1 rejects special characters" do
      refute is_nth_formula_starting_char(?.)
      refute is_nth_formula_starting_char(?#)
      refute is_nth_formula_starting_char(?*)
      refute is_nth_formula_starting_char(?()
      refute is_nth_formula_starting_char(?))
      refute is_nth_formula_starting_char(?=)
    end

    test "is_nth_formula_starting_char/1 rejects non-ASCII digits" do
      refute is_nth_formula_starting_char(0x0660)  # Arabic-Indic digit
      refute is_nth_formula_starting_char(0xFF10)  # Fullwidth digit  
    end

    test "nth-formula validates simple integer formulas" do
      # "5"
      assert is_nth_formula_starting_char(?5)
      
      # "0"  
      assert is_nth_formula_starting_char(?0)
    end

    test "nth-formula validates keyword formulas" do
      # "odd"
      assert is_nth_formula_starting_char(?o)
      assert is_nth_formula_char(?d)
      assert is_nth_formula_char(?d)
      
      # "even"
      assert is_nth_formula_starting_char(?e)
      assert is_nth_formula_char(?v)
      assert is_nth_formula_char(?e)
      assert is_nth_formula_char(?n)
    end

    test "nth-formula validates An+B formulas" do
      # "2n+1"
      assert is_nth_formula_starting_char(?2)
      assert is_nth_formula_char(?n)
      assert is_nth_formula_char(?+)
      assert is_nth_formula_char(?1)
      
      # "-n+3"
      assert is_nth_formula_starting_char(?-)
      assert is_nth_formula_char(?n)
      assert is_nth_formula_char(?+)
      assert is_nth_formula_char(?3)
      
      # "3n-2"
      assert is_nth_formula_starting_char(?3)
      assert is_nth_formula_char(?n)
      assert is_nth_formula_char(?-)
      assert is_nth_formula_char(?2)
    end

    test "nth-formula validates formulas with whitespace" do
      # " 2n + 1 " (with spaces)
      assert is_nth_formula_starting_char(0x0020)  # Leading space
      assert is_nth_formula_char(?2)
      assert is_nth_formula_char(?n)
      assert is_nth_formula_char(0x0020)  # Space before +
      assert is_nth_formula_char(?+)
      assert is_nth_formula_char(0x0020)  # Space after +
      assert is_nth_formula_char(?1)
      assert is_nth_formula_char(0x0020)  # Trailing space
    end

    test "nth-formula validates n-only formulas" do
      # "n"
      assert is_nth_formula_starting_char(?n)
      
      # "+n"
      assert is_nth_formula_starting_char(?+)
      assert is_nth_formula_char(?n)
      
      # "-n"
      assert is_nth_formula_starting_char(?-)
      assert is_nth_formula_char(?n)
    end

    test "nth-formula validates coefficient-only formulas" do
      # "2n"
      assert is_nth_formula_starting_char(?2)
      assert is_nth_formula_char(?n)
      
      # "-3n"
      assert is_nth_formula_starting_char(?-)
      assert is_nth_formula_char(?3)
      assert is_nth_formula_char(?n)
    end

    test "comprehensive selector examples" do
      # Simple selector: div.class#id
      for char <- String.to_charlist("div.class#id") do
        assert is_selector_char(char)
      end

      # Complex selector: [data-value~="test"]:nth-child(2n+1)
      for char <- String.to_charlist("[data-value~=\"test\"]:nth-child(2n+1)") do
        assert is_selector_char(char)
      end

      # International selector: .クラス#标识符[атрибут="القيمة"]
      for char <- String.to_charlist(".クラス#标识符[атрибут=\"القيمة\"]") do
        assert is_selector_char(char)
      end

      # Namespace and combinators: ns|element > .class + #id ~ [attr]
      for char <- String.to_charlist("ns|element > .class + #id ~ [attr]") do
        assert is_selector_char(char)
      end
    end
  end
end
