defmodule Lexer do
  defstruct [:input, :grapheme]

  def new(input) do
    [grapheme | input] = String.graphemes(input)
    %Lexer{grapheme: grapheme, input: input}
  end

  def next_token(lex) do
    case lex.grapheme do
      "=" ->
        {next_grapheme(lex), Token.match()}

      "+" ->
        {next_grapheme(lex), Token.plus()}

      "(" ->
        {next_grapheme(lex), Token.lparen()}

      ")" ->
        {next_grapheme(lex), Token.rparen()}

      ":" ->
        {next_grapheme(lex), Token.colon()}

      " " ->
        {next_grapheme(lex), Token.space()}

      "\n" ->
        {next_grapheme(lex), Token.newline()}

      nil ->
        {lex, Token.eof()}

      grapheme ->
        cond do
          letter?(grapheme) ->
            {literal, lex} = read_literal(grapheme, lex, &letter?/1)
            {next_grapheme(lex), Token.ident(literal)}

          digit?(grapheme) ->
            {literal, lex} = read_literal(grapheme, lex, &digit?/1)
            {next_grapheme(lex), Token.int(literal)}

          true ->
            {lex, Token.illegal(grapheme)}
        end
    end
  end

  defp next_grapheme(%{input: [grapheme | input]} = lex) do
    struct(lex, grapheme: grapheme, input: input)
  end

  defp next_grapheme(%{input: []} = lex) do
    struct(lex, grapheme: nil)
  end

  defp read_literal(literal, %{input: [grapheme | _]} = lex, condition) do
    if condition.(grapheme) do
      read_literal(literal <> grapheme, next_grapheme(lex), condition)
    else
      {literal, lex}
    end
  end

  defp letter?(grapheme) do
    # This only supports ASCII for now.
    Regex.match?(~r/[a-zA-Z]/, grapheme)
  end

  defp digit?(grapheme), do: Regex.match?(~r/\d/, grapheme)
end
