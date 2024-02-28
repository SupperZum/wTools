// xxx : finish
use super::*;
use former::runtime::{ OnEnd, NoEnd };

// let ca = wca::CommandsAggregator::former()
// .parameter1( "val" )
// .parameter2( "val2" )
// .command( "echo" )
//   .hint( "prints all subjects and properties" )
//   .subject( "Subject", wca::Type::String, true )
//   .property( "property", "simple property", wca::Type::String, true )
//   .routine( f1 )
//   .end()
// .command( "exit" )
//   .hint( "just exit" )
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
    Name : core::convert::Into< Name > + Clone,
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
  pub hint : String,
  pub subject : String,
  pub properties : std::collections::HashMap< K, Property< K > >,
}

// generated by former
impl< K > Command< K >
where
  K : core::hash::Hash + std::cmp::Eq,
{

  #[ inline( always ) ]
  pub fn former() -> CommandFormer< K, (), impl OnEnd< Command< K >, () > >
  {
    CommandFormer::< K, (), NoEnd >::begin
    (
      None,
      NoEnd,
    )
  }

  #[ inline( always ) ]
  pub fn perform( self ) -> Self
  {
    self
  }

}

// generated by former
// #[ derive( Debug, Default ) ]
pub struct CommandFormer< K, Context = (), P = NoEnd >
where
  K : core::hash::Hash + std::cmp::Eq,
  P : OnEnd< Command< K >, Context >,
{
  hint : core::option::Option< String >,
  subject : core::option::Option< String >,
  properties : core::option::Option< std::collections::HashMap< K, Property< K > > >,
  context : core::option::Option< Context >,
  on_end : core::option::Option< P >,
}

// generated by former
impl< K, Context, P >
CommandFormer< K, Context, P >
where
  K : core::hash::Hash + std::cmp::Eq,
  P : OnEnd< Command< K >, Context >,
{

  #[ inline( always ) ]
  fn form( mut self ) -> Command< K >
  {

    let hint = if self.hint.is_some()
    {
      self.hint.take().unwrap()
    }
    else
    {
      let val = Default::default();
      val
    };

    let subject = if self.subject.is_some()
    {
      self.subject.take().unwrap()
    }
    else
    {
      let val = Default::default();
      val
    };

    let properties = if self.properties.is_some()
    {
      self.properties.take().unwrap()
    }
    else
    {
      let val = Default::default();
      val
    };

    Command
    {
      hint,
      subject,
      properties,
    }.perform()
  }

  #[ inline( always ) ]
  pub fn begin
  (
    context :  core::option::Option< Context >,
    on_end : P,
  ) -> Self
  {

    Self
    {
      hint : None,
      subject : None,
      properties : None,
      context : context,
      on_end : Some( on_end ),
    }
  }

  /// Return former of your struct moving container there. Should be called after configuring the container.
  #[ inline( always ) ]
  pub fn end( mut self ) -> Context
  {
    let on_end = self.on_end.take().unwrap();
    let context = self.context.take().unwrap();
    let container = self.form();
    on_end.call( container, context )
  }

  pub fn hint< Src >( mut self, src : Src ) -> Self
  where Src : core::convert::Into< String >,
  {
    debug_assert!( self.hint.is_none() );
    self.hint = Some( src.into() );
    self
  }

  pub fn subject< Src >( mut self, src : Src ) -> Self
  where Src : core::convert::Into< String >,
  {
    debug_assert!( self.subject.is_none() );
    self.subject = Some( src.into() );
    self
  }

  pub fn properties( mut self ) -> former::runtime::HashMapSubformer
  <
    K,
    Property< K >,
    std::collections::HashMap< K, Property< K > >,
    CommandFormer< K, Context, P >,
    impl Fn( std::collections::HashMap< K, Property< K > >, Self ) -> Self
  >
  {
    let container = self.properties.take();
    let on_end = | container : std::collections::HashMap< K, Property< K > >, mut former : Self | -> Self
    {
      former.properties = Some( container );
      former
    };
    former::runtime::HashMapSubformer::begin( Some( self ), container, on_end )
  }

}

impl< K, Context, P >
CommandFormer< K, Context, P >
where
  K : core::hash::Hash + std::cmp::Eq,
  P : OnEnd< Command< K >, Context >,
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
    if self.properties.is_none()
    {
      self.properties = core::option::Option::Some( Default::default() );
    }
    if let core::option::Option::Some( ref mut properties ) = self.properties
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

//

include!( "only_test/subformer_basic.rs" );
