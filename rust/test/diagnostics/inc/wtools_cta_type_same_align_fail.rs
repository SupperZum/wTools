use wtools::diagnostics::*;

fn main()
{
  #[ repr( align( 128 ) )]
  struct Int( i16 );
  cta_type_same_align!( Int, i16 );
}
