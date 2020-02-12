defmodule Token do
  defstruct [:type, :literal]

  @keyword_types %{
    "val" => :VAL
  }

  def match, do: %Token{type: :MATCH, literal: "="}
  def eof, do: %Token{type: :EOF, literal: ""}

  def int(literal), do: %Token{type: :INT, literal: literal}
  def ident(literal), do: %Token{type: ident_type(literal), literal: literal}

  defp ident_type(ident) do
    Map.get(@keyword_types, ident, :IDENT)
  end
end
