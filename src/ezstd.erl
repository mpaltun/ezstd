-module(ezstd).

-export([
  compress/1,
  compress/2,
  decompress/1
]).

-on_load(init/0).

-spec compress(binary()) -> {ok, binary()} | {error, term()}.
compress(Binary) ->
  compress(Binary, 0).

-spec compress(binary(), integer()) -> {ok, binary()} | {error, term()}.
compress(_Binary, _Level) ->
  not_loaded(?LINE).

-spec decompress(binary()) -> {ok, binary()} | {error, term()}.
decompress(_Binary) ->
  not_loaded(?LINE).

init() ->
  PrivDir = case code:priv_dir(?MODULE) of
    {error, _} ->
      EbinDir = filename:dirname(code:which(?MODULE)),
      AppPath = filename:dirname(EbinDir),
      filename:join(AppPath, "priv");
    Path ->
      Path
  end,
  erlang:load_nif(filename:join(PrivDir, ezstd), 0).

not_loaded(Line) ->
  erlang:nif_error({error, {not_loaded, [{module, ?MODULE}, {line, Line}]}}).