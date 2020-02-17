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

  defmodule StringLiteral do
    defstruct [:value, :token]
  end

  defmodule Boolean do
    defstruct [:value, :token]
  end

  defmodule Function do
    defstruct [:name, :body, :token, parameters: []]
  end

  defmodule Block do
    defstruct [:token, expressions: []]
  end
end
