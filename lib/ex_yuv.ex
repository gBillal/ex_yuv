defmodule ExYUV do
  @moduledoc File.read!("README.md")

  alias ExYUV.NIF

  @type width :: pos_integer()
  @type height :: pos_integer()

  @type y_plane :: binary()
  @type u_plane :: binary()
  @type v_plane :: binary()

  @type i420_data :: binary() | {y_plane(), u_plane(), v_plane()} | [binary()]
  @type yuv_planes :: {y_plane(), u_plane(), v_plane()}

  @type filter_mode :: :none | :linear | :bilinear | :box

  @filter_modes [:none, :linear, :bilinear, :box]

  @doc """
  Converts from I420 to RGB24 format.

  The input should be the planes (Y, U and V), in case a binary is
  provided, it'll try to get the planes from it.
  """
  @spec i420_to_raw!(i420_data(), width(), height()) :: binary()
  def i420_to_raw!(data, width, height) do
    {y_plane, u_plane, v_plane} = yuv_planes(data, width, height)
    NIF.i420_to_raw(y_plane, u_plane, v_plane, width, height)
  end

  @doc """
  Converts from RGB24 to I420 format.
  """
  @spec raw_to_i420!(binary(), width(), height()) :: yuv_planes()
  def raw_to_i420!(data, width, height) do
    NIF.raw_to_i420(data, width, height)
  end

  @doc """
  Scale I420 image.

  The following filters are supported: `none`, `linear`, `bilinear`, and `box`.

  Check [libyuv](https://chromium.googlesource.com/libyuv/libyuv/+/refs/heads/main/docs/filtering.md) documentation for more details.
  """
  @spec scale_i420!(i420_data(), width(), height(), width(), height()) :: yuv_planes()
  @spec scale_i420!(i420_data(), width(), height(), width(), height(), filter_mode()) ::
          yuv_planes()
  def scale_i420!(data, width, height, out_width, out_height, filter_mode \\ :none)
      when filter_mode in @filter_modes do
    {y_plane, u_plane, v_plane} = yuv_planes(data, width, height)
    NIF.scale_i420(y_plane, u_plane, v_plane, width, height, out_width, out_height, filter_mode)
  end

  defp yuv_planes(data, width, height) do
    case data do
      [y, u, v] -> {y, u, v}
      {y, u, v} -> {y, u, v}
      data -> planes_from_binary(data, width, height, :I420)
    end
  end

  defp planes_from_binary(data, width, height, :I420) when is_binary(data) do
    y_plane_size = width * height
    u_plane_size = div(width * height, 4)

    <<y::binary-size(y_plane_size), u::binary-size(u_plane_size), v::binary-size(u_plane_size)>> =
      data

    {y, u, v}
  end
end
