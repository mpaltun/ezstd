extern crate lazy_static;
#[macro_use]
extern crate rustler;
extern crate zstd;

use rustler::{Binary, Encoder, Env, NifResult, OwnedBinary, Term};

mod atoms {
    rustler_atoms! {
        atom ok;
        atom error;
    }
}

rustler_export_nifs! {
    "ezstd",
    [
        ("compress", 2, compress),
        ("decompress", 1, decompress),
    ],
    None
}

fn compress<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let input: Binary = args[0].decode()?;
    let level: i32 = args[1].decode()?;

    if input.is_empty() {
        let empty_bin = OwnedBinary::new(0).unwrap();
        return Ok((atoms::ok(), empty_bin.release(env)).encode(env));
    }

    match zstd::block::compress(input.as_slice(), level) {
        Ok(compressed) => {
            let mut bin = OwnedBinary::new(compressed.len()).unwrap();
            bin.clone_from_slice(&compressed);

            Ok((atoms::ok(), bin.release(env)).encode(env))
        }
        Err(e) => {
            Ok((atoms::error(), e.to_string()).encode(env))
        }
    }
}

fn decompress<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let compressed: Binary = args[0].decode()?;

    if compressed.is_empty() {
        let empty_bin = OwnedBinary::new(0).unwrap();
        return Ok((atoms::ok(), empty_bin.release(env)).encode(env));
    }

    match zstd::stream::decode_all(compressed.as_slice()) {
        Ok(decompressed) => {
            let mut bin = OwnedBinary::new(decompressed.len()).unwrap();
            bin.clone_from_slice(&decompressed);

            Ok((atoms::ok(), bin.release(env)).encode(env))
        }
        Err(e) => {
            Ok((atoms::error(), e.to_string()).encode(env))
        }
    }
}
