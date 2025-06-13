defmodule Selector.Parser.Pseudo do
  @moduledoc false

  import Selector.Parser.Guards
  import Selector.Parser.Utils

  alias Selector.Parser.Pseudo.NthFormula
  alias Selector.Parser.Pseudo.{
    LanguageCode,
    Name,
    NthFormula,
    SelectorList
  }

  defguard is_nth_param(name) when name in ~w{
    nth-child
    nth-col
    nth-last-child
    nth-last-of-type
    nth-of-type
  }
  defguard is_selector_param(name) when name in ~w{
    cue
    cue-region
  }
  defguard is_compound_selector_param(name) when name in ~w{
    host
    host-context
    slotted
  }
  defguard is_relative_selector_param(name) when name in ~w{
    has
    host
    host-context
    slotted
  }
  defguard is_selector_list_param(name) when name in ~w{
    is
    matches
    not
    where
    -webkit-any
    -moz-any
  }
  defguard is_dir_keyword_param(name) when name in ~w{
    dir
  }
  defguard is_dir_type_param(name) when name in ~w{
    scroll-button
  }
  defguard is_lang_code_param(name) when name in ~w{
    lang
  }
  defguard is_name_param(name) when name in ~w{
    active-view-transition-type
    highlight
    part
    picker
    state
  }

  defguard is_param_pseudo(name) when 
    is_nth_param(name) or
    is_selector_param(name) or
    is_compound_selector_param(name) or
    is_relative_selector_param(name) or
    is_selector_list_param(name) or
    is_dir_keyword_param(name) or
    is_dir_type_param(name) or
    is_lang_code_param(name) or
    is_name_param(name)

  @pseudo_classes ~w{
    active
    active-view-transition
    active-view-transition-type
    any-link
    autofill
    blank
    buffering
    checked
    current
    default
    defined
    dir
    disabled
    empty
    enabled
    first
    first-child
    first-of-type
    focus
    focus-visible
    focus-within
    fullscreen
    future
    has
    host
    host-context
    hover
    in-range
    indeterminate
    invalid
    is
    lang
    last-child
    last-of-type
    left
    link
    local-link
    modal
    muted
    not
    nth-child
    nth-col
    nth-last-child
    nth-last-col
    nth-last-of-type
    nth-of-type
    only-child
    only-of-type
    open
    optional
    out-of-range
    past
    paused
    picture-in-picture
    placeholder-shown
    playing
    popover-open
    read-only
    read-write
    required
    right
    root
    scope
    seeking
    stalled
    state
    target
    target-current
    target-within
    user-invalid
    user-valid
    valid
    visited
    volume-locked
    where
    -moz-any-link
    -moz-broken
    -moz-drag-over
    -moz-first-node
    -moz-focusring
    -moz-full-screen
    -moz-last-node
    -moz-loading
    -moz-only-whitespace
    -moz-range-progress
    -moz-range-thumb
    -moz-range-track
    -moz-read-only
    -moz-read-write
    -moz-suppressed
    -moz-ui-invalid
    -moz-ui-valid
    -moz-user-disabled
    -moz-window-inactive
    -ms-accelerator
    -ms-alt
    -ms-checked
    -ms-disabled
    -ms-enabled
    -ms-expand
    -ms-fill
    -ms-first-child
    -ms-fullscreen
    -ms-hover
    -ms-indeterminate
    -ms-keyboard-active
    -ms-keyboard-select
    -ms-link
    -ms-link-visited
    -ms-logical
    -ms-middle
    -ms-read-only
    -ms-read-write
    -ms-selected
    -ms-user-select-contain
    -ms-user-select-text
    -webkit-any-link
    -webkit-autofill
    -webkit-full-screen
  }

  def classes, do: @pseudo_classes

  @pseudo_elements ~w{
    after
    backdrop
    before
    checkmark
    column
    cue
    cue-region
    details-content
    file-selector-button
    first-letter
    first-line
    grammar-error
    marker
    part
    picker
    picker-icon
    placeholder
    postfix
    prefix
    scroll-button
    scroll-marker
    scroll-marker-group
    selection
    slotted
    spelling-error
    target-text
    view-transition
    view-transition-group
    view-transition-image-pair
    view-transition-new
    view-transition-old
    -moz-focus-inner
    -moz-focus-outer
    -moz-list-bullet
    -moz-list-number
    -moz-placeholder
    -moz-progress-bar
    -moz-range-progress
    -moz-range-thumb
    -moz-range-track
    -moz-selection
    -ms-browse
    -ms-check
    -ms-clear
    -ms-content-zoom-factor
    -ms-content-zoom-snap
    -ms-content-zoom-snap-points
    -ms-content-zooming
    -ms-expand
    -ms-fill
    -ms-fill-lower
    -ms-fill-upper
    -ms-input-placeholder
    -ms-reveal
    -ms-thumb
    -ms-ticks-after
    -ms-ticks-before
    -ms-tooltip
    -ms-track
    -ms-value
    -webkit-input-placeholder
    -webkit-progress-bar
    -webkit-progress-inner-element
    -webkit-progress-value
    -webkit-scrollbar
    -webkit-scrollbar-button
    -webkit-scrollbar-thumb
    -webkit-scrollbar-track
    -webkit-scrollbar-track-piece
    -webkit-scroll-corner
    -webkit-slider-runnable-track
    -webkit-slider-thumb
  }

  def elements, do: @pseudo_elements

  def parse(<<char::utf8, rest::binary>>, opts) when is_pseudo_start_char(char) do
    parse_name(rest, [char], opts)
  end

  defp parse_name(<<"("::utf8, selectors::binary>>, name, opts) do
    name = List.to_string(name)
    selectors = drain_whitespace(selectors)
    {param, selectors} = parse_param(selectors, name, opts)
    
    {{name, param}, selectors}
  end

  defp parse_name(<<char::utf8, selectors::binary>>, name, opts) when is_pseudo_char(char) do
    parse_name(selectors, [name, char], opts)
  end

  defp parse_name(selectors, name, _opts) do
    name = List.to_string(name)

    if is_param_pseudo(name) do
      raise ArgumentError, ~s(Argument is required for pseudo-class "#{name}".)
    end

    {{name, []}, selectors}
  end
  
  defp parse_param_close(<<char::utf8, selectors::binary>>, param, opts) when is_whitespace(char) do
    selectors = drain_whitespace(selectors)
    parse_param_close(selectors, param, opts)
  end

  defp parse_param_close(<<")"::utf8, selectors::binary>>, param, _opts) do
    {[param], selectors}
  end

  defp parse_param(selectors, name, opts) when is_nth_param(name) do
    {param, selectors} = NthFormula.parse(selectors, opts)
    parse_param_close(selectors, param, opts)
  end

  defp parse_param(selectors, name, opts) when is_relative_selector_param(name) do
    {rule_opts, selectors} = Selector.Parser.Combinator.parse(selectors, opts)
    {param, selectors} = Selector.Parser.Pseudo.Selector.parse(selectors, Keyword.merge(opts, rule_opts))
    parse_param_close(selectors, param, opts)
  end

  defp parse_param(selectors, name, opts) when is_selector_list_param(name) do
    {param, selectors} = SelectorList.parse(selectors, opts)
    parse_param_close(selectors, param, opts)
  end

  defp parse_param(selectors, name, opts) when is_lang_code_param(name) do
    {param, selectors} = LanguageCode.parse(selectors, [], opts)
    parse_param_close(selectors, param, opts)
  end

  defp parse_param(selectors, name, opts) when is_name_param(name) do
    {param, selectors} = Name.parse(selectors, [], opts)
    parse_param_close(selectors, param, opts)
  end

  defp parse_param(_selectors, name, _opts) do
    raise ArgumentError, "Pseudo #{name} cannot take param"
  end
end
