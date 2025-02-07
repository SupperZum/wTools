
#[ cfg( feature = "compiletime_assertions" ) ]
pub( crate ) mod private
{

  ///
  /// Compile-time assertion that two types have the same size.
  ///

  // #[ cfg( feature = "compiletime_assertions" ) ]
  #[ macro_export ]
  macro_rules! cta_type_same_size
  {
    ( $Type1:ty, $Type2:ty $(,)? ) =>
    {{
      const _ : fn() = ||
      {
        let _ : [ () ; core::mem::size_of::< $Type1 >() ] = [ () ; core::mem::size_of::< $Type2 >() ];
      };
      // let _ = core::mem::transmute::< $Type1, $Type2 >;
      true
    }}
  }

  ///
  /// Compile-time assertion of having the same align.
  ///

  // #[ cfg( feature = "compiletime_assertions" ) ]
  #[ macro_export ]
  macro_rules! cta_type_same_align
  {
    ( $Type1:ty, $Type2:ty $(,)? ) =>
    {{
      const _ : fn() = ||
      {
        let _ : [ () ; core::mem::align_of::< $Type1 >() ] = [ () ; core::mem::align_of::< $Type2 >() ];
      };
      true
    }};
  }

  ///
  /// Compile-time assertion that memory behind two references have the same size.
  ///

  // #[ cfg( feature = "compiletime_assertions" ) ]
  #[ macro_export ]
  macro_rules! cta_ptr_same_size
  {
    ( $Ins1:expr, $Ins2:expr $(,)? ) =>
    {{
      #[ allow( unsafe_code, unknown_lints, forget_copy, useless_transmute ) ]
      let _ = || unsafe
      {
        let mut ins1 = core::ptr::read( $Ins1 );
        core::ptr::write( &mut ins1, core::mem::transmute( core::ptr::read( $Ins2 ) ) );
        core::mem::forget( ins1 );
      };
      true
    }}
  }

  ///
  /// Compile-time assertion that two values have the same size.
  ///
  /// Does not consume values.
  ///

  // #[ cfg( feature = "compiletime_assertions" ) ]
  #[ macro_export ]
  macro_rules! cta_mem_same_size
  {
    ( $Ins1:expr, $Ins2:expr $(,)? ) =>
    {{
      $crate::cta_ptr_same_size!( &$Ins1, &$Ins2 )
    }}
  }

  pub use cta_type_same_size;
  pub use cta_type_same_align;

  pub use cta_ptr_same_size;
  pub use cta_mem_same_size;
}

/// Protected namespace of the module.
pub mod protected
{
  #[ doc( inline ) ]
  pub use super::orphan::*;
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
}

/// Prelude to use essentials: `use my_module::prelude::*`.
pub mod prelude
{
  #[ cfg( feature = "compiletime_assertions" ) ]
  #[ doc( inline ) ]
  pub use super::private::
  {
    cta_type_same_size,
    cta_type_same_align,
    cta_ptr_same_size,
    cta_mem_same_size,
  };
}
