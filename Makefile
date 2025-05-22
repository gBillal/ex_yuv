TEMP ?= $(HOME)/.cache
LIBYUV_DIR ?= $(TEMP)/libyuv
LIBYUV_GIT_REPO ?= https://chromium.googlesource.com/libyuv/libyuv
LIBYUV_SRC = $(LIBYUV_DIR)/source

CXXFLAGS?=-O2 -fomit-frame-pointer -fPIC
CXXFLAGS+=-I$(LIBYUV_DIR)/include/

SRC = c_src/yuv_nif.c
PRIV_DIR = $(MIX_APP_PATH)/priv
YUV_NIF_SO = $(PRIV_DIR)/yuv_nif.so

CFLAGS = -shared -fPIC
IFLAGS = -I$(LIBYUV_DIR)/include/ -I$(ERTS_INCLUDE_DIR)

LOCAL_OBJ_FILES := \
	$(LIBYUV_SRC)/compare.o           \
	$(LIBYUV_SRC)/compare_common.o    \
	$(LIBYUV_SRC)/compare_gcc.o       \
	$(LIBYUV_SRC)/compare_msa.o       \
	$(LIBYUV_SRC)/compare_neon.o      \
	$(LIBYUV_SRC)/compare_neon64.o    \
	$(LIBYUV_SRC)/compare_win.o       \
	$(LIBYUV_SRC)/convert.o           \
	$(LIBYUV_SRC)/convert_argb.o      \
	$(LIBYUV_SRC)/convert_from.o      \
	$(LIBYUV_SRC)/convert_from_argb.o \
	$(LIBYUV_SRC)/convert_jpeg.o      \
	$(LIBYUV_SRC)/convert_to_argb.o   \
	$(LIBYUV_SRC)/convert_to_i420.o   \
	$(LIBYUV_SRC)/cpu_id.o            \
	$(LIBYUV_SRC)/mjpeg_decoder.o     \
	$(LIBYUV_SRC)/mjpeg_validate.o    \
	$(LIBYUV_SRC)/planar_functions.o  \
	$(LIBYUV_SRC)/rotate.o            \
	$(LIBYUV_SRC)/rotate_any.o        \
	$(LIBYUV_SRC)/rotate_argb.o       \
	$(LIBYUV_SRC)/rotate_common.o     \
	$(LIBYUV_SRC)/rotate_gcc.o        \
	$(LIBYUV_SRC)/rotate_lsx.o        \
	$(LIBYUV_SRC)/rotate_msa.o        \
	$(LIBYUV_SRC)/rotate_neon.o       \
	$(LIBYUV_SRC)/rotate_neon64.o     \
	$(LIBYUV_SRC)/rotate_win.o        \
	$(LIBYUV_SRC)/row_any.o           \
	$(LIBYUV_SRC)/row_common.o        \
	$(LIBYUV_SRC)/row_gcc.o           \
	$(LIBYUV_SRC)/row_lasx.o          \
	$(LIBYUV_SRC)/row_lsx.o           \
	$(LIBYUV_SRC)/row_msa.o           \
	$(LIBYUV_SRC)/row_neon.o          \
	$(LIBYUV_SRC)/row_neon64.o        \
	$(LIBYUV_SRC)/row_rvv.o           \
	$(LIBYUV_SRC)/row_win.o           \
	$(LIBYUV_SRC)/scale.o             \
	$(LIBYUV_SRC)/scale_any.o         \
	$(LIBYUV_SRC)/scale_argb.o        \
	$(LIBYUV_SRC)/scale_common.o      \
	$(LIBYUV_SRC)/scale_gcc.o         \
	$(LIBYUV_SRC)/scale_lsx.o         \
	$(LIBYUV_SRC)/scale_msa.o         \
	$(LIBYUV_SRC)/scale_neon.o        \
	$(LIBYUV_SRC)/scale_neon64.o      \
	$(LIBYUV_SRC)/scale_rgb.o         \
	$(LIBYUV_SRC)/scale_rvv.o         \
	$(LIBYUV_SRC)/scale_uv.o          \
	$(LIBYUV_SRC)/scale_win.o         \
	$(LIBYUV_SRC)/video_common.o

all: fetch_libyuv $(YUV_NIF_SO)

.cc.o:
	$(CXX) -c $(CXXFLAGS) $*.cc -o $*.o

$(YUV_NIF_SO): $(LOCAL_OBJ_FILES) $(SRC)
	mkdir -p $(PRIV_DIR)
	$(CC) $(CFLAGS) $(IFLAGS) $(LFLAGS) $(SRC) $(LOCAL_OBJ_FILES) -o $(YUV_NIF_SO)

fetch_libyuv: 
	mkdir -p $(LIBYUV_DIR)
	if [ ! -d "$(LIBYUV_DIR)/.git" ]; then \
		git clone -q --depth=1 $(LIBYUV_GIT_REPO) $(LIBYUV_DIR); \
	fi

clean:
	# /bin/rm -rf $(LIBYUV_DIR)
	/bin/rm -f $(YUV_NIF_SO) $(LOCAL_OBJ_FILES)