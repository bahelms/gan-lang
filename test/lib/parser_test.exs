defmodule ParserTest do
  use ExUnit.Case

  test "root node" do
    {root, parser} =
      """
      val x = 5
      val y = 11
      """
      |> Lexer.new()
      |> Parser.parse_tokens()

    assert_no_errors(parser.errors)

    expected_nodes = [
      AST.Val,
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
      {"val five = 5", "five", 5}
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

  def assert_no_errors([]), do: nil

  def assert_no_errors(errors) do
    IO.puts("\n")
    Enum.each(errors, &IO.puts/1)
    flunk("Parser errors found")
  end
end
