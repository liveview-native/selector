defmodule Selector.Parser.TagName do
  @moduledoc false

  import Selector.Parser.Guards
  
  def parse(<<"\\ "::utf8, selectors::binary>>, tag_name, opts) do
    parse(selectors, [tag_name, ?\s], opts)
  end

  def parse(<<"\\"::utf8, char::utf8, selectors::binary>>, tag_name, opts) when is_escapable_char(char) do
    parse(selectors, [tag_name, char], opts)
  end

  def parse(<<"\\|"::utf8, selectors::binary>>, tag_name, opts) do
    parse(selectors, [tag_name, ?|], opts)
  end

  def parse(<<"|"::utf8, selectors::binary>>, namespace, opts) do
    parse(selectors, [], Keyword.put(opts, :namespace, List.to_string(namespace)))
  end

  def parse(<<"\\*"::utf8, selectors::binary>>, [], opts) do
    {"*", selectors, extract_opts(opts)}
  end

  def parse(<<"*"::utf8, selectors::binary>>, [], opts) do
    {"*", selectors, extract_opts(opts)}
  end

  def parse(<<char::utf8, selectors::binary>>, ~c"|", opts) when is_tag_name_char(char) do
    parse(selectors, [char], Keyword.put(opts, :namespace, ""))
  end

  def parse(<<char::utf8, selectors::binary>>, tag_name, opts) when is_tag_name_char(char) do
    parse(selectors, [tag_name, char], opts)
  end

  def parse(selectors, buffer, opts) do
    {List.to_string(buffer), selectors, extract_opts(opts)}
  end

  defp extract_opts(opts) do
    Keyword.take(opts, [
      :namespace
    ])
  end
end
