defmodule ParserTest do
  use ExUnit.Case

  test "root node" do
    {root, parser} =
      """
      val x = 5
      val y = false

      fn heyThere(no):
        "say what?"

      val z = x
      """
      |> Lexer.new()
      |> Parser.parse_tokens()

    assert_no_errors(parser.errors)

    expected_nodes = [
      AST.Val,
      AST.Val,
      AST.Function,
      AST.Val
    ]

    assert length(root.statements) == length(expected_nodes)

    root.statements
    |> Enum.zip(expected_nodes)
    |> Enum.each(fn {node, expected_type} ->
      assert %^expected_type{} = node
    end)
  end

  test "val statements" do
    [
      {"val five = 5", "five", 5},
      {"val        x        =        0    ", "x", 0},
      {"val truth = true", "truth", true}
    ]
    |> Enum.each(fn {input, expected_name, expected_value} ->
      {root, parser} =
        input
        |> Lexer.new()
        |> Parser.parse_tokens()

      assert_no_errors(parser.errors)

      stmt = hd(root.statements)
      assert stmt.name.value == expected_name
      assert stmt.value.value == expected_value
    end)
  end

  test "integer expressions" do
    [
      {"5", 5},
      {"91923837373832", 91_923_837_373_832}
    ]
    |> Enum.each(fn {input, expected_value} ->
      {root, parser} =
        input
        |> Lexer.new()
        |> Parser.parse_tokens()

      assert_no_errors(parser.errors)

      stmt = hd(root.statements)
      assert stmt.value == expected_value
    end)
  end

  test "identifier expressions" do
    [
      {"foobar", "foobar"}
    ]
    |> Enum.each(fn {input, expected_value} ->
      {root, parser} =
        input
        |> Lexer.new()
        |> Parser.parse_tokens()

      assert_no_errors(parser.errors)

      stmt = hd(root.statements)
      assert stmt.value == expected_value
    end)
  end

  test "boolean expressions" do
    [
      {"true", true},
      {"false", false}
    ]
    |> Enum.each(fn {input, expected_value} ->
      {root, parser} =
        input
        |> Lexer.new()
        |> Parser.parse_tokens()

      assert_no_errors(parser.errors)

      stmt = hd(root.statements)
      assert stmt.value == expected_value
    end)
  end

  test "string expressions" do
    [
      {"\"hello there\"", "hello there"}
    ]
    |> Enum.each(fn {input, expected_value} ->
      {root, parser} =
        input
        |> Lexer.new()
        |> Parser.parse_tokens()

      assert_no_errors(parser.errors)

      stmt = hd(root.statements)
      assert stmt.value == expected_value
    end)
  end

  test "named function binding" do
    {root, parser} =
      """
      fn yo(x, another):
        val str = "str expr"
        x
      "block ended up there ^ "
      """
      |> Lexer.new()
      |> Parser.parse_tokens()

    assert_no_errors(parser.errors)

    [func | rest] = root.statements
    assert func.name.value == "yo"
    assert Enum.map(func.parameters, & &1.value) == ["x", "another"]

    [val | exprs] = func.body.expressions
    assert val.name.value == "str"
    assert val.value.value == "str expr"
    [ident | _] = exprs
    assert ident.value == "x"

    assert hd(rest).value == "block ended up there ^ "
  end

  def assert_no_errors([]), do: nil

  def assert_no_errors(errors) do
    IO.puts("\n")
    Enum.each(errors, &IO.puts/1)
    flunk("Parser errors found")
  end
end
