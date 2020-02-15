defmodule Parser do
  defstruct [:lexer, :token, :peek, prefix_parse_fns: %{}, infix_parse_fns: %{}, errors: []]

  # precedence values
  @lowest 0
  @equals 1
  @less_greater 2
  @sum 3
  @product 4
  @prefix 5
  @call 6

  def new(lexer) do
    %Parser{lexer: lexer}
    |> set_precedences()
    |> register_prefix_fns()
    |> register_infix_fns()
    |> next_token()
    |> next_token()
  end

  def parse_tokens(lexer) do
    {statements, parser} = parse_statements(new(lexer))
    {%AST.Root{statements: statements}, parser}
  end

  defp next_token(%{peek: peek} = parser) do
    {lex, token} = Lexer.next_token(parser.lexer)
    struct(parser, lexer: lex, token: peek, peek: token)
  end

  defp skip_spaces(parser) do
    case parser.token.type do
      :SPACE ->
        parser
        |> next_token()
        |> skip_spaces()

      _ ->
        parser
    end
  end

  defp set_precedences(parser) do
    parser
    |> struct(
      precedences: %{
        EQ: @equals,
        NOT_EQ: @equals,
        LT: @less_greater,
        GT: @less_greater,
        PLUS: @sum,
        MINUS: @sum,
        FSLASH: @product,
        ASTERISK: @product,
        LPAREN: @call
      }
    )
  end

  defp register_prefix_fns(parser) do
    parser
    |> struct(
      prefix_parse_fns: %{
        INT: &parse_integer_literal/1,
        IDENT: &parse_identifier/1
      }
    )
  end

  defp register_infix_fns(parser) do
    parser
    |> struct(infix_parse_fns: %{})
  end

  defp add_error(parser, error) do
    struct(parser, errors: parser.errors ++ [error])
  end

  defp parse_statements(parser, statements \\ []) do
    if parser.token.type != :EOF do
      {statements, parser} =
        case parse_statement(parser) do
          {nil, parser} ->
            {statements, parser}

          {stmt, parser} ->
            {statements ++ [stmt], parser}
        end

      parser
      |> next_token()
      |> parse_statements(statements)
    else
      {statements, parser}
    end
  end

  def parse_statement(parser) do
    case parser.token.type do
      :VAL ->
        parse_val_stmt(parser)

      _ ->
        parse_expression(parser, @lowest)
    end
  end

  def parse_val_stmt(parser) do
    node = %AST.Val{token: parser.token}
    parser = next_token(parser)
    {name, parser} = parse_name(parser)
    {value, parser} = parse_value(parser)
    parser = skip_spaces(parser)
    {struct(node, name: name, value: value), parser}
  end

  defp parse_name(parser) do
    parser = skip_spaces(parser)

    case parser.token.type do
      :IDENT ->
        {node, _} = parse_identifier(parser)
        {node, next_token(parser)}

      type ->
        error = "expected next token to be :IDENT, got #{type} instead"
        {nil, add_error(parser, error)}
    end
  end

  defp parse_value(parser) do
    parser = skip_spaces(parser)

    case parser.token.type do
      :MATCH ->
        {value, parser} =
          parser
          |> next_token()
          |> parse_expression(@lowest)

        {value, next_token(parser)}

      type ->
        error = "expected next token to be :MATCH, got #{type} instead"
        {nil, add_error(parser, error)}
    end
  end

  defp parse_expression(parser, precedence) do
    parser = skip_spaces(parser)

    case parser.prefix_parse_fns[parser.token.type] do
      nil ->
        error = "Prefix Parse function not found for #{parser.token.type}"
        {nil, add_error(parser, error)}

      prefix ->
        {left_expr, parser} = prefix.(parser)
        parse_infix(parser, left_expr, precedence)
    end
  end

  defp parse_infix(parser, left_expr, precedence) do
    if precedence < peek_precedence(parser) do
      case parser.infix_parse_fns[parser.peek.type] do
        nil ->
          {left_expr, parser}

        infix ->
          parser
          |> next_token()
          |> infix.(left_expr)
      end
    else
      {left_expr, parser}
    end
  end

  defp peek_precedence(parser), do: Map.get(parser, parser.peek.type, @lowest)

  defp parse_integer_literal(parser) do
    node = %AST.IntegerLiteral{
      token: parser.token,
      value: String.to_integer(parser.token.literal)
    }

    {node, parser}
  end

  defp parse_identifier(parser) do
    node = %AST.Identifier{value: parser.token.literal, token: parser.token}
    {node, parser}
  end
end
