defmodule Selector.Parser.Hex do
  @moduledoc false

  import Selector.Parser.Guards
  import Selector.Parser.Utils

  def parse(<<hex1::utf8, hex2::utf8, hex3::utf8, hex4::utf8, hex5::utf8, hex6::utf8, selectors::binary>>, _opts)
    when is_hex_digit(hex1)
     and is_hex_digit(hex2)
     and is_hex_digit(hex3)
     and is_hex_digit(hex4)
     and is_hex_digit(hex5)
     and is_hex_digit(hex6)
  do
    {[List.to_integer([hex1, hex2, hex3, hex4, hex5, hex6], 16)], drain_whitespace(selectors)}
  end

  def parse(<<hex1::utf8, hex2::utf8, hex3::utf8, hex4::utf8, hex5::utf8, selectors::binary>>, _opts)
    when is_hex_digit(hex1)
     and is_hex_digit(hex2)
     and is_hex_digit(hex3)
     and is_hex_digit(hex4)
     and is_hex_digit(hex5)
  do
    {[List.to_integer([hex1, hex2, hex3, hex4, hex5], 16)], drain_whitespace(selectors)}
  end

  def parse(<<hex1::utf8, hex2::utf8, hex3::utf8, hex4::utf8, selectors::binary>>, _opts)
    when is_hex_digit(hex1)
     and is_hex_digit(hex2)
     and is_hex_digit(hex3)
     and is_hex_digit(hex4)
  do
    {[List.to_integer([hex1, hex2, hex3, hex4], 16)], drain_whitespace(selectors)}
  end

  def parse(<<hex1::utf8, hex2::utf8, hex3::utf8, selectors::binary>>, _opts)
    when is_hex_digit(hex1)
     and is_hex_digit(hex2)
     and is_hex_digit(hex3)
  do
    {[List.to_integer([hex1, hex2, hex3], 16)], drain_whitespace(selectors)}
  end

  def parse(<<hex1::utf8, hex2::utf8, selectors::binary>>, _opts)
    when is_hex_digit(hex1)
     and is_hex_digit(hex2)
  do
    {[List.to_integer([hex1, hex2], 16)], drain_whitespace(selectors)}
  end

  def parse(<<hex1::utf8, selectors::binary>>, _opts)
    when is_hex_digit(hex1)
  do

    {[List.to_integer([hex1], 16)], drain_whitespace(selectors)}
  end

  def parse(selectors, _opts),
    do: {[], selectors}
end
