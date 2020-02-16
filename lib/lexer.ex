defmodule Macros do
  @doc """
  This only supports ASCII for now.
  """
  @spec letter?(String.t()) :: boolean()
  defmacro letter?(grapheme) do
    quote do
      (unquote(grapheme) >= "A" and unquote(grapheme) <= "Z") or
        (unquote(grapheme) >= "a" and unquote(grapheme) <= "z")
    end
  end

  @spec digit?(String.t()) :: boolean()
  defmacro digit?(grapheme) do
    quote do
      unquote(grapheme) >= "0" and unquote(grapheme) <= "9"
    end
  end
end

defmodule Lexer do
  defstruct [:input, :grapheme]

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
        {next_grapheme(lex), Token.space()}

      "\n" ->
        {next_grapheme(lex), Token.newline()}

      nil ->
        {lex, Token.eof()}

      grapheme ->
        tokenize_unknown(grapheme, lex)
    end
  end

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
