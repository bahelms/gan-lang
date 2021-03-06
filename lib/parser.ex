defmodule Parser do
  defstruct [
    :lexer,
    :token,
    :peek,
    block_level: 0,
    prefix_parse_fns: %{},
    infix_parse_fns: %{},
    errors: []
  ]

  @whitespace_delimiter_count 2

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
  end

  def parse_tokens(lexer) do
    {statements, parser} = parse_statements(new(lexer))
    {%AST.Root{statements: statements}, parser}
  end

  defp next_token(%{peek: peek} = parser) do
    {lex, next} = Lexer.next_token(parser.lexer)
    struct(parser, lexer: lex, token: peek, peek: next)
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
        IDENT: &parse_identifier/1,
        TRUE: &parse_boolean/1,
        FALSE: &parse_boolean/1,
        STRING: &parse_string_literal/1,
        FUNCTION: &parse_function/1
      }
    )
  end

  defp register_infix_fns(parser) do
    parser
    |> struct(infix_parse_fns: %{})
  end

  defp add_error(parser, error) do
    Map.update(parser, :errors, [], &(&1 ++ [error]))
  end

  defp increment_block_level(parser) do
    Map.update(parser, :block_level, 0, &(&1 + 1))
  end

  defp decrement_block_level(parser) do
    Map.update(parser, :block_level, 0, &(&1 - 1))
  end

  defp parse_statements(parser, statements \\ []) do
    parser = next_token(parser)

    case parser.token.type do
      :EOF ->
        {statements, parser}

      :SPACE ->
        parse_statements(parser, statements)

      :NEWLINE ->
        block_indent = parser.block_level * @whitespace_delimiter_count
        indent = calculate_ident(parser.peek)

        cond do
          block_indent == indent ->
            parse_statements(parser, statements)

          block_indent > indent ->
            {statements, parser}
        end

      _ ->
        {statements, parser} =
          case parse_statement(parser) do
            {nil, parser} ->
              {statements, parser}

            {stmt, parser} ->
              {statements ++ [stmt], parser}
          end

        parse_statements(parser, statements)
    end
  end

  defp calculate_ident(nil), do: 0

  defp calculate_ident(%{type: :SPACE, literal: literal}) do
    String.length(literal)
  end

  defp calculate_ident(_), do: 0

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
    {name, parser} = parse_name(parser)
    {value, parser} = parse_value(parser)
    {struct(node, name: name, value: value), parser}
  end

  defp parse_name(parser) do
    parser = next_token(parser)

    case parser.token.type do
      :IDENT ->
        parse_identifier(parser)

      type ->
        error = "expected next token to be :IDENT, got #{type} instead"
        {nil, add_error(parser, error)}
    end
  end

  defp parse_value(parser) do
    parser = next_token(parser)

    case parser.token.type do
      :MATCH ->
        {value, parser} =
          parser
          |> next_token()
          |> parse_expression(@lowest)

        {value, parser}

      type ->
        error = "expected next token to be :MATCH, got #{type} instead"
        {nil, add_error(parser, error)}
    end
  end

  defp parse_expression(parser, precedence) do
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
    case parser.infix_parse_fns[parser.peek.type] do
      nil ->
        {left_expr, parser}

      infix ->
        if precedence < peek_precedence(parser) do
          parser
          |> next_token()
          |> infix.(left_expr)
        else
          {left_expr, parser}
        end
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
    {%AST.Identifier{value: parser.token.literal, token: parser.token}, parser}
  end

  defp parse_boolean(parser) do
    value =
      case parser.token.type do
        :TRUE -> true
        _ -> false
      end

    {%AST.Boolean{value: value, token: parser.token}, parser}
  end

  defp parse_string_literal(parser) do
    {%AST.StringLiteral{value: parser.token.literal, token: parser.token}, parser}
  end

  defp parse_function(parser) do
    node = %AST.Function{token: parser.token}
    {name, parser} = parse_function_name(parser)
    {parameters, parser} = parse_parameters(parser)
    {body, parser} = parse_body(parser)
    {struct(node, name: name, parameters: parameters, body: body), parser}
  end

  defp parse_function_name(parser) do
    parser = next_token(parser)

    case parser.token.type do
      :IDENT ->
        parse_identifier(parser)

      _ ->
        # anonymous fn
        {nil, parser}
    end
  end

  defp parse_parameters(parser) do
    parser = next_token(parser)

    case parser.token.type do
      :LPAREN ->
        parse_parameters(parser, [])

      type ->
        error = "expected next token to be :LPAREN, got #{type} instead"
        {nil, add_error(parser, error)}
    end
  end

  defp parse_parameters(parser, params) do
    parser = next_token(parser)

    case parser.token.type do
      :RPAREN ->
        {params, next_token(parser)}

      :COMMA ->
        parse_parameters(parser, params)

      :IDENT ->
        {param, parser} = parse_identifier(parser)
        parse_parameters(parser, params ++ [param])

      type ->
        error = "expected next token to be :RPAREN, :COMMA, :IDENT, got #{type} instead"
        {nil, add_error(parser, error)}
    end
  end

  defp parse_body(parser) do
    case parser.token.type do
      :COLON ->
        parser = next_token(parser)

        case parser.token.type do
          :NEWLINE ->
            block = %AST.Block{token: parser.token}

            {exprs, parser} =
              parser
              |> increment_block_level()
              |> parse_statements()

            parser = decrement_block_level(parser)
            {Map.put(block, :expressions, exprs), parser}

          _ ->
            IO.inspect(parser, label: "one line expression")
        end

      type ->
        error = "expected next token to be :COLON, got #{type} instead"
        {nil, add_error(parser, error)}
    end
  end
end
