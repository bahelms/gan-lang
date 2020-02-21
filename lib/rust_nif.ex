defmodule RustNIF do
  use Rustler, otp_app: :gan, crate: "rustnif"

  def add(_a, _b), do: :erlang.nif_error(:nif_not_loaded)
end
