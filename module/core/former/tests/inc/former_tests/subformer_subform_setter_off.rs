#![ allow( dead_code ) ]
// xxx : rename

use super::*;

/// Child
#[ derive( Debug, Default, PartialEq, the_module::Former ) ]
pub struct Child
{
  name : String,
  is_mandatory : bool,
}

/// Parent

#[ derive( Debug, Default, PartialEq, the_module::Former ) ]
// #[ debug ]
// #[ derive( Debug, Default, PartialEq ) ]
pub struct Parent
{
  #[ subform( setter = false ) ]
  // #[ scalar( setter = false ) ]
  // xxx : should be #[ scalar_setter = false ]
  children : Vec< Child >,
}

impl< Definition > ParentFormer< Definition >
where
  Definition : former::FormerDefinition< Storage = < Parent as former::EntityToStorage >::Storage >,
{

  #[ inline( always ) ]
  pub fn children( self ) -> &'static str
  {
    r#"
    Scalar setter `children` should not be generated by default if subform is used.
    It can only be generated if req
    "#
  }

  #[ inline( always ) ]
  pub fn children2( self, name : &str ) ->
  ChildAsSubformer< Self, impl ChildAsSubformerEnd< Self > >
  {
    self._children_add
    ::< ChildFormer< _ >, _, >()
    .name( name )
  }

}

include!( "./only_test/subformer_subform_children2.rs" );
