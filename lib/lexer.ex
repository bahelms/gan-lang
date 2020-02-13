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
            {literal, lex} = read_identifier(grapheme, lex)
            {next_grapheme(lex), Token.ident(literal)}

          digit?(grapheme) ->
            {literal, lex} = read_number(grapheme, lex)
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

  defp read_identifier(identifier, %{input: [grapheme | _]} = lex) do
    if letter?(grapheme) do
      read_identifier(identifier <> grapheme, next_grapheme(lex))
    else
      {identifier, lex}
    end
  end

  defp read_number(number, %{input: [grapheme | _]} = lex) do
    if digit?(grapheme) do
      read_number(number <> grapheme, next_grapheme(lex))
    else
      {number, lex}
    end
  end

  defp read_number(number, lex), do: {number, lex}

  defp letter?(grapheme) do
    # This only supports ASCII for now.
    Regex.match?(~r/[a-zA-Z]/, grapheme)
  end

  defp digit?(grapheme), do: Regex.match?(~r/\d/, grapheme)
end
