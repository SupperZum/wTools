
use std::env;

#[test]
fn tests()
{
  let t = trybuild::TestCases::new();
  println!( "current_dir : {:?}", env::current_dir().unwrap() );
  t.pass( "../../../rust/former/test/test/basic_former.rs" );
}