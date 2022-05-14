#![ warn( rust_2018_idioms ) ]
#![ warn( missing_debug_implementations ) ]
#![ warn( missing_docs ) ]

//!
//! Several of macros to put each function under a named macro to index every function in a class.
//!

#![ doc = include_str!( concat!( env!( "CARGO_MANIFEST_DIR" ), "/Readme.md" ) ) ]

/// Collection of general purpose meta tools.
pub mod impls_index;

/// Dependencies.
pub mod dependencies
{
  // pub use ::literally;
  // pub use ::for_each;
}

/// Owned namespace of the module.
pub mod own
{
  pub use super::exposed::*;
  pub use super::impls_index::parented::*;
}

pub use own::*;

/// Exposed namespace of the module.
pub mod exposed
{
  pub use super::prelude::*;
  pub use super::impls_index::exposed::*;
}

/// Prelude to use: `use wtools::prelude::*`.
pub mod prelude
{
  pub use super::impls_index::prelude::*;
}
