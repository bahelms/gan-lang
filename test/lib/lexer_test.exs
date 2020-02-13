defmodule LexerTest do
  use ExUnit.Case

  test "val statements" do
    """
    val five = 5
    val another = 10 / 2
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
      {:SPACE, " "},
      {:FSLASH, "/"},
      {:SPACE, " "},
      {:INT, "2"},
      {:NEWLINE, "\n"},
      {:EOF, ""}
    ])
  end

  test "named function definitions" do
    """
    fn AddOne(num, extra):
      num + extra - 1
    """
    |> test_tokens([
      {:FUNCTION, "fn"},
      {:SPACE, " "},
      {:IDENT, "AddOne"},
      {:LPAREN, "("},
      {:IDENT, "num"},
      {:COMMA, ","},
      {:SPACE, " "},
      {:IDENT, "extra"},
      {:RPAREN, ")"},
      {:COLON, ":"},
      {:NEWLINE, "\n"},
      {:SPACE, " "},
      {:SPACE, " "},
      {:IDENT, "num"},
      {:SPACE, " "},
      {:PLUS, "+"},
      {:SPACE, " "},
      {:IDENT, "extra"},
      {:SPACE, " "},
      {:MINUS, "-"},
      {:SPACE, " "},
      {:INT, "1"},
      {:NEWLINE, "\n"},
      {:EOF, ""}
    ])
  end

  test "function literal binding" do
    """
    val multiply = fn(x,y):
      x*y
    """
    |> test_tokens([
      {:VAL, "val"},
      {:SPACE, " "},
      {:IDENT, "multiply"},
      {:SPACE, " "},
      {:MATCH, "="},
      {:SPACE, " "},
      {:FUNCTION, "fn"},
      {:LPAREN, "("},
      {:IDENT, "x"},
      {:COMMA, ","},
      {:IDENT, "y"},
      {:RPAREN, ")"},
      {:COLON, ":"},
      {:NEWLINE, "\n"},
      {:SPACE, " "},
      {:SPACE, " "},
      {:IDENT, "x"},
      {:ASTERISK, "*"},
      {:IDENT, "y"},
      {:NEWLINE, "\n"},
      {:EOF, ""}
    ])
  end

  test "functions definitions without args don't have parens " do
    """
    val answer = fn:
      42
    fn question:
      someClosureBinding
    """
    |> test_tokens([
      {:VAL, "val"},
      {:SPACE, " "},
      {:IDENT, "answer"},
      {:SPACE, " "},
      {:MATCH, "="},
      {:SPACE, " "},
      {:FUNCTION, "fn"},
      {:COLON, ":"},
      {:NEWLINE, "\n"},
      {:SPACE, " "},
      {:SPACE, " "},
      {:INT, "42"},
      {:NEWLINE, "\n"},
      {:FUNCTION, "fn"},
      {:SPACE, " "},
      {:IDENT, "question"},
      {:COLON, ":"},
      {:NEWLINE, "\n"},
      {:SPACE, " "},
      {:SPACE, " "},
      {:IDENT, "someClosureBinding"},
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
