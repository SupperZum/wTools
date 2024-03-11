#![ doc( html_logo_url = "https://raw.githubusercontent.com/Wandalen/wTools/master/asset/img/logo_v3_trans_square.png" ) ]
#![ doc( html_favicon_url = "https://raw.githubusercontent.com/Wandalen/wTools/alpha/asset/img/logo_v3_trans_square_icon_small_v2.ico" ) ]
#![ doc( html_root_url = "https://docs.rs/former_derive_meta/latest/former_derive_meta/" ) ]
#![ doc = include_str!( concat!( env!( "CARGO_MANIFEST_DIR" ), "/", "Readme.md" ) ) ]

#[ cfg( feature = "enabled" ) ]
mod derive;

///
/// Derive macro to generate former for a structure. Former is variation of Builder Pattern.
///

/// Derives a 'Former' for a struct, implementing a variation of the Builder Pattern.
///
/// This macro simplifies the creation of builder patterns for structs by automatically
/// generating a 'former' (builder) struct and implementation. It supports customization
/// through attributes to control default values, setter generation, subformer inclusion,
/// and field aliases.
///
/// # Attributes :
/// - `perform` : Specifies a method to call on the built object immediately after its construction.
/// - `default` : Sets a default value for a field.
/// - `setter` : Enables or disables the generation of a setter method for a field.
/// - `subformer` : Defines a sub-former for complex field types, allowing nested builders.
/// - `alias` : Creates an alias for a field setter.
/// - `doc` : Adds documentation to the generated setter methods.
///
/// # Input Example :
///
/// ```rust
/// #[ cfg( all( feature = "derive_former", feature = "enabled" ) ) ]
/// fn main()
/// {
///   use former::Former;
///
///   #[ derive( Debug, PartialEq, Former ) ]
///   pub struct UserProfile
///   {
///     age : i32,
///     username : String,
///     bio_optional : Option< String >, // Fields could be optional
///   }
///
///   let profile = UserProfile::former()
///   .age( 30 )
///   .username( "JohnDoe".to_string() )
///   .bio_optional( "Software Developer".to_string() ) // Optionally provide a bio
///   .form();
///
///   dbg!( &profile );
///   // Expected output:
///   // &profile = UserProfile {
///   //   age: 30,
///   //   username: "JohnDoe",
///   //   bio_optional: Some("Software Developer"),
///   // }
///
/// }
/// ```
///
/// # Generated Code Example :
///
/// Assuming the struct above, the macro generates something like this :
///
/// ```rust
/// # #[ cfg( feature = "enabled" ) ]
/// # #[ allow( dead_code ) ]
/// # fn main()
/// # {
///
///   #[ derive( Debug, PartialEq ) ]
///   pub struct UserProfile
///   {
///     age : i32,
///     username : String,
///     bio_optional : Option< String >, // Fields could be optional
///   }
///
///   impl UserProfile
///   {
///     #[ inline( always ) ]
///     pub fn former() -> UserProfileFormer< UserProfile, former::ReturnContainer >
///     {
///       UserProfileFormer::< UserProfile, former::ReturnContainer >::new()
///     }
///   }
///
///   #[ derive( Debug, Default ) ]
///   pub struct UserProfileFormerContainer
///   {
///     age : Option< i32 >,
///     username : Option< String >,
///     bio_optional : Option< String >,
///   }
///
///   pub struct UserProfileFormer
///   <
///     FormerContext = UserProfile,
///     FormerEnd = former::ReturnContainer,
///   >
///   where
///     FormerEnd : former::ToSuperFormer< UserProfile, FormerContext >,
///   {
///     container : UserProfileFormerContainer,
///     context : Option< FormerContext >,
///     on_end : Option< FormerEnd >,
///   }
///
///   impl< FormerContext, FormerEnd > UserProfileFormer< FormerContext, FormerEnd >
///   where
///     FormerEnd : former::ToSuperFormer< UserProfile, FormerContext >,
///   {
///     #[ inline( always ) ]
///     pub fn form( mut self ) -> UserProfile
///     {
///       let age = self.container.age.take().unwrap_or_else( ||
///       {
///         default_for_field::< i32 >( "age" )
///       } );
///       let username = self.container.username.take().unwrap_or_else( ||
///       {
///         default_for_field::< String >( "username" )
///       } );
///       let bio_optional = self.container.bio_optional.take();
///       UserProfile { age, username, bio_optional }
///     }
///
///     #[ inline( always ) ]
///     pub fn perform( self ) -> UserProfile
///     {
///       self.form()
///     }
///
///      #[ inline( always ) ]
///      pub fn new() -> UserProfileFormer< UserProfile, former::ReturnContainer >
///      {
///        UserProfileFormer::< UserProfile, former::ReturnContainer >::begin( None, former::ReturnContainer )
///      }
///
///     #[ inline( always ) ]
///     pub fn begin( context : Option< FormerContext >, on_end : FormerEnd ) -> Self
///     {
///       Self
///       {
///         container : Default::default(),
///         context,
///         on_end : Some( on_end ),
///       }
///     }
///
///     #[ inline( always ) ]
///     pub fn end( mut self ) -> FormerContext
///     {
///       let on_end = self.on_end.take().unwrap();
///       let context = self.context.take();
///       let container = self.form();
///       on_end.call( container, context )
///     }
///
///     #[ inline ]
///     pub fn age< Src >( mut self, src : Src ) -> Self
///     where
///       Src : Into< i32 >,
///     {
///       self.container.age = Some( src.into() );
///       self
///     }
///
///     #[ inline ]
///     pub fn username< Src >( mut self, src : Src ) -> Self
///     where
///       Src : Into< String >,
///     {
///       self.container.username = Some( src.into() );
///       self
///     }
///
///     #[ inline ]
///     pub fn bio_optional< Src >( mut self, src : Src ) -> Self
///     where
///       Src : Into< String >,
///     {
///       self.container.bio_optional = Some( src.into() );
///       self
///     }
///   }
///
///   fn default_for_field<T: Default>(field_name: &str) -> T {
///     eprintln!("Field '{}' isn't initialized, using default value.", field_name);
///     T::default()
///   }
///
///   let profile = UserProfile::former()
///   .age( 30 )
///   .username( "JohnDoe".to_string() )
///   .bio_optional( "Software Developer".to_string() )
///   .form();
///
///   dbg!( &profile );
///   // Expected output:
///   // &profile = UserProfile {
///   //   age: 30,
///   //   username: "JohnDoe",
///   //   bio_optional: Some("Software Developer"),
///   // }
/// # }
/// ```
///
/// This generated code allows building an instance of `MyStruct` fluently, with optional customization for each field.

#[ cfg( feature = "enabled" ) ]
#[ cfg( feature = "derive_former" ) ]
#[ proc_macro_derive( Former, attributes( perform, default, setter, subformer, alias, doc ) ) ]
pub fn former( input : proc_macro::TokenStream ) -> proc_macro::TokenStream
{
  let result = derive::former::former( input );
  match result
  {
    Ok( stream ) => stream.into(),
    Err( err ) => err.to_compile_error().into(),
  }
}

///
/// Macro to implement `From` for each component (field) of a structure.
/// This macro simplifies the creation of `From` trait implementations for struct fields,
/// enabling easy conversion from a struct reference to its field types.
///
/// # Features
///
/// - Requires the `derive_component_from` feature to be enabled for use.
/// - The `ComponentFrom` derive macro can be applied to structs to automatically generate
///   `From` implementations for each field.
///
/// # Attributes
///
/// - `debug` : Optional attribute to enable debug-level output during the macro expansion process.
///
/// # Examples
///
/// Assuming the `derive_component_from` feature is enabled in your `Cargo.toml`, you can use the macro as follows :
///
/// ```rust
/// # fn main()
/// # {
/// #[ derive( former::ComponentFrom ) ]
/// struct Person
/// {
///   pub age : i32,
///   pub name : String,
/// }
///
/// let my_struct = Person { age : 10, name : "Hello".into() };
/// let age : i32 = From::from( &my_struct );
/// let name : String = From::from( &my_struct );
/// dbg!( age );
/// dbg!( name );
/// // > age = 10
/// // > name = "Hello"
/// # }
/// ```
///

// qqq : xxx : implement debug
#[ cfg( feature = "enabled" ) ]
#[ cfg( feature = "derive_component_from" ) ]
#[ proc_macro_derive( ComponentFrom, attributes( debug ) ) ]
pub fn component_from( input : proc_macro::TokenStream ) -> proc_macro::TokenStream
{
  let result = derive::component_from::component_from( input );
  match result
  {
    Ok( stream ) => stream.into(),
    Err( err ) => err.to_compile_error().into(),
  }
}

/// Derives the `SetComponent` trait for struct fields, allowing each field to be set
/// with a value that can be converted into the field's type.
///
/// This macro facilitates the automatic implementation of the `SetComponent` trait for all
/// fields within a struct, leveraging the power of Rust's type system to ensure type safety
/// and conversion logic. It is particularly useful for builder patterns or mutating instances
/// of data structures in a fluent and ergonomic manner.
///
/// # Attributes
///
/// - `debug` : An optional attribute to enable debugging of the trait derivation process.
///
/// # Conditions
///
/// - This macro is only enabled when the `derive_set_component` feature is active in your `Cargo.toml`.
///
/// # Input Code Example
///
/// Given a struct definition annotated with `#[ derive( SetComponent ) ]` :
///
/// ```rust
/// use former::SetComponent;
///
/// #[ derive( Default, PartialEq, Debug, former::SetComponent ) ]
/// struct Person
/// {
///   age : i32,
///   name : String,
/// }
///
/// let mut person : Person = Default::default();
/// person.set( 13 );
/// person.set( "John" );
/// assert_eq!( person, Person { age : 13, name : "John".to_string() } );
/// ```
///
/// # Generated Code Example
///
/// The procedural macro generates the following implementations for `Person` :
///
/// ```rust
/// use former::SetComponent;
///
/// #[ derive( Default, PartialEq, Debug ) ]
/// struct Person
/// {
///   age : i32,
///   name : String,
/// }
///
/// impl< IntoT > SetComponent< i32, IntoT > for Person
/// where
///   IntoT : Into< i32 >,
/// {
///   fn set( &mut self, component : IntoT )
///   {
///     self.age = component.into();
///   }
/// }
///
/// impl< IntoT > SetComponent< String, IntoT > for Person
/// where
///   IntoT : Into< String >,
/// {
///   fn set( &mut self, component : IntoT )
///   {
///     self.name = component.into();
///   }
/// }
///
/// let mut person : Person = Default::default();
/// person.set( 13 );
/// person.set( "John" );
/// assert_eq!( person, Person { age : 13, name : "John".to_string() } );
/// ```
/// This allows any type that can be converted into an `i32` or `String` to be set as
/// the value of the `age` or `name` fields of `Person` instances, respectively.

// qqq : xxx : implement debug
#[ cfg( feature = "enabled" ) ]
#[ cfg( feature = "derive_set_component" ) ]
#[ proc_macro_derive( SetComponent, attributes( debug ) ) ]
pub fn set_component( input : proc_macro::TokenStream ) -> proc_macro::TokenStream
{
  let result = derive::set_component::set_component( input );
  match result
  {
    Ok( stream ) => stream.into(),
    Err( err ) => err.to_compile_error().into(),
  }
}
