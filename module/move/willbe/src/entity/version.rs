/// Internal namespace.
mod private
{
  use crate::*;

  use std::
  {
    fmt,
    str::FromStr,
  };
  use std::fmt::Formatter;
  use toml_edit::value;
  use semver::Version as SemVersion;

  use wtools::error::for_app::Result;
  use manifest::Manifest;
  use _path::AbsolutePath;
  use package::Package;
  use wtools::{ error::anyhow::format_err, iter::Itertools };

  /// Wrapper for a SemVer structure
  #[ derive( Debug, Clone, Eq, PartialEq, Ord, PartialOrd ) ]
  pub struct Version( SemVersion );

  impl FromStr for Version
  {
    type Err =  semver::Error;

    fn from_str( s : &str ) -> std::result::Result< Self, Self::Err >
    {
      Ok( Self( SemVersion::from_str( s )? ) )
    }
  }

  impl TryFrom< &str > for Version
  {
    type Error = semver::Error;

    fn try_from( value : &str ) -> Result< Self, Self::Error >
    {
      FromStr::from_str( value )
    }
  }

  impl TryFrom< &String > for Version
  {
    type Error = semver::Error;

    fn try_from( value : &String ) -> Result< Self, Self::Error >
    {
      Self::try_from( value.as_str() )
    }
  }

  impl fmt::Display for Version
  {
    fn fmt( &self, f : &mut fmt::Formatter< '_ > ) -> fmt::Result
    {
      write!( f, "{}", self.0.to_string() )
    }
  }

  impl Version
  {
    /// Bump a version with default strategy
    ///
    /// This function increases first not 0 number
    pub fn bump( self ) -> Self
    {
      let mut ver = self.0;
      if ver.major != 0
      {
        ver.major += 1;
        ver.minor = 0;
        ver.patch = 0;
      }
      else if ver.minor != 0
      {
        ver.minor += 1;
        ver.patch = 0;
      }
      else
      {
        ver.patch += 1;
      }

      Self( ver )
    }
  }

  /// A structure that represents a bump report, which contains information about a version bump.
  #[ derive( Debug, Default, Clone ) ]
  pub struct BumpReport
  {
    /// Pacakge name.
    pub name : Option< String >,
    /// Package old version.
    pub old_version : Option< String >,
    /// Package new version.
    pub new_version : Option< String >,
  }

  impl fmt::Display for BumpReport
  {
    fn fmt( &self, f : &mut fmt::Formatter< '_ > ) -> fmt::Result
    {
      let Self { name, old_version, new_version } = self;
      match ( name, old_version, new_version )
      {
        ( Some( name ), Some( old_version ), Some( new_version ) )
        => f.write_fmt( format_args!( "`{name}` bumped from {old_version} to {new_version}" ) ),
        _ => f.write_fmt( format_args!( "Bump failed" ) )
      }
    }
  }

  /// Bump version by manifest.
  /// It takes data from the manifest and increments the version number according to the semantic versioning scheme.
  /// It then writes the updated manifest file back to the same path, unless the flag is set to true, in which case it only returns the new version number as a string.
  ///
  /// # Args :
  /// - `manifest` - a manifest mutable reference
  /// - `dry` - a flag that indicates whether to apply the changes or not
  ///         - `true` - does not modify the manifest file, but only returns the new version;
  ///         - `false` - overwrites the manifest file with the new version.
  ///
  /// # Returns :
  /// - `Ok` - the new version number as a string;
  /// - `Err` - if the manifest file cannot be read, written, parsed.
  pub fn bump( manifest : &mut Manifest, dry : bool ) -> Result< BumpReport, manifest::ManifestError >
  {
    let mut report = BumpReport::default();

    let version=
    {
      if manifest.manifest_data.is_none()
      {
        manifest.load()?;
      }
      let data = manifest.manifest_data.as_ref().unwrap();
      if !manifest.package_is()?
      {
        return Err( manifest::ManifestError::NotAPackage );
      }
      let package = data.get( "package" ).unwrap();

      let version = package.get( "version" );
      if version.is_none()
      {
        return Err( manifest::ManifestError::CannotFindValue( "version".into() ) );
      }
      let version = version.unwrap().as_str().unwrap();
      report.name = Some( package[ "name" ].as_str().unwrap().to_string() );
      report.old_version = Some( version.to_string() );

      Version::from_str( version ).map_err( | e | manifest::ManifestError::InvalidValue( e.to_string() ) )?
    };

    let new_version = version.bump().to_string();
    report.new_version = Some( new_version.clone() );

    if !dry
    {
      let data = manifest.manifest_data.as_mut().unwrap();
      data[ "package" ][ "version" ] = value( &new_version );
      manifest.store()?;
    }

    Ok( report )
  }

  // qqq : we have to replace the implementation above with the implementation below, don't we?

  /// `BumpOptions` manages the details necessary for the version bump process for crates.
  /// This includes the directory of the crate whose version is being bumped, the old and new version numbers,
  /// and the set of dependencies of that crate.
  #[ derive( Debug, Clone ) ]
  pub struct BumpOptions
  {
    /// `crate_dir` - The directory of the crate which you want to bump the version of. This value is
    /// represented by `CrateDir` which indicates the directory of the crate.
    pub crate_dir : CrateDir,

    /// `old_version` - The version of the crate before the bump. It's represented by `Version` which
    /// denotes the old version number of the crate.
    pub old_version : Version,

    /// `new_version` - The version number to assign to the crate after the bump. It's also represented
    /// by `Version` which denotes the new version number of the crate.
    pub new_version : Version,

    /// `dependencies` - This is a vector containing the directories of all the dependencies of the crate.
    /// Each item in the `dependencies` vector indicates a `CrateDir` directory of a single dependency.
    pub dependencies : Vec< CrateDir >,

    /// `dry` - A boolean indicating whether to do a "dry run". If set to `true`, a simulated run is performed
    /// without making actual changes. If set to `false`, the operations are actually executed. This is
    /// useful for validating the process of bumping up the version or for testing and debugging.
    pub dry : bool,
  }

  /// Report about a changing version.
  #[ derive( Debug, Default, Clone ) ]
  pub struct ExtendedBumpReport
  {
    /// Pacakge name.
    pub name : Option< String >,
    /// Package old version.
    pub old_version : Option< String >,
    /// Package new version.
    pub new_version : Option< String >,
    /// Files that should(already) changed for bump.
    pub changed_files : Vec< AbsolutePath >
  }

  impl std::fmt::Display for ExtendedBumpReport
  {
    fn fmt( &self, f : &mut Formatter< '_ > ) -> std::fmt::Result
    {
      let Self { name, old_version, new_version, changed_files } = self;
      if self.changed_files.is_empty()
      {
        write!( f, "Files were not changed during bumping the version" )?;
        return Ok( () )
      }

      let files = changed_files.iter().map( | f | f.as_ref().display() ).join( ",\n    " );
      match ( name, old_version, new_version )
      {
        ( Some( name ), Some( old_version ), Some( new_version ) )
        => writeln!( f, "`{name}` bumped from {old_version} to {new_version}\n  changed files :\n    {files}" ),
        _ => writeln!( f, "Bump failed" )
      }?;

      Ok( () )
    }
  }


  /// Bumps the version of a package and its dependencies.
  ///
  /// # Arguments
  ///
  /// * `args` - The options for version bumping.
  ///
  /// # Returns
  ///
  /// Returns a result containing the extended bump report if successful.
  ///
  pub fn version_bump( o : BumpOptions ) -> Result< ExtendedBumpReport >
  {
    let mut report = ExtendedBumpReport::default();
    let package_path = o.crate_dir.absolute_path().join( "Cargo.toml" );
    let package = Package::try_from( package_path.clone() ).map_err( | e | format_err!( "{report:?}\n{e:#?}" ) )?;
    let name = package.name().map_err( | e | format_err!( "{report:?}\n{e:#?}" ) )?;
    report.name = Some( name.clone() );
    let package_version = package.version().map_err( | e | format_err!( "{report:?}\n{e:#?}" ) )?;
    let current_version = version::Version::try_from( package_version.as_str() ).map_err( | e | format_err!( "{report:?}\n{e:#?}" ) )?;
    if current_version > o.new_version
    {
      return Err( format_err!( "{report:?}\nThe current version of the package is higher than need to be set\n\tpackage: {name}\n\tcurrent_version: {current_version}\n\tnew_version: {}", o.new_version ) );
    }
    report.old_version = Some( o.old_version.to_string() );
    report.new_version = Some( o.new_version.to_string() );

    let mut package_manifest = package.manifest().map_err( | e | format_err!( "{report:?}\n{e:#?}" ) )?;
    if !o.dry
    {
      let data = package_manifest.manifest_data.as_mut().unwrap();
      data[ "package" ][ "version" ] = value( &o.new_version.to_string() );
      package_manifest.store()?;
    }
    report.changed_files = vec![ package_path ];
    let new_version = &o.new_version.to_string();
    for dep in &o.dependencies
    {
      let manifest_path = dep.absolute_path().join( "Cargo.toml" );
      let mut manifest = manifest::open( manifest_path.clone() ).map_err( | e | format_err!( "{report:?}\n{e:#?}" ) )?;
      let data = manifest.manifest_data.as_mut().unwrap();
      let item = if let Some( item ) = data.get_mut( "package" ) { item }
      else if let Some( item ) = data.get_mut( "workspace" ) { item }
      else { return Err( format_err!( "{report:?}\nThe manifest nor the package and nor the workspace" ) ); };
      if let Some( dependency ) = item.get_mut( "dependencies" ).and_then( | ds | ds.get_mut( &name ) )
      {
        if let Some( previous_version ) = dependency.get( "version" ).and_then( | v | v.as_str() ).map( | v | v.to_string() )
        {
          if previous_version.starts_with('~')
          {
            dependency[ "version" ] = value( format!( "~{new_version}" ) );
          }
          else
          {
            dependency[ "version" ] = value( new_version.clone() );
          }
        }
      }
      if !o.dry { manifest.store().map_err( | e | format_err!( "{report:?}\n{e:#?}" ) )?; }
      report.changed_files.push( manifest_path );
    }

    Ok( report )
  }
}

//

crate::mod_interface!
{
  /// Version entity.
  protected use Version;

  /// Report for bump operation.
  protected use BumpReport;

  /// Bump version.
  protected use bump;

  /// Options for version bumping.
  protected use BumpOptions;
  /// Report about a changing version with list of files that was changed.
  protected use ExtendedBumpReport;
  /// Bumps the version of a package and its dependencies.
  protected use version_bump;
}
