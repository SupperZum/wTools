/// Internal namespace.
pub( crate ) mod private
{

  ///
  /// Implementation of trait From to vectorize into/from.
  ///
  /// Standard `From` unfortunately is not autoimplemented for tuples and arrays and cant be implemented for them because of orphans restrictions.
  /// That how pair of traits `VectorizedFrom`/`VectorizedInto` could be useful. They are implemented for tuples and arrays.
  /// Their implementation is based on standard `From`, if `From` is implemented for elements of a tuple then `VectorizedFrom`/`VectorizedInto` implemented for collection containing them.
  ///
  /// ### Sample
  /// ```rust
  /// use type_constructor::prelude::*;
  /// types!( single Single1 : i32 );
  /// let src = ( 1, 3 );
  /// let got = <( Single1, Single1 )>::vectorized_from( src );
  /// ```
  ///

  pub trait VectorizedFrom< T > : Sized
  {
    /// Performs the conversion.
    fn vectorized_from( src : T ) -> Self;
  }

  ///
  /// Implementation of trait Into to vectorize into/from.
  ///
  /// Standard `From` unfortunately is not autoimplemented for tuples and arrays and cant be implemented for them because of orphans restrictions.
  /// That how pair of traits `VectorizedFrom`/`VectorizedInto` could be useful. They are implemented for tuples and arrays.
  /// Their implementation is based on standard `From`, if `From` is implemented for elements of a tuple then `VectorizedFrom`/`VectorizedInto` implemented for collection containing them.
  ///
  /// ### Sample
  /// ```rust
  /// use type_constructor::prelude::*;
  /// types!( single Single1 : i32 );
  /// let src = ( 1, 3 );
  /// let got : ( Single1, Single1 ) = src.vectorized_into();
  /// ```
  ///

  pub trait VectorizedInto< T > : Sized
  {
    /// Performs the conversion.
    fn vectorized_into( self ) -> T;
  }

  //

  impl< Target, Original > VectorizedInto< Target > for Original
  where
    Target : VectorizedFrom< Original >,
  {
    fn vectorized_into( self ) -> Target
    {
      Target::vectorized_from( self )
    }
  }

  //

  impl<>
  VectorizedFrom< () >
  for ()
  {
    fn vectorized_from( _ : () ) -> Self
    {
    }
  }

  //

  impl< Into1, Id1 >
  VectorizedFrom< ( Into1, ) >
  for ( Id1, )
  where
    Into1 : Into< Id1 >,
  {
    fn vectorized_from( src : ( Into1, ) ) -> Self
    {
      ( src.0.into(), )
    }
  }

  //

  impl< Into1, Into2, Id1, Id2 >
  VectorizedFrom< ( Into1, Into2 ) >
  for ( Id1, Id2 )
  where
    Into1 : Into< Id1 >,
    Into2 : Into< Id2 >,
  {
    fn vectorized_from( src : ( Into1, Into2 ) ) -> Self
    {
      ( src.0.into(), src.1.into() )
    }
  }

  //

  impl< Into1, Into2, Into3, Id1, Id2, Id3 >
  VectorizedFrom< ( Into1, Into2, Into3 ) >
  for ( Id1, Id2, Id3 )
  where
    Into1 : Into< Id1 >,
    Into2 : Into< Id2 >,
    Into3 : Into< Id3 >,
  {
    fn vectorized_from( src : ( Into1, Into2, Into3 ) ) -> Self
    {
      ( src.0.into(), src.1.into(), src.2.into() )
    }
  }

  //

  impl< Id, Into1, const N : usize >
  VectorizedFrom< [ Into1 ; N ] >
  for [ Id ; N ]
  where
    Into1 : Into< Id > + Clone,
  {
    fn vectorized_from( src : [ Into1 ; N ] ) -> Self
    {
      // SAFETY : safe because all elements are set in the funtions
      #[ allow( clippy::uninit_assumed_init ) ]
      let mut result : Self = unsafe { core::mem::MaybeUninit::uninit().assume_init() };
      for i in 0..N
      {
        result[ i ] = src[ i ].clone().into();
      }
      result
    }
  }

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

#[ doc( inline ) ]
pub use exposed::*;

/// Prelude to use essentials: `use my_module::prelude::*`.
pub mod prelude
{
  #[ doc( inline ) ]
  pub use super::private::
  {
    VectorizedFrom,
    VectorizedInto,
  };
}
