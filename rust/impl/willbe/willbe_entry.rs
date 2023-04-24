#![ cfg_attr( not( feature = "use_std" ), no_std ) ]
#![ doc( html_logo_url = "https://raw.githubusercontent.com/Wandalen/wTools/master/asset/img/logo_v3_trans_square.png" ) ]
#![ doc( html_favicon_url = "https://raw.githubusercontent.com/Wandalen/wTools/alpha/asset/img/logo_v3_trans_square_icon_small_v2.ico" ) ]
#![ doc( html_root_url = "https://docs.rs/wpublisher/" ) ]
#![ warn( rust_2018_idioms ) ]
#![ warn( missing_debug_implementations ) ]
#![ warn( missing_docs ) ]

//!
//! ___.
//!

#![ doc = include_str!( concat!( env!( "CARGO_MANIFEST_DIR" ), "/", "Readme.md" ) ) ]

#[ allow( unused_imports ) ]
use ::willbe::*;

//

#[ cfg( feature = "use_std" ) ]
fn main() -> wca::Result< () >
{
  let args = std::env::args().skip( 1 ).collect::< Vec< String > >();

  let ca = wca::CommandsAggregator::former()
  .grammar( commands::grammar_form() )
  .executor( commands::executor_form() )
  .build();

  ca.perform( if args.is_empty() { "".to_owned() } else { args.join( " " ) + " .end" } )
}

#[ cfg( not( feature = "use_std" ) ) ]
fn main() {}
