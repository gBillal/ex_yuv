#include "libyuv/include/libyuv.h"
#include "erl_nif.h"

static ErlNifFunc nif_funcs[] = {
};

ERL_NIF_INIT(Elixir.ExYUV.NIF, nif_funcs, NULL, NULL, NULL, NULL);