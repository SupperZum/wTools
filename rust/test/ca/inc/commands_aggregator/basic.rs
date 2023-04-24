use super::*;

//

tests_impls!
{
  fn simple()
  {
    let ca = CommandsAggregator::former()
    .grammar( // list of commands -> Collect all to GrammarConverter 
    [
      wca::Command::former()
      .hint( "hint" )
      .long_hint( "long_hint" )
      .phrase( "command" )
      .form(),
      wca::Command::former()
      .hint( "hint" )
      .long_hint( "long_hint" )
      .phrase( "command2" )
      .form(),
    ])
    .executor( // hashmap of routines -> ExecutorConverter
    [
      ( "command".to_owned(), Routine::new( | _ | { println!( "Command" ); Ok( () ) } ) ),
      ( "command2".to_owned(), Routine::new( | _ | { println!( "Command2" ); Ok( () ) } ) ),
    ])
    .build();

    a_id!( Ok( () ), ca.perform( ".command2 .help" ) ); // raw string -> GrammarProgram -> ExecutableProgram -> execute

    a_id!( Ok( () ), ca.perform( ".help command" ) );
    a_id!( Ok( () ), ca.perform( ".help command2" ) );
    a_id!( Ok( () ), ca.perform( ".help help" ) );

    a_id!( Ok( () ), ca.perform( ".help.command" ) );
    a_id!( Ok( () ), ca.perform( ".help.command2" ) );
    a_id!( Ok( () ), ca.perform( ".help.help" ) );

    a_true!( ca.perform( ".help.help.help" ).is_err() );
  }

  fn with_only_general_help()
  {
    let ca = CommandsAggregator::former()
    .grammar( // list of commands -> Collect all to GrammarConverter 
    [
      wca::Command::former()
      .hint( "hint" )
      .long_hint( "long_hint" )
      .phrase( "command" )
      .form(),
      wca::Command::former()
      .hint( "hint" )
      .long_hint( "long_hint" )
      .phrase( "command2" )
      .form(),
    ])
    .executor( // hashmap of routines -> ExecutorConverter
    [
      ( "command".to_owned(), Routine::new( | _ | { println!( "Command" ); Ok( () ) } ) ),
      ( "command2".to_owned(), Routine::new( | _ | { println!( "Command2" ); Ok( () ) } ) ),
    ])
    .help_variants([ HelpVariants::General ])
    .build();

    a_id!( Ok( () ), ca.perform( ".help" ) ); // raw string -> GrammarProgram -> ExecutableProgram -> execute

    a_true!( ca.perform( ".help command" ).is_err() );

    a_true!( ca.perform( ".help.command" ).is_err() );
  }

  fn custom_converters()
  {
    let grammar = GrammarConverter::former()
    .command
    (
      wca::Command::former()
      .hint( "hint" )
      .long_hint( "long_hint" )
      .phrase( "command" )
      .form()
    )
    .command
    (
      wca::Command::former()
      .hint( "hint" )
      .long_hint( "long_hint" )
      .phrase( "command2" )
      .form()
    )
    .form();

    let executor = ExecutorConverter::former()
    .routine( "command", Routine::new( | _ | { println!( "hello" ); Ok( () ) } ) )
    .form();

    let ca = CommandsAggregator::former()
    .grammar_converter( grammar )
    .executor_converter( executor )
    .build();

    a_id!( Ok( () ), ca.perform( ".command" ) );
  }

  fn custom_parser()
  {
    let parser = Parser::former()
    .command_prefix( '-' )
    .form();

    let ca = CommandsAggregator::former()
    .parser( parser )
    .grammar(
    [
      wca::Command::former()
      .hint( "hint" )
      .long_hint( "long_hint" )
      .phrase( "command" )
      .form(),
    ])
    .executor(
    [
      ( "command".to_owned(), Routine::new( | _ | { println!( "Command" ); Ok( () ) } ) ),
    ])
    .build();

    a_id!( Ok( () ), ca.perform( "-command" ) );
  }
}

//

tests_index!
{
  simple,
  with_only_general_help,
  custom_converters,
  custom_parser,
}
