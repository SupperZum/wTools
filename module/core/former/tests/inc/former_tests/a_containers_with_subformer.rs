#[ allow( unused_imports ) ]
use super::*;

// use std::collections::HashMap;
// use std::collections::HashSet;

// #[ derive( Debug, PartialEq, former::Former ) ]
// #[ debug ]
#[ derive( Debug, PartialEq ) ]
pub struct Struct1
{
  // #[ subformer( former::VectorSubformer ) ]
  vec_1 : Vec< String >,
  // #[ subformer( former::HashMapSubformer ) ]
  hashmap_1 : std::collections::HashMap< String, String >,
  // #[ subformer( former::HashSetSubformer ) ]
  hashset_1 : std::collections::HashSet< String >,
}

// = generated

#[ automatically_derived ]
impl Struct1
{
  #[ doc = r"" ]
  #[ doc = r" Make former, variation of builder pattern to form structure defining values of fields step by step." ]
  #[ doc = r"" ]
  #[ inline( always ) ]
  pub fn former() -> Struct1Former< >
  {
    Struct1Former::<>::new( former::ReturnPreformed )
  }
}

#[ derive( Debug ) ]
pub struct Struct1FormerDefinitionTypes< Context = (), Formed = Struct1 >
{
  _phantom : core::marker::PhantomData< ( Context, Formed ) >,
}

impl< Context, Formed > Default for Struct1FormerDefinitionTypes< Context, Formed >
{
  fn default() -> Self
  {
    Self
    {
      _phantom : core::marker::PhantomData,
    }
  }
}

#[ derive( Debug ) ]
pub struct Struct1FormerDefinition< Context = (), Formed = Struct1, End = former::ReturnPreformed >
{
  _phantom : core::marker::PhantomData< ( Context, Formed, End ) >,
}

impl< Context, Formed, End > Default for Struct1FormerDefinition< Context, Formed, End >
{
  fn default() -> Self
  {
    Self
    {
      _phantom : core::marker::PhantomData,
    }
  }
}

impl< Context, Formed > former::FormerDefinitionTypes for Struct1FormerDefinitionTypes< Context, Formed >
{
  type Storage = Struct1FormerStorage;
  type Formed = Formed;
  type Context = Context;
}

impl< Context, Formed, End > former::FormerDefinition for Struct1FormerDefinition< Context, Formed, End >
where
  End : former::FormingEnd< Struct1FormerDefinitionTypes< Context, Formed > >,
{
  type Types = Struct1FormerDefinitionTypes< Context, Formed >;
  type End = End;
}

pub type Struct1FormerWithClosure< Context, Formed > = Struct1FormerDefinition< Context, Formed, former::FormingEndClosure< Struct1FormerDefinitionTypes< Context, Formed > > >;

#[ doc = "Container of a corresponding former." ]
pub struct Struct1FormerStorage
{
  #[ doc = r" A field" ]
  pub vec_1 : ::core::option::Option< Vec< String > >,

  #[ doc = r" A field" ]
  pub hashmap_1 : ::core::option::Option< std::collections::HashMap< String, String > >,

  #[ doc = r" A field" ]
  pub hashset_1 : ::core::option::Option< std::collections::HashSet< String > >,
}

impl ::core::default::Default for Struct1FormerStorage
{
  #[ inline( always ) ]
  fn default() -> Self
  {
    Self
    {
      vec_1 : ::core::option::Option::None,
      hashmap_1 : ::core::option::Option::None,
      hashset_1 : ::core::option::Option::None,
    }
  }
}

impl former::Storage for Struct1FormerStorage
{
  type Formed = Struct1;
}

impl former::StoragePreform for Struct1FormerStorage
{
  fn preform( mut self ) -> < Self as former::Storage >::Formed
  {
    let vec_1 = if self.vec_1.is_some()
    {
      self.vec_1.take().unwrap()
    }
    else
    {
      {
        trait MaybeDefault< T >
        {
          fn maybe_default( self : &Self ) -> T
          {
            panic!( "Field 'vec_1' isn't initialized" )
          }
        }
        impl< T > MaybeDefault< T > for &::core::marker::PhantomData< T > {}
        impl< T > MaybeDefault< T > for ::core::marker::PhantomData< T >
        where T : ::core::default::Default,
        {
          fn maybe_default( self : &Self ) -> T
          {
            T::default()
          }
        }
        ( &::core::marker::PhantomData::< Vec< String > > ).maybe_default()
      }
    };
    let hashmap_1 = if self.hashmap_1.is_some()
    {
      self.hashmap_1.take().unwrap()
    }
    else
    {
      {
        trait MaybeDefault< T >
        {
          fn maybe_default( self : &Self ) -> T
          {
            panic!( "Field 'hashmap_1' isn't initialized" )
          }
        }
        impl< T > MaybeDefault< T > for &::core::marker::PhantomData< T > {}
        impl< T > MaybeDefault< T > for ::core::marker::PhantomData< T >
        where T : ::core::default::Default,
        {
          fn maybe_default( self : &Self ) -> T
          {
            T::default()
          }
        }
        ( &::core::marker::PhantomData::< std::collections::HashMap< String, String > > ).maybe_default()
      }
    };
    let hashset_1 = if self.hashset_1.is_some()
    {
      self.hashset_1.take().unwrap()
    }
    else
    {
      {
        trait MaybeDefault< T >
        {
          fn maybe_default( self : &Self ) -> T
          {
            panic!( "Field 'hashset_1' isn't initialized" )
          }
        }
        impl< T > MaybeDefault< T > for &::core::marker::PhantomData< T > {}
        impl< T > MaybeDefault< T > for ::core::marker::PhantomData< T >
        where T : ::core::default::Default,
        {
          fn maybe_default( self : &Self ) -> T
          {
            T::default()
          }
        }
        ( &::core::marker::PhantomData::< std::collections::HashSet< String > > ).maybe_default()
      }
    };
    let result = Struct1
    {
      vec_1,
      hashmap_1,
      hashset_1,
    };
    return result;
  }
}

#[ doc = " Object to form [Struct1]. If field's values is not set then default value of the field is set.\n\nFor specifying custom default value use attribute `default`. For example:\n```\n\nuse former::Former;\n#[ derive( Former ) ]\npub struct Struct1\n{\n  #[ default( 31 ) ]\n  field1 : i32,\n}\n\n```\n" ]
pub struct Struct1Former< Definition = Struct1FormerDefinition >
where
  Definition : former::FormerDefinition,
  Definition::Types : former::FormerDefinitionTypes< Storage = Struct1FormerStorage >,
  < Definition::Types as former::FormerDefinitionTypes >::Storage : former::StoragePreform,
{
  storage : < Definition::Types as former::FormerDefinitionTypes >::Storage,
  context : core::option::Option< < Definition::Types as former::FormerDefinitionTypes >::Context >,
  on_end : core::option::Option< Definition::End >,
}

#[ automatically_derived ]
impl< Definition > Struct1Former< Definition >
where
  Definition : former::FormerDefinition,
  Definition::Types : former::FormerDefinitionTypes< Storage = Struct1FormerStorage >,
  < Definition::Types as former::FormerDefinitionTypes >::Storage : former::StoragePreform,
{
  #[ doc = r"" ]
  #[ doc = r" Finish setting options and call perform on formed entity." ]
  #[ doc = r"" ]
  #[ doc = r" If `perform` defined then associated method is called and its result returned instead of entity." ]
  #[ doc = r" For example `perform()` of structure with : `#[ perform( fn after1() -> &str ) ]` returns `&str`." ]
  #[ doc = r"" ]
  #[ inline( always ) ]
  pub fn perform( self ) -> < Definition::Types as former::FormerDefinitionTypes >::Formed
  {
    let result = self.form();
    return result;
  }

  #[ doc = r"" ]
  #[ doc = r" Construct new instance of former with default parameters." ]
  #[ doc = r"" ]
  #[ inline( always ) ]
  pub fn _new_precise( on_end : Definition::End ) -> Self
  {
    Self::begin( None, None, on_end )
  }

  #[ doc = r"" ]
  #[ doc = r" Construct new instance of former with default parameters." ]
  #[ doc = r"" ]
  #[ inline( always ) ]
  pub fn new< IntoEnd >( end : IntoEnd ) -> Self
  where
    IntoEnd : Into< Definition::End >,
  {
    Self::begin( None, None, end, )
  }

  #[ doc = r"" ]
  #[ doc = r" Begin the process of forming. Expects context of forming to return it after forming." ]
  #[ doc = r"" ]
  #[ inline( always ) ]
  pub fn _begin_precise(
    mut storage : core::option::Option< < Definition::Types as former::FormerDefinitionTypes >::Storage >,
    context : core::option::Option< < Definition::Types as former::FormerDefinitionTypes >::Context >,
    on_end : < Definition as former::FormerDefinition >::End,
  ) -> Self
  {
    if storage.is_none()
    {
      storage = Some( ::core::default::Default::default() );
    }
    Self
    {
      storage : storage.unwrap(),
      context : context,
      on_end : ::core::option::Option::Some( on_end ),
    }
  }

  #[ doc = r"" ]
  #[ doc = r" Begin the process of forming. Expects context of forming to return it after forming." ]
  #[ doc = r"" ]
  #[ inline( always ) ]
  pub fn begin< IntoEnd >(
    mut storage : core::option::Option< < Definition::Types as former::FormerDefinitionTypes >::Storage >,
    context : core::option::Option< < Definition::Types as former::FormerDefinitionTypes >::Context >,
    on_end : IntoEnd,
  ) -> Self
  where
    IntoEnd : ::core::convert::Into< < Definition as former::FormerDefinition >::End >,
  {
    if storage.is_none()
    {
      storage = Some( ::core::default::Default::default() );
    }
    Self
    {
      storage : storage.unwrap(),
      context : context,
      on_end : ::core::option::Option::Some( ::core::convert::Into::into( on_end ) ),
    }
  }

  #[ doc = r"" ]
  #[ doc = r" End the process of forming returning original context of forming." ]
  #[ doc = r"" ]
  #[ inline( always ) ]
  pub fn form( self ) -> < Definition::Types as former::FormerDefinitionTypes >::Formed
  {
    self.end()
  }

  #[ doc = r"" ]
  #[ doc = r" End the process of forming returning original context of forming." ]
  #[ doc = r"" ]
  #[ inline( always ) ]
  pub fn end( mut self ) -> < Definition::Types as former::FormerDefinitionTypes >::Formed
  {
    let on_end = self.on_end.take().unwrap();
    let context = self.context.take();
    former::FormingEnd::< Definition::Types >::call( &on_end, self.storage, context )
  }

  // #[ doc = "Subformer setter for the 'vec_1' field." ]
  // #[ inline ]
  // pub fn vec_1( mut self ) -> former::VectorSubformer< String, Vec< String >, Self, impl Fn( Vec< String >, core::option::Option< Self > ) -> Self, >
  // {
  //   let formed = self.storage.vec_1.take();
  //   let on_end = | formed : Vec< String >, former : core::option::Option< Self > | -> Self
  //   {
  //     let mut former = former.unwrap();
  //     former.storage.vec_1 = Some( formed );
  //     former
  //   };
  //   former::VectorSubformer::begin( formed, Some( self ), on_end )
  // }

  #[ inline( always ) ]
  pub fn vec_1_set< Former2 >( self ) -> Former2
  where
    Former2 : former::FormerBegin
    <
      former::VectorDefinition
      <
        String,
        Self,
        Self,
        Struct1FormerVec_1End,
      >
    >,
  {
    Former2::_begin( None, Some( self ), Struct1FormerVec_1End )
  }

  pub fn vec_1( self ) ->
  former::ContainerSubformer::
  <
    String, former::VectorDefinition< String, Self, Self, Struct1FormerVec_1End >
  >
  {
    self.vec_1_set::< former::ContainerSubformer::
    <
      String, former::VectorDefinition< String, Self, Self, Struct1FormerVec_1End >
    >>()
  }

//   #[ doc = "Subformer setter for the 'hashmap_1' field." ]
//   #[ inline ]
//   pub fn hashmap_1( mut self ) -> former::HashMapSubformer< String, String, std::collections::HashMap< String, String >, Self, impl Fn( std::collections::HashMap< String, String >, core::option::Option< Self > ) -> Self, >
//   {
//     let formed = self.storage.hashmap_1.take();
//     let on_end = | formed : std::collections::HashMap< String, String >, former : core::option::Option< Self > | -> Self
//     {
//       let mut former = former.unwrap();
//       former.storage.hashmap_1 = Some( formed );
//       former
//     };
//     former::HashMapSubformer::begin( formed, Some( self ), on_end )
//   }
//
//   #[ doc = "Subformer setter for the 'hashset_1' field." ]
//   #[ inline ]
//   pub fn hashset_1( mut self ) -> former::HashSetSubformer< String, std::collections::HashSet< String >, Self, impl Fn( std::collections::HashSet< String >, core::option::Option< Self > ) -> Self, >
//   {
//     let formed = self.storage.hashset_1.take();
//     let on_end = | formed : std::collections::HashSet< String >, former : core::option::Option< Self > | -> Self
//     {
//       let mut former = former.unwrap();
//       former.storage.hashset_1 = Some( formed );
//       former
//     };
//     former::HashSetSubformer::begin( formed, Some( self ), on_end )
//   }

}

impl< Definition > Struct1Former< Definition >
where
  Definition : former::FormerDefinition,
  Definition::Types : former::FormerDefinitionTypes< Storage = Struct1FormerStorage, Formed = Struct1 >,
  < Definition::Types as former::FormerDefinitionTypes >::Storage : former::StoragePreform,
{
  pub fn preform( self ) -> < Definition::Types as former::FormerDefinitionTypes >::Formed
  {
    former::StoragePreform::preform( self.storage )
  }
}

// zzz : description
/// Return original former after subformer for `vec_1` is done.
#[ allow( non_camel_case_types ) ]
pub struct Struct1FormerVec_1End;
#[ automatically_derived ]
impl< Definition > former::FormingEnd
<
  former::VectorDefinition< String, Struct1Former< Definition >, Struct1Former< Definition >, former::NoEnd >,
>
for Struct1FormerVec_1End
where
  Definition : former::FormerDefinition,
  Definition::Types : former::FormerDefinitionTypes
  <
    Storage = Struct1FormerStorage
  >,
{
  #[ inline( always ) ]
  fn call( &self, storage : Vec< String >, super_former : Option< Struct1Former< Definition > > ) -> Struct1Former< Definition >
  {
    let mut super_former = super_former.unwrap();
    if let Some( ref mut field ) = super_former.storage.vec_1
    {
      former::ContainerAssign::assign( field, storage );
    }
    else
    {
      super_former.storage.vec_1 = Some( storage );
    }
    super_former
  }
}

// = generated

// include!( "./only_test/containers_with_subformer.rs" );
// xxx : uncomment
