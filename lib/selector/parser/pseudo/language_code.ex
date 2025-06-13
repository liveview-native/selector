defmodule Selector.Parser.Pseudo.LanguageCode do
  @moduledoc false

  import Selector.Parser.Guards

  def parse(<<char::utf8, selectors::binary>>, [], opts) when is_lang_start_char(char) do
    parse(selectors, [char], opts)
  end

  def parse(<<char::utf8, selectors::binary>>, lang, opts) when is_lang_char(char) do
    parse(selectors, [lang, char], opts)
  end

  def parse(selectors, lang, _opts) do
    {List.to_string(lang), selectors}
  end
end
