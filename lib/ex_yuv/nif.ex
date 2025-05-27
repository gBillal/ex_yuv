defmodule ExYUV.NIF do
  @moduledoc false

  @on_load :load_nif

  def load_nif do
    path = :filename.join(:code.priv_dir(:ex_yuv), ~c"yuv_nif")

    case :erlang.load_nif(path, 0) do
      :ok -> :ok
      {:error, {:reload, _}} -> :ok
      {:error, reason} -> IO.puts("Failed to load nif: #{inspect(reason)}")
    end
  end

  def convert_from_i420(_y_plane, _u_plane, _v_plane, _width, _height, _out_format) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def raw_to_i420(_raw, _width, _height) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def scale_i420(
        _y_plane,
        _u_plane,
        _v_plane,
        _width,
        _height,
        _out_width,
        _out_height,
        _filter_mode
      ) do
    :erlang.nif_error(:nif_not_loaded)
  end
end
