defmodule Lexer do
  defstruct [:input, :grapheme]

  def new(input) do
    [grapheme | input] = String.graphemes(input)
    %Lexer{grapheme: grapheme, input: input}
  end

  def next_token(lex) do
    token =
      case lex.grapheme do
        grapheme ->
          cond do
            letter?(grapheme) ->
              literal = read_identifier(lex)
              %Token{type: Token.ident_type(literal), literal: literal}
          end
      end

    {lex, token}
  end

  defp read_identifier(lex) do
    for grapheme <- [lex.grapheme | lex.input], letter?(grapheme), do: grapheme, into: ""
  end

  defp letter?(grapheme) do
    ("a" <= grapheme && grapheme <= "z") || ("A" <= grapheme && grapheme <= "Z")
  end
end
