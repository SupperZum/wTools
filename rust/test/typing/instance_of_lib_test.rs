#![ warn( rust_2018_idioms ) ]
#![ warn( missing_debug_implementations ) ]
#![ warn( missing_docs ) ]

// #![ feature( type_name_of_val ) ]
// #![ feature( trace_macros ) ]

use test_tools::*;
use instance_of as TheModule;

//

fn implements_basic_test()
{

  let src = Box::new( true );
  assert_eq!( TheModule::implements!( src => Copy ), false );
  assert_eq!( TheModule::implements!( src => Clone ), true );

}

//

fn instance_of_basic_test()
{

  let src = Box::new( true );
  assert_eq!( TheModule::instance_of!( src => Copy ), false );
  assert_eq!( TheModule::instance_of!( src => Clone ), true );

}

//

test_suite!
{
  implements_basic,
  instance_of_basic,
}