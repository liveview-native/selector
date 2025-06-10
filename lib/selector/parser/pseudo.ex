defmodule Selector.Parser.Pseudo do
  @moduledoc false

  import Selector.Parser.Guards

  def parse(<<char::utf8, rest::binary>>, opts) when is_pseudo_start_char(char) do
    parse_name(rest, [char], opts)
  end

  defp parse_name(<<"("::utf8, selectors::binary>>, name, opts) do
    {params, selectors} = parse_params(selectors, [], opts)
    
    {{atomize_pseudo_name(name), params}, selectors}
  end

  defp parse_name(<<char::utf8, selectors::binary>>, name, opts) when is_pseudo_char(char) do
    parse_name(selectors, [name, char], opts)
  end

  defp parse_name(selectors, name, _opts) do
    {{atomize_pseudo_name(name), []}, selectors}
  end
  
  defp parse_params(<<")"::utf8, selectors::binary>>, params, _opts) do
    {params, selectors}
  end
  
  # defp parse_params(<<char::utf8, selectors::binary>>, params, opts) when is_whitespace(char) do
  #   parse_params(selectors::binary, params, opts)
  # end
  
  defp parse_params(<<char::utf8, selectors::binary>>, params, opts) when is_pseudo_start_char(char) do
    # parse_param(selectors, [char], opts)
    {[], selectors}
  end
  
  # defp parse_param(<<char::utf8, selector::binary>>, param, opts) when is_pseudo_char(char) do
  #  pa 
  # end
  
  defp atomize_pseudo_name(name) do
    # not sure if this should be String.to_existing_atom/1
    # it might be tricky with case insensitive options
    # will need to revisit this later
    List.to_string(name) |> String.to_atom()
  end
end
