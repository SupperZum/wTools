//! With help of `Former`, it is possible to define multiple versions of a setter for a single field, providing the flexibility to include custom logic within the setter methods.
//!
//! This feature is particularly useful when you need to preprocess data or enforce specific constraints before assigning values to fields. Custom setters should have unique names to differentiate them from the default setters generated by `Former`, allowing for specialized behavior while maintaining clarity in your code.
//! In the example showcases a custom alternative setter, `word_exclaimed`, which appends an exclamation mark to the input string before storing it. This approach allows for additional processing or validation of the input data without compromising the simplicity of the builder pattern.
//!

#[ cfg( not( feature = "derive_former" ) ) ]
fn main() {}

#[ cfg( feature = "derive_former" ) ]
fn main()
{
  use former::Former;

  /// Structure with a custom setter.
  #[ derive( Debug, Former ) ]
  pub struct StructWithCustomSetters
  {
    word : String,
  }

  impl StructWithCustomSettersFormer
  {

    // Custom alternative setter for `word`
    pub fn word_exclaimed( mut self, value : impl Into< String > ) -> Self
    {
      debug_assert!( self.container.word.is_none() );
      self.container.word = Some( format!( "{}!", value.into() ) );
      self
    }

  }

  let example = StructWithCustomSetters::former()
  .word( "Hello" )
  .form();
  assert_eq!( example.word, "Hello".to_string() );

  let example = StructWithCustomSetters::former()
  .word_exclaimed( "Hello" )
  .form();
  assert_eq!( example.word, "Hello!".to_string() );

}