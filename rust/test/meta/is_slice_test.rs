// #![feature(type_name_of_val)]

use is_slice as TheModule;
use wtest::test_suite;

//

fn _is_slice_basic()
{


  let src : &[ i32 ] = &[ 1, 2, 3 ];
  assert_eq!( TheModule::is_slice!( src ), true );
  assert_eq!( TheModule::is_slice!( &[ 1, 2, 3 ][ .. ] ), true );
  assert_eq!( TheModule::is_slice!( &[ 1, 2, 3 ] ), false );

  // TheModule::inspect_logging_type_of!( &[ 1, 2, 3 ][ .. ] );
  // TheModule::inspect_logging_type_of!( &[ 1, 2, 3 ] );

  assert_eq!( TheModule::is_slice!( vec!( 1, 2, 3 ) ), false );
  assert_eq!( TheModule::is_slice!( 13_f32 ), false );
  assert_eq!( TheModule::is_slice!( true ), false );
  let src = false;
  assert_eq!( TheModule::is_slice!( src ), false );
  assert_eq!( TheModule::is_slice!( Box::new( true ) ), false );
  let src = Box::new( true );
  assert_eq!( TheModule::is_slice!( src ), false );

}

//

test_suite!
{
  is_slice_basic,
}
