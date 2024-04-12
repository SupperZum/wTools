#[ allow( unused_imports ) ]
use super::*;

#[ derive( Debug, PartialEq, the_module::Former ) ]
pub struct StructWithCustomSetters
{
  ordinary : String,
  #[ setter( false ) ]
  magic : String,
}

// impl< Context, End > StructWithCustomSettersFormer< Context, End >
// where
//   End: the_module::FormingEnd< StructWithCustomSetters, Context >,
// {

impl< Definition > StructWithCustomSettersFormer< Definition >
where
  Definition : former::FormerDefinition,
  Definition::Types : former::FormerDefinitionTypes< Storage = StructWithCustomSettersFormerStorage >,
{

  /// Custom alternative setter of ordinary field.
  fn ordinary_exclamaited< IntoString >( mut self, val : IntoString ) -> Self
  where
    IntoString : Into< String >
  {
    debug_assert!( self.storage.ordinary.is_none() );
    self.storage.ordinary = Some( format!( "{}!", val.into() ) );
    self
  }

  /// Custom primary setter of field without autogenerated setter.
  fn magic< IntoString >( mut self, val : IntoString ) -> Self
  where
    IntoString : Into< String >
  {
    debug_assert!( self.storage.magic.is_none() );
    self.storage.magic = Some( format!( "Some magic : < {} >", val.into() ) );
    self
  }

}

#[ test ]
fn basic()
{

  // ordinary + magic
  let got = StructWithCustomSetters::former()
  .ordinary( "val1" )
  .magic( "val2" )
  .form()
  ;
  let exp = StructWithCustomSetters
  {
    ordinary : "val1".to_string(),
    magic : "Some magic : < val2 >".to_string(),
  };
  a_id!( got, exp );

  // alternative
  let got = StructWithCustomSetters::former()
  .ordinary_exclamaited( "val1" )
  .form()
  ;
  let exp = StructWithCustomSetters
  {
    ordinary : "val1!".to_string(),
    magic : "".to_string(),
  };
  a_id!( got, exp );

}
