/// Internal namespace.
mod private
{
  use crate::*;
  use test::*;
  use path::AbsolutePath;

  use std::collections::HashSet;

  use std::{ env, fs };

  use cargo_metadata::Package;

  use former::Former;
  use wtools::
  {
    error::
    {
      for_app::
      {
        Error,
        format_err
      },
      Result
    },
    iter::Itertools,
  };

  /// Used to store arguments for running tests.
  ///
  /// - The `dir` field represents the directory of the crate under test.
  /// - The `channels` field is a set of `Channel` enums representing the channels for which the tests should be run.
  /// - The `concurrent` field determines how match tests can be run at the same time.
  /// - The `exclude_features` field is a vector of strings representing the names of features to exclude when running tests.
  /// - The `include_features` field is a vector of strings representing the names of features to include when running tests.
  #[ derive( Debug, Former ) ]
  pub struct TestsCommandOptions
  {
    dir : AbsolutePath,
    channels : HashSet< channel::Channel >,
    #[ default( 0u32 ) ]
    concurrent : u32,
    #[ default( 1u32 ) ]
    power : u32,
    include_features : Vec< String >,
    exclude_features : Vec< String >,
    #[ default( true ) ]
    temp : bool,
  }

  /// The function runs tests with a different set of features in the selected crate (the path to the crate is specified in the dir variable).
  /// Tests are run with each feature separately, with all features together, and without any features.
  /// The tests are run in nightly and stable versions of Rust.
  /// It is possible to enable and disable various features of the crate.
  /// The function also has the ability to run tests in parallel using `Rayon` crate.
  /// The result of the tests is written to the structure `TestsReport` and returned as a result of the function execution.
  pub fn test( args : TestsCommandOptions, dry : bool ) -> Result< TestsReport, ( TestsReport, Error ) >
  {
    let mut reports = TestsReport::default();
    // fail fast if some additional installations required
    let channels = channel::available_channels( args.dir.as_ref() ).map_err( | e | ( reports.clone(), e ) )?;
    let channels_diff = args.channels.difference( &channels ).collect::< Vec< _ > >();
    if !channels_diff.is_empty()
    {
      return Err(( reports, format_err!( "Missing toolchain(-s) that was required : [{}]. Try to install it with `rustup install {{toolchain name}}` command(-s)", channels_diff.into_iter().join( ", " ) ) ))
    }

    reports.dry = dry;
    let TestsCommandOptions
    {
      dir : _ ,
      channels,
      concurrent,
      power,
      include_features,
      exclude_features,
      temp
    } = args;
    let packages = needed_packages( args.dir.clone() ).map_err( | e | ( reports.clone(), e ) )?;

    if temp
    {
      
      let mut unique_name = format!( "temp_dir_for_test_command_{}", path::unique_folder_name_generate().map_err( | e | ( reports.clone(), e ) )? );

      let mut temp_dir = env::temp_dir().join( unique_name );

      while temp_dir.exists()
      {
        unique_name = format!( "temp_dir_for_test_command_{}", path::unique_folder_name_generate().map_err( | e | ( reports.clone(), e ) )? );
        temp_dir = env::temp_dir().join( unique_name );
      }

      fs::create_dir( &temp_dir ).map_err( | e | ( reports.clone(), e.into() ) )?;

      let t_args = TestOptions
      {
        channels,
        concurrent,
        power,
        include_features,
        exclude_features,
        temp_path: Some( temp_dir.clone() ),
      };
      
      let report = tests_run( &t_args, &packages, dry );

      fs::remove_dir_all(&temp_dir).map_err( | e | ( reports.clone(), e.into() ) )?;

      report
    }
    else
    {
      let t_args = TestOptions
      {
        channels,
        concurrent,
        power,
        include_features,
        exclude_features,
        temp_path: None,
      };

      tests_run( &t_args, &packages, dry )
    }
  }

  fn needed_packages( path : AbsolutePath ) -> Result< Vec< Package > >
  {
    let path = if path.as_ref().file_name() == Some( "Cargo.toml".as_ref() )
    {
      path.parent().unwrap()
    }
    else
    {
      path
    };
    let metadata = Workspace::with_crate_dir( CrateDir::try_from( path.clone() )? )?;

    let result = metadata
    .packages()?
    .into_iter()
    .cloned()
    .filter( move | x | x.manifest_path.starts_with( path.as_ref() ) )
    .collect();
    Ok( result )
  }
}

crate::mod_interface!
{
  /// run all tests in all crates
  orphan use test;
  protected use TestsCommandOptions;
}