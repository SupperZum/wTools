#![ cfg_attr( feature = "no_std", no_std ) ]
#![ doc( html_logo_url = "https://raw.githubusercontent.com/Wandalen/wTools/master/asset/img/logo_v3_trans_square.png" ) ]
#![ doc( html_favicon_url = "https://raw.githubusercontent.com/Wandalen/wTools/alpha/asset/img/logo_v3_trans_square_icon_small_v2.ico" ) ]
#![ doc( html_root_url = "https://docs.rs/diagnostics_tools/latest/diagnostics_tools/" ) ]
#![ warn( rust_2018_idioms ) ]
#![ deny( missing_debug_implementations ) ]
#![ deny( missing_docs ) ]

//!
//! Diagnostics tools.
//!

#![ doc = include_str!( concat!( env!( "CARGO_MANIFEST_DIR" ), "/", "Readme.md" ) ) ]

/// Compile-time asserting.
pub mod diagnostics;
/// Compile-time asserting of memory layout.
pub mod layout;

/// Dependencies.
#[ cfg( feature = "enabled" ) ]
pub mod dependency
{
  #[ cfg( feature = "runtime_assertions" ) ]
  pub use ::pretty_assertions;
}

/// Protected namespace of the module.
pub mod protected
{
  #[ doc( inline ) ]
  pub use super::orphan::*;
  #[ doc( inline ) ]
  pub use super::diagnostics::orphan::*;
  #[ doc( inline ) ]
  pub use super::layout::orphan::*;
}

#[ doc( inline ) ]
pub use protected::*;

/// Orphan namespace of the module.
pub mod orphan
{
  #[ doc( inline ) ]
  pub use super::exposed::*;
}

/// Exposed namespace of the module.
pub mod exposed
{
  #[ doc( inline ) ]
  pub use super::prelude::*;
  #[ doc( inline ) ]
  pub use super::diagnostics::exposed::*;
  #[ doc( inline ) ]
  pub use super::layout::exposed::*;
}

/// Prelude to use essentials: `use my_module::prelude::*`.
pub mod prelude
{
  #[ doc( inline ) ]
  pub use super::diagnostics::prelude::*;
  #[ doc( inline ) ]
  pub use super::layout::prelude::*;
}