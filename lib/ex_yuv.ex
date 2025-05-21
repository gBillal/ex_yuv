defmodule ExYUV do
  @moduledoc File.read!("README.md")

  alias ExYUV.NIF

  @type width :: pos_integer()
  @type height :: pos_integer()

  @type y_plane :: binary()
  @type u_plane :: binary()
  @type v_plane :: binary()

  @type i420 :: binary() | {y_plane(), u_plane(), v_plane()} | [binary()]

  @doc """
  Converts from I420 to RGB24 format.

  The input should be the planes (Y, U and V), in case a binary is
  provided, it'll try to get the planes from it.
  """
  @spec i420_to_raw!(i420(), width(), height()) :: binary()
  def i420_to_raw!(data, width, height) do
    {y_plane, u_plane, v_plane} =
      case data do
        [y, u, v] -> {y, u, v}
        {y, u, v} -> {y, u, v}
        data -> planes_from_binary(data, width, height, :I420)
      end

    NIF.i420_to_raw(y_plane, u_plane, v_plane, width, height)
  end

  @doc """
  Converts from RGB24 to I420 format.
  """
  @spec raw_to_i420!(binary(), width(), height()) :: {y_plane(), u_plane(), v_plane()}
  def raw_to_i420!(data, width, height) do
    NIF.raw_to_i420(data, width, height)
  end

  defp planes_from_binary(data, width, height, :I420) when is_binary(data) do
    y_plane_size = width * height
    u_plane_size = div(width * height, 4)

    <<y::binary-size(y_plane_size), u::binary-size(u_plane_size), v::binary-size(u_plane_size)>> =
      data

    {y, u, v}
  end
end
