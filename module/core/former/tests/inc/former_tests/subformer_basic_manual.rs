#![ allow( dead_code ) ]
use super::*;

// let ca = Aggregator::former()
// .parameter1( "val" )
// .command( "echo" )
//   .name( "prints all subjects and properties" )
//   .subject( "Subject", wca::Type::String, true )
//   .property( "property", "simple property", wca::Type::String, true )
//   .routine( f1 )
//   .end()
// .command( "exit" )
//   .name( "just exit" )
//   .routine( || exit() )
//   .end()
// .perform()
// ;
// ca.execute( input ).unwrap();

#[ derive( Debug, PartialEq, Default ) ]
pub struct Property< Name >
{
  name : Name,
  description : String,
  code : isize,
}

/// generated by new
impl< Name > Property< Name >
{
  #[ inline ]
  pub fn new< Description, Code >( name : Name, description : Description, code : Code ) -> Self
  where
    Name : core::convert::Into< Name >,
    Description : core::convert::Into< String >,
    Code : core::convert::Into< isize >,
  {
    Self { name : name.into(), description : description.into(), code : code.into() }
  }
}

#[ derive( Debug, PartialEq ) ]
pub struct Command< K >
where
  K : core::hash::Hash + std::cmp::Eq,
{
  pub name : String,
  pub subject : String,
  pub properties : collection_tools::HashMap< K, Property< K > >,
}

// generated by former
impl< K > Command< K >
where
  K : core::hash::Hash + std::cmp::Eq,
{

  #[ inline( always ) ]
  pub fn former() -> CommandFormer< K >
  {
    CommandFormer::< K >::new()
  }

}

// generated by former
pub struct CommandFormerStorage< K >
where
  K : core::hash::Hash + std::cmp::Eq,
{
  name : core::option::Option< String >,
  subject : core::option::Option< String >,
  properties : core::option::Option< collection_tools::HashMap< K, Property< K > > >,
}

impl< K > Default for CommandFormerStorage< K >
where
  K : core::hash::Hash + std::cmp::Eq,
{

  #[ inline( always ) ]
  fn default() -> Self
  {
    Self
    {
      name : None,
      subject : None,
      properties : None,
    }
  }

}

// generated by former
// #[ derive( Debug, Default ) ]
pub struct CommandFormer< K, Context = Command< K >, End = the_module::ReturnFormed >
where
  K : core::hash::Hash + std::cmp::Eq,
  End : the_module::FormingEnd< Command< K >, Context >,
{
  storage : CommandFormerStorage< K >,
  context : core::option::Option< Context >,
  on_end : core::option::Option< End >,
}

// generated by former
impl< K, Context, End >
CommandFormer< K, Context, End >
where
  K : core::hash::Hash + std::cmp::Eq,
  End : the_module::FormingEnd< Command< K >, Context >,
{

  #[ inline( always ) ]
  fn form( mut self ) -> Command< K >
  {

    let name = if self.storage.name.is_some()
    {
      self.storage.name.take().unwrap()
    }
    else
    {
      let val = Default::default();
      val
    };

    let subject = if self.storage.subject.is_some()
    {
      self.storage.subject.take().unwrap()
    }
    else
    {
      let val = Default::default();
      val
    };

    let properties = if self.storage.properties.is_some()
    {
      self.storage.properties.take().unwrap()
    }
    else
    {
      let val = Default::default();
      val
    };

    Command
    {
      name,
      subject,
      properties,
    }
  }

  #[ inline( always ) ]
  pub fn perform( self ) -> Command< K >
  {
    self.form()
  }

  #[ inline( always ) ]
  pub fn new() -> CommandFormer< K >
  {
    CommandFormer::< K >::begin
    (
      None,
      None,
      the_module::ReturnFormed,
    )
  }

  #[ inline( always ) ]
  pub fn begin
  (
    storage : core::option::Option< CommandFormerStorage< K > >,
    context : core::option::Option< Context >,
    on_end : End,
  ) -> Self
  {
    // qqq : fix
    debug_assert!( storage.is_none() );
    Self
    {
      storage : Default::default(),
      context : context,
      on_end : Some( on_end ),
    }
  }

  /// Return former of your struct moving container there. Should be called after configuring the container.
  #[ inline( always ) ]
  pub fn end( mut self ) -> Context
  {
    let on_end = self.on_end.take().unwrap();
    let context = self.context.take();
    let formed = self.form();
    on_end.call( formed, context )
  }

  #[ inline( always ) ]
  pub fn name< Src >( mut self, src : Src ) -> Self
  where Src : core::convert::Into< String >,
  {
    debug_assert!( self.storage.name.is_none() );
    self.storage.name = Some( src.into() );
    self
  }

  #[ inline( always ) ]
  pub fn subject< Src >( mut self, src : Src ) -> Self
  where Src : core::convert::Into< String >,
  {
    debug_assert!( self.storage.subject.is_none() );
    self.storage.subject = Some( src.into() );
    self
  }

  #[ inline( always ) ]
  pub fn properties( mut self ) -> the_module::HashMapSubformer
  <
    K,
    Property< K >,
    collection_tools::HashMap< K, Property< K > >,
    CommandFormer< K, Context, End >,
    impl the_module::FormingEnd< collection_tools::HashMap< K, Property< K > >, Self >,
  >
  {
    let formed = self.storage.properties.take();
    let on_end = | formed : collection_tools::HashMap< K, Property< K > >, super_former : core::option::Option< Self > | -> Self
    {
      let mut super_former = super_former.unwrap();
      super_former.storage.properties = Some( formed );
      super_former
    };
    the_module::HashMapSubformer::begin( formed, Some( self ), on_end )
  }

}

// manual
impl< K, Context, End >
CommandFormer< K, Context, End >
where
  K : core::hash::Hash + std::cmp::Eq,
  End : the_module::FormingEnd< Command< K >, Context >,
{

  /// Inserts a key-value pair into the map. Make a new container if it was not made so far.
  #[ inline( always ) ]
  pub fn property< Name, Description, Code >
  ( mut self, name : Name, description : Description, code : Code ) -> Self
  where
    Name : core::convert::Into< K > + Clone,
    Description : core::convert::Into< String >,
    Code : core::convert::Into< isize >,
  {
    if self.storage.properties.is_none()
    {
      self.storage.properties = core::option::Option::Some( Default::default() );
    }
    if let core::option::Option::Some( ref mut properties ) = self.storage.properties
    {
      let property = Property
      {
        name : name.clone().into(),
        description : description.into(),
        code : code.into(),
      };
      properties.insert( name.into(), property );
    }
    self
  }

}

// == aggregator

#[ derive( Debug, PartialEq ) ]
pub struct Aggregator< K >
where
  K : core::hash::Hash + std::cmp::Eq,
{
  pub parameter1 : String,
  pub commands : collection_tools::HashMap< String, Command< K > >,
}

// generated by former
impl< K > Aggregator< K >
where
  K : core::hash::Hash + std::cmp::Eq,
{

  #[ inline( always ) ]
  pub fn former() -> AggregatorFormer< K >
  {
    AggregatorFormer::< K >::new()
  }

}

// generated by former
// #[ derive( Debug, Default ) ]
pub struct AggregatorFormer< K, Context = Aggregator< K >, End = the_module::ReturnFormed >
where
  K : core::hash::Hash + std::cmp::Eq,
  End : the_module::FormingEnd< Aggregator< K >, Context >,
{
  parameter1 : core::option::Option< String >,
  commands : core::option::Option< collection_tools::HashMap< String, Command< K > > >,
  context : core::option::Option< Context >,
  on_end : core::option::Option< End >,
}

// generated by former
impl< K, Context, End >
AggregatorFormer< K, Context, End >
where
  K : core::hash::Hash + std::cmp::Eq,
  End : the_module::FormingEnd< Aggregator< K >, Context >,
{

  #[ inline( always ) ]
  fn form( mut self ) -> Aggregator< K >
  {

    let parameter1 = if self.parameter1.is_some()
    {
      self.parameter1.take().unwrap()
    }
    else
    {
      let val = Default::default();
      val
    };

    let commands = if self.commands.is_some()
    {
      self.commands.take().unwrap()
    }
    else
    {
      let val = Default::default();
      val
    };

    Aggregator
    {
      parameter1,
      commands,
    }
  }

  #[ inline( always ) ]
  pub fn perform( self ) -> Aggregator< K >
  {
    self.form()
  }

  #[ inline( always ) ]
  pub fn new() -> AggregatorFormer< K >
  {
    AggregatorFormer::< K >::begin
    (
      None,
      the_module::ReturnFormed,
    )
  }

  #[ inline( always ) ]
  pub fn begin
  (
    context :  core::option::Option< Context >,
    on_end : End,
  ) -> Self
  {
    Self
    {
      parameter1 : None,
      commands : None,
      context : context,
      on_end : Some( on_end ),
    }
  }

  /// Return former of your struct moving container there. Should be called after configuring the container.
  #[ inline( always ) ]
  pub fn end( mut self ) -> Context
  {
    let on_end = self.on_end.take().unwrap();
    let context = self.context.take();
    let formed = self.form();
    on_end.call( formed, context )
  }

  #[ inline( always ) ]
  pub fn parameter1< Src >( mut self, src : Src ) -> Self
  where Src : core::convert::Into< String >,
  {
    debug_assert!( self.parameter1.is_none() );
    self.parameter1 = Some( src.into() );
    self
  }

  #[ inline( always ) ]
  pub fn commands( mut self ) -> the_module::HashMapSubformer
  <
    String,
    Command< K >,
    collection_tools::HashMap< String, Command< K > >,
    AggregatorFormer< K, Context, End >,
    impl the_module::FormingEnd< collection_tools::HashMap< String, Command< K > >, Self >,
  >
  {
    let formed = self.commands.take();
    let on_end = | formed : collection_tools::HashMap< String, Command< K > >, super_former : core::option::Option< Self > | -> Self
    {
      let mut super_former = super_former.unwrap();
      super_former.commands = Some( formed );
      super_former
    };
    the_module::HashMapSubformer::begin(  formed, Some( self ), on_end )
  }

}

// manual
impl< K, Context, End >
AggregatorFormer< K, Context, End >
where
  K : core::hash::Hash + std::cmp::Eq,
  End : the_module::FormingEnd< Aggregator< K >, Context >,
{

  #[ inline( always ) ]
  pub fn command< IntoName >( self, name : IntoName )
  -> CommandFormer< K, Self, impl the_module::FormingEnd< Command< K >, Self > >
  where
    K : core::hash::Hash + std::cmp::Eq,
    IntoName : core::convert::Into< String >,
  {
    let on_end = | command : Command< K >, super_former : core::option::Option< Self > | -> Self
    {
      let mut super_former = super_former.unwrap();
      if let Some( ref mut commands ) = super_former.commands
      {
        commands.insert( command.name.clone(), command );
      }
      else
      {
        let mut commands : collection_tools::HashMap< String, Command< K > > = Default::default();
        commands.insert( command.name.clone(), command );
        super_former.commands = Some( commands );
      }
      super_former
    };
    let former = CommandFormer::begin( None, Some( self ), on_end );
    former.name( name )
  }

}

// ==

include!( "../only_test/subformer_basic.rs" );
