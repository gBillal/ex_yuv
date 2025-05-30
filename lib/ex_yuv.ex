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

  The memory layout of the result is `<<red::8, green::8, blue::8>>`
  """
  @spec i420_to_raw!(i420_data(), width(), height()) :: binary()
  def i420_to_raw!(data, width, height) do
    convert_from_i420(data, width, height, :RAW)
  end

  @doc """
  Convert I420 to BGR24.

  > ### Note {: .info}
  >
  > Even when the function name hints that the output format is RGB24, it's
  > actually BGR24.
  > We kept the same naming convention used in `libyuv`.
  """
  @spec i420_to_rgb24!(i420_data(), width(), height()) :: binary()
  def i420_to_rgb24!(data, width, height) do
    convert_from_i420(data, width, height, :RGB24)
  end

  @doc """
  Convert I420 to ARGB.

  The memory layout of the result is `<<blue::8, green::8, red::8, alpha::8>>`
  """
  @spec i420_to_argb!(i420_data(), width(), height()) :: binary()
  def i420_to_argb!(data, width, height) do
    convert_from_i420(data, width, height, :ARGB)
  end

  @doc """
  Convert I420 to ABGR.

  The memory layout of the result is `<<red::8, green::8, blue::8, alpha::8>>`
  """
  @spec i420_to_abgr!(i420_data(), width(), height()) :: binary()
  def i420_to_abgr!(data, width, height) do
    convert_from_i420(data, width, height, :ABGR)
  end

  @doc """
  Convert I420 to RGBA.

  The memory layout of the result is `<<alpha::8, blue::8, green::8, red::8>>`
  """
  @spec i420_to_rgba!(i420_data(), width(), height()) :: binary()
  def i420_to_rgba!(data, width, height) do
    convert_from_i420(data, width, height, :RGBA)
  end

  @doc """
  Convert I420 to BGRA.

  The memory layout of the result is `<<alpha::8, red::8, green::8, blue::8>>`
  """
  @spec i420_to_bgra!(i420_data(), width(), height()) :: binary()
  def i420_to_bgra!(data, width, height) do
    convert_from_i420(data, width, height, :BGRA)
  end

  @doc """
  Convert I420 to RGB565.

  The memory layout of the result is `<<red::5, green::6, blue::5>>`
  """
  @spec i420_to_rgb565!(i420_data(), width(), height()) :: binary()
  def i420_to_rgb565!(data, width, height) do
    convert_from_i420(data, width, height, :RGB565)
  end

  @doc """
  Convert I420 to ARGB1555.

  The memory layout of the result is `<<alpha::1, red::5, green::5, blue::5>>`
  """
  @spec i420_to_argb1555!(i420_data(), width(), height()) :: binary()
  def i420_to_argb1555!(data, width, height) do
    convert_from_i420(data, width, height, :ARGB1555)
  end

  @doc """
  Convert I420 to ARGB4444.

  The memory layout of the result is `<<alpha::4, red::4, green::4, blue::4>>`
  """
  @spec i420_to_argb4444!(i420_data(), width(), height()) :: binary()
  def i420_to_argb4444!(data, width, height) do
    convert_from_i420(data, width, height, :ARGB4444)
  end

  @doc """
  Convert I420 to AR30.

  The memory layout of the result is `<<alpha::2, red::10, green::10, blue::10>>`
  """
  @spec i420_to_ar30!(i420_data(), width(), height()) :: binary()
  def i420_to_ar30!(data, width, height) do
    convert_from_i420(data, width, height, :AR30)
  end

  @doc """
  Convert I420 to AB30.

  The memory layout of the result is `<<alpha::2, blue::10, green::10, red::10>>`
  """
  @spec i420_to_ab30!(i420_data(), width(), height()) :: binary()
  def i420_to_ab30!(data, width, height) do
    convert_from_i420(data, width, height, :AB30)
  end

  @doc """
  Converts from RGB24 to I420 format.
  """
  @spec raw_to_i420!(binary(), width(), height()) :: yuv_planes()
  def raw_to_i420!(data, width, height) do
    NIF.raw_to_i420(data, width, height)
  end

  defp convert_from_i420(data, width, height, out_format) do
    {y_plane, u_plane, v_plane} = yuv_planes(data, width, height)
    NIF.convert_from_i420(y_plane, u_plane, v_plane, width, height, out_format)
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
    u_width = div(width, 2) + rem(width, 2)
    u_height = div(height, 2) + rem(height, 2)
    u_plane_size = u_height * u_width

    <<y::binary-size(y_plane_size), u::binary-size(u_plane_size), v::binary-size(u_plane_size)>> =
      data

    {y, u, v}
  end
end
