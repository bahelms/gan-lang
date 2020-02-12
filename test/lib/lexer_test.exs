defmodule LexerTest do
  use ExUnit.Case

  test "val statements" do
    input = "val five = 5"

    [
      {:VAL, "val"},
      {:IDENT, "five"},
      {:MATCH, "="},
      {:INT, "5"},
      {:EOF, ""}
    ]
    |> Enum.reduce(Lexer.new(input), fn {expected_type, expected_literal}, lex ->
      {lex, token} = Lexer.next_token(lex)
      assert token.type == expected_type
      assert token.literal == expected_literal
      lex
    end)
  end
end
