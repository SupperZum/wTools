( function _Diagnostics_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( '../../Tools.s' );
  _.include( 'wTesting' );
}

var _global = _global_;
var _ = _global_.wTools;

//

function _err( test )
{

  var errObj1 = new Error( 'err obj for tesst' );
  var errMsg2 = errObj1.message;

  var errMsg1 = 'some error message',
    strName = 'Diagnostics.test.s',
    errObj2 = new Error( 'Error #3' ),
    errMsg3 = errObj2.message,
    optionsObj3 =
    {
      level : 1,
      args : [ errObj1 ]
    },

    optionsObj4 =
    {
      level : 3,
      args : [ errMsg1, errObj2 ]
    };

  /* - */

  test.case = 'single string passed as args property : result should be Error obj';
  var optionsObj2 =
  {
    level : 1,
    args : [ errMsg1 ]
  };
  var got = _._err( optionsObj2 );
  test.identical( got instanceof Error, true );

  test.case = 'single string passed as args property : result message should contains passed string';
  var expectMsg = new RegExp( errMsg1 );
  test.identical( expectMsg.test( got.message ), true );

  test.case = 'single string passed as args property : result message should contains file name';
  var expectFileName = new RegExp( strName );
  test.identical( expectFileName.test( got.message ), true );

  test.case = 'single error instance passed as args property : result should be Error obj';
  var got = _._err( optionsObj3 );
  test.identical( got instanceof Error, true );

  test.case = 'single error instance passed as args property : result message should contains passed string';
  var expectMsg = new RegExp( errMsg2 );
  test.identical( expectMsg.test( got.message ), true );

  test.case = 'single error instance passed as args property : result message should contains file name';
  test.identical( _.strHas( got.message, errObj1.location.path ), true );

  /* - */

  test.open( 'several error instances/messages passed as args property' );
  var got = _._err( optionsObj4 );
  test.identical( got instanceof Error, true );

  test.case = 'result message should contains all passed string';
  var expectMsg1 = new RegExp( errMsg3 );
  var expectMsg2 = new RegExp( errMsg1 );
  test.identical( [ expectMsg1.test( got.message ), expectMsg2.test( got.message ) ], [ true, true ] );

  test.case = 'result message should contains file name';
  var expectFileName = new RegExp( strName );
  test.identical( expectFileName.test( got.message ), true );

  test.close( 'several error instances/messages passed as args property' );

  /* - */

  var optionsObj1 =
  {
    level : 1,
    args : null
  };

  if( !Config.debug )
  return;

  test.case = 'missed argument';
  test.shouldThrowError( function( )
  {
    _._err( );
  } );

  test.case = 'extra argument';
  test.shouldThrowError( function( )
  {
    _._err( optionsObj1, optionsObj2 );
  } );

  test.case = 'options.args not array';
  test.shouldThrowError( function( )
  {
    _._err( optionsObj1 );
  } );

}

//

function err( test )
{
  var errMsg1 = 'some error message',
    strName = 'Diagnostics.test.s',
    errObj1 = new Error( 'err obj for tesst' ),
    errMsg2 = errObj1.message,
    errObj2 = new Error( 'Error #3' ),
    errMsg3 = errObj2.message;

  test.case = 'single string passed as args property : result should be Error obj';
  var got = _.err( errMsg1 );
  test.identical( got instanceof Error, true );

  test.case = 'single string passed as args property : result message should contains passed string';
  var expectMsg = new RegExp( errMsg1 );
  test.identical( expectMsg.test( got.message ), true );

  test.case = 'single string passed as args property : result message should contains file name';
  var expectFileName = new RegExp( strName );
  test.identical( expectFileName.test( got.message ), true );

  test.case = 'single error instance passed as args property : result should be Error obj';
  var got = _.err( errObj1 );
  test.identical( got instanceof Error, true );

  test.case = 'single error instance passed as args property : result message should contains passed string';
  var expectMsg = new RegExp( errMsg2 );
  test.identical( expectMsg.test( got.message ), true );

  test.case = 'single error instance passed as args property : result message should contains file name';
  test.identical( _.strHas( got.message,errObj1.location.path ), true );

  test.case = 'several error instances/messages passed as args property : result should be Error obj';
  var got = _.err( errObj2, errMsg1 );
  test.identical( got instanceof Error, true );

  test.case = 'several error instances/messages passed as args : result message should contains all ' +
    'passed string';
  var expectMsg1 = new RegExp( errMsg3 ),
    expectMsg2 = new RegExp( errMsg1 );
  test.identical( [ expectMsg1.test( got.message ), expectMsg2.test( got.message ) ], [ true, true ] );

  test.case = 'several error instances/messages passed as args property : result message should contains ' +
    'file name';
  var expectFileName = new RegExp( strName );
  test.identical( expectFileName.test( got.message ), true );

};

//

function errLog( test )
{
  var errMsg1 = 'some error message',
    strName = 'Diagnostics.test.s',
    errObj1 = new Error( 'err obj for tesst' ),
    errMsg2 = errObj1.message;


  test.case = 'single string passed as args property : result should be Error obj';
  var got = _.errLog( errMsg1 );
  test.identical( got instanceof Error, true );

  test.case = 'single string passed as args property : result message should contains passed string';
  var expectMsg = new RegExp( errMsg1 );
  test.identical( expectMsg.test( got.message ), true );

  test.case = 'single string passed as args property : result message should contains file name';
  var expectFileName = new RegExp( strName );
  test.identical( expectFileName.test( got.message ), true );

  test.case = 'single error instance passed as args property : result should be Error obj';
  var got = _.errLog( errObj1 );
  test.identical( got instanceof Error, true );

  test.case = 'single error instance passed as args property : result message should contains passed string';
  var expectMsg = new RegExp( errMsg2 );
  test.identical( expectMsg.test( got.message ), true );

  test.case = 'single error instance passed as args property : result message should contains file name';
  test.identical( _.strHas( got.message,errObj1.location.path ), true );

}

//
    
function sureMapHasOnly( test )
{    
//  test.open( 'standard input' );
//  var srcMap = { 'a' : 13, 'b' : 77, 'c' : 3, 'name' : 'Mikle' };
//  var screenMaps = { 'a' : 13, 'b' : 77, 'c' : 3, 'name' : 'Hello' };
//  var otherMap = { 'd' : 13 };
//  var msg = function(){ return srcMap.a + screenMaps.b };
//  
//  test.case = 'check sureMapHasExactly';
//  test.identical( _.sureMapHasExactly( srcMap, screenMaps, msg ), true );
//    
//  test.case = 'check sureMapOwnExactly';
//  test.identical( _.sureMapHasExactly( srcMap, screenMaps, msg ), true );
//    
//  test.case = 'check sureMapOwnExactly';
//  test.identical( _.sureMapHasOnly( srcMap, screenMaps, msg ), true );
//    
//  test.case = 'check sureMapOwnOnly';
//  test.identical( _.sureMapOwnOnly( srcMap, screenMaps, msg ), true );
//    
//  test.case = 'check sureMapHasAll';
//  test.identical( _.sureMapHasAll( srcMap, screenMaps, msg ), true );
//
//  test.case = 'check sureMapOwnAll';
//  test.identical( _.sureMapOwnAll( srcMap, screenMaps, msg ), true );
//    
//  test.case = 'check sureMapHasNone';
//  test.identical( _.sureMapHasNone( srcMap, otherMap, msg ), true );
//    
//  test.case = 'check sureMapOwnNone';
//  test.identical( _.sureMapOwnNone( srcMap, otherMap, msg ), true );
//    
//  test.case = 'check sureMapHasNoUndefine';
//  test.identical( _.sureMapHasNoUndefine( srcMap, msg ), true );
//    
//  test.close( 'standard input' );
    
  test.open( 'failure input' );
  var srcMap = { 'a' : 13, 'b' : 77, 'c' : 3, 'd' : 'Mikle' };
  var screenMaps = { 'a' : 13, 'b' : 77, 'c' : 3, 'name' : 'Hello' };
  var otherMap = { 'd' : undefined };
  var msg = function(){ return srcMap.a + screenMaps.b };    
    
  test.case = 'check error message, no msg';
    try
    {
      _.sureMapHasOnly( srcMap, screenMaps )
    }
    catch ( e )
    {
      err = e;
    }
  test.identical( err instanceof Error, true );
      console.log( err.message );
  test.identical( _.strHas( err.message, 'Object should have no fields : "d"' ), true );
    
  test.case = 'check error message, msg routine';
    try
    {
      _.sureMapHasOnly( srcMap, screenMaps, msg )
    }
    catch ( e )
    {
      err = e;
    }
  test.identical( err instanceof Error, true );
      console.log( err.message );
  test.identical( _.strHas( err.message, '90' ), true ); 
    
  test.case = 'check error message, msg string';
    try
    {
      _.sureMapHasOnly( srcMap, screenMaps, 'msg' )
    }
    catch ( e )
    {
      err = e;
    }
  test.identical( err instanceof Error, true );
      console.log( err.message );
  test.identical( _.strHas( err.message, 'msg' ), true );
    
  test.case = 'check error message, msg string';
    try
    {
      _.sureMapHasOnly( srcMap, screenMaps, 'msg', msg )
    }
    catch ( e )
    {
      err = e;
    }
  test.identical( err instanceof Error, true );
      console.log( err.message );
  test.identical( _.strHas( err.message, 'msg 90' ), true );
    
  test.case = 'check error message, msg string';
    try
    {
      _.sureMapHasOnly( srcMap, screenMaps, () => 'This is ' + 'explanation' )
    }
    catch ( e )
    {
      err = e;
    }
  test.identical( err instanceof Error, true );
      console.log( err.message );
  test.identical( _.strHas( err.message, 'This is explanation' ), true );
    
//  test.case = 'check error message sureMapOwnOnly';
//    try
//    {
//      _.sureMapOwnOnly( srcMap, screenMaps, msg )
//    }
//    catch ( e )
//    {
//      err = e;
//    }
//  test.identical( err instanceof Error, true );
//  test.identical( _.strHas( err.message, '90 "d"' ), true );
//    
//  test.case = 'check error message sureMapHasAll';
//    try
//    {
//      _.sureMapHasAll( srcMap, screenMaps, msg )
//    }
//    catch ( e )
//    {
//      err = e;
//    }
//  test.identical( err instanceof Error, true );
//  test.identical( _.strHas( err.message, '90 "name"' ), true );
//
//  test.case = 'check error message sureMapOwnAll';
//    try
//    {
//      _.sureMapOwnAll( srcMap, screenMaps, msg )
//    }
//    catch ( e )
//    {
//      err = e;
//    }
//  test.identical( err instanceof Error, true );
//  test.identical( _.strHas( err.message, '90 "name"' ), true );
//   
//  test.case = 'check error message sureMapHasNone';
//    try
//    {
//      _.sureMapHasNone( srcMap, screenMaps, msg )
//    }
//    catch ( e )
//    {
//      err = e;
//    }
//  test.identical( err instanceof Error, true );
//  test.identical( _.strHas( err.message, '90 "a", "b", "c"' ), true );
//   
//  test.case = 'check error message sureMapOwnNone';
//    try
//    {
//      _.sureMapOwnNone( srcMap, screenMaps, msg )
//    }
//    catch ( e )
//    {
//      err = e;
//    }
//  test.identical( err instanceof Error, true );
//  test.identical( _.strHas( err.message, '90 "a", "b", "c"' ), true );  
//    
//  test.case = 'check error message sureMapHasNoUndefine';
//    try
//    {
//      _.sureMapHasNoUndefine( otherMap, msg )
//    }
//    catch ( e )
//    {
//      err = e;
//    }
//  test.identical( err instanceof Error, true );
//  test.identical( _.strHas( err.message, 'Object 90 : "d"' ), true );
//    
  test.close( 'failure input' );
}

//
    
function assertSurer( test )
{    
  var srcMap = { 'a' : 13, 'b' : 77, 'c' : 3, 'd' : 'Mikle' };
  var srcMap1 = { 'a' : 13, 'b' : 77, 'c' : 3, 'd' : 'Mikle' };
  var screenMaps = { 'a' : 13, 'b' : 77, 'c' : 3, 'name' : 'Hello' };
  var otherMap = { 'd' : undefined };
  var msg = function(){ return srcMap.a + screenMaps.b };
  
  test.case = 'check error message assertMapHasFields';
    try
    {
      _.assertMapHasFields( srcMap, screenMaps, msg )
    }
    catch ( e )
    {
      err = e;
    }
  test.identical( err instanceof Error, true );
  test.identical( _.strHas( err.message, '90 "d"' ), true );  
    
  test.case = 'check error message assertMapOwnFields';
    try
    {
      _.assertMapOwnFields( srcMap, screenMaps, msg )
    }
    catch ( e )
    {
      err = e;
    }
  test.identical( err instanceof Error, true );
  test.identical( _.strHas( err.message, '90 "d"' ), true );    
    
  test.case = 'check error message assertMapHasOnly';
    try
    {
      _.assertMapHasOnly( srcMap, screenMaps, msg )
    }
    catch ( e )
    {
      err = e;
    }
  test.identical( err instanceof Error, true );
  test.identical( _.strHas( err.message, '90 "d"' ), true );
    
  test.case = 'check error message assertMapOwnOnly';
    try
    {
      _.assertMapOwnOnly( srcMap, screenMaps, msg )
    }
    catch ( e )
    {
      err = e;
    }
  test.identical( err instanceof Error, true );
  test.identical( _.strHas( err.message, '90 "d"' ), true );
    
//  test.case = 'check error message sureMapHasAll';
//    try
//    {
//      _.sureMapHasAll( srcMap, screenMaps, msg )
//    }
//    catch ( e )
//    {
//      err = e;
//    }
//  test.identical( err instanceof Error, true );
//  test.identical( _.strHas( err.message, '90 "name"' ), true );
//
//  test.case = 'check sureMapOwnAll';
//    try
//    {
//      _.sureMapOwnAll( srcMap, screenMaps, msg )
//    }
//    catch ( e )
//    {
//      err = e;
//    }
//  test.identical( err instanceof Error, true );
//  test.identical( _.strHas( err.message, '90 "name"' ), true );
   
  test.case = 'check error message assertMapHasNone';
    try
    {
      _.assertMapHasNone( srcMap, screenMaps, msg )
    }
    catch ( e )
    {
      err = e;
    }
  test.identical( err instanceof Error, true );
  test.identical( _.strHas( err.message, '90 "a", "b", "c"' ), true );
   
//  test.case = 'check sureMapOwnNone';
//    try
//    {
//      _.sureMapOwnNone( srcMap, screenMaps, msg )
//    }
//    catch ( e )
//    {
//      err = e;
//    }
//  test.identical( err instanceof Error, true );
//  test.identical( _.strHas( err.message, '90 "a", "b", "c"' ), true );  
//    
//  test.case = 'check sureMapHasNoUndefine';
//    try
//    {
//      _.sureMapHasNoUndefine( otherMap, msg )
//    }
//    catch ( e )
//    {
//      err = e;
//    }
//  test.identical( err instanceof Error, true );
//  test.identical( _.strHas( err.message, 'Object 90 : "d"' ), true );
}
    
//

function assert( test )
{
  var err;
  var msg1 = 'short error description';
  var rgMsg1 = new RegExp( msg1 );

  test.case = 'assert successful condition';
  var got = _.assert( 5 === 5 );
  test.identical( got, true );

  test.case = 'passed failure condition : should generates exception';
  try
  {
    _.assert( 5 != 5 )
  }
  catch ( e )
  {
    err = e;
  }
  test.identical( err instanceof Error, true );

  test.case = 'passed failure condition with passed message : should generates exception with message';
  try
  {
    _.assert( false, msg1 )
  }
  catch ( e )
  {
    err = e;
  }
  test.identical( rgMsg1.test( err.message ), true );
};

//

function diagnosticStack( test )
{
  function function1( )
  {
    return function2( );
  }

  function function2( )
  {
    return function3( );
  }

  function function3( )
  {
    debugger;
    return _.diagnosticStack();
  }

  /* - */

  test.case = 'trivial';
  var expectedTrace = [ 'function3', 'function2', 'function1', 'Diagnostics.test.s' ];
  var got = function1();
  got = got.split( '\n' );
  debugger;
  expectedTrace.forEach( function( expectedStr, i )
  {
    var expectedRegexp = new RegExp( expectedStr );
    test.description = expectedStr;
    test.identical( expectedRegexp.test( got[ i ] ), true );
  });
  debugger;

  /* - */

  // test.case = 'second';
  // var got = function1();
  // debugger;
  // got = got.split( '\n' ).slice( -5, -1 ).join( '\n' );
  // debugger;
  // expectedTrace.forEach( function( expectedStr, i )
  // {
  //   var expectedRegexp = new RegExp( expectedStr );
  //   test.identical( expectedRegexp.test( got[ i ] ), true );
  // });

};

//

var Self =
{

  name : 'Tools/base/l1/Diagnostics',
  silencing : 1,

  tests :
  {

    _err   : _err,
    err    : err,
    errLog : errLog,
    
    sureMapHasOnly : sureMapHasOnly,
    assertSurer : assertSurer,

    assert : assert,
    diagnosticStack  : diagnosticStack

  }

}

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

} )( );
