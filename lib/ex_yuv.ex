defmodule ExYUV do
  @moduledoc File.read!("README.md")

  alias ExYUV.NIF

  @type width :: pos_integer()
  @type height :: pos_integer()

  @type y_plane :: binary()
  @type u_plane :: binary()
  @type v_plane :: binary()

  @doc """
  Converts I420 YUV format to RGB24 format.
  """
  @spec i420_to_raw!(binary(), width(), height()) :: binary()
  def i420_to_raw!(data, width, height) do
    {y_plane, u_plane, v_plane} =
      case data do
        [y, u, v] -> {y, u, v}
        {y, u, v} -> {y, u, v}
        data -> planes_from_binary(data, width, height, :I420)
      end

    NIF.i420_to_raw(y_plane, u_plane, v_plane, width, height)
  end

  defp planes_from_binary(data, width, height, :I420) when is_binary(data) do
    y_plane_size = width * height
    u_plane_size = div(width * height, 4)

    <<y::binary-size(y_plane_size), u::binary-size(u_plane_size), v::binary-size(u_plane_size)>> =
      data

    {y, u, v}
  end
end
