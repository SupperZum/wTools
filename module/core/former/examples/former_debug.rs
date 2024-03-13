//!
//! This is a demonstration of attribute debug.
//! The attribute `#[ debug ]` outputs generated code into the console during compilation.
//!

#[ cfg( not( feature = "derive_former" ) ) ]
fn main() {}

#[ cfg( all( feature = "derive_former", feature = "enabled" ) ) ]
fn main()
{
  use former::Former;


  #[ derive( Debug, PartialEq, Former ) ]
  #[ debug ]
  pub struct UserProfile
  {
    age : i32,
    username : String,
    bio_optional : Option< String >, // Fields could be optional
  }

  let profile = UserProfile::former()
  .age( 30 )
  .username( "JohnDoe".to_string() )
  .bio_optional( "Software Developer".to_string() ) // Optionally provide a bio
  .form();

  dbg!( &profile );
  // Expected output:
  // &profile = UserProfile {
  //   age: 30,
  //   username: "JohnDoe",
  //   bio_optional: Some("Software Developer"),
  // }

}