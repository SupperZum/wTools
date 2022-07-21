/// Private namespace.
pub( crate ) mod private
{
  use wtools::error::Result;
  use crate::common::prelude::*;

  /// Encoder for the buffer.

  #[ derive( Debug ) ]
  pub struct Encoder< T >
  where
    T : EncodeData
  {
    /// Frame width.
    width : usize,
    /// Frame height.
    height : usize,
    /// Frame rate.
    frame_rate : usize,
    /// Color encoding.
    color_type : ColorType,

    /// Type of output format.
    encoder_type : EncoderType,
    /// Encoder for the output format.
    encoder : Box< T >,

    /// Output filename.
    output_filename : std::path::PathBuf,
  }

  impl< T > EncodeData for Encoder< T >
  where
    T : EncodeData
  {
    /// Encode bytes buffer to output.
    fn encode( &mut self, data : impl AsRef< [ u8 ] > ) -> Result< () >
    {
      self.encoder.encode( data )
    }
    /// Finish encoding.
    fn flush( &self ) -> Result< () >
    {
      self.encoder.flush()
    }
  }

  impl< T > Encoder< T >
  where
    T : EncodeData
  {
    /// Create an instance.
    pub fn new( width : usize, height : usize, frame_rate : usize, encoder_type : EncoderType, filename : impl AsRef< str > ) -> Self
    {
      unimplemented!( "not implemented" );
      // let color_type = ColorType::Rgb;
      // let encoder = Encoder::encoder_make( width, height, frame_rate, &encoder_type, &color_type );
      //
      // Self
      // {
      //   width,
      //   height,
      //   frame_rate,
      //   color_type,
      //   encoder_type,
      //   encoder : Box::new( encoder ),
      //   output_filename : std::path::PathBuf::from( filename.as_ref() ),
      // }
    }

    // fn encoder_make( width : usize, height : usize, frame_rate : usize, &encoder_type : &EncoderType, &color_type : &ColorType ) -> impl EncodeData
    // {
    //   let encoder = match encoder_type
    //   {
    //     EncoderType::Gif => crate::encoders::Gif::new( width, height, frame_rate, color_type ),
    //     EncoderType::Png => crate::encoders::Png::new( width, height, frame_rate, color_type ),
    //     EncoderType::Mp4 => crate::encoders::Mp4::new( width, height, frame_rate, color_type ),
    //     _ => panic!( "unknown encoder type \"{:?}\"", _ ),
    //   }
    //   encoder
    // }
  }
}

wtools::meta::mod_interface!
{
  prelude use Encoder;
}
