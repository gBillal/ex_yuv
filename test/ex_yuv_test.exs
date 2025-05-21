defmodule ExYUVTest do
  use ExUnit.Case

  test "convert I420 to RAW" do
    input = File.read!("test/fixtures/I420_640x480.raw")
    output = File.read!("test/fixtures/reference_RGB24_640x480.raw")

    assert ^output = ExYUV.i420_to_raw!(input, 640, 480)
  end
end
