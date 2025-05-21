defmodule ExYUV.NIF do
  @moduledoc false

  @compile {:autoload, false}
  @on_load {:load_nif, 0}

  def load_nif do
    path = :filename.join(:code.priv_dir(:ex_yuv), ~c"yuv_nif")
    :erlang.load_nif(path, 0)
  end

  def i420_to_raw(_y_plane, _u_plane, _v_plane, _width, _height) do
    :erlang.nif_error(:nif_not_loaded)
  end
end
