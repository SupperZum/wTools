#[ allow( unused_imports ) ]
use super::*;

#[ derive( Debug, PartialEq ) ]
pub struct Struct1
{
  pub int_1 : i32,
  string_1 : String,
  int_optional_1 : core::option::Option< i32 >,
  string_optional_1 : Option< String >,
}

// = formed

// generated by former
impl Struct1
{
  pub fn former() -> Struct1Former< (), former::ReturnFormed >
  {
    Struct1Former::new()
  }
}

// = descriptor

#[ derive( Debug ) ]
pub struct Struct1FormerDefinition;

impl Struct1FormerDefinition
{
  pub fn new() -> Self
  {
    Self
  }
}

impl former::FormerDefinition
for Struct1FormerDefinition
{
  type Storage = Struct1FormerStorage;
  type Formed = Struct1;
}

// = storage

// generated by former
pub struct Struct1FormerStorage
{
  pub int_1 : core::option::Option< i32 >,
  pub string_1 : core::option::Option< String >,
  pub int_optional_1 :  core::option::Option< i32 >,
  pub string_optional_1 : core::option::Option< String >,
}

impl Default for Struct1FormerStorage
{

  #[ inline( always ) ]
  fn default() -> Self
  {
    Self
    {
      int_1 : core::option::Option::None,
      string_1 : core::option::Option::None,
      int_optional_1 : core::option::Option::None,
      string_optional_1 : core::option::Option::None,
    }
  }

}

impl former::Storage
for Struct1FormerStorage
{
  type Definition = Struct1FormerDefinition;
}

impl former::StoragePerform
for Struct1FormerStorage
{

  fn preform( mut self ) -> < < Self as former::Storage >::Definition as former::FormerDefinition >::Formed
  {

    let int_1 = if self.int_1.is_some()
    {
      self.int_1.take().unwrap()
    }
    else
    {
      let val : i32 = Default::default();
      val
    };

    let string_1 = if self.string_1.is_some()
    {
      self.string_1.take().unwrap()
    }
    else
    {
      let val : String = Default::default();
      val
    };

    let int_optional_1 = if self.int_optional_1.is_some()
    {
      Some( self.int_optional_1.take().unwrap() )
    }
    else
    {
      None
    };

    let string_optional_1 = if self.string_optional_1.is_some()
    {
      Some( self.string_optional_1.take().unwrap() )
    }
    else
    {
      None
    };

    // Rust failt to use parameter here
    // < < Self as former::Storage >::Definition as former::FormerDefinition >::Formed
    Struct1
    {
      int_1,
      string_1,
      int_optional_1,
      string_optional_1,
    }

  }

}

// = former

pub struct Struct1Former
<
  FormerContext = Struct1,
  FormerEnd = the_module::ReturnFormed,
>
where
  FormerEnd : the_module::FormingEnd< Struct1FormerDefinition, FormerContext >,
{
  storage : Struct1FormerStorage,
  context : core::option::Option< FormerContext >,
  on_end : core::option::Option< FormerEnd >,
}

impl< FormerContext, FormerEnd > Struct1Former< FormerContext, FormerEnd >
where
  FormerEnd: the_module::FormingEnd< Struct1FormerDefinition, FormerContext >,
{

  fn preform( self ) -> < Struct1FormerDefinition as former::FormerDefinition >::Formed
  {
    former::StoragePerform::preform( self.storage )
  }

  #[ inline( always ) ]
  pub fn perform(self) -> < Struct1FormerDefinition as former::FormerDefinition >::Formed
  {
    let result = self.form();
    return result;
  }

  #[ inline( always ) ]
  pub fn begin
  (
    mut storage : core::option::Option< < Struct1FormerDefinition as former::FormerDefinition >::Storage >,
    context : core::option::Option< FormerContext >,
    on_end : FormerEnd,
    // xxx : cover by test existance of these 3 parameters in the function
  ) -> Self
  {
    if storage.is_none()
    {
      storage = Some( core::default::Default::default() );
    }
    Self
    {
      storage : storage.unwrap(),
      context : context,
      on_end : ::core::option::Option::Some( on_end ),
    }
  }

  #[ inline( always ) ]
  pub fn end( mut self ) -> < Struct1FormerDefinition as former::FormerDefinition >::Formed
  {
    let on_end = self.on_end.take().unwrap();
    let context = self.context.take();
    on_end.call( self.storage, context )
  }

  #[ inline( always ) ]
  pub fn form( self ) -> < Struct1FormerDefinition as former::FormerDefinition >::Formed
  {
    self.end()
  }

  pub fn int_1< Src >( mut self, src : Src ) -> Self
  where Src : core::convert::Into< i32 >,
  {
    debug_assert!( self.storage.int_1.is_none() );
    self.storage.int_1 = Some( src.into() );
    self
  }

  pub fn string_1< Src >( mut self, src : Src ) -> Self
  where Src : core::convert::Into< String >,
  {
    debug_assert!( self.storage.string_1.is_none() );
    self.storage.string_1 = Some( src.into() );
    self
  }

  pub fn string_optional_1< Src >( mut self, src : Src ) -> Self
  where Src : core::convert::Into< String >
  {
    debug_assert!( self.storage.string_optional_1.is_none() );
    self.storage.string_optional_1 = Some( src.into() );
    self
  }

}

impl Struct1Former< (), the_module::ReturnFormed >
{

  #[ inline( always ) ]
  pub fn new() -> Struct1Former< (), the_module::ReturnFormed >
  {
    Struct1Former::< (), the_module::ReturnFormed >::begin( None, None, the_module::ReturnFormed )
  }

}

//

include!( "./only_test/primitives.rs" );
