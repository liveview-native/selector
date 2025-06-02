defmodule Selector.Parser do
  @valid_rule_start_chars Enum.to_list(?a..?z) ++
                          Enum.to_list(?A..?Z) ++
                          Enum.to_list(?0..?9) ++
                          [?*, ?#, ?., ?[, ?:]

  @valid_rule_chars @valid_rule_start_chars ++
                    [?-, ?_, ?|, ?>, ?+, ?~, ?(, ?), ?\", ?']

  def parse(selector) when is_binary(selector) do
    parse_selector(selector, [], [])
  end

  defp parse_selector(<<?#, document::binary>>, buffer, selectors) do

  end
end
