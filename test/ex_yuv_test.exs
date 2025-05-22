defmodule ExYUVTest do
  use ExUnit.Case

  test "convert I420 to RAW" do
    input = File.read!("test/fixtures/I420_640x480.raw")
    output = File.read!("test/fixtures/reference_RGB24_640x480.raw")

    assert ^output = ExYUV.i420_to_raw!(input, 640, 480)
  end

  test "scale down I420" do
    input = File.read!("test/fixtures/I420_640x480.raw")
    output = File.read!("test/fixtures/reference_I420_scaled_360x240.raw")

    assert {y, u, v} = ExYUV.scale_i420!(input, 640, 480, 360, 240)
    assert ^output = <<y::binary, u::binary, v::binary>>
  end
end
