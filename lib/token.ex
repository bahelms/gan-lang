defmodule Token do
  defstruct [:type, :literal]

  @keyword_types %{
    "val" => :VAL,
    "fn" => :FUNCTION,
    "true" => :TRUE,
    "false" => :FALSE
  }

  def match, do: %Token{type: :MATCH, literal: "="}
  def plus, do: %Token{type: :PLUS, literal: "+"}
  def minus, do: %Token{type: :MINUS, literal: "-"}
  def asterisk, do: %Token{type: :ASTERISK, literal: "*"}
  def fslash, do: %Token{type: :FSLASH, literal: "/"}
  def lparen, do: %Token{type: :LPAREN, literal: "("}
  def rparen, do: %Token{type: :RPAREN, literal: ")"}
  def comma, do: %Token{type: :COMMA, literal: ","}
  def colon, do: %Token{type: :COLON, literal: ":"}
  def space, do: %Token{type: :SPACE, literal: " "}
  def newline, do: %Token{type: :NEWLINE, literal: "\n"}
  def eof, do: %Token{type: :EOF, literal: ""}

  def illegal(literal), do: %Token{type: :ILLEGAL, literal: literal}
  def int(literal), do: %Token{type: :INT, literal: literal}
  def ident(literal), do: %Token{type: ident_type(literal), literal: literal}
  def string(literal), do: %Token{type: :STRING, literal: literal}

  defp ident_type(ident) do
    Map.get(@keyword_types, ident, :IDENT)
  end
end
