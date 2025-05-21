
CXXFLAGS?=-O2 -fomit-frame-pointer -fPIC
CXXFLAGS+=-Ic_src/libyuv/include/
YUV_A = c_src/libyuv/libyuv.a

PRIV_DIR = $(MIX_APP_PATH)/priv
YUV_NIF_SO = $(PRIV_DIR)/yuv_nif.so

SRC = c_src/yuv_nif.c
CFLAGS = -fPIC -shared
IFLAGS+=-Ic_src/libyuv/include/
IFLAGS+=-I$(ERTS_INCLUDE_DIR)

LOCAL_OBJ_FILES := \
	c_src/libyuv/source/compare.o           \
	c_src/libyuv/source/compare_common.o    \
	c_src/libyuv/source/compare_gcc.o       \
	c_src/libyuv/source/compare_msa.o       \
	c_src/libyuv/source/compare_neon.o      \
	c_src/libyuv/source/compare_neon64.o    \
	c_src/libyuv/source/compare_win.o       \
	c_src/libyuv/source/convert.o           \
	c_src/libyuv/source/convert_argb.o      \
	c_src/libyuv/source/convert_from.o      \
	c_src/libyuv/source/convert_from_argb.o \
	c_src/libyuv/source/convert_jpeg.o      \
	c_src/libyuv/source/convert_to_argb.o   \
	c_src/libyuv/source/convert_to_i420.o   \
	c_src/libyuv/source/cpu_id.o            \
	c_src/libyuv/source/mjpeg_decoder.o     \
	c_src/libyuv/source/mjpeg_validate.o    \
	c_src/libyuv/source/planar_functions.o  \
	c_src/libyuv/source/rotate.o            \
	c_src/libyuv/source/rotate_any.o        \
	c_src/libyuv/source/rotate_argb.o       \
	c_src/libyuv/source/rotate_common.o     \
	c_src/libyuv/source/rotate_gcc.o        \
	c_src/libyuv/source/rotate_lsx.o        \
	c_src/libyuv/source/rotate_msa.o        \
	c_src/libyuv/source/rotate_neon.o       \
	c_src/libyuv/source/rotate_neon64.o     \
	c_src/libyuv/source/rotate_win.o        \
	c_src/libyuv/source/row_any.o           \
	c_src/libyuv/source/row_common.o        \
	c_src/libyuv/source/row_gcc.o           \
	c_src/libyuv/source/row_lasx.o          \
	c_src/libyuv/source/row_lsx.o           \
	c_src/libyuv/source/row_msa.o           \
	c_src/libyuv/source/row_neon.o          \
	c_src/libyuv/source/row_neon64.o        \
	c_src/libyuv/source/row_rvv.o           \
	c_src/libyuv/source/row_win.o           \
	c_src/libyuv/source/scale.o             \
	c_src/libyuv/source/scale_any.o         \
	c_src/libyuv/source/scale_argb.o        \
	c_src/libyuv/source/scale_common.o      \
	c_src/libyuv/source/scale_gcc.o         \
	c_src/libyuv/source/scale_lsx.o         \
	c_src/libyuv/source/scale_msa.o         \
	c_src/libyuv/source/scale_neon.o        \
	c_src/libyuv/source/scale_neon64.o      \
	c_src/libyuv/source/scale_rgb.o         \
	c_src/libyuv/source/scale_rvv.o         \
	c_src/libyuv/source/scale_uv.o          \
	c_src/libyuv/source/scale_win.o         \
	c_src/libyuv/source/video_common.o

.cc.o:
	$(CXX) -c $(CXXFLAGS) $*.cc -o $*.o

all: $(YUV_NIF_SO)

$(YUV_A): $(LOCAL_OBJ_FILES)
	$(AR) $(ARFLAGS) $@ $(LOCAL_OBJ_FILES)

$(YUV_NIF_SO): $(YUV_A) $(SRC)
	mkdir -p $(PRIV_DIR)
	$(CC) $(CFLAGS) $(IFLAGS) $(LFLAGS) $(SRC) -o $(YUV_NIF_SO) -Wl,--whole-archive $(YUV_A) -Wl,--no-whole-archive

clean:
	/bin/rm -f c_src/libyuv/source/*.o $(YUV_A) $(YUV_NIF_SO)