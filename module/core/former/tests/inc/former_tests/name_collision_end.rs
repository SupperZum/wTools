#![ allow( dead_code ) ]

#[ allow( unused_imports ) ]
use super::*;

pub trait CloneAny{}
pub trait Context{}
pub trait Formed{}
pub trait OnEnd{}

#[ derive( Clone, the_module::Former ) ]
// #[ derive( Clone, the_module::Former ) ] #[ debug ]
// #[ derive( Clone ) ]
pub struct End
{
  inner : std::sync::Arc< core::cell::RefCell< dyn CloneAny > >
}

// = begin of generated

// = end of generated