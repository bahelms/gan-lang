defmodule Lexer do
  defstruct [:input, :grapheme, :previous]

  import Macros

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

      "-" ->
        {next_grapheme(lex), Token.minus()}

      "*" ->
        {next_grapheme(lex), Token.asterisk()}

      "/" ->
        {next_grapheme(lex), Token.fslash()}

      "(" ->
        {next_grapheme(lex), Token.lparen()}

      ")" ->
        {next_grapheme(lex), Token.rparen()}

      "\"" ->
        {literal, lex} = read_string(lex)
        {next_grapheme(lex), Token.string(literal)}

      "," ->
        {next_grapheme(lex), Token.comma()}

      ":" ->
        {next_grapheme(lex), Token.colon()}

      " " ->
        case lex.previous do
          "\n" ->
            {count, lex} = read_spaces(lex)
            {lex, Token.space(String.duplicate(" ", count))}

          _ ->
            next_token(next_grapheme(lex))
        end

      "\n" ->
        {next_grapheme(lex), Token.newline()}

      nil ->
        {lex, Token.eof()}

      grapheme ->
        tokenize_unknown(grapheme, lex)
    end
  end

  defp read_spaces(lex, count \\ 0)

  defp read_spaces(%{grapheme: " "} = lex, count) do
    read_spaces(next_grapheme(lex), count + 1)
  end

  defp read_spaces(lex, count), do: {count, lex}

  defp tokenize_unknown(grapheme, lex) when letter?(grapheme) do
    {literal, lex} = read_literal(grapheme, lex, &letter?/1)
    {next_grapheme(lex), Token.ident(literal)}
  end

  defp tokenize_unknown(grapheme, lex) when digit?(grapheme) do
    {literal, lex} = read_literal(grapheme, lex, &digit?/1)
    {next_grapheme(lex), Token.int(literal)}
  end

  defp tokenize_unknown(grapheme, lex) do
    IO.inspect(grapheme, label: "ILLEGAL")
    {lex, Token.illegal(grapheme)}
  end

  defp next_grapheme(%{grapheme: previous, input: [grapheme | input]} = lex) do
    struct(lex, grapheme: grapheme, previous: previous, input: input)
  end

  defp next_grapheme(%{grapheme: previous, input: []} = lex) do
    struct(lex, grapheme: nil, previous: previous)
  end

  defp read_literal(literal, %{input: [grapheme | _]} = lex, condition) do
    if condition.(grapheme) do
      read_literal(literal <> grapheme, next_grapheme(lex), condition)
    else
      {literal, lex}
    end
  end

  defp read_literal(literal, lex, _) do
    {literal, lex}
  end

  defp read_string(%{input: [grapheme | _]} = lex, string \\ "") do
    case grapheme do
      "\"" ->
        {string, next_grapheme(lex)}

      nil ->
        {string, lex}

      grapheme ->
        read_string(next_grapheme(lex), string <> grapheme)
    end
  end
end
