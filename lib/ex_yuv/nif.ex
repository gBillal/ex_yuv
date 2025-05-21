defmodule ExYUV.NIF do
  @moduledoc false

  @compile {:autoload, false}
  @on_load {:load_nif, 0}

  def load_nif do
    path = :filename.join(:code.priv_dir(:ex_yuv), ~c"yuv_nif")
    :erlang.load_nif(path, 0)
  end
end
