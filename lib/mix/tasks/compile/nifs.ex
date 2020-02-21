defmodule Mix.Tasks.Compile.Nifs do
  use Mix.Task

  def run(_args) do
    {result, _err} = System.cmd("make", [], stderr_to_stdout: true)
    IO.binwrite(result)
  end
end
