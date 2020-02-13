defmodule Token do
  defstruct [:type, :literal]

  @keyword_types %{
    "val" => :VAL,
    "fn" => :FUNCTION
  }

  def match, do: %Token{type: :MATCH, literal: "="}
  def plus, do: %Token{type: :PLUS, literal: "+"}
  def lparen, do: %Token{type: :LPAREN, literal: "("}
  def rparen, do: %Token{type: :RPAREN, literal: ")"}
  def colon, do: %Token{type: :COLON, literal: ":"}
  def space, do: %Token{type: :SPACE, literal: " "}
  def newline, do: %Token{type: :NEWLINE, literal: "\n"}
  def eof, do: %Token{type: :EOF, literal: ""}

  def illegal(literal), do: %Token{type: :ILLEGAL, literal: literal}
  def int(literal), do: %Token{type: :INT, literal: literal}
  def ident(literal), do: %Token{type: ident_type(literal), literal: literal}

  defp ident_type(ident) do
    Map.get(@keyword_types, ident, :IDENT)
  end
end
