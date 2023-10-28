
#![ cfg_attr( feature = "no_std", no_std ) ]
#![ doc( html_logo_url = "https://raw.githubusercontent.com/Wandalen/wTools/master/asset/img/logo_v3_trans_square.png" ) ]
#![ doc( html_favicon_url = "https://raw.githubusercontent.com/Wandalen/wTools/alpha/asset/img/logo_v3_trans_square_icon_small_v2.ico")]
#![ doc( html_root_url = "https://docs.rs/type_constructor/latest/type_constructor/")]
#![ warn( rust_2018_idioms ) ]
#![ deny( missing_debug_implementations ) ]
#![ deny( missing_docs ) ]

//!
//! Fundamental data types and type constructors, like Single, Pair, Many.
//!

#![ doc = include_str!( concat!( env!( "CARGO_MANIFEST_DIR" ), "/", "Readme.md" ) ) ]

// #![ without_std ]

// #[ cfg( feature = "no_std" ) ]
// extern crate core as std;
// #[ cfg( all( feature = "no_std", feature = "use_alloc" ) ) ]
// extern crate alloc;

#[ path = "./inc.rs" ]
mod inc;
#[ doc( inline ) ]
#[ allow( unused_imports ) ]
pub use inc::*;
