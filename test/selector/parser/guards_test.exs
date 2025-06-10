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

  describe "is_combinator/1" do
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

    test "recognizes fullwidth hexadecimal digits" do
      assert is_hex_digit(0xFF10)  # Fullwidth 0
      assert is_hex_digit(0xFF19)  # Fullwidth 9
      assert is_hex_digit(0xFF21)  # Fullwidth A
      assert is_hex_digit(0xFF26)  # Fullwidth F
      assert is_hex_digit(0xFF41)  # Fullwidth a
      assert is_hex_digit(0xFF46)  # Fullwidth f
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

    test "rejects comment-related characters" do
      refute is_comment_char(0x002A)  # *
      refute is_comment_char(0x002F)  # /
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
      assert is_selector_start_char(?:)  # :pseudo
      assert is_selector_start_char(?*)  # *
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

    test "accepts underscore and hyphen as first character" do
      assert is_pseudo_start_char(?_)
      assert is_pseudo_start_char(?-)
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

    test "accepts parentheses for functional pseudo-classes" do
      assert is_pseudo_char(?()
      assert is_pseudo_char(?))
    end

    test "accepts whitespace for arguments" do
      assert is_pseudo_char(?\s)
      assert is_pseudo_char(0x0009)  # Tab
    end

    test "rejects invalid characters" do
      refute is_pseudo_char(?@)
      refute is_pseudo_char(?[)
      refute is_pseudo_char(?])
      refute is_pseudo_char(?{)
      refute is_pseudo_char(?})
      refute is_pseudo_char(?=)
      refute is_pseudo_char(?~)
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
      assert is_pseudo_char(?()
      assert is_pseudo_char(?2)
      assert is_pseudo_char(?n)
      assert is_pseudo_char(?+)
      assert is_pseudo_char(?1)
      assert is_pseudo_char(?))
    end

    test ":lang(fr) example" do
      assert is_pseudo_start_char(?l)
      assert is_pseudo_char(?a)
      assert is_pseudo_char(?n)
      assert is_pseudo_char(?g)
      assert is_pseudo_char(?()
      assert is_pseudo_char(?f)
      assert is_pseudo_char(?r)
      assert is_pseudo_char(?))
    end
  end
end
