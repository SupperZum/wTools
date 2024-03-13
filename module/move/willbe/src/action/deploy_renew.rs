mod private
{
  use crate::*;
  use std::path::Path;
  use error_tools::{for_app::Context, Result};
  use tool::template::*;

  /// Template for creating deploy files.
  ///
  /// Includes terraform deploy options to GCP, and Hetzner,
  /// a Makefile for useful commands, and a key directory.
  #[ derive( Debug ) ]
  pub struct DeployTemplate
  {
    files : DeployTemplateFiles,
    parameters : TemplateParameters,
    values : TemplateValues,
  }

  impl Template< DeployTemplateFiles > for DeployTemplate
  {
    fn create_all( self, path : &Path ) -> Result< () >
    {
      self.files.create_all( path, &self.values )
    }

    fn parameters( &self ) -> &TemplateParameters
    {
      &self.parameters
    }

    fn set_values( &mut self, values : TemplateValues )
    {
      self.values = values
    }
  }

  impl Default for DeployTemplate
  {
    fn default() -> Self
    {
      Self
      {
        files : Default::default(),
        parameters : TemplateParameters::new
          (
            &
            [
              "gcp_project_id",
              "gcp_region",
              "gcp_artifact_repo_name",
              "docker_image_name"
            ]
          ),
        values : Default::default(),
      }
    }
  }

  /// Files for the deploy template.
  ///
  /// Default implementation contains all required files.
  #[ derive( Debug ) ]
  pub struct DeployTemplateFiles( Vec< TemplateFileDescriptor > );

  impl Default for DeployTemplateFiles
  {
    fn default() -> Self
    {
      let formed = TemplateFilesBuilder::former()
      // root
      .file().data( include_str!( "../../template/deploy/Makefile" ) ).path( "./Makefile" ).is_template( true ).end()
      // /key
      .file().data( include_str!( "../../template/deploy/key/pack.sh" ) ).path( "./key/pack.sh" ).end()
      .file().data( include_str!( "../../template/deploy/key/Readme.md" ) ).path( "./key/Readme.md" ).end()
      // /deploy/
      .file().data( include_str!( "../../template/deploy/deploy/Dockerfile" ) ).path( "./deploy/Dockerfile" ).end()
      .file().data( include_str!( "../../template/deploy/deploy/Readme.md" ) ).path( "./deploy/Readme.md" ).end()
      // /deploy/gar
      .file().data( include_str!( "../../template/deploy/deploy/gar/Readme.md" ) ).path( "./deploy/gar/Readme.md" ).end()
      .file().data( include_str!( "../../template/deploy/deploy/gar/main.tf" ) ).path( "./deploy/gar/main.tf" ).end()
      .file().data( include_str!( "../../template/deploy/deploy/gar/outputs.tf" ) ).path( "./deploy/gar/outputs.tf" ).end()
      .file().data( include_str!( "../../template/deploy/deploy/gar/variables.tf" ) ).path( "./deploy/gar/variables.tf" ).end()
      // /deploy/gce
      .file().data( include_str!( "../../template/deploy/deploy/gce/Readme.md" ) ).path( "./deploy/gce/Readme.md" ).end()
      .file().data( include_str!( "../../template/deploy/deploy/gce/main.tf" ) ).path( "./deploy/gce/main.tf" ).end()
      .file().data( include_str!( "../../template/deploy/deploy/gce/outputs.tf" ) ).path( "./deploy/gce/outputs.tf" ).end()
      .file().data( include_str!( "../../template/deploy/deploy/gce/variables.tf" ) ).path( "./deploy/gce/variables.tf" ).end()
      // /deploy/gce/templates
      .file().data( include_str!( "../../template/deploy/deploy/gce/templates/cloud-init.tpl" ) ).path( "./deploy/gce/templates/cloud-init.tpl" ).end()
      // /deploy/gcs
      .file().data( include_str!( "../../template/deploy/deploy/gcs/main.tf" ) ).path( "./deploy/gcs/main.tf" ).end()
      // /deploy/hetzner
      .file().data( include_str!( "../../template/deploy/deploy/hetzner/main.tf" ) ).path( "./deploy/hetzner/main.tf" ).end()
      .file().data( include_str!( "../../template/deploy/deploy/hetzner/outputs.tf" ) ).path( "./deploy/hetzner/outputs.tf" ).end()
      .file().data( include_str!( "../../template/deploy/deploy/hetzner/variables.tf" ) ).path( "./deploy/hetzner/variables.tf" ).end()
      // /deploy/hetzner/templates
      .file().data( include_str!( "../../template/deploy/deploy/hetzner/templates/cloud-init.tpl" ) ).path( "./deploy/hetzner/templates/cloud-init.tpl" ).end()
      .form();

      Self( formed.files )
    }
  }

  impl TemplateFiles for DeployTemplateFiles {}
  impl IntoIterator for DeployTemplateFiles
  {
    type Item = TemplateFileDescriptor;

    type IntoIter = std::vec::IntoIter< Self::Item >;

    fn into_iter( self ) -> Self::IntoIter
    {
      self.0.into_iter()
    }
  }

  fn get_dir_name() -> Result< String >
  {
    let current_dir = std::env::current_dir()?;
    let current_dir = current_dir.components().last().context( "Invalid current directory" )?;
    Ok( current_dir.as_os_str().to_string_lossy().into() )
  }

  fn dir_name_to_formatted( dir_name : &str, separator : &str ) -> String
  {
    dir_name
    .replace( ' ', separator )
    .replace( '_', separator )
    .to_lowercase()
  }

  /// Creates deploy template
  pub fn deploy_renew
  (
    path : &Path,
    mut template : DeployTemplate
  ) -> Result< () >
  {
    let current_dir = get_dir_name()?;
    let artifact_repo_name = dir_name_to_formatted( &current_dir, "-" );
    let docker_image_name = dir_name_to_formatted( &current_dir, "_" );
    template.values.insert_if_empty( "gcp_artifact_repo_name", wca::Value::String( artifact_repo_name ) );
    template.values.insert_if_empty( "docker_image_name", wca::Value::String( docker_image_name ) );
    template.values.insert_if_empty( "gcp_region", wca::Value::String( "europe-central2".into() ) );
    template.values.interactive_if_empty( "gcp_project_id" );
    template.create_all( path )?;
    Ok( () )
  }

}

crate::mod_interface!
{
  orphan use deploy_renew;
  orphan use DeployTemplate;
}