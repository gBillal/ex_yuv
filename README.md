# ExYUV

Elixir binding for [libyuv](https://chromium.googlesource.com/libyuv/libyuv/).

libyuv is an open source project that includes YUV scaling and conversion functionality.

  * Scale YUV to prepare content for compression, with point, bilinear or box filter.
  * Convert to YUV from webcam formats for compression.
  * Convert to RGB formats for rendering/effects.
  * Rotate by 90/180/270 degrees to adjust for mobile devices in portrait mode.
  * Optimized for SSSE3/AVX2 on x86/x64.
  * Optimized for Neon/SVE2/SME on Arm.
  * Optimized for MSA on Mips.
  * Optimized for RVV on RISC-V.

## Installation

The package can be installed by adding `ex_yuv` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_yuv, "~> 0.1.0"}
  ]
end
```

