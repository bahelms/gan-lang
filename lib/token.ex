defmodule Token do
  defstruct [:type, :literal]

  @keyword_types %{
    "val" => :VAL
  }

  def ident_type(ident) do
    @keyword_types[ident]
  end
end
