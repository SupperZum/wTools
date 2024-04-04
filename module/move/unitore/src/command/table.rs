//! 

use crate::*;
use gluesql::sled_storage::sled::Config;
use wca::{ Command, Type, VerifiedCommand };
use storage::FeedStorage;
use action::{ Report, table::table_list };
use error_tools::Result;

pub struct TableCommand( Command );

impl TableCommand
{
  pub fn new() -> Result< Self >
  {

    let rt  = tokio::runtime::Runtime::new()?;
  
    Ok( Self
    (
      Command::former()
      .long_hint( concat!
      (
        "Delete file with feeds configuraiton. Subject: path to config file.\n",
        "    Example: .config.delete ./config/feeds.toml",
      ))
      .subject().hint( "Path" ).kind( Type::Path ).optional( false ).end()
      .routine( move | o : VerifiedCommand |
      {
        let res = rt.block_on( async move
        {
          let path_to_storage = std::env::var( "UNITORE_STORAGE_PATH" )
          .unwrap_or( String::from( "./_data" ) )
          ;
          
          let config = Config::default()
          .path( path_to_storage )
          ;

          let feed_storage = FeedStorage::init_storage( &config ).await?;
          table_list( feed_storage, &o.args ).await
        } );
        match res
        {
          Ok( report ) => report.report(),
          Err( err ) => println!( "{:?}", err ),
        }
      })
      .end()
    ) )
  }
  pub fn command()
  {

  }
}