 defmodule Selector.Parser.Guards do
  @moduledoc """
  Provides defguards for validating Unicode code points according to CSS Selector
  specification rules for different parts of a CSS selector.

  Based on CSS Syntax Module Level 3 and CSS Selectors Level 4 specifications.
  Enhanced with full UTF-8/Unicode support.
  """

  #--------------------------------------------------------------------------------
  # Region: Module Attributes (Character Sets and Forbidden Codepoints)
  #--------------------------------------------------------------------------------

  @whitespace_chars [
    0x0009, # Tab
    0x000A, # Line Feed
    0x000C, # Form Feed
    0x000D, # Carriage Return
    0x0020  # Space
  ]

  @combinator_chars [
    0x003E, # > (child combinator)
    0x002B, # + (adjacent sibling combinator)
    0x007E  # ~ (general sibling combinator)
  ]

  @delimiter_chars [
    0x0023, # # (hash/ID selector)
    0x002E, # . (class selector)
    0x003A, # : (pseudo-class/element)
    0x005B, # [ (attribute selector start)
    0x005D, # ] (attribute selector end)
    0x0028, # ( (function start)
    0x0029, # ) (function end)
    0x002C, # , (selector list separator)
    0x0022, # " (string delimiter)
    0x0027, # ' (string delimiter)
    0x005C  # \ (escape character)
  ]

  @attribute_operators [
    # Single character operators
    0x003D, # = (exact match)
    0x007E, # ~ (for ~=, word match)
    0x007C, # | (for |=, language match)
    0x005E, # ^ (for ^=, prefix match)
    0x0024, # $ (for $=, suffix match)
    0x002A  # * (for *=, substring match)
  ]

  #--------------------------------------------------------------------------------
  # Region: Private Helper Guards
  #--------------------------------------------------------------------------------

  defguard is_utf8_letter(codepoint) when
    is_integer(codepoint) and
    (
      # Basic Latin letters
      (codepoint >= ?a and codepoint <= ?z) or
      (codepoint >= ?A and codepoint <= ?Z) or
      # Latin-1 Supplement letters
      (codepoint >= 0x00C0 and codepoint <= 0x00D6) or
      (codepoint >= 0x00D8 and codepoint <= 0x00F6) or
      (codepoint >= 0x00F8 and codepoint <= 0x00FF) or
      # Latin Extended-A
      (codepoint >= 0x0100 and codepoint <= 0x017F) or
      # Latin Extended-B
      (codepoint >= 0x0180 and codepoint <= 0x024F) or
      # Greek and Coptic
      (codepoint >= 0x0370 and codepoint <= 0x03FF) or
      # Cyrillic
      (codepoint >= 0x0400 and codepoint <= 0x04FF) or
      # Hebrew
      (codepoint >= 0x0590 and codepoint <= 0x05FF) or
      # Arabic
      (codepoint >= 0x0600 and codepoint <= 0x06FF) or
      # CJK Unified Ideographs (Common range)
      (codepoint >= 0x4E00 and codepoint <= 0x9FFF) or
      # Hiragana
      (codepoint >= 0x3040 and codepoint <= 0x309F) or
      # Katakana
      (codepoint >= 0x30A0 and codepoint <= 0x30FF) or
      # Other common letter ranges
      (codepoint >= 0x1E00 and codepoint <= 0x1EFF) or # Latin Extended Additional
      (codepoint >= 0x2C60 and codepoint <= 0x2C7F) or # Latin Extended-C
      (codepoint >= 0xA720 and codepoint <= 0xA7FF) or # Latin Extended-D
      # Hangul Syllables
      (codepoint >= 0xAC00 and codepoint <= 0xD7AF) or
      # Additional Unicode letter blocks (basic coverage)
      (codepoint >= 0x0100 and codepoint <= 0x017F) or # Latin Extended-A
      (codepoint >= 0x1F00 and codepoint <= 0x1FFF)    # Greek Extended
    )

  defguard is_utf8_digit(codepoint) when
    is_integer(codepoint) and
    (
      # ASCII digits
      (codepoint >= ?0 and codepoint <= ?9) or
      # Arabic-Indic digits
      (codepoint >= 0x0660 and codepoint <= 0x0669) or
      # Extended Arabic-Indic digits
      (codepoint >= 0x06F0 and codepoint <= 0x06F9) or
      # Devanagari digits
      (codepoint >= 0x0966 and codepoint <= 0x096F) or
      # Bengali digits
      (codepoint >= 0x09E6 and codepoint <= 0x09EF) or
      # Fullwidth digits
      (codepoint >= 0xFF10 and codepoint <= 0xFF19)
    )

  defguardp is_utf8_hex_digit(codepoint) when
    is_integer(codepoint) and
    (
      (codepoint >= ?0 and codepoint <= ?9) or
      (codepoint >= ?a and codepoint <= ?f) or
      (codepoint >= ?A and codepoint <= ?F) or
      # Fullwidth hex digits
      (codepoint >= 0xFF10 and codepoint <= 0xFF19) or # 0-9
      (codepoint >= 0xFF21 and codepoint <= 0xFF26) or # A-F
      (codepoint >= 0xFF41 and codepoint <= 0xFF46)    # a-f
    )

  defguardp is_non_ascii(codepoint) when
    is_integer(codepoint) and codepoint >= 0x0080

  defguardp is_surrogate_codepoint(codepoint) when
    is_integer(codepoint) and
    (codepoint >= 0xD800 and codepoint <= 0xDFFF)

  defguardp is_newline(codepoint) when
    is_integer(codepoint) and
    (
      codepoint == 0x000A or # Line Feed
      codepoint == 0x000C or # Form Feed
      codepoint == 0x000D or # Carriage Return
      codepoint == 0x0085 or # Next Line (NEL)
      codepoint == 0x2028 or # Line Separator
      codepoint == 0x2029    # Paragraph Separator
    )

  defguardp is_unicode_whitespace(codepoint) when
    is_integer(codepoint) and
    (
      codepoint in @whitespace_chars or
      codepoint == 0x0085 or # Next Line (NEL)
      codepoint == 0x00A0 or # Non-breaking space
      codepoint == 0x1680 or # Ogham space mark
      (codepoint >= 0x2000 and codepoint <= 0x200A) or # Various spaces
      codepoint == 0x2028 or # Line separator
      codepoint == 0x2029 or # Paragraph separator
      codepoint == 0x202F or # Narrow no-break space
      codepoint == 0x205F or # Medium mathematical space
      codepoint == 0x3000    # Ideographic space
    )

  #--------------------------------------------------------------------------------
  # Region: Public Guards for CSS Selector Components
  #--------------------------------------------------------------------------------

  @doc """
  Guard: Checks if a codepoint is CSS whitespace.
  CSS whitespace includes: tab, line feed, form feed, carriage return, and space.
  Note: This follows CSS specification which only recognizes ASCII whitespace.
  """
  defguard is_whitespace(codepoint) when
    is_integer(codepoint) and codepoint in @whitespace_chars

  @doc """
  Guard: Checks if a codepoint is Unicode whitespace (broader than CSS whitespace).
  Includes various Unicode whitespace characters beyond CSS specification.
  """
  defguard is_unicode_whitespace_char(codepoint) when
    is_unicode_whitespace(codepoint)

  @doc """
  Guard: Checks if a codepoint can start a CSS identifier.
  Valid start characters: UTF-8 letters, underscore, non-ASCII, or escaped characters.
  """
  defguard is_identifier_start_char(codepoint) when
    is_integer(codepoint) and
    (
      (is_utf8_letter(codepoint) or
      codepoint == ?_ or                    # underscore
      is_non_ascii(codepoint)) and
      not is_utf8_digit(codepoint)          # explicitly exclude digits
    )

  @doc """
  Guard: Checks if a codepoint can continue a CSS identifier.
  Valid continuation characters: identifier start chars, UTF-8 digits, or hyphens.
  """
  defguard is_identifier_char(codepoint) when
    is_integer(codepoint) and
    (
      is_identifier_start_char(codepoint) or
      is_utf8_digit(codepoint) or
      codepoint == ?-                       # hyphen
    )

  @doc """
  Guard: Checks if a codepoint is valid inside a CSS string (excluding delimiters).
  Excludes the quote character, newlines, and unescaped backslashes.
  """
  defguard is_string_char(codepoint) when
    is_integer(codepoint) and
    not (
      codepoint == 0x0022 or               # double quote
      codepoint == 0x0027 or               # single quote
      codepoint == 0x005C or               # backslash
      is_newline(codepoint)
    )

  @doc """
  Guard: Checks if a codepoint is a CSS combinator character.
  """
  defguard is_combinator(codepoint) when
    is_integer(codepoint) and codepoint in @combinator_chars

  @doc """
  Guard: Checks if a codepoint is a CSS delimiter character.
  """
  defguard is_delimiter(codepoint) when
    is_integer(codepoint) and codepoint in @delimiter_chars

  @doc """
  Guard: Checks if a codepoint is part of a CSS attribute operator.
  """
  defguard is_attribute_operator_char(codepoint) when
    is_integer(codepoint) and codepoint in @attribute_operators

  @doc """
  Guard: Checks if a codepoint is a valid hexadecimal digit for CSS escape sequences.
  Now supports UTF-8 hexadecimal digits including fullwidth characters.
  """
  defguard is_hex_digit(codepoint) when
    is_utf8_hex_digit(codepoint)

  @doc """
  Guard: Checks if a codepoint can be escaped in CSS.
  Any character except newlines can be escaped in CSS.
  """
  defguard is_escapable_char(codepoint) when
    is_integer(codepoint) and
    not is_newline(codepoint)

  @doc """
  Guard: Checks if a codepoint is valid for CSS ID selector content (after #).
  Must be a valid identifier character with UTF-8 support.
  """
  defguard is_id_char(codepoint) when
    is_identifier_char(codepoint)

  @doc """
  Guard: Checks if a codepoint can start a CSS ID selector content (after #).
  Must be a valid identifier start character with UTF-8 support.
  """
  defguard is_id_start_char(codepoint) when
    is_identifier_start_char(codepoint)

  @doc """
  Guard: Checks if a codepoint is valid for CSS class selector content (after .).
  Must be a valid identifier character with UTF-8 support.
  """
  defguard is_class_char(codepoint) when
    is_identifier_char(codepoint)

  @doc """
  Guard: Checks if a codepoint can start a CSS class selector content (after .).
  Must be a valid identifier start character with UTF-8 support.
  """
  defguard is_class_start_char(codepoint) when
    is_identifier_start_char(codepoint)

  @doc """
  Guard: Checks if a codepoint is valid for CSS element/type selector names.
  Must be a valid identifier character with UTF-8 support.
  """
  defguard is_tag_name_char(codepoint) when
    is_identifier_char(codepoint)

  @doc """
  Guard: Checks if a codepoint can start a CSS element/type selector name.
  Must be a valid identifier start character with UTF-8 support.
  """
  defguard is_tag_name_start_char(codepoint) when
    is_identifier_start_char(codepoint)

  @doc """
  Guard: Checks if a codepoint is valid for CSS attribute names.
  Must be a valid identifier character with UTF-8 support.
  """
  defguard is_attribute_name_char(codepoint) when
    is_identifier_char(codepoint)

  @doc """
  Guard: Checks if a codepoint can start a CSS attribute name.
  Must be a valid identifier start character with UTF-8 support.
  """
  defguard is_attribute_name_start_char(codepoint) when
    is_identifier_start_char(codepoint)

  @doc """
  Guard: Checks if a codepoint is valid for CSS pseudo-class/element names.
  Must be a valid identifier character with UTF-8 support.
  """
  defguard is_pseudo_name_char(codepoint) when
    is_identifier_char(codepoint)

  @doc """
  Guard: Checks if a codepoint can start a CSS pseudo-class/element name.
  Must be a valid identifier start character with UTF-8 support.
  """
  defguard is_pseudo_name_start_char(codepoint) when
    is_identifier_start_char(codepoint)

  @doc """
  Guard: Checks if a codepoint is valid for CSS function names.
  Must be a valid identifier character with UTF-8 support.
  """
  defguard is_function_name_char(codepoint) when
    is_identifier_char(codepoint)

  @doc """
  Guard: Checks if a codepoint can start a CSS function name.
  Must be a valid identifier start character with UTF-8 support.
  """
  defguard is_function_name_start_char(codepoint) when
    is_identifier_start_char(codepoint)

  @doc """
  Guard: Checks if a codepoint is a valid CSS number character.
  Includes UTF-8 digits, decimal point, plus, minus, and e/E for scientific notation.
  """
  defguard is_number_char(codepoint) when
    is_integer(codepoint) and
    (
      is_utf8_digit(codepoint) or
      codepoint == ?. or                    # decimal point
      codepoint == ?+ or                    # plus sign
      codepoint == ?- or                    # minus sign
      codepoint == ?e or                    # scientific notation
      codepoint == ?E                       # scientific notation
    )

  @doc """
  Guard: Checks if a codepoint can start a CSS number.
  Can start with UTF-8 digit, decimal point, plus, or minus.
  """
  defguard is_number_start_char(codepoint) when
    is_integer(codepoint) and
    (
      is_utf8_digit(codepoint) or
      codepoint == ?. or                    # decimal point
      codepoint == ?+ or                    # plus sign
      codepoint == ?-                       # minus sign
    )

  @doc """
  Guard: Checks if a codepoint is valid within CSS comment content.
  Excludes only the comment end sequence characters when they appear together.
  """
  defguard is_comment_char(codepoint) when
    is_integer(codepoint) and
    codepoint != 0x002A and                 # * (when not followed by /)
    codepoint != 0x002F                     # / (when not preceded by *)

  @doc """
  Guard: Checks if a codepoint is valid for CSS attribute values.
  Attribute values can contain any character except:
  - The delimiter being used (quote or apostrophe)
  - Newlines (unless escaped)
  - Unescaped backslashes
  This guard assumes unquoted values and allows most characters.
  """
  defguard is_attribute_value_char(codepoint) when
    is_integer(codepoint) and
    not (
      codepoint == 0x005D or               # ] (attribute selector end)
      codepoint == 0x0022 or               # " (double quote)
      codepoint == 0x0027 or               # ' (single quote)
      codepoint == 0x005C or               # \ (backslash - needs escaping)
      is_newline(codepoint) or             # Newlines
      is_whitespace(codepoint)             # Whitespace (for unquoted values)
    )

  @doc """
  Guard: Checks if a codepoint can start any valid CSS selector.
  This includes: element names, class selectors, ID selectors, attribute selectors,
  pseudo-class/element selectors, universal selector, and whitespace.
  Enhanced with UTF-8 support.
  """
  defguard is_selector_start_char(codepoint) when
    is_integer(codepoint) and
    (
      is_tag_name_start_char(codepoint) or  # Element/type selectors (div, span, etc.)
      codepoint == ?| or
      codepoint == ?. or                        # Class selector start
      codepoint == ?# or                        # ID selector start
      codepoint == ?[ or                        # Attribute selector start
      codepoint == ?: or                        # Pseudo-class/element start
      codepoint == ?* or                        # Universal selector
      codepoint == ?\\ or                       # Escape character (for escaped characters like \*)
      is_whitespace(codepoint)                  # Whitespace before selector
    )

  #--------------------------------------------------------------------------------
  # Region: Utility Guards for UTF-8 Character Classification
  #--------------------------------------------------------------------------------

  @doc """
  Guard: Checks if a codepoint is a UTF-8 letter.
  Covers major Unicode letter blocks including Latin, Greek, Cyrillic, Arabic, Hebrew, CJK, etc.
  """
  defguard is_utf8_letter_char(codepoint) when
    is_utf8_letter(codepoint)

  @doc """
  Guard: Checks if a codepoint is a UTF-8 digit.
  Includes ASCII digits and various Unicode digit systems.
  """
  defguard is_utf8_digit_char(codepoint) when
    is_utf8_digit(codepoint)

  @doc """
  Guard: Checks if a codepoint is valid as the first character of a pseudo-class or pseudo-element name.

  Valid starting characters are:
  - Any letter (a-z, A-Z)
  - Underscore (_)
  - Hyphen (-)
  - Any non-ASCII character (Unicode > 0x7F)
  """
  defguard is_pseudo_start_char(codepoint) when
    is_integer(codepoint) and (
      (codepoint >= ?a and codepoint <= ?z) or
      (codepoint >= ?A and codepoint <= ?Z) or
      codepoint == ?_ or
      codepoint == ?- or
      (codepoint >= 0x00A0 and codepoint <= 0x10FFFF)  # Non-ASCII chars
    )

  @doc """
  Guard: Checks if a codepoint is valid within a pseudo-class or pseudo-element name.

  Valid characters include:
  - Any letter (a-z, A-Z)
  - Digits (0-9)
  - Underscore (_)
  - Hyphen (-)
  - Parentheses (for functional pseudo-classes)
  - Whitespace (for arguments)
  - Any non-ASCII character (Unicode > 0x7F)
  """
  defguard is_pseudo_char(codepoint) when
    is_integer(codepoint) and (
      (codepoint >= ?a and codepoint <= ?z) or
      (codepoint >= ?A and codepoint <= ?Z) or
      (codepoint >= ?0 and codepoint <= ?9) or
      codepoint == ?_ or
      codepoint == ?- or
      codepoint == ?( or
      codepoint == ?) or
      codepoint == ?+ or  # For expressions like 2n+1 in :nth-child
      codepoint == ?\s or # Space
      codepoint == 0x0009 or # Tab
      (codepoint >= 0x00A0 and codepoint <= 0x10FFFF)  # Non-ASCII chars
    )

  @doc """
  Guard: Checks if a codepoint is a valid UTF-8 character (not a surrogate).
  Excludes surrogate pair codepoints which are invalid in UTF-8.
  """
  defguard is_valid_utf8_codepoint(codepoint) when
    is_integer(codepoint) and
    codepoint >= 0 and
    codepoint <= 0x10FFFF and
    not is_surrogate_codepoint(codepoint)

end
