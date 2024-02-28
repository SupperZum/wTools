

/// Handler which is called on end of subforming to return origina context.
pub trait OnEnd< T, Context >
{
  /// Function to call.
  fn call( &self, container : T, context : Context ) -> Context;
}

impl< T, Context, F > OnEnd< T, Context > for F
where
  F : Fn( T, Context ) -> Context,
{
  #[ inline( always ) ]
  fn call( &self, container : T, context : Context ) -> Context
  {
    self( container, context )
  }
}

/// Don't do any processing, but return context as is.
#[ derive( Debug, Default ) ]
pub struct NoEnd;

impl< T, Context > OnEnd< T, Context >
for NoEnd
{
  #[ inline( always ) ]
  fn call( &self, _container : T, context : Context ) -> Context
  {
    context
  }
}

/// Don't do any processing, but return container instrad of context.
#[ derive( Debug, Default ) ]
pub struct JustContainerEnd;

impl< T > OnEnd< T, T >
for JustContainerEnd
{
  #[ inline( always ) ]
  fn call( &self, container : T, _context : T ) -> T
  {
    container
  }
}

//
