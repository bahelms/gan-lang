defmodule AST do
  defmodule Root do
    defstruct statements: []
  end

  defmodule Val do
    defstruct [:name, :value, :token]
  end

  defmodule Identifier do
    defstruct [:value, :token]
  end

  defmodule IntegerLiteral do
    defstruct [:value, :token]
  end
end
