/// Internal namespace.
pub( crate ) mod private
{
  use crate::*;
  // use once_cell::sync::Lazy;
  // use std::sync::Mutex;
  // use dashmap::DashMap;
  // use std::sync::Arc;

  /// Context.
  #[ derive( Debug, Clone ) ]
  pub struct Context
  {
    id : Id,
    stroke : Option< StrokeBrush >,
  }

  impl Context
  {
    /// Constructor.
    pub( crate ) fn _new() -> Self
    {
      let id = Id::new::< Self >();
      let stroke = None;
      Self
      {
        id,
        stroke,
      }
    }
    /// Parameters of stroke.
    pub fn stroke( &mut self ) -> StrokeBrush
    {
      if self.stroke.is_none()
      {
        self.stroke = Some( StrokeBrush::new() );
      }
      self.stroke.as_ref().unwrap().clone()
    }
  }

  impl HasIdInterface for Context
  {
    #[ inline ]
    fn id( &self ) -> Id
    {
      self.id
    }
  }

}

/// Protected namespace of the module.
pub mod protected
{
  pub use super::
  {
    orphan::*,
  };
}

pub use protected::*;

/// Parented namespace of the module.
pub mod orphan
{
  pub use super::exposed::*;
}

/// Exposed namespace of the module.
pub mod exposed
{
  pub use super::
  {
    prelude::*,
    private::Context,
  };
}

pub use exposed::*;

/// Prelude to use essentials: `use my_module::prelude::*`.
pub mod prelude
{
  pub use super::private::
  {
  };
}