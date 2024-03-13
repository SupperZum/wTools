mod private
{
  use crate::*;
  use std::
  {
    fmt::Formatter,
    path::Path,
    collections::HashSet,
  };
  use std::ffi::OsString;
  use wtools::error::Result;

  /// The `Channel` enum represents different release channels for rust.
  #[ derive( Debug, Default, Copy, Clone, Hash, Eq, PartialEq, Ord, PartialOrd ) ]
  pub enum Channel
  {
    /// Represents the stable release channel.
    #[ default ]
    Stable,
    /// Represents the nightly release channel.
    Nightly,
  }

  impl std::fmt::Display for Channel
  {
    fn fmt( &self, f : &mut Formatter< '_ > ) -> std::fmt::Result
    {
      match self
      {
        Self::Stable => write!( f, "stable" ),
        Self::Nightly => write!( f, "nightly" ),
      }
    }
  }

  /// Retrieves a list of available channels.
  ///
  /// This function takes a path and returns a `Result` with a vector of strings representing the available channels.
  pub fn available_channels< P >( path : P ) -> Result< HashSet< Channel > >
  where
    P : AsRef< Path >,
  {
    let ( program, options ) = ( "rustup", [ "toolchain", "list" ] );
    let options = 
    process::RunOptions::former()
    .application( program )
    .args( options.into_iter().map( OsString::from ).collect::< Vec< _ > >() )
    .path( path.as_ref().to_path_buf() )
    .form();
    let report = process::run( options ).map_err( | ( report, err ) | err.context( report ) )?;

    let list = report
    .out
    .lines()
    .map( | l | l.split_once( '-' ).unwrap().0 )
    .filter_map( | c | match c
    {
      "stable" => Some( Channel::Stable ),
      "nightly" => Some( Channel::Nightly ),
      _ => None
    } )
    .collect();

    Ok( list )
  }
}

//

crate::mod_interface!
{
  protected use Channel;
  protected use available_channels;
}