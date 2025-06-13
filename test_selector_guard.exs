#!/usr/bin/env elixir

# Load the guards module
Code.require_file("lib/selector/parser/guards.ex")

import Selector.Parser.Guards

IO.puts("Testing is_selector_char guard...")

# Test cases
test_cases = [
  # Should pass
  {?a, true, "letter 'a'"},
  {?Z, true, "letter 'Z'"},
  {?0, true, "digit '0'"},
  {?#, true, "hash '#'"},
  {?., true, "dot '.'"},
  {?:, true, "colon ':'"},
  {?,, true, "comma ','"},
  {?>, true, "greater than '>'"},
  {?+, true, "plus '+'"},
  {?~, true, "tilde '~'"},
  {?*, true, "asterisk '*'"},
  {?|, true, "pipe '|'"},
  {?[, true, "bracket '['"},
  {?], true, "bracket ']'"},
  {?", true, "double quote"},
  {?', true, "single quote"},
  {?\\, true, "backslash"},
  {0x0020, true, "space"},
  {0x4E2D, true, "Chinese character 中"},
  {0x0391, true, "Greek letter Α"},
  
  # Should fail
  {0x0000, false, "null character"},
  {0x0001, false, "control character"},
  {0x007F, false, "DEL character"},
  {0xD800, false, "surrogate codepoint"},
]

# Run tests
passed = 0
failed = 0

for {codepoint, expected, description} <- test_cases do
  result = is_selector_char(codepoint)
  status = if result == expected do
    passed = passed + 1
    "✓"
  else
    failed = failed + 1
    "✗"
  end
  
  IO.puts("#{status} #{description}: is_selector_char(#{inspect(codepoint)}) => #{result} (expected #{expected})")
end

IO.puts("\nSummary: #{passed} passed, #{failed} failed")

# Test with actual selector strings
IO.puts("\nTesting complete selector strings:")

selectors = [
  "div.class#id",
  "[data-value~=\"test\"]:nth-child(2n+1)",
  ".クラス#标识符[атрибут=\"القيمة\"]",
  "ns|element > .class + #id ~ [attr]",
  "div, .class, #id"
]

for selector <- selectors do
  all_valid = Enum.all?(String.to_charlist(selector), &is_selector_char/1)
  status = if all_valid, do: "✓", else: "✗"
  IO.puts("#{status} \"#{selector}\" - all characters valid: #{all_valid}")
end