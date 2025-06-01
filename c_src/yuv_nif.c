#include "libyuv.h"
#include "libyuv/scale_rgb.h"
#include "erl_nif.h"
#include "string.h"

static ERL_NIF_TERM am_badarg;
static ERL_NIF_TERM am_failed_to_convert;
static ERL_NIF_TERM am_unknown_format;

static ERL_NIF_TERM raise_badarg(ErlNifEnv* env, ERL_NIF_TERM term)
{
    ERL_NIF_TERM badarg = enif_make_tuple2(env, am_badarg, term);
    return enif_raise_exception(env, badarg);
}

static int get_atom(ErlNifEnv* env, ERL_NIF_TERM atom, char** atom_name) {
    unsigned int atom_len;
    if (!enif_get_atom_length(env, atom, &atom_len, ERL_NIF_LATIN1)) {
        return 0;
    }

    *atom_name = enif_alloc(atom_len + 1);
    return enif_get_atom(env, atom, *atom_name, atom_len + 1, ERL_NIF_LATIN1);    
}

static enum FilterMode filter_mode_from_string(const char* filter_mode) {
    if (strcmp(filter_mode, "none") == 0) {
        return kFilterNone;
    } else if (strcmp(filter_mode, "bilinear") == 0) {
        return kFilterBilinear;
    } else if (strcmp(filter_mode, "linear") == 0) {
        return kFilterLinear;
    } else {
        return kFilterBox;
    }
}

static ERL_NIF_TERM convert_i420(ErlNifEnv *env, ErlNifBinary y_plane, ErlNifBinary u_plane, ErlNifBinary v_plane,
                                 int width, int height, const char *out_format) {
    int ret;
    unsigned char *ptr;
    ERL_NIF_TERM res;

    int uv_stride = width / 2 + width % 2;

    if (strcmp(out_format, "RAW") == 0) {
        unsigned char *ptr = enif_make_new_binary(env, width * height * 3, &res);
        ret = I420ToRAW(y_plane.data, width, u_plane.data, uv_stride, v_plane.data, uv_stride, ptr, width * 3, width, height);
    } else if (strcmp(out_format, "RGB24") == 0) {
        unsigned char *ptr = enif_make_new_binary(env, width * height * 3, &res);
        ret = I420ToRGB24(y_plane.data, width, u_plane.data, uv_stride, v_plane.data, uv_stride, ptr, width * 3, width, height);
    } else if (strcmp(out_format, "ARGB") == 0) {
        unsigned char *ptr = enif_make_new_binary(env, width * height * 4, &res);
        ret = I420ToARGB(y_plane.data, width, u_plane.data, uv_stride, v_plane.data, uv_stride, ptr, width * 4, width, height);
    } else if (strcmp(out_format, "ABGR") == 0) {
        unsigned char *ptr = enif_make_new_binary(env, width * height * 4, &res);
        ret = I420ToABGR(y_plane.data, width, u_plane.data, uv_stride, v_plane.data, uv_stride, ptr, width * 4, width, height);
    } else if (strcmp(out_format, "RGBA") == 0) {
        unsigned char *ptr = enif_make_new_binary(env, width * height * 4, &res);
        ret = I420ToRGBA(y_plane.data, width, u_plane.data, uv_stride, v_plane.data, uv_stride, ptr, width * 4, width, height);
    } else if (strcmp(out_format, "BGRA") == 0) {
        unsigned char *ptr = enif_make_new_binary(env, width * height * 4, &res);
        ret = I420ToBGRA(y_plane.data, width, u_plane.data, uv_stride, v_plane.data, uv_stride, ptr, width * 4, width, height);
    } else if (strcmp(out_format, "RGB565") == 0) {
        unsigned char *ptr = enif_make_new_binary(env, width * height * 2, &res);
        ret = I420ToRGB565(y_plane.data, width, u_plane.data, uv_stride, v_plane.data, uv_stride, ptr, width * 2, width, height);
    } else if (strcmp(out_format, "ARGB1555") == 0) {
        unsigned char *ptr = enif_make_new_binary(env, width * height * 2, &res);
        ret = I420ToARGB1555(y_plane.data, width, u_plane.data, uv_stride, v_plane.data, uv_stride, ptr, width * 2, width, height);
    } else if (strcmp(out_format, "ARGB4444") == 0) {
        unsigned char *ptr = enif_make_new_binary(env, width * height * 2, &res);
        ret = I420ToARGB4444(y_plane.data, width, u_plane.data, uv_stride, v_plane.data, uv_stride, ptr, width * 2, width, height);
    } else if (strcmp(out_format, "AR30") == 0) {
        unsigned char *ptr = enif_make_new_binary(env, width * height * 4, &res);
        ret = I420ToAR30(y_plane.data, width, u_plane.data, uv_stride, v_plane.data, uv_stride, ptr, width * 4, width, height);
    } else if (strcmp(out_format, "AB30") == 0) {
        unsigned char *ptr = enif_make_new_binary(env, width * height * 4, &res);
        ret = I420ToAB30(y_plane.data, width, u_plane.data, uv_stride, v_plane.data, uv_stride, ptr, width * 4, width, height);
    } else {
        return raise_badarg(env, am_unknown_format);
    }

    return ret == 0 ? res : raise_badarg(env, am_failed_to_convert);
}

ERL_NIF_TERM convert_from_i420(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
    if (argc != 6) {
        return enif_make_badarg(env);
    }

    ErlNifBinary y_plane;
    ErlNifBinary u_plane;
    ErlNifBinary v_plane;
    int width, height;
    char *out_format;
    
    if (!enif_inspect_binary(env, argv[0], &y_plane)) {
        return raise_badarg(env, argv[0]);
    }

    if (!enif_inspect_binary(env, argv[1], &u_plane)) {
        return raise_badarg(env, argv[1]);
    }

    if (!enif_inspect_binary(env, argv[2], &v_plane)) {
        return raise_badarg(env, argv[2]);
    }

    if (!enif_get_int(env, argv[3], &width)) {
        return raise_badarg(env, argv[3]);
    }

    if (!enif_get_int(env, argv[4], &height)) {
        return raise_badarg(env, argv[4]);
    }

    if (!get_atom(env, argv[5], &out_format)) {
        return raise_badarg(env, argv[5]);
    }

    ERL_NIF_TERM res = convert_i420(env, y_plane, u_plane, v_plane, width, height, out_format);
    enif_free(out_format);
    return res;
}

ERL_NIF_TERM raw_to_i420(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
    if (argc != 3) {
        return enif_make_badarg(env);
    }

    ErlNifBinary raw_data;
    int width, height;
    
    if (!enif_inspect_binary(env, argv[0], &raw_data)) {
        return raise_badarg(env, argv[0]);
    }

    if (!enif_get_int(env, argv[1], &width)) {
        return raise_badarg(env, argv[1]);
    }

    if (!enif_get_int(env, argv[2], &height)) {
        return raise_badarg(env, argv[2]);
    }

    ERL_NIF_TERM y_plane;
    ERL_NIF_TERM u_plane;
    ERL_NIF_TERM v_plane;

    unsigned char *y_ptr = enif_make_new_binary(env, width * height, &y_plane);
    unsigned char *u_ptr = enif_make_new_binary(env, width * height / 4, &u_plane);
    unsigned char *v_ptr = enif_make_new_binary(env, width * height / 4, &v_plane);

    int uv_stride = width / 2 + width % 2;

    if (RAWToI420(raw_data.data, width * 3, y_ptr, width, u_ptr, uv_stride, v_ptr, uv_stride, width, height)) {
        return raise_badarg(env, am_failed_to_convert);
    }

    return enif_make_tuple3(env, y_plane, u_plane, v_plane);
}

ERL_NIF_TERM scale_i420(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
    if (argc != 8) {
        return enif_make_badarg(env);
    }

    ErlNifBinary y_plane;
    ErlNifBinary u_plane;
    ErlNifBinary v_plane;
    int width, height, out_width, out_height;
    char* filter_mode;
    
    if (!enif_inspect_binary(env, argv[0], &y_plane)) {
        return raise_badarg(env, argv[0]);
    }

    if (!enif_inspect_binary(env, argv[1], &u_plane)) {
        return raise_badarg(env, argv[1]);
    }

    if (!enif_inspect_binary(env, argv[2], &v_plane)) {
        return raise_badarg(env, argv[2]);
    }

    if (!enif_get_int(env, argv[3], &width)) {
        return raise_badarg(env, argv[3]);
    }

    if (!enif_get_int(env, argv[4], &height)) {
        return raise_badarg(env, argv[4]);
    }

    if (!enif_get_int(env, argv[5], &out_width)) {
        return raise_badarg(env, argv[5]);
    }

    if (!enif_get_int(env, argv[6], &out_height)) {
        return raise_badarg(env, argv[6]);
    }

    if (!get_atom(env, argv[7], &filter_mode)) {
        return raise_badarg(env, argv[7]);
    }

    ERL_NIF_TERM y_plane_out;
    ERL_NIF_TERM u_plane_out;
    ERL_NIF_TERM v_plane_out;

    unsigned char *y_ptr_out = enif_make_new_binary(env, out_width * out_height, &y_plane_out);
    unsigned char *u_ptr_out = enif_make_new_binary(env, out_width * out_height / 4, &u_plane_out);
    unsigned char *v_ptr_out = enif_make_new_binary(env, out_width * out_height / 4, &v_plane_out);

    int uv_stride = width / 2 + width % 2;
    int out_uv_stride = out_width / 2 + out_width % 2;

    if (I420Scale(y_plane.data, width, u_plane.data, uv_stride, v_plane.data, uv_stride, width, height,
                  y_ptr_out, out_width, u_ptr_out, out_uv_stride, v_ptr_out, out_uv_stride,
                  out_width, out_height, filter_mode_from_string(filter_mode))) {
        enif_free(filter_mode);
        return raise_badarg(env, am_failed_to_convert);
    }

    enif_free(filter_mode);

    return enif_make_tuple3(env, y_plane_out, u_plane_out, v_plane_out);
}

ERL_NIF_TERM scale_argb(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
    if (argc != 7) {
        return enif_make_badarg(env);
    }

    ErlNifBinary data;
    int width, height, out_width, out_height;
    char *filter_mode, *format;
    
    if (!enif_inspect_binary(env, argv[0], &data)) {
        return raise_badarg(env, argv[0]);
    }

    if (!enif_get_int(env, argv[1], &width)) {
        return raise_badarg(env, argv[1]);
    }

    if (!enif_get_int(env, argv[2], &height)) {
        return raise_badarg(env, argv[2]);
    }

    if (!enif_get_int(env, argv[3], &out_width)) {
        return raise_badarg(env, argv[3]);
    }

    if (!enif_get_int(env, argv[4], &out_height)) {
        return raise_badarg(env, argv[4]);
    }

    if (!get_atom(env, argv[5], &filter_mode)) {
        return raise_badarg(env, argv[5]);
    }

    if (!get_atom(env, argv[6], &format)) {
        return raise_badarg(env, argv[6]);
    }

    ERL_NIF_TERM result;
    unsigned char *out_data_ptr;
    int ret;

    if (strcmp(format, "RGB24") == 0) {
        out_data_ptr = enif_make_new_binary(env, out_width * out_height * 3, &result);
        ret = RGBScale(data.data, width * 3, width, height, out_data_ptr, out_width * 3, out_width, 
                out_height, filter_mode_from_string(filter_mode));
    } else if (strcmp(format, "ARGB") == 0) {
        out_data_ptr = enif_make_new_binary(env, out_width * out_height * 4, &result);
        ret = ARGBScale(data.data, width * 4, width, height, out_data_ptr, out_width * 4, out_width, 
                    out_height, filter_mode_from_string(filter_mode));
    } else {
        result = raise_badarg(env, am_unknown_format);
    }

    if (ret < 0)
        result = raise_badarg(env, am_failed_to_convert);


    enif_free(filter_mode);
    enif_free(format);

    return result;
}

static int on_load(ErlNifEnv* env, void** priv_data, ERL_NIF_TERM load_info) {
    am_badarg = enif_make_atom(env, "badarg");
    am_failed_to_convert = enif_make_atom(env, "failed_to_convert");
    am_unknown_format = enif_make_atom(env, "Unknown format");
    return 0;
}

static int on_reload(ErlNifEnv *_sth0, void **_sth1, ERL_NIF_TERM _sth2) {
    return 0;
}

static int on_upgrade(ErlNifEnv *_sth0, void **_sth1, void **_sth2, ERL_NIF_TERM _sth3) {
    return 0;
}

static ErlNifFunc nif_funcs[] = {
    {"convert_from_i420", 6, convert_from_i420, ERL_NIF_DIRTY_JOB_CPU_BOUND},
    {"raw_to_i420", 3, raw_to_i420, ERL_NIF_DIRTY_JOB_CPU_BOUND},
    {"scale_i420", 8, scale_i420, ERL_NIF_DIRTY_JOB_CPU_BOUND},
    {"scale_argb", 7, scale_argb, ERL_NIF_DIRTY_JOB_CPU_BOUND}
};

ERL_NIF_INIT(Elixir.ExYUV.NIF, nif_funcs, on_load, on_reload, on_upgrade, NULL);