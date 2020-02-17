defmodule LexerTest do
  use ExUnit.Case

  test "single val statement" do
    "val five = 5"
    |> assert_tokens([
      {:VAL, "val"},
      {:SPACE, " "},
      {:IDENT, "five"},
      {:SPACE, " "},
      {:MATCH, "="},
      {:SPACE, " "},
      {:INT, "5"},
      {:EOF, ""}
    ])
  end

  test "multiple val statements with newlines" do
    """
    val five = 5
    val another = 10 / 2
    """
    |> assert_tokens([
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

  test "named function binding with block" do
    """
    fn AddOne(num, extra):
      num + extra - 1
    """
    |> assert_tokens([
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

  test "named function binding one liner" do
    """
    fn again(num): num+1
    """
    |> assert_tokens([
      {:FUNCTION, "fn"},
      {:SPACE, " "},
      {:IDENT, "again"},
      {:LPAREN, "("},
      {:IDENT, "num"},
      {:RPAREN, ")"},
      {:COLON, ":"},
      {:SPACE, " "},
      {:IDENT, "num"},
      {:PLUS, "+"},
      {:INT, "1"},
      {:NEWLINE, "\n"},
      {:EOF, ""}
    ])
  end

  test "anonymous function with block" do
    """
    fn(x,y):
      x*y
    """
    |> assert_tokens([
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

  test "anonymous function one liner" do
    """
    fn(x): x
    """
    |> assert_tokens([
      {:FUNCTION, "fn"},
      {:LPAREN, "("},
      {:IDENT, "x"},
      {:RPAREN, ")"},
      {:COLON, ":"},
      {:SPACE, " "},
      {:IDENT, "x"},
      {:NEWLINE, "\n"},
      {:EOF, ""}
    ])
  end

  test "function bindings without args don't have parens" do
    """
    val answer = fn:
      42
    fn question:
      someClosureBinding
    """
    |> assert_tokens([
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

  test "single line function bindings" do
    """
    val answer = fn:
      42
    fn question:
      someClosureBinding
    """
    |> assert_tokens([
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

  test "function calls" do
    """
    DoSomething(num, 9)
    fn(x): x/0
    """
    |> assert_tokens([
      {:IDENT, "DoSomething"},
      {:LPAREN, "("},
      {:IDENT, "num"},
      {:COMMA, ","},
      {:SPACE, " "},
      {:INT, "9"},
      {:RPAREN, ")"},
      {:NEWLINE, "\n"},
      {:FUNCTION, "fn"},
      {:LPAREN, "("},
      {:IDENT, "x"},
      {:RPAREN, ")"},
      {:COLON, ":"},
      {:SPACE, " "},
      {:IDENT, "x"},
      {:FSLASH, "/"},
      {:INT, "0"},
      {:NEWLINE, "\n"},
      {:EOF, ""}
    ])
  end

  test "boolean expression" do
    """
    true
    false
    """
    |> assert_tokens([
      {:TRUE, "true"},
      {:NEWLINE, "\n"},
      {:FALSE, "false"},
      {:NEWLINE, "\n"},
      {:EOF, ""}
    ])
  end

  test "string expressions" do
    """
    "hey there"
    """
    |> assert_tokens([
      {:STRING, "hey there"},
      {:NEWLINE, "\n"},
      {:EOF, ""}
    ])
  end

  defp assert_tokens(input, tokens) do
    tokens
    |> Enum.reduce(Lexer.new(input), fn {expected_type, expected_literal}, lex ->
      {lex, token} = Lexer.next_token(lex)
      assert token.type == expected_type
      assert token.literal == expected_literal
      lex
    end)
  end
end
