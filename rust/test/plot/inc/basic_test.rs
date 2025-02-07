use super::*;

// zzz : remove
// pub use wmath::X2;
// pub use wmath::X2BasicInterface;

//

tests_impls!
{

  #[ignore]
  fn without()
  {
    use TheModule::math::X2;
    use TheModule::prelude::*;

    let file_name = "./test.png";
    let dims = X2::make( 32, 32 );
    let mut imgbuf = TheModule::dependency::image::ImageBuffer::new( dims.0, dims.1 );

    for x in 0 ..= 30
    {
      let y = 0;
      *imgbuf.get_pixel_mut( x, y ) = TheModule::dependency::image::Rgb( [ 255_u8, 0_u8, 255_u8 ] );
    }

    for x in 1 ..= 31
    {
      let y = 31;
      *imgbuf.get_pixel_mut( x, y ) = TheModule::dependency::image::Rgb( [ 255_u8, 0_u8, 255_u8 ] );
    }

    for y in 0 ..= 30
    {
      let x = 31;
      *imgbuf.get_pixel_mut( x, y ) = TheModule::dependency::image::Rgb( [ 255_u8, 0_u8, 255_u8 ] );
    }

    for y in 1 ..= 31
    {
      let x = 0;
      *imgbuf.get_pixel_mut( x, y ) = TheModule::dependency::image::Rgb( [ 255_u8, 0_u8, 255_u8 ] );
    }

    imgbuf.save( file_name ).unwrap();
    // open::that( file_name ).unwrap();

  }

  //

  // #[ignore]
  fn basic()
  {
    use TheModule::math::X2;
    use TheModule::prelude::*;

    // let c = TheModule::context::make();
    let mut c = TheModule::context();
    // let c = TheModule::context().new();

    // c.canvas.size( make!( 32, 32 ) );
    let c = c
    // .stroke().color( [ 1.0, 0.0, 1.0 ] ).end()
    .stroke().width( 2.0 ).color( [ 1.0, 0.0, 1.0 ] ).context()
    // c.draw().begin();
    // c.draw().name( "drawing1" );
    .draw().rect().context()
    // c.draw().rect().region( make!( 0.0, 0.0 ), make!( 1.0, 1.0 ) ).context();
    // c.draw().end();
    // c.draw().now();
    ;

//     // c.canvas().storing_to_file_path( file_name );
//     // c.canvas().showing_file( true );
//     c.canvas().store_to_file();

    println!( "{:?}", c );

  }

}

//

tests_index!
{
  without,
  basic,
}
