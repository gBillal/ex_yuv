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

## Formats

Formats (FOURCC) supported by libyuv are detailed here.

### Core Formats

There are 2 core formats supported by libyuv - `I420` and `ARGB`. All YUV formats can be converted to/from `I420`. All `RGB` formats can be converted to/from `ARGB`.

Filtering functions such as scaling and planar functions work on `I420` and/or `ARGB`.

### FOURCC (Four Charactacter Code) List

All the `FOURCC` list are available [here](https://chromium.googlesource.com/libyuv/libyuv/+/refs/heads/main/include/libyuv/video_common.h#52)

### The ARGB FOURCC

There are 4 ARGB layouts - ARGB, BGRA, ABGR and RGBA. ARGB is most common by far, used for screen formats,

These formats are presented as little endian in memory, so `ARGB` format is presented as `<<b::8, g::8, r::8, a::8>>`.

```elixir
argb = ExYUV.i420_to_argb!(data, width, height)
```

The memory presentation is equivalent to `BGRA`.

### RGB24 and RAW

There are two other RGB layouts - RGB24 (aka 24BG) and RAW

RGB24 is B,G,R in memory RAW is R,G,B in memory

## Installation

The package can be installed by adding `ex_yuv` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_yuv, "~> 0.1.0"}
  ]
end
```

