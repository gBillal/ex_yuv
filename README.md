# ExYUV

[![Hex.pm](https://img.shields.io/hexpm/v/ex_yuv.svg)](https://hex.pm/packages/ex_yuv)
[![API Docs](https://img.shields.io/badge/api-docs-yellow.svg?style=flat)](https://hexdocs.pm/ex_yuv)

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

### Planar Formats

| Format | Planes | Description |
|--------|--------|-------------|
| `I420` | 3      | Y full resolution. U half width, half height. V half width, half height |

### Packed Formats

| Format | Bits Per Pixel | Pixel Memory Layout |
|--------|---------------|---------------|
| `RAW` (RGB) | 24       | `<<r::8, g::8, b::8>>` |
| `RGB24` | 24           | `<<b::8, g::8, r::8>>` |
| `ARGB`  | 32           | `<<b::8, g::8, r::8, a::8>>` |
| `ABGR`  | 32           | `<<r::8, g::8, b::8, a::8>>` |
| `BGRA`  | 32           | `<<a::8, r::8, g::8, b::8>>` |
| `RGBA`  | 32           | `<<a::8, b::8, g::8, r::8>>` |
| `RGB565`| 16           | `<<r::5, g::6, b::5>>` |
| `RGB1555`| 16          | `<<a::1, r::5, g::6, b::5>>` |
| `RGB4444`| 16          | `<<a::4, r::4, g::4, b::4>>` |
| `AR30`  | 32          | `<<a::2, r::10, g::10, b::10>>` |
| `AB30`  | 32          | `<<a::2, b::10, g::10, r::10>>` |


## Installation

The package can be installed by adding `ex_yuv` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_yuv, "~> 0.2.0"}
  ]
end
```

