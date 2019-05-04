-module(zstd_tests).

-include_lib("eunit/include/eunit.hrl").

test_data() ->
  <<"Zstandard is a real-time compression algorithm, providing high compression ratios.
  It offers a very wide range of compression / speed trade-off, while being backed by a very fast decoder.
  It also offers a special mode for small data, called dictionary compression, and can create dictionaries from any sample set.
  Zstandard library is provided as open source software using a BSD license.">>.

compression_test() ->
  Data = test_data(),

  {ok, Compressed} = ezstd:compress(Data),
  ?assertEqual(true, byte_size(Compressed) < byte_size(Data)),

  {ok, BetterCompressed} = ezstd:compress(Data, 20),
  ?assertEqual(true, byte_size(BetterCompressed) < byte_size(Compressed)).

iolist_compression_test() ->
  Data = lists:duplicate(5, test_data()),

  {ok, IoListCompressed} = ezstd:compress(Data),
  {ok, Compressed} = ezstd:compress(iolist_to_binary(Data)),

  ?assertEqual(IoListCompressed, Compressed).


decompression_test() ->
  Data = test_data(),
  {ok, Compressed} = ezstd:compress(Data),

  ?assertEqual({ok, Data}, ezstd:decompress(Compressed)).

iolist_decompression_test() ->
  Data = lists:duplicate(5, test_data()),

  {ok, <<First:16/binary, Rest/binary>>} = ezstd:compress(Data),
  {ok, Decompressed} = ezstd:decompress([First, Rest]),

  ?assertEqual(iolist_to_binary(Data), Decompressed).

compress_empty_binary_test() ->
  ?assertMatch({ok, <<>>}, ezstd:compress(<<>>)).

decompress_empty_binary_test() ->
  ?assertMatch({ok, <<>>}, ezstd:decompress(<<>>)).