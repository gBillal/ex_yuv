TEMP ?= $(HOME)/.cache
LIBYUV_DIR ?= $(TEMP)/libyuv
LIBYUV_BUILD ?= $(LIBYUV_DIR)/out
LIBYUV_BUILD_FLAG ?= $(LIBYUV_BUILD)/flag
LIBYUV_GIT_REPO ?= https://chromium.googlesource.com/libyuv/libyuv
LIBYUV_SRC = $(LIBYUV_DIR)/source

SRC = c_src/yuv_nif.c
PRIV_DIR = $(MIX_APP_PATH)/priv
YUV_NIF_SO = $(PRIV_DIR)/yuv_nif.so

CFLAGS = -shared -fPIC
IFLAGS = -I$(LIBYUV_DIR)/include/ -I$(ERTS_INCLUDE_DIR)
LDFLAGS = -L$(LIBYUV_BUILD) -lyuv
LDFLAGS += -Wl,-rpath,'$$ORIGIN'
LDFLAGS += -Wl,--allow-multiple-definition

ifeq ($(shell uname -s),Darwin)
	CFLAGS+=-undefined dynamic_lookup -flat_namespace
endif

all: $(LIBYUV_BUILD_FLAG) $(YUV_NIF_SO)

$(YUV_NIF_SO): $(SRC)
	@mkdir -p $(PRIV_DIR)
	cp $(abspath $(LIBYUV_BUILD)/libyuv.so) $(PRIV_DIR)
	$(CC) $(CFLAGS) $(IFLAGS) $(SRC) -o $(YUV_NIF_SO) $(LDFLAGS)

$(LIBYUV_BUILD_FLAG): 
	@mkdir -p $(LIBYUV_DIR)
	@if [ ! -d "$(LIBYUV_DIR)/.git" ]; then \
		git clone --depth=1 $(LIBYUV_GIT_REPO) $(LIBYUV_DIR); \
	fi
	@mkdir -p $(LIBYUV_BUILD) && \
		cd $(LIBYUV_BUILD) && \
		cmake .. && \
		cmake --build . --config Release && \
		touch $(LIBYUV_BUILD_FLAG)

clean:
	# /bin/rm -rf $(LIBYUV_DIR)
	# /bin/rm -rf $(LIBYUV_BUILD)/*
	/bin/rm -rf $(YUV_NIF_SO)
