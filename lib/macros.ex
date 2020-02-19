defmodule Macros do
  @doc """
  This only supports ASCII for now.
  """
  @spec letter?(String.t()) :: boolean()
  defmacro letter?(grapheme) do
    quote do
      (unquote(grapheme) >= "A" and unquote(grapheme) <= "Z") or
        (unquote(grapheme) >= "a" and unquote(grapheme) <= "z")
    end
  end

  @spec digit?(String.t()) :: boolean()
  defmacro digit?(grapheme) do
    quote do
      unquote(grapheme) >= "0" and unquote(grapheme) <= "9"
    end
  end
end
