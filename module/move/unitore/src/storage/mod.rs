use std::sync::Arc;
use tokio::sync::Mutex;
use feed_rs::model::{ Entry, Feed };
use gluesql::
{
  core::
  {
    ast_builder::{ col, table, Build, Execute },
    data::Value,
    executor::Payload,
    store::{ GStore, GStoreMut },
  },
  prelude::Glue,
  sled_storage::{ sled::Config, SledStorage },
};
use wca::wtools::Itertools;

mod model;
use model::{ FeedRow, FrameRow };

/// Storage for feed frames.
pub struct FeedStorage< S : GStore + GStoreMut + Send >
{
  /// GlueSQL storage.
  pub storage : Arc< Mutex< Glue< S > > >,
  frame_fields : Vec< [ &'static str; 3 ] >,
}

impl FeedStorage< SledStorage >
{
  /// Initialize new storage from configuration, create feed table.
  pub async fn init_storage( config : Config ) -> Result< Self, Box< dyn std::error::Error + Send + Sync > >
  {
    let storage = SledStorage::try_from( config )?;
    let mut glue = Glue::new( storage );

    let feed_table = table( "Feeds" )
    .create_table_if_not_exists()
    .add_column( "id TEXT PRIMARY KEY" )
    .add_column( "type TEXT" )
    .add_column( "title TEXT" )
    .add_column( "updated TIMESTAMP" )
    .add_column( "authors TEXT" )
    .add_column( "description TEXT" )
    .add_column( "published TIMESTAMP" )
    .build()?
    ;

    feed_table.execute( &mut glue ).await?;
  
    let frame_fields = vec!
    [
      [ "id", "TEXT", "A unique identifier for this frame in the feed. " ],
      [ "title", "TEXT", "Title of the frame" ],
      [ "updated", "TIMESTAMP", "Time at which this item was fetched from source." ],
      [ "authors", "TEXT", "List of authors of the frame, optional." ],
      [ "content", "TEXT", "The content of the frame in html or plain text, optional." ],
      [ "links", "TEXT", "List of links associated with this item of related Web page and attachments." ],
      [ "summary", "TEXT", "Short summary, abstract, or excerpt of the frame item, optional." ],
      [ "categories", "TEXT", "Specifies a list of categories that the item belongs to." ],
      [ "published", "TIMESTAMP", "Time at which this item was first published or updated." ],
      [ "source", "TEXT", "Specifies the source feed if the frame was copied from one feed into another feed, optional." ],
      [ "rights", "TEXT", "Conveys information about copyrights over the feed, optional." ],
      [ "media", "TEXT", "List of media oblects, encountered in the frame, optional." ],
      [ "language", "TEXT", "The language specified on the item, optional." ],
      [ "feed_id", "TEXT", "Id of feed that contains this frame." ],
    ];
    let mut table = table( "Frames" ).create_table_if_not_exists().add_column( "id TEXT PRIMARY KEY" );

    for column in frame_fields.iter().skip( 1 ).take( frame_fields.len() - 2 )
    {
      table = table.add_column( format!( "{} {}", column[ 0 ], column[ 1 ] ).as_str() );
    }

    let table = table.add_column( "feed_id TEXT FOREIGN KEY REFERENCES Feeds(id)" )
    .build()?
    ;
  
    table.execute( &mut glue ).await?;

    Ok( Self{ storage : Arc::new( Mutex::new( glue ) ), frame_fields } )
  }
}

/// Functionality of feed storage.
#[ mockall::automock ]
#[ async_trait::async_trait(?Send ) ]
pub trait FeedStore
{
  /// Insert items from list into feed table.
  async fn save_frames( &mut self, feed : Vec< ( Entry, String ) > ) -> Result< (), Box< dyn std::error::Error + Send + Sync > >;

  /// Insert items from list into feed table.
  async fn save_feed( &mut self, feed : Vec< Feed > ) -> Result< (), Box< dyn std::error::Error + Send + Sync > >;

  /// Update items from list in feed table.
  async fn update_feed( &mut self, feed : Vec< ( Entry, String ) > ) -> Result< (), Box< dyn std::error::Error + Send + Sync > >;

  /// Process fetched feed, new items will be saved, modified items will be updated.
  async fn process_feeds( &mut self, feeds : Vec< Feed > ) -> Result< (), Box< dyn std::error::Error + Send + Sync > >;

  /// Get all feed frames from storage.
  async fn get_all_frames( &mut self ) -> Result< Payload, Box< dyn std::error::Error + Send + Sync > >;

  /// Get all feeds from storage.
  async fn get_all_feeds( &mut self ) -> Result< Payload, Box< dyn std::error::Error + Send + Sync > >;

  /// Execute custom query passed as String.
  async fn execute_query( &mut self, query : String ) -> Result< (), Box< dyn std::error::Error + Send + Sync > >;

  /// Get list of column titles of feed table.
  fn columns_titles( &mut self ) -> Vec< [ &'static str; 3 ] >;
}

#[ async_trait::async_trait(?Send) ]
impl FeedStore for FeedStorage< SledStorage >
{
  fn columns_titles( &mut self ) -> Vec< [ &'static str; 3 ] >
  {
    self.frame_fields.clone()
  }

  async fn execute_query( &mut self, query : String ) -> Result< (), Box< dyn std::error::Error + Send + Sync > >
  {
    let glue = &mut *self.storage.lock().await;
    let payloads = glue.execute( &query ).await?;

    for payload in payloads
    {
      match payload
      {
        Payload::ShowColumns( columns ) =>
        {
          for column in columns
          {
            println!( "{} : {}", column.0, column.1 )
          }
        },
        Payload::Create => println!( "Table created" ),
        Payload::Insert( number ) => println!( "Inserted {} rows", number ),
        Payload::Delete( number ) => println!( "Deleted {} rows", number ),
        Payload::Update( number ) => println!( "Updated {} rows", number ),
        Payload::DropTable => println!( "Table dropped" ),
        Payload::Select { labels: label_vec, rows: rows_vec } =>
        {
          println!( "labels : {}", label_vec.iter().fold( String::new(), | acc, val | format!( "{}, {}", acc, val ) ) );
          for row in rows_vec
          {
            println!( "{}", row.iter().fold( String::new(), | acc, val | format!( "{}, {:?}", acc, val ) ) );
          }
        },
        Payload::AlterTable => println!( "Table altered" ),
        Payload::StartTransaction => println!( "Transaction started" ),
        Payload::Commit => println!( "Transaction commited" ),
        Payload::Rollback => println!( "Transaction rolled back" ),
        _ => {},
      };
    }

    Ok( () )
  }

  async fn get_all_frames( &mut self ) -> Result< Payload, Box< dyn std::error::Error + Send + Sync > >
  {
    let res = table( "Frames" ).select().execute( &mut *self.storage.lock().await ).await?;
    Ok( res )
  }

  async fn get_all_feeds( &mut self ) -> Result< Payload, Box< dyn std::error::Error + Send + Sync > >
  {
    //HashMap< &str, &Value >
    let res = table( "Feeds" ).select().project( "id, title" ).execute( &mut *self.storage.lock().await ).await?;
    Ok( res )
  }

  async fn save_frames( &mut self, frames : Vec< ( Entry, String ) > ) -> Result< (), Box< dyn std::error::Error + Send + Sync > >
  {
    let entries_rows = frames.into_iter().map( | entry | FrameRow::from( entry ).0 ).collect_vec();
    println!( "{}", self.frame_fields.iter().map( | field | field[ 0 ] ).join( "," ).as_str() );
    let _insert = table( "Frames" )
    .insert()
    .columns
    (
      self.frame_fields.iter().map( | field | field[ 0 ] ).join( "," ).as_str()
    )
    .values( entries_rows )
    .execute( &mut *self.storage.lock().await )
    .await?
    ;

    Ok( () )
  }

  async fn save_feed( &mut self, feed : Vec< Feed > ) -> Result< (), Box< dyn std::error::Error + Send + Sync > >
  {
    let feeds_rows = feed.into_iter().map( | feed | FeedRow::from( feed ).0 ).collect_vec();

    let _insert = table( "Feeds" )
    .insert()
    .columns
    (
      "id,
      title,
      updated,
      authors,
      description,
      published",
    )
    .values( feeds_rows )
    .execute( &mut *self.storage.lock().await )
    .await?
    ;

    Ok( () )
  }

  async fn update_feed( &mut self, feed : Vec< ( Entry, String ) > ) -> Result< (), Box< dyn std::error::Error + Send + Sync > >
  {
    let entries_rows = feed.into_iter().map( | entry | FrameRow::from( entry ).0 ).collect_vec();

    for entry in entries_rows
    {
      let _update = table( "Frames" )
      .update()
      .set( "title", entry[ 1 ].to_owned() )
      .set( "content", entry[ 4 ].to_owned() )
      .set( "links", entry[ 5 ].to_owned() )
      .set( "summary", entry[ 6 ].to_owned() )
      .set( "published", entry[ 8 ].to_owned() )
      .set( "media", entry[ 9 ].to_owned() )
      .filter( col( "id" ).eq( entry[ 0 ].to_owned() ) )
      .execute( &mut *self.storage.lock().await )
      .await?
      ;
    }
    Ok( () )
  }

  async fn process_feeds
  (
    &mut self,
    feeds : Vec< Feed >,
  ) -> Result< (), Box< dyn std::error::Error + Send + Sync > >
  {
    let new_feed_ids = feeds.iter().map( | feed | format!("'{}'", feed.id ) ).join( "," );
    let existing_feeds = table( "Feeds" )
    .select()
    .filter( format!( "id IN ({})", new_feed_ids ).as_str() )
    .project( "id" )
    .execute( &mut *self.storage.lock().await )
    .await?
    ;

    let existing_frames = table( "Frames" )
    .select()
    .project( "id, published" )
    .execute( &mut *self.storage.lock().await )
    .await?
    ;

    let mut new_entries = Vec::new();
    let mut modified_entries = Vec::new();

    for feed in &feeds
    {
      // check if feed is new
      if let Some( existing_feeds ) = existing_feeds.select()
      {
        let existing_ids = existing_feeds.filter_map( | feed | feed.get( "id" ).map( | id | id.to_owned() ) ).filter_map( | id | 
          match id
          {
            Value::Str( s ) => Some( s ),
            _ => None,
          }
        ).collect_vec();

        if !existing_ids.contains( &&feed.id )
        {
          self.save_feed( vec![ feed.clone() ] ).await?;
          
          new_entries.extend( feed.entries.clone().into_iter().zip( std::iter::repeat( feed.id.clone() ).take( feed.entries.len() ) ) );
          continue;
        }
      }
      if let Some( rows ) = existing_frames.select()
      {
        let existing_entries = rows
        .map( | r | ( r.get( "id" ).map( | &val | val.clone() ), r.get( "published" ).map( | &val | val.clone() ) ) )
        .flat_map( | ( id, published ) |
          id.map( | id |
            (
              id,
              published.map( | date |
                {
                  match date 
                  {
                    Value::Timestamp( date_time ) => Some( date_time ),
                    _ => None,
                  } 
                } )
              .flatten()
            )
          )
        )
        .flat_map( | ( id, published ) | match id { Value::Str( id ) => Some( ( id, published ) ), _ => None } )
        .collect_vec()
        ;

        let existing_ids = existing_entries.iter().map( | ( id, _ ) | id ).collect_vec();
        for entry in &feed.entries
        {
          // if extry with same id is already in db, check if it is updated
          if let Some( position ) = existing_ids.iter().position( | &id | id == &entry.id )
          {
            if let Some( date ) = existing_entries[ position ].1
            {
              if date.and_utc() != entry.published.unwrap()
              {
                modified_entries.push( ( entry.clone(), feed.id.clone() ) );
              }
            }
          }
          else
          {
            new_entries.push( ( entry.clone(), feed.id.clone() ) );
          }
        }
      }
    }
    
    if new_entries.len() > 0
    {
      self.save_frames( new_entries ).await?;
    }
    if modified_entries.len() > 0
    {
      self.update_feed( modified_entries ).await?;
    }
    
    Ok( () )
  }
}