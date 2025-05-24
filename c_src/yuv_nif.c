#include "libyuv.h"
#include "erl_nif.h"
#include "string.h"

static ERL_NIF_TERM am_badarg;
static ERL_NIF_TERM am_failed_to_convert;

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

ERL_NIF_TERM i420_to_raw(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]) {
    if (argc != 5) {
        return enif_make_badarg(env);
    }

    ErlNifBinary y_plane;
    ErlNifBinary u_plane;
    ErlNifBinary v_plane;
    int width, height;
    
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

    ERL_NIF_TERM res;
    unsigned char *ptr = enif_make_new_binary(env, width * height * 3, &res);

    if (I420ToRAW(y_plane.data, width, u_plane.data, width / 2,  v_plane.data, width / 2, ptr, width * 3, width, height)) {
        return raise_badarg(env, am_failed_to_convert);
    }

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

    if (RAWToI420(raw_data.data, width * 3, y_ptr, width, u_ptr, width / 2, v_ptr, width / 2, width, height)) {
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

    if (I420Scale(y_plane.data, width, u_plane.data, width / 2, v_plane.data, width / 2, width, height,
                  y_ptr_out, out_width, u_ptr_out, out_width / 2, v_ptr_out, out_width / 2,
                  out_width, out_height, filter_mode_from_string(filter_mode))) {
        enif_free(filter_mode);
        return raise_badarg(env, am_failed_to_convert);
    }

    enif_free(filter_mode);

    return enif_make_tuple3(env, y_plane_out, u_plane_out, v_plane_out);
}

static int on_load(ErlNifEnv* env, void** priv_data, ERL_NIF_TERM load_info) {
    am_badarg = enif_make_atom(env, "badarg");
    am_failed_to_convert = enif_make_atom(env, "failed_to_convert");
    return 0;
}

static int on_reload(ErlNifEnv *_sth0, void **_sth1, ERL_NIF_TERM _sth2) {
    return 0;
}

static int on_upgrade(ErlNifEnv *_sth0, void **_sth1, void **_sth2, ERL_NIF_TERM _sth3) {
    return 0;
}

static ErlNifFunc nif_funcs[] = {
    {"i420_to_raw", 5, i420_to_raw, ERL_NIF_DIRTY_JOB_CPU_BOUND},
    {"raw_to_i420", 3, raw_to_i420, ERL_NIF_DIRTY_JOB_CPU_BOUND},
    {"scale_i420", 8, scale_i420, ERL_NIF_DIRTY_JOB_CPU_BOUND}
};

ERL_NIF_INIT(Elixir.ExYUV.NIF, nif_funcs, on_load, on_reload, on_upgrade, NULL);