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
  pub fn former() -> Struct1Former
  {
    Struct1Former::new()
  }
}

// = definition

#[ derive( Debug, Default ) ]
pub struct Struct1FormerDefinition;

// impl Struct1FormerDefinition
// {
//   pub fn new() -> Self
//   {
//     Self
//   }
// }

impl former::FormerDefinitionTypes
for Struct1FormerDefinition
{
  type Storage = Struct1FormerStorage;
  type Formed = Struct1;
  type Context = ();
}

impl former::FormerDefinition
for Struct1FormerDefinition
{
  type Types = Struct1FormerDefinition;
  type End = former::ReturnPreformed;
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
  // type Types = Struct1FormerDefinition;
  type Formed = Struct1;
}

impl former::StoragePerform
for Struct1FormerStorage
{

  fn preform( mut self ) -> < Self as former::Storage >::Formed
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
    // < < Self as former::Storage >::Definition as former::FormerDefinitionTypes >::Formed
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
  // FormerContext = Struct1,
  // FormerEnd = the_module::ReturnPreformed,
>
// where
  // FormerEnd : the_module::FormingEnd< Struct1FormerDefinition >,
{
  storage : Struct1FormerStorage,
  context : core::option::Option< < Struct1FormerDefinition as former::FormerDefinitionTypes >::Context >,
  on_end : core::option::Option< < Struct1FormerDefinition as former::FormerDefinition >::End >,
}

impl Struct1Former
// where
  // FormerEnd: the_module::FormingEnd< Struct1FormerDefinition, FormerContext >,
{

  fn preform( self ) -> < Struct1FormerDefinition as former::FormerDefinitionTypes >::Formed
  {
    former::StoragePerform::preform( self.storage )
  }

  #[ inline( always ) ]
  pub fn perform(self) -> < Struct1FormerDefinition as former::FormerDefinitionTypes >::Formed
  {
    let result = self.form();
    return result;
  }

  #[ inline( always ) ]
  pub fn begin
  (
    mut storage : core::option::Option< < Struct1FormerDefinition as former::FormerDefinitionTypes >::Storage >,
    context : core::option::Option< < Struct1FormerDefinition as former::FormerDefinitionTypes >::Context >,
    on_end : < Struct1FormerDefinition as former::FormerDefinition >::End,
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
      context,
      on_end : ::core::option::Option::Some( on_end ),
    }
  }

  #[ inline( always ) ]
  pub fn end( mut self ) -> < Struct1FormerDefinition as former::FormerDefinitionTypes >::Formed
  {
    let on_end = self.on_end.take().unwrap();
    let context = self.context.take();
    former::FormingEnd::< Struct1FormerDefinition >::call( &on_end, self.storage, context )
  }

  #[ inline( always ) ]
  pub fn form( self ) -> < Struct1FormerDefinition as former::FormerDefinitionTypes >::Formed
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

impl Struct1Former
{

  #[ inline( always ) ]
  pub fn new() -> Struct1Former
  {
    Struct1Former::begin( None, None, the_module::ReturnPreformed )
  }

}

//

include!( "./only_test/primitives.rs" );
