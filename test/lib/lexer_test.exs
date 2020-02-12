defmodule LexerTest do
  use ExUnit.Case

  test "next_token returns the next token" do
    {_lexer, token} =
      Lexer.new("val")
      |> Lexer.next_token()

    assert token.type == :VAL
    assert token.literal == "val"
  end
end
