# ezstd [![Build Status](https://travis-ci.com/mpaltun/ezstd.svg?branch=master)](https://travis-ci.com/mpaltun/ezstd)

Erlang bindings to the Zstandard compression library, based on [zstd rust binding](https://github.com/Gyscos/zstd-rs)

## Usage
```erlang
{ok, Compressed} = ezstd:compress(<<"Hello there!">>),
{ok, <<"Hello there!">>} = ezstd:decompress(Compressed).
```