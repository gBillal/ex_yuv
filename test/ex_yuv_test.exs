defmodule ExYUVTest do
  use ExUnit.Case

  @i420_refs ~w(raw rgb24 argb abgr bgra rgba rgb565 argb1555 argb4444 ar30 ab30)

  Enum.map(@i420_refs, fn format ->
    test "convert I420 to #{format}" do
      input = File.read!("test/fixtures/src_i420_120x80.raw")
      output = File.read!("test/fixtures/i420/ref_#{unquote(format)}_120x80.raw")

      assert ^output = apply(ExYUV, :"i420_to_#{unquote(format)}!", [input, 120, 80])
    end
  end)

  test "scale down I420" do
    input = File.read!("test/fixtures/src_i420_120x80.raw")
    output = File.read!("test/fixtures/i420/ref_scaled_80x40.raw")

    assert {y, u, v} = ExYUV.scale_i420!(input, 120, 80, 80, 40)
    assert ^output = <<y::binary, u::binary, v::binary>>
  end

  test "scale down ARGB" do
    input = File.read!("test/fixtures/src_argb_120x80.raw")
    output = File.read!("test/fixtures/argb/ref_scaled_100x60.raw")
    assert ^output = ExYUV.scale_argb!(input, 120, 80, 100, 60, :box)
  end
end
