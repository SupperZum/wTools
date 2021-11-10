
// use wtools::vector;
// use wtools::vector::{ left_index, append_vectors_once };
use wtools as TheModule;
use wtools::test_suite;

//

fn _is_slice_basic()
{

  let src : &[ i32 ] = &[ 1, 2, 3 ];
  assert_eq!( TheModule::is_slice!( src ), true );
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

fn _implements_basic()
{

  trait Trait1 {}
  fn implementsement_trait1( _ : &impl Trait1 ) -> bool { true }

  impl< T : Sized > Trait1 for &[ T ] {}
  impl< T : Sized, const N : usize > Trait1 for [ T; N ] {}
  impl< T : Sized, const N : usize > Trait1 for &[ T; N ] {}
  let src : &[ i32 ] = &[ 1, 2, 3 ];
  assert_eq!( TheModule::implements!( src => Trait1 ), true );
  assert_eq!( implementsement_trait1( &src ), true );
  assert_eq!( TheModule::implements!( &[ 1, 2, 3 ] => Trait1 ), true );
  assert_eq!( implementsement_trait1( &[ 1, 2, 3 ] ), true );
  assert_eq!( TheModule::implements!( [ 1, 2, 3 ] => Trait1 ), true );

  impl< T : Sized > Trait1 for Vec< T > {}
  assert_eq!( TheModule::implements!( vec!( 1, 2, 3 ) => Trait1 ), true );

  impl Trait1 for f32 {}
  assert_eq!( TheModule::implements!( 13_f32 => Trait1 ), true );

  assert_eq!( TheModule::implements!( true => Copy ), true );
  assert_eq!( TheModule::implements!( true => Clone ), true );

  let src = true;
  assert_eq!( TheModule::implements!( src => Copy ), true );
  assert_eq!( TheModule::implements!( src => Clone ), true );

  assert_eq!( TheModule::implements!( Box::new( true ) => Copy ), false );
  assert_eq!( TheModule::implements!( Box::new( true ) => Clone ), true );

  let src = Box::new( true );
  assert_eq!( TheModule::implements!( src => Copy ), false );
  assert_eq!( TheModule::implements!( src => Clone ), true );

  let pointer_size = std::mem::size_of::< &u8 >();
  dbg!( &pointer_size );
  assert_eq!( 2 * pointer_size, std::mem::size_of::< &[ u8 ] >() );
  assert_eq!( 2 * pointer_size, std::mem::size_of::< *const [ u8 ] >() );
  assert_eq!( 2 * pointer_size, std::mem::size_of::< Box< [ u8 ] > >() );
  assert_eq!( 2 * pointer_size, std::mem::size_of::< std::rc::Rc< [ u8 ] > >() );
  assert_eq!( 1 * pointer_size, std::mem::size_of::< &[ u8 ; 20 ] >() );

}

//

fn _implements_functions()
{

  let _f = ||
  {
    println!( "hello" );
  };

  let fn_context = vec!( 1, 2, 3 );
  let _fn = ||
  {
    println!( "hello {:?}", fn_context );
  };

  let mut fn_mut_context = vec!( 1, 2, 3 );
  let _fn_mut = ||
  {
    fn_mut_context[ 0 ] = 3;
    println!( "{:?}", fn_mut_context );
  };

  let mut fn_once_context = vec!( 1, 2, 3 );
  let _fn_once = ||
  {
    fn_once_context[ 0 ] = 3;
    let x = fn_once_context;
    println!( "{:?}", x );
  };

  // assert_eq!( TheModule::implements!( function1 => fn() -> () ), true );
  // assert_eq!( TheModule::implements!( &function1 => Fn() -> () ), true );
  // assert_eq!( TheModule::implements!( &function1 => FnMut() -> () ), true );
  // assert_eq!( TheModule::implements!( &function1 => FnOnce() -> () ), true );

  // assert_eq!( TheModule::implements!( _fn => fn() -> () ), true );
  assert_eq!( TheModule::implements!( _fn => Fn() -> () ), true );
  assert_eq!( TheModule::implements!( _fn => FnMut() -> () ), true );
  assert_eq!( TheModule::implements!( _fn => FnOnce() -> () ), true );

  // assert_eq!( TheModule::implements!( _fn_mut => fn() -> () ), true );
  // assert_eq!( TheModule::implements!( _fn_mut => Fn() -> () ), true );
  assert_eq!( TheModule::implements!( _fn_mut => FnMut() -> () ), true );
  assert_eq!( TheModule::implements!( _fn_mut => FnOnce() -> () ), true );

  // assert_eq!( TheModule::implements!( _fn_once => fn() -> () ), true );
  // assert_eq!( TheModule::implements!( _fn_once => Fn() -> () ), true );
  // assert_eq!( TheModule::implements!( _fn_once => FnMut() -> () ), true );
  assert_eq!( TheModule::implements!( _fn_once => FnOnce() -> () ), true );

  fn is_f < R >                             ( _x : fn() -> R )      -> bool { true }
  fn is_fn < R, F : Fn() -> R >             ( _x : &F )             -> bool { true }
  fn is_fn_mut < R, F : FnMut() -> R >      ( _x : &F )             -> bool { true }
  fn is_fn_once < R, F : FnOnce() -> R >    ( _x : &F )             -> bool { true }
  fn function1() -> bool { true }

}

//

fn _fn_experiment()
{

  fn function1() -> bool { true }

  let _f = ||
  {
    println!( "hello" );
  };

  let fn_context = vec!( 1, 2, 3 );
  let _fn = ||
  {
    println!( "hello {:?}", fn_context );
  };

  let mut fn_mut_context = vec!( 1, 2, 3 );
  let _fn_mut = ||
  {
    fn_mut_context[ 0 ] = 3;
    println!( "{:?}", fn_mut_context );
  };

  let mut fn_once_context = vec!( 1, 2, 3 );
  let _fn_once = ||
  {
    fn_once_context[ 0 ] = 3;
    let x = fn_once_context;
    println!( "{:?}", x );
  };

  assert_eq!( is_f( function1 ), true );
  assert_eq!( is_fn( &function1 ), true );
  assert_eq!( is_fn_mut( &function1 ), true );
  assert_eq!( is_fn_once( &function1 ), true );

  assert_eq!( is_f( _f ), true );
  assert_eq!( is_fn( &_f ), true );
  assert_eq!( is_fn_mut( &_f ), true );
  assert_eq!( is_fn_once( &_f ), true );

  // assert_eq!( is_f( _fn ), true );
  assert_eq!( is_fn( &_fn ), true );
  assert_eq!( is_fn_mut( &_fn ), true );
  assert_eq!( is_fn_once( &_fn ), true );

  // assert_eq!( is_f( _fn_mut ), true );
  // assert_eq!( is_fn( &_fn_mut ), true );
  assert_eq!( is_fn_mut( &_fn_mut ), true );
  assert_eq!( is_fn_once( &_fn_mut ), true );

  // assert_eq!( is_f( _fn_once ), true );
  // assert_eq!( is_fn( &_fn_once ), true );
  // assert_eq!( is_fn_mut( &_fn_once ), true );
  assert_eq!( is_fn_once( &_fn_once ), true );

  // type Routine< R > = fn() -> R;
  fn is_f < R >                             ( _x : fn() -> R )      -> bool { true }
  // fn is_f < R >                             ( _x : Routine< R > )   -> bool { true }
  fn is_fn < R, F : Fn() -> R >             ( _x : &F )             -> bool { true }
  fn is_fn_mut < R, F : FnMut() -> R >      ( _x : &F )             -> bool { true }
  fn is_fn_once < R, F : FnOnce() -> R >    ( _x : &F )             -> bool { true }

}

//

// trace_macros!( true );
test_suite!
{
  is_slice_basic,
  implements_basic,
  implements_functions,
  fn_experiment,
}
// trace_macros!( false );