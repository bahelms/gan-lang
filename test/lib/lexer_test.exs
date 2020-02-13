defmodule LexerTest do
  use ExUnit.Case

  test "val statements" do
    """
    val five = 5
    val another = 10
    """
    |> test_tokens([
      {:VAL, "val"},
      {:SPACE, " "},
      {:IDENT, "five"},
      {:SPACE, " "},
      {:MATCH, "="},
      {:SPACE, " "},
      {:INT, "5"},
      {:NEWLINE, "\n"},
      {:VAL, "val"},
      {:SPACE, " "},
      {:IDENT, "another"},
      {:SPACE, " "},
      {:MATCH, "="},
      {:SPACE, " "},
      {:INT, "10"},
      {:NEWLINE, "\n"},
      {:EOF, ""}
    ])
  end

  test "named function definitions" do
    """
    fn AddOne(num):
      num + 1
    """
    |> test_tokens([
      {:FUNCTION, "fn"},
      {:SPACE, " "},
      {:IDENT, "AddOne"},
      {:LPAREN, "("},
      {:IDENT, "num"},
      {:RPAREN, ")"},
      {:COLON, ":"},
      {:NEWLINE, "\n"},
      {:SPACE, " "},
      {:SPACE, " "},
      {:IDENT, "num"},
      {:SPACE, " "},
      {:PLUS, "+"},
      {:SPACE, " "},
      {:INT, "1"},
      {:NEWLINE, "\n"},
      {:EOF, ""}
    ])
  end

  defp test_tokens(input, tokens) do
    tokens
    |> Enum.reduce(Lexer.new(input), fn {expected_type, expected_literal}, lex ->
      {lex, token} = Lexer.next_token(lex)
      assert token.type == expected_type
      assert token.literal == expected_literal
      lex
    end)
  end
end
