//#! /usr/bin/env NODE
( function _wTools_s_() {

'use strict';

/**
 * @file wTools.s - Generic purpose tools of base level for solving problems in Java Script.
 */

// global

var _global_ = undefined;

if( !_global_ && typeof Global !== 'undefined' && Global.Global === Global ) _global_ = Global;
if( !_global_ && typeof global !== 'undefined' && global.global === global ) _global_ = global;
if( !_global_ && typeof window !== 'undefined' && window.window === window ) _global_ = window;
if( !_global_ && typeof self   !== 'undefined' && self.self === self ) _global_ = self;

// name

if( _global_.wBase )
throw new Error( 'wTools included several times' );

_global_[ '_global_' ] = _global_;
_global_._global_ = _global_;

_global_.DEBUG = true;

// parent

if( typeof module !== 'undefined' && module !== null )
{
  if( !_global_.Underscore )
  _global_.Underscore = require( 'underscore' );
}

if( typeof wTools === 'undefined' )
{
  if( _global_.Underscore !== undefined ) _global_.wTools = Object.create( _global_.Underscore );
  else if( _global_._ !== undefined ) _global_.wTools = Object.create( _global_._ );
  else _global_.wTools = Object.create( null );
}

//

/**
 * wTools - Generic purpose tools of base level for solving problems in Java Script.
 * @class wTools
 */

var Self = wTools;
var _ = wTools;

var _ArraySlice = Array.prototype.slice;
var _FunctionBind = Function.prototype.bind;
var _ObjectToString = Object.prototype.toString;
var _ObjectHasOwnProperty = Object.hasOwnProperty;

// --
// init
// --

var _initConfig = function _initConfig()
{

  /* config */

  if( !_global_.Config )
  {
    _global_.Config = {};
  }

  if( _global_.Config.debug === undefined )
  _global_.Config.debug = true;

  Object.defineProperty( _global_, 'Config',
  {
    value : _global_.Config,
    enumerable : true,
    writable : false,
  });

  Object.defineProperty( _global_.Config, 'debug',
  {
    value : !!_global_.Config.debug,
    enumerable : true,
    writable : false,
  });

  Object.defineProperty( _global_, 'DEBUG',
  {
    value : _global_.Config.debug,
    enumerable : true,
    writable : false,
  });

}

// --
// entity modifier
// --

var enityExtend = function( dst,src )
{

  if( _.strIs( src ) )
  {

    dst = src;

  }
  else if( _.objectIs( src ) || _.hasLength( src ) )
  {

    _.each( src,function( e,k,i ){
      dst[ k ] = e;
    });

  }
  else
  {

    dst = src;

  }

  return dst;
}

//

var entityClone = function( src,options )
{
  var result;

  //throw 'not stable';

  if( options !== undefined && !_.objectIs( options ) )
  throw _.err( 'wTools.entityClone :','need options' );

  var options = options || {};

  if( options.forWorker === undefined ) options.forWorker = 0;

  if( options.depth === undefined ) options.depth = 16;

  if( options.useClone === undefined ) options.useClone = 1;

  if( options.depth < 0 )
  {
    if( options.silent ) console.log( 'wTools.entityClone : overflow' );
    else throw _.err( 'wTools.entityClone :','overflow' );
  }

  _assert( !options.forWorker,'forWorker is deprecated' );

  //

  if( !src ) return src;

  if( options.useClone && _.routineIs( src.clone ) )
  {
    result = src.clone();
  }
  else if( arrayIs( src ) )
  {

    result = [];
    src.forEach(function( child, index, array ) {
      result[index] = entityClone( child,options );
    });

  }
  else if( _.objectIs( src ) )
  {

    result = {};
    var proto = Object.getPrototypeOf( src );
    var result = Object.create( proto );
    for( var s in src )
    {
      if( !_ObjectHasOwnProperty.call( src,s ) )
      continue; // xxx
      var c = entityClone( src[ s ],{
        depth : options.depth-1,
        silent :options.silent,
        forWorker : options.forWorker,
      });
      result[s] = c;
    }

  }
  else if( src.constructor )
  {

    if( options.forWorker )
    {
      var good = _.strIs( src ) || _.numberIs( src ) || _.dateIs( src ) || _.boolIs( src ) || _.regexpIs( src ) || _.bufferIs( src );
      if( good )
      {
        return src;
      }
      else
      {
        return;
      }
    }
    else
    {
      if( _.strIs( src ) || _.numberIs( src ) || _.dateIs( src ) || _.boolIs( src ) || _.regexpIs( src ) )
      result = src.constructor( src );
      else if( _.routineIs( src ) )
      result = src;
      else
      result = new src.constructor( src );
    }

  }
  else
  {

    result = src;

  }

  return result;
}

//

var _entityCloneAct = function( o )
{

  var result;
  var o = o || {};

  if( !( o.levels > 0 ) )
  throw _.err
  (
    'failed to clone structure',_.strTypeOf( o.rootSrc ) +
    '\nat ' + o.path +
    '\ntoo deep structure' +
    '\no : ' + _.toStr( o ) +
    '\no.rootSrc : ' + _.toStr( o.rootSrc )
  );

  o.levels -= 1;

  /* routine */

  if( _.routineIs( o.src ) )
  {
    if( o.onRoutine )
    return o.onRoutine( o.src );
    return o.src;
  }

  /* string */

  if( _.strIs( o.src ) )
  {
    if( o.onString )
    return o.onString( o.src );
    return o.src;
  }

  /* atomic */

  if( _.atomicIs( o.src ) )
  {
    return o.src;
  }

  /* class instance */

  if( o.technique === 'data' )
  {
    if( o.src.cloneData )
    {
      return o.src.cloneData( o );
    }
  }
  else if( o.technique === 'object' )
  {
    if( o.src.cloneObject )
    {
      return o.src.cloneObject( o );
    }
  }
  else
  {
    //debugger;
    throw _.err( 'unexpected clone technique : ' + o.technique );
  }

  /* map */

  if( _.objectIs( o.src ) )
  {

    var mapIs = _.mapIs( o.src );

    if( !mapIs )
    if( o.src.constructor !== Object && o.src.constructor !== null )
    {
      //debugger;
      throw _.err
      (
        'Complex objets should have ' +
        ( o.technique === 'data' ? 'cloneData' : 'cloneObject' ) +
        ', but object ' + _.strTypeOf( o.src ) + ' \n' +
        'at ' + ( o.path || '.' ) + '\ndoes not have ',o.src
      );
    }

    if( o.dst )
    result = o.dst;
    else if( o.proto )
    result = new o.proto();
    else
    result = new o.src.constructor();

    for( var s in o.src )
    {

      if( !mapIs )
      if( !Object.hasOwnProperty.call( o.src,s ) )
      continue;

      var elementOptions = _.mapExtend( {},o );
      elementOptions.src = o.src[ s ];
      elementOptions.path += '.' + s;
      delete elementOptions.dst;
      delete elementOptions.proto;
      result[ s ] = _entityCloneAct( elementOptions );
    }

    return result;
  }

  /* array like */

  if( _.arrayLike( o.src ) )
  {

    if( _.bufferIs( o.src ) )
    {

      if( o.copyBuffers )
      {
        debugger;
        result = new o.src.constructor( o.src );
      }
      else
      {
        result = o.src;
      }

      if( o.onBuffer )
      {
        result = o.onBuffer.call( o,result );
      }

      return result;
    }


    /**/

    if( o.dst )
    result = o.dst;
    else if( o.proto )
    result = new o.proto( o.src.length );
    else
    result = _.arrayNewOfSameLength( o.src );

    /**/

    if( _.bufferRawIs( o.src ) )
    throw _.err( 'not implemented' );

    for( var s = 0 ; s < o.src.length ; s++ )
    {
      var elementOptions = _.mapExtend( {},o );
      elementOptions.src = o.src[ s ];
      elementOptions.path += '.' + s;
      delete elementOptions.dst;
      delete elementOptions.proto;
      result[ s ] = _entityCloneAct( elementOptions );
    }

    return result;
  }

  throw _.err( 'unexpected type of src : ' + _.strTypeOf( o.src ) );
}

//

var _entityClone = function( o )
{

  if( o.rootSrc === undefined )
  o.rootSrc = o.src;

  _.assertMapOnly( o,_entityClone.defaults );
  _.mapComplement( o,_entityClone.defaults );

  return _entityCloneAct( o );
}

_entityClone.defaults =
{

  src : null,
  rootSrc : null,
  key : null,

  dst : null,
  proto : null,

  copyComposes : true,
  copyAggregates : true,
  copyAssociates : true,
  copyRestricts : false,
  copyBuffers : false,

  levels : 16,
  path : '',
  technique : null,

  onString : null,
  onRoutine : null,
  onBuffer : null,

}

//

var entityCloneObject = function( o )
{

  if( o.rootSrc === undefined )
  o.rootSrc = o.src;

  _.assertMapOnly( o,entityCloneObject.defaults );
  _.mapSupplement( o,entityCloneObject.defaults );

  var result = _entityClone( o );

  return result;
}

entityCloneObject.defaults =
{
  copyAssociates : true,
  technique : 'object',
}

entityCloneObject.defaults.__proto__ = _entityClone.defaults;

//

var entityCloneObjectMergingBuffers = function entityCloneObjectMergingBuffers( o )
{
  var result = {};
  var src = o.src;
  var descriptorsMap = o.src.descriptorsMap;
  var buffer = o.src.buffer;
  var data = o.src.data;

  if( o.rootSrc === undefined )
  o.rootSrc = o.src;

  _.assertMapOnly( o,entityCloneObjectMergingBuffers.defaults );
  _.mapSupplement( o,entityCloneObjectMergingBuffers.defaults );

  _.assert( _.objectIs( o.src.descriptorsMap ) );
  _.assert( _.bufferRawIs( o.src.buffer ) );
  _.assert( o.src.data !== undefined );

  /**/

  var optionsCloneObject = _.mapScreen( _.entityCloneObject.defaults,o );
  optionsCloneObject.src = data;

  /* onString */

  optionsCloneObject.onString = function onString( strString )
  {

    var id = _.strUnjoin( strString,[ '--buffer-->',_.strUnjoin.any,'<--buffer--' ] )

    if( id === undefined )
    return strString;

    var descriptor = o.src.descriptorsMap[ strString ];
    _.assert( descriptor !== undefined );

    var bufferConstructor = _global_[ descriptor[ 'bufferConstructorName' ] ];
    var offset = descriptor[ 'offset' ];
    var size = descriptor[ 'size' ];
    var sizeOfAtom = descriptor[ 'sizeOfAtom' ];
    var result = bufferConstructor ? new bufferConstructor( buffer,offset,size / sizeOfAtom ) : null;

    return result;
  }

  /* clone object */

  var result = _.entityCloneObject( optionsCloneObject );

  // xxx

  return result;
}

entityCloneObjectMergingBuffers.defaults =
{
  copyBuffers : false,
}

entityCloneObjectMergingBuffers.defaults.__proto__ = entityCloneObject.defaults;

//

var entityCloneData = function( o )
{

  if( o.rootSrc === undefined )
  o.rootSrc = o.src;

  _.assertMapOnly( o,entityCloneData.defaults );
  _.mapSupplement( o,entityCloneData.defaults );

  var result = _entityClone( o );

  return result;
}

entityCloneData.defaults =
{
  technique : 'data',
  copyAssociates : false,
}

entityCloneData.defaults.__proto__ = _entityClone.defaults;

//

var entityCloneDataSeparatingBuffers = function entityCloneDataSeparatingBuffers( o )
{
  var result = {};
  var buffers = [];
  var descriptorsArray = [];
  var descriptorsMap = {};
  var size = 0;
  var offset = 0;

  if( o.rootSrc === undefined )
  o.rootSrc = o.src;

  _.assertMapOnly( o,entityCloneDataSeparatingBuffers.defaults );
  _.mapSupplement( o,entityCloneDataSeparatingBuffers.defaults );

  /* onBuffer */

  o.onBuffer = function onBuffer( srcBuffer )
  {

    _.assert( _.bufferIs( srcBuffer ),'not tested' );

    var index = buffers.length;
    var id = _.strJoin( '--buffer-->',index,'<--buffer--' );
    var bufferSize = srcBuffer ? srcBuffer.length*srcBuffer.BYTES_PER_ELEMENT : 0;
    size += bufferSize;

    var descriptor =
    {
      'bufferConstructorName' : srcBuffer ? srcBuffer.constructor.name : 'null',
      'sizeOfAtom' : srcBuffer ? srcBuffer.BYTES_PER_ELEMENT : 0,
      'offset' : -1,
      'size' : bufferSize,
      'index' : index,
      //'id' : id,
    }

    buffers.push( srcBuffer );
    descriptorsArray.push( descriptor );
    descriptorsMap[ id ] = descriptor;

    return id;
  }

  /* clone data */

  result.data = _entityCloneAct( o );
  result.descriptorsMap = descriptorsMap;

  /* sort by atom size */

  descriptorsArray.sort( function( a,b )
  {
    return b[ 'sizeOfAtom' ] - a[ 'sizeOfAtom' ];
  });

  /* alloc */

  result.buffer = new ArrayBuffer( size );
  var dstBuffer = _.bufferBytesGet( result.buffer );

  /* copy buffers */

  for( var b = 0 ; b < descriptorsArray.length ; b++ )
  {

    var descriptor = descriptorsArray[ b ];
    var buffer = buffers[ descriptor.index ];
    var bytes = buffer ? _.bufferBytesGet( buffer ) : new Uint8Array();
    var bufferSize = descriptor[ 'size' ];

    descriptor[ 'offset' ] = offset;

    _.bufferMove( dstBuffer.subarray( offset,offset+bufferSize ),bytes );

    offset += bufferSize;

  }

  /**/ // xxx

  return result;
}

entityCloneDataSeparatingBuffers.defaults =
{
  copyBuffers : false,
}

entityCloneDataSeparatingBuffers.defaults.__proto__ = entityCloneData.defaults;

//

var entityCopy = function( dst,src,onRecursive )
{
  var result;

  _.assert( arguments.length === 2 || arguments.length === 3 );
  _.assert( arguments.length < 3 || _.routineIs( onRecursive ) );

  if( src === null )
  {

    result = src;

  }
  else if( dst && _.routineIs( dst.copy ) )
  {

    dst.copy( src );

  }
  else if( src && _.routineIs( src.clone ) )
  {

    if( dst instanceof src.constructor )
    {
      throw _.err( 'not tested' );
      result = src.clone( dst );
    }
    else if( _.atomicIs( dst ) || _.arrayLike( dst ) )
    {
      result = src.clone();
    }
    else throw _.err( 'unexpected' );

  }
  else if( src && _.routineIs( src.slice ) )
  {

    result = src.slice( 0 );

  }
  else if( dst && _.routineIs( dst.set ) )
  {

    dst.set( src );

  }
  else if( _.objectIs( src ) )
  {

    if( onRecursive )
    result = _.mapClone( src,{ onCopyField : onRecursive, dst : _.atomicIs( dst ) ? {} : dst } );
    else
    result = _.mapClone( src );

  }
  else
  {

    result = src;

  }

  return result;
}

//

var entityCopyField = function( dstContainer,srcContainer,name,onRecursive )
{
  var result;
  var name = _.nameUnfielded( name ).coded;

  _.assert( arguments.length === 3 || arguments.length === 4 );

  if( onRecursive )
  result = entityCopy( dstContainer[ name ],srcContainer[ name ],onRecursive );
  else
  result = entityCopy( dstContainer[ name ],srcContainer[ name ] );

  if( result !== undefined )
  dstContainer[ name ] = result;

  return result;
}

//

var entityAssignField = function( dstContainer,srcValue,name,onRecursive )
{
  var result;
  var name = _.nameUnfielded( name ).coded;

  _.assert( arguments.length === 3 || arguments.length === 4 );

  if( onRecursive )
  {
    throw _.err( 'not tested' );
    result = entityCopy( dstContainer[ name ],srcValue,onRecursive );
  }
  else
  result = entityCopy( dstContainer[ name ],srcValue );

  if( result !== undefined )
  dstContainer[ name ] = result;

  return result;
}

//

var entityCoerceTo = function( src,ins )
{

  _.assert( arguments.length === 2 );

  if( _.numberIs( ins ) )
  {

    return _.numberFrom( src );

  }
  else if( _.strIs( ins ) )
  {

    return _.strFrom( src );

  }
  else if( _.boolIs( ins ) )
  {

    return _.boolFrom( src );

  }
  else throw _.err( 'unknown type to coerce to : ' + _.strTypeOf( ins ) );

}

//

var entityWrap = function( o )
{
  var result = o.dst;

  _.routineOptions( entityWrap,o );
  _.assert( arguments.length === 1 );

  if( o.onCondition )
  o.onCondition = _entityConditionMake( o.onCondition );

  /* */

  var handleDown = function( e,k,i )
  {

    //debugger;
    //if( o.condition )

    if( o.onCondition )
    if( !o.onCondition.call( this,e,k,i ) )
    return

    if( o.onWrap )
    {
      var newElement = o.onWrap.call( this,e,k,i );

      if( newElement !== e )
      {
        if( e === result )
        result = newElement;
        if( this.down && this.down.src )
        this.down.src[ k ] = newElement;
      }

    }
    else
    {

      var newElement = { _ : e };
      if( e === result )
      result = newElement;
      else
      this.down.src[ k ] = newElement;

    }

  }

  /* */

  _.eachRecursive
  ({
    src : o.dst,
    own : o.own,
    levels : o.levels,
    onDown : handleDown,
  });

  return result;
}

entityWrap.defaults =
{

  onCondition : null,
  onWrap : null,
  dst : null,
  own : 1,
  levels : 256,

}

// --
// entity checker
// --

var entityHasNan = function( src )
{

  var result = false;
  if( src === undefined )
  {
    return true;
  }
  else if( _.numberIs( src ) )
  {
    return isNaN( src );
  }
  else if( _.arrayIs( src ) )
  {
    for( var s = 0 ; s < src.length ; s++ )
    if( _.numberHasNan( src[s] ) )
    {
      return true;
    }
  }
  else if( _.objectIs( src ) )
  {
    for( s in src )
    if( _.numberHasNan( src[s] ) )
    {
      return true;
    }
  }

  return result;
}

//

var entityHasUndef = function( src )
{

  var result = false;
  if( src === undefined )
  {
    return true;
  }
  else if( _.arrayIs( src ) )
  {
    for( var s = 0 ; s < src.length ; s++ )
    if( _.hasUndef( src[s] ) )
    {
      return true;
    }
  }
  else if( _.objectIs( src ) )
  {
    for( s in src )
    if( _.hasUndef( src[s] ) )
    {
      return true;
    }
  }
  return result;

}

//

  /**
   * Compare two values. For objects, arrays, array like objects, comparison will be recursive. Comparison criteria set
      in the `options`. If in some moment method finds different values in two entities, then it returns false.
   * @param {*} src1 entity for comparison
   * @param {*} src2 entity for comparison
   * @param {Object} options Comparison criteria
   * @param {Function} options.onSameNumbers Function that uses for comparison two numbers. If function returned true,
      the passed numbers is considered equal.
   * @param {boolean} options.contain If this parameter sets to true, two entities will be considered the same,
      if all keys/indexes of `src2`, are in `src1` with same values. Has no effect on comparison entities with primitive
      types. If `options.contain` set to false, `src1` and `src2` will be considered the same, if and only if they has
      the same lengths, same keys/indexes and same appropriates values.
   * @param {boolean} options.strict Specify equality comparison. When it set to true, then the Strict equality
      using (===), else the Loose equality using (==).
   * @param {String} options.lastPath This parameters is modified during the execution of method. Specified on path to
      value, that composite from keys/indexes separated by '.'
   * @param {String} path For non primitive entities indicates the current path for elements that is compared now.
   * @returns {boolean} result - true for same entities.
   * @private
   * @method _entitySame
   * @memberof wTools
   */

var _entitySame = function _entitySame( src1,src2,o )
{

  var path = o.path;
  o.lastPath = path;

  _.assert( arguments.length === 3 );

  if( o.strict )
  {
    if( _ObjectToString.call( src1 ) !== _ObjectToString.call( src2 ) )
    return false;
  }
  else
  {
    if( _ObjectToString.call( src1 ) !== _ObjectToString.call( src2 ) && src1 != src2 )
    return false;
  }

  /**/

  if( _.arrayLike( src1 ) )
  {
    if( !src2 )
    return false;
    if( src1.constructor !== src2.constructor )
    return false;
    if( !o.contain )
    if( src1.length !== src2.length )
    return false;
    for( var k = 0 ; k < src2.length ; k++ )
    {
      o.path = path + '.' + k;
      if( !_entitySame( src1[ k ], src2[ k ], o ) )
      return false;
      o.path = path;
    }
  }
  else if( _.objectLike( src1 ) )
  {

    if( _.routineIs( src1.isSame ) )
    {
      _.assert( src1.isSame.length === 3 );
      if( !src1.isSame( src1,src2,o ) )
      return false;
    }
    else
    {

      if( !o.contain )
      if( _.entityLength( src1 ) !== _.entityLength( src2 ) )
      return false;
      for( var k in src2 )
      {
        o.path = path + '.' + k;
        if( !_entitySame( src1[ k ], src2[ k ], o ) )
        return false;
        o.path = path;
      }

    }
  }
  else if( _.numberIs( src1 ) )
  {
    return o.onSameNumbers( src1,src2 );
  }
  else
  {
    if( o.strict )
    {
      if( src1 !== src2 )
      return false;
    }
    else
    {
      if( src1 != src2 )
      return false;
    }
  }

  return true;
}

//

/**
 * Deep equaliser of 2 entities.
 * @param {object} src1 - entity to compare.
 * @param {object} src2 - entity to compare.
 * @param {object} options - options.
 * @method entitySame
 * @memberof wTools
 */

var entitySame = function entitySame()
{

  var sameNumbers = function( a,b )
  {
    return a === b;
  }

  var def =
  {
    onSameNumbers : sameNumbers,
    contain : 0,
    strict : 1,
    lastPath : '',
    path : '',
  }

  Object.freeze( def );

  return function entitySame( src1,src2,o )
  {

    _assert( arguments.length === 2 || arguments.length === 3 );
    _assert( o === undefined || _.objectIs( o ), '_.toStrFine :','options must be object' );
    var o = o || {};

    _.assertMapOnly( o,def );
    _.mapSupplement( o,def );

    return _entitySame( src1,src2,o );
  }

}();

//

/**
 * Deep equaliser of 2 entities.
 * Return string refering first found difference or false if entities are sames.
 * @param {object} src1 - entity to compare.
 * @param {object} src2 - entity to compare.
 * @param {object} o - options.
 * @method entityDiff
 * @memberof wTools
 */

var entityDiff = function entityDiff( src1,src2,o )
{

  var o = o || {};
  _assert( arguments.length === 2 || arguments.length === 3 );
  var same = _.entitySame( src1,src2,o );

  if( same )
  return false;

  var result = '';

  if( !_.atomicIs( src1 ) )
  src1 = _.toStr( _.entitySelect( src1,o.path ) );

  if( !_.atomicIs( src2 ) )
  src2 = _.toStr( _.entitySelect( src2,o.path ) );

  result += _.str
  (
    'at : ' + o.path +
    '\nsrc1 :\n' + src1 +
    '\nsrc2 :\n' + src2
  );

  if( _.strIs( src1 ) && _.strIs( src2 ) )
  result += ( '\ndifference :\n' + _.strDifference( src1,src2 ) );

  return result;
}

//

/**
 * Deep strict equaliser of 2 entities.
 * @example
    var obj1 = { a: 0, b: 1, e: { c: 2, d: 3 } },
    obj2 = { a: 0, b: 1, e: { c: 2, d: 3 } };

    wTools.entityIdentical( obj1, obj2 );

    // returns true
 * @param {object} src1 - entity to compare.
 * @param {object} src2 - entity to compare.
 * @param {object} options - options.
 * @throws {Error} Missed arguments.
 * @throws {Error} Extra arguments.
 * @method entityIdentical
 * @memberof wTools
 */

var entityIdentical = function entityIdentical( src1,src2,options )
{

  _.assert( arguments.length === 2 || arguments.length === 3 );

  var options = _.mapSupplement( options || {},
  {
    strict : 1,
  });

  return _.entitySame( src1,src2,options );
}

//

/**
 * Deep soft equaliser of 2 entities.
 * @example
   var eps = 1e-5,
   x = 1,
   y = 1 + eps / 2

   wTools.entityEquivalent( x, y );
   // true
 * @param {object} src1 - entity to compare.
 * @param {object} src2 - entity to compare.
 * @param {object} options - options.
 * @throws {Error} Missed arguments.
 * @throws {Error} Extra arguments.
 * @method entityEquivalent
 * @memberof wTools
 */

var entityEquivalent = function entityEquivalent( src1,src2,options )
{
  var EPS = options.eps;
  if( EPS === undefined )
  EPS = 1e-5;
  delete options.eps;

  _.assert( arguments.length === 2 || arguments.length === 3 );

  var _sameNumbers = function( a,b )
  {
    if( a === b )
    return true;
    if( isNaN( a ) === true && isNaN( b ) === true )
    return true;
    return Math.abs( a-b ) <= EPS;
  }

  var options = _.mapSupplement( options || {},
  {
    strict : 0,
    onSameNumbers : _sameNumbers,
  });

  return _.entitySame( src1,src2,options );
}

//

/**
 * Deep contain equaliser of 2 entities.
 * @example
   var arr1 = [ 0, 1, 2, 3, 9 ],
   arr2 = [ 0, 1, 2 ];
   wTools.entityContain( arr1, arr2 );
   // true
 * @param {object} src1 - entity to compare.
 * @param {object} src2 - entity to compare.
 * @param {object} options - options.
 * @throws {Error} Missed arguments.
 * @throws {Error} Extra arguments.
 * @method entityContain
 * @memberof wTools
 */

var entityContain = function entityContain( src1,src2,options )
{

  _.assert( arguments.length === 2 || arguments.length === 3 );

  var options = _.mapSupplement( options || {},
  {
    strict : 1,
    contain : 1,
  });

  return _.entitySame( src1,src2,options );
}

// --
// entity selector
// --

  /**
   * On depend form `src` type, returns length if `src` is array ar array like object, count of own enumerable
      properties if `src` is object, 0 if `src` is undefined, 1 in all other cases.
   * @example
   *
     var obj =
     {
       a: 1,
       b: { e: 2, c: 3 }
     };
     wTools.entityLength(obj); // 2
   * @param {*} src Input entity
   * @returns {number} Length of entity.
   */

var entityLength = function( src )
{
  if( src === undefined ) return 0;
  if( _.arrayLike( src ) )
  return src.length;
  else if( _.objectLike( src ) )
  return _.mapOwnKeys( src ).length;
  else return 1;
}

//

var entityWithKeyRecursive = function( src,key,onEach )
{
  var i = 0;

  debugger;
  throw _.err( 'deprecated' );

  if( key in src )
  {
    if( onEach )
    onEach.call( src,src[ key ],key,i );
    return src[ key ];
  }

  _.eachRecursive( src,function( e,k,i )
  {

    if( k === key )
    {
      if( onEach ) onEach( e,k,i );
      return { value : src[ key ], key : key, index : i, container : src };
    }

  });
}

//

var entityValueWithIndex = function( src,index )
{

  if( _.arrayIs( src ) )
  {
    return src[ index ];
  }
  else if( _.objectIs( src ) )
  {
    var i = 0;
    for( var s in src )
    {
      if( i === index ) return src[ s ];
      i++;
    }
  }
  else if( _.strIs( src ) )
  {
    return src[ index ];
  }

}

//

var entityKeyWithValue = function( src,value )
{

  var result = null;

  if( _.arrayIs( src ) )
  {
    result = src.indexOf( value );
  }
  else if( _.objectIs( src ) )
  {
    var i = 0;
    for( var s in src )
    {
      if( src[ s ] == value ) return s;
    }
  }
  else if( _.strIs( src ) )
  {
    result = src.indexOf( value );
  }

  if( result === -1 ) result = null;
  return result;
}

//

var entitySelectUnique = function( o )
{

  o = _entitySelectOptions( arguments[ 0 ],arguments[ 1 ] );

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( _.arrayCount( o.qarrey,'*' ) <= 1,'not implemented' );
  debugger;

  var result = _entitySelect( o );

  if( o.qarrey.indexOf( '*' ) !== -1 )
  if( _.arrayLike( result ) )
  result = _.arrayUnique( result );

  return result;
}

//

var entitySelect = function( o )
{

  o = _entitySelectOptions( arguments[ 0 ],arguments[ 1 ] );

  _.assert( arguments.length === 1 || arguments.length === 2 );

  var result = _entitySelect( o );

  return result;
}

//

var entitySelectSet = function( container,query,value )
{

  _.assert( arguments.length === 1 || arguments.length === 3 );

  if( arguments.length === 3 )
  {
    var o = _entitySelectOptions( arguments[ 0 ],arguments[ 1 ] );
    o.set = value;
  }
  else
  {
    var o = _entitySelectOptions( arguments[ 0 ] );
    _.assert( _.mapOwn( o,{ set : 'set' } ) );
  }

  var result = _entitySelect( o );

  return result;
}

//

var _entitySelectOptions = function( o )
{

  if( arguments.length === 2 && arguments[ 1 ] !== undefined )
  {
    var o = {};
    o.container = arguments[ 0 ];
    o.query = arguments[ 1 ];
  }

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.routineOptions( _entitySelectOptions,o );
  _.assert( _.strIs( o.query ) || _.arrayIs( o.query ) );

  /* makeQarrey */

  var makeQarrey = function( query )
  {

    var qarrey = _.strSplit
    ({
      src : query,
      splitter : o.delimeter,
      strip : 1,
    });

    if( qarrey[ 0 ] === '' )
    qarrey.splice( 0,1 );

    return qarrey;
  }

  /**/

  if( _.arrayIs( o.query ) )
  {
    o.qarrey = [];
    for( var i = 0 ; i < o.query.length ; i++ )
    o.qarrey[ i ] = makeQarrey( o.query[ i ] );
  }
  else
  {
    o.qarrey = makeQarrey( o.query );
  }

  return o;
}

_entitySelectOptions.defaults =
{
  container : null,
  query : null,
  delimeter : [ '.','[',']' ],
  undefinedForNone : 1,
}

//

var _entitySelect = function _entitySelect( o )
{
  var result;

  if( _.arrayIs( o.query ) )
  {
    result = {};
    for( var i = 0 ; i < o.query.length ; i++ )
    {
      var selectOptions = _.mapExtend( {},o );
      selectOptions.query = o.query[ i ];
      selectOptions.qarrey = o.qarrey[ i ];
      result[ selectOptions.query ] = __entitySelectAct( selectOptions );
    }
  }
  else
  {
    result = __entitySelectAct( o );
  }

  return result;
}

//

var __entitySelectAct = function __entitySelectAct( o )
{

  var hasSet = !!o.set;
  var result;
  var container = o.container;

  var name = o.qarrey[ 0 ];
  var name2 = o.qarrey[ 1 ];

  if( !o.qarrey.length )
  return container;

  if( _.atomicIs( container ) )
  {
    if( o.undefinedForNone )
    return undefined;
    else
    throw _.err( 'cant select',o.qarrey.join( '.' ),'from atomic',_.strTypeOf( container ) );
  }

  var o = _.mapExtend( {},o );
  o.qarrey = o.qarrey.slice( 1 );

  if( hasSet )
  o.set = o.set;

  //

  var _select = function( name )
  {

    if( !o.qarrey.length && hasSet )
    container[ name ] = o.set;

    var field = container[ name ];

    if( field === undefined && hasSet )
    {
      if( !isNaN( name2 ) )
      {
        container[ name ] = field = [];
      }
      else
      {
        container[ name ] = field = {};
      }
    }

    var selectOptions = _.mapExtend( {},o );
    selectOptions.container = field;
    return __entitySelectAct( selectOptions );
  }

  //

  if( name === '*' )
  {

    result = new container.constructor();
    _.each( container,function( e,name,c )
    {
      result[ name ] = _select( name );
    });

  }
  else
  {
    result = _select( name );
  }

  return result;
}

//

var _entityConditionMake = function( condition )
{
  var result;

  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( condition ) || _.objectIs( condition ) );

  if( _.objectIs( condition ) )
  {
    var template = condition;
    condition = function( e )
    {
      if( !_.objectLike( e ) )
      return;
      if( _.mapSatisfy( template,e ) )
      return e;
    };
  }

  return condition;
}

//

  /**
   * Function that produces an elements for entityMap result
   * @callback wTools~onEach
   * @param {*} val The current element being processed in the entity.
   * @param {string|number} key The index (if entity is array) or key of processed element.
   * @param {Array|Object} src The src passed to entityMap
   */

  /**
   * Creates new instance with same as `src` type. Elements of new instance results of calling a provided `onEach`
   * function on every element of src. If entity is array, the new array has the same length as source.
   *
   * @example
    var numbers = [ 3, 4, 6 ];

    function sqr( v )
    {
      return v * v
    };

    var res = wTools.entityMap(numbers, sqr);
    // [ 9, 16, 36 ]
    // numbers is still [ 3, 4, 6 ]

    function checkSidesOfTriangle( v, i, src )
    {
      var sumOthers = 0,
        l = src.length,
        j;

      for ( j = 0; j < l; j++ )
      {
        if ( i === j ) continue;
        sumOthers += src[ j ];
      }
      return v < sumOthers;
    }

    var res = wTools.entityMap( numbers, checkSidesOfTriangle );
   // [ true, true, true ]
   *
   * @param {ArrayLike|ObjectLike} src Entity, on each elements of which will be called `onEach` function.
   * @param {wTools~onEach} onEach Function that produces an element of the new entity;
   * @returns {ArrayLike|ObjectLike} New entity.
   * @thorws {Error} If number of arguments less or more than 2;
   * @thorws {Error} If `src` is not Array or ObjectLike;
   * @thorws {Error} If `onEach` is not function;
   * @method entityMap
   * @memberof wTools
   */

var entityMap = function( src,onEach )
{

  _.assert( arguments.length === 2 );
  _.assert( _.objectLike( src ) || _.arrayLike( src ) );
  _.assert( _.routineIs( onEach ) );

  var result;

  if( _.arrayLike( src ) )
  {
    result = _.arrayNewOfSameLength( src );
    for( var s = 0 ; s < src.length ; s++ )
    result[ s ] = onEach( src[ s ],s,src );
  }
  else
  {
    result = new src.constructor()
    for( var s in src )
    result[ s ] = onEach( src[ s ],s,src );
  }

  return result;
}

//

  /**
   * Creates new instance with same as `src` type. Elements of new instance results of calling a provided `onEach`
   * function on every element of src. If `onEach` returns undefined, then this result is not included into the new
   * entity.
   * @see wTools.entityMap
   *
   * @example
     var numbers = [ 36, -25, 49, 64, -16 ];

     function sqrt( v )
     {
        return ( v > 0 ) ? Math.sqrt( v ) : undefined;
     };

     var res = wTools.entityMap( numbers, sqr );
   // [ 6, 7, 8 ]
   // numbers is still [ 36, -25, 49, 64, -16 ];
   *
   * @param {ArrayLike|ObjectLike} src Entity, on each elements of which will be called `onEach` function.
   * @param {wTools~onEach} onEach Function that produces an element of the new entity;
   * @returns {ArrayLike|ObjectLike} New entity.
   * @thorws {Error} If number of arguments less or more than 2;
   * @thorws {Error} If `src` is not Array or ObjectLike;
   * @thorws {Error} If `onEach` is not function;
   * @method entityFilter
   * @memberof wTools
   */

var entityFilter = function( src,onEach )
{

  var result;
  var onEach = _entityConditionMake( onEach );

  _.assert( arguments.length === 2 );
  _.assert( _.objectLike( src ) || _.arrayLike( src ),'entityFilter : expects objectLike or arrayLike src, but got',_.strTypeOf( src ) );
  _.assert( _.routineIs( onEach ) || _.objectIs( onEach ) );

  /**/

  if( _.arrayLike( src ) )
  {
    result = _.arrayNew( src,0 );
    for( var s = 0, d = 0 ; s < src.length ; s++, d++ )
    {
      var r = onEach( src[ s ],s,src );
      if( r === undefined )
      d--;
      else
      result[ d ] = r;
    }
  }
  else
  {
    result = new src.constructor()
    for( var s in src )
    {
      r = onEach( src[ s ],s,src );
      if( r !== undefined )
      result[ s ] = r;
    }
  }

  /**/

  return result;
}

//

  /**
   * The entityGroup() group input data structure by one or several keys.
   *
   * It creates an empty (result) object, iterate over array (src),
   * checks if (result) object has certain value.
   * If undefined, it creates (value) with an empty array.
   * Otherwise, it adds to certain (value) the object with target key.
   *
   * @param { array } src - The target array.
   * @param { objectLike | string } o - Options.
   *
   * @example
   * // returns { 33 : [ { key1 : 33 } ], 44 : [ { key1 : 44 }, { key2 : 77 } ] }
   * _.entityGroup( [ { key1 : 44, key2 : 77 }, { key1 : 33 } ], 'key1');
   *
   * @returns { object } Returns an object with certain group of key.
   * @method entityGroup
   * @throws { Error } Will throw an Error if (o.key) is not a string,
   * if (src) is not an object, if (o) is not an object.
   * @memberof wTools
   */

var entityGroup = function( o )
{
  var o = o || {};

  /* key */

  if( o.key === undefined || o.key === null )
  {

    if( o.usingOriginal === undefined )
    o.usingOriginal = 0;

    if( _.arrayLike( o.key ) )
    o.key = _.mapKeys.apply( _,o.src );
    else
    o.key = _.mapKeys.apply( _,_.mapValues( o.src ) );

  }

  /* */

  var o = _.routineOptions( entityGroup,o );

  _assert( arguments.length === 1 );
  _assert( _.strIs( o.key ) || _.arrayIs( o.key ) );
  _assert( _.objectLike( o.src ) || _.arrayLike( o.src ) );
  _assert( _.arrayIs( o.src ),'not tested' );

  /* */

  var groupForKey = function( key,result )
  {

    _.each( o.src, function( e,k )
    {

      var value = o.usingOriginal ? o.src[ k ] : o.src[ k ][ key ];
      var dstKey = o.usingOriginal ? o.src[ k ][ key ] : k;

      if( o.usingOriginal )
      {
        if( result[ dstKey ] === undefined )
        result[ dstKey ] = [];
        result[ dstKey ].push( value );
      }
      else
      {
        result[ dstKey ] = value;
      }

    });

    return result;
  }

  /* */

  var result;
  if( _.arrayIs( o.key ) )
  {

    result = {};
    for( var k = 0 ; k < o.key.length ; k++ )
    result[ o.key[ k ] ] = groupForKey( o.key[ k ],o.usingOriginal ? {} : new o.src.constructor() );

  }
  else
  {
    result = {};
    groupForKey( o.key,result );
  }

  /**/

  return result;
}

entityGroup.defaults =
{
  src : null,
  key : null,
  usingOriginal : 1,
}

//

  /**
   * The result of _entityMost method object.
   * @typedef {Object} wTools~entityMostResult
   * @property {number} index - Index of found element;
   * @property {string|number} key - If the search was on map, the value of this property sets to key of found element;
   * Else if search was on array - to index of found element.
   * @property {number} value - The found result of onElement, if onElement don't set, this value will be same as element.
   * @property {number} element - The appropriate element for found value.
   */

  /**
   * On depend from passed `returnMax` argument, method returns maximum or minimum of results `onEach` function.
   * `onEach` function calls for every element of passed `src` entity. If `onElement` is undefined, method return
   maximum or minimum of passed `src` elements.
   * @param {ArrayLike|Object} src Input entity with elements.
   * @param {onEach} onElement `onEach` function calls for every element of `src`.
   * @param {boolean} returnMax If true - method returns maximum, else method returns minimum of values.
   * @returns {wTools~entityMostResult} Object with results of search.
   * @private
   * @method _entityMost
   * @memberof wTools
   */

var _entityMost = function( src,onElement,returnMax )
{

  if( onElement === undefined )
  onElement = function( element ){ return element; }

  _.assert( arguments.length === 3 );
  _.assert( onElement.length === 1,'not mplemented' );

  var onCompare = null;

  if( returnMax )
  onCompare = function( a,b )
  {
    return a-b;
  }
  else
  onCompare = function( a,b )
  {
    return b-a;
  }

  var result = { index : -1, key : undefined, value : undefined, element : undefined };

  if( _.arrayLike( src ) )
  {

    if( src.length === 0 )
    return result;
    result.key = 0;
    result.value = onElement( src[ 0 ] );
    result.element = src[ 0 ];

    for( var s = 0 ; s < src.length ; s++ )
    {
      var value = onElement( src[ s ] );
      if( onCompare( value,result.value ) > 0 )
      {
        result.key = s;
        result.value = value;
        result.element = src[ s ];
      }
    }
    result.index = result.key;

  }
  else
  {

    //throw _.err( 'not tested' );
    for( var s in src )
    {
      result.index = 0;
      result.key = s;
      result.value = onElement( src[ s ] );
      result.element = src[ s ]
      break;
    }

    var index = 0;
    for( var s in src )
    {
      var value = onElement( src[ s ] );
      if( onCompare( value,result.value ) > 0 )
      {
        result.index = index;
        result.key = s;
        result.value = value;
        result.element = src[ s ];
      }
      index += 1;
    }

  }

  return result;
}

//

  /**
   * Method returns minimum of results `onEach` function.
   * Function `onEach` calls for every element of passed `src` entity. If `onElement` is undefined, method returns
      minimum of passed `src` elements.
   * @example
   *
     var obj = { a: 25, b: 16, c: 9 };

     var min = wTools.entityMin( obj, Math.sqrt );
     // expected4 = { index : 2, key : 'c', value 3: , element : 9  };

   * @param {ArrayLike|Object} src
   * @param {onEach} onElement onElement `onEach` function calls for every element of `src`.
   * @returns {wTools~entityMostResult}
   * @throws {Error} If missed arguments.
   * @throws {Error} If passed extra arguments.
   * @see wTools~onEach
   * @see wTools~entityMostResult
   * @method entityMin
   * @memberof wTools
   */

var entityMin = function( src,onElement )
{
  _.assert( arguments.length === 1 || arguments.length === 2 );
  return _entityMost( src,onElement,0 );
}

//

  /**
   * Method returns maximum of results `onEach` function.
   * Function `onEach` calls for every element of passed `src` entity. If `onElement` is undefined, method returns
      maximum of passed `src` elements.
   * @example
   *
     var args = [3, -4, 9, -16, 5, -2];

     var sqr = function( v )
     {
       return v * v;
     };
     var max = wTools.entityMax( args, sqr );
     // { index : 3, key : 3, value : 256, element : -16 }

   * @param {ArrayLike|Object} src
   * @param {wTools~onEach} onElement `onEach` function calls for every element of `src`.
   * @returns {wTools~entityMostResult}
   * @throws {Error} If missed arguments.
   * @throws {Error} If passed extra arguments.
   * @see wTools~onEach
   * @see wTools~entityMostResult
   * @method entityMax
   * @memberof wTools
   */

var entityMax = function( src,onElement )
{
  _.assert( arguments.length === 1 || arguments.length === 2 );
  return _entityMost( src,onElement,1 );
}

//

var entitySearch = function( o )
{
  var result = {};

  if( arguments.length === 2 )
  {
    o = { src : arguments[ 0 ], ins : arguments[ 1 ] };
  }

  _.routineOptions( entitySearch,o );
  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( !o.searchingCaseInsensitive,'not implemented' );

  var strIns,regexpIns;
  strIns = String( o.ins );
  if( o.searchingCaseInsensitive )
  regexpIns = new RegExp( ( o.searchingSubstring ? '' : '^' ) + strIns + ( o.searchingSubstring ? '' : '$' ),'i' );

  if( o.condition )
  o.condition = _entityConditionMake( o.condition );

  /* */

  var checkCandidate = function( e,k,i,r,path )
  {

    var c = true;
    if( o.condition )
    c = o.condition.call( this,e,k,i );

    if( !c )
    return c;

    if( e === o.ins )
    {
      result[ path ] = r;
    }
    else if( o.searchingSubstring && _.strIs( e ) && e.indexOf( strIns ) !== -1 )
    {
      result[ path ] = r;
    }

  }

  /* */

  var handleUp = function( e,k,i )
  {

    if( o.onUp )
    if( o.onUp.call( this,e,k,i ) === false )
    return false;

    var path;
    if( o.pathOfParent )
    path = this.path;
    else
    path = this.path + k;

    var r;
    if( o.returnParent && this.down )
    r = this.down.src;
    else
    r = e;

    if( o.searchingValue )
    {

      checkCandidate.call( this,e,k,i,r,path );

    }

    if( o.searchingKey )
    {

      checkCandidate.call( this,k,k,i,r,path );

    }

  }

  /* */

  _.eachRecursive
  ({
    src : o.src,
    own : o.own,
    onUp : handleUp,
    onDown : o.onDown,
  });

  return result;
}

entitySearch.defaults =
{

  src : null,
  ins : null,
  condition : null,

  onUp : null,
  onDown : null,

  own : 1,
  pathOfParent : 1,
  returnParent : 0,

  searchingKey : 1,
  searchingValue : 1,
  searchingSubstring : 1,
  searchingCaseInsensitive : 0,

}

// --
// iterator
// --

var __eachAct = function( o )
{

  var i = 0;
  var src = o.src;

  /* usingVisits */

  if( o.usingVisits )
  {
    if( o.visited.indexOf( o.src ) !== -1 )
    return i;
    o.visited.push( o.src );
  }

  var end = function()
  {

    if( o.root !== src )
    o.onDown.call( o,src,o.key,o.index );
    else if( o.usingRootVisit )
    {
      o.onDown.call( o,src,o.key,o.index );
    }

    if( o.usingVisits )
    {
      _.assert( o.visited[ o.visited.length-1 ] === o.src );
      o.visited.pop();
    }

    return i;
  }

  /* on up */

  o.counter += 1;
  var c = true;
  if( o.root !== src )
  {
    c = o.onUp.call( o,src,o.key,o.index );
  }
  else if( o.usingRootVisit )
  {
    c = o.onUp.call( o,src,o.key,o.index );
  }

  if( c === false )
  return end();

  /* element */

  var __onElement = function( k )
  {

    //o.onUp.call( o,src[ k ],k,i );
    //o.counter += 1;
    i += 1;

    if( o.recursive || o.root === o.src )
    {

      __eachAct
      ({
        src : src[ k ],
        root : o.root,
        onUp : o.onUp,
        onDown : o.onDown,
        own : o.own,
        recursive : o.recursive,
        usingVisits : o.usingVisits,
        counter : o.counter,
        visited : o.visited,
        levels : o.levels-1,
        path : o.path + k + '.',
        key : k,
        index : i,
        down : o,
      });

    }

    //o.onDown.call( o,src[ k ],k,i );

  }

  /* */

  if( _.arrayLike( src ) )
  {

    for( var k = 0 ; k < src.length ; k++ )
    {

      __onElement( k );

    }

  }
  else if( _.objectLike( src ) )
  {

    for( var k in src )
    {

      if( o.own )
      if( !Object.hasOwnProperty.call( src,k ) )
      continue;

      __onElement( k );

    }

  }
  else
  {

    // if( o.src !== o.root )
    // {
    //   end();
    //   return i;
    // }
    //
    // debugger;
    //
    // o.onUp.call( o,src[ k ],k,i );
    // o.onDown.call( o,src[ k ],k,i );
    // o.counter += 1;
    // i++;

  }

  /* end */

  return end();
}

//

var _each = function( o )
{

  if( o.root === undefined )
  o.root = o.src;

  _.routineOptions( _each,o );
  _.assert( _.routineIs( o.onUp ) || _.routineIs( o.onDown ),'each : expects routine o.onUp or o.onDown' );

  o.onUp = o.onUp || function(){};
  o.onDown = o.onDown || function(){};

  return __eachAct( o );
}

_each.defaults =
{
  src : null,
  root : null,
  onUp : null,
  onDown : null,
  own : 0,
  recursive : 0,
  usingVisits : 1,
  usingRootVisit : 1,
  counter : 0,
  visited : [],
  levels : 256,
  path : '.',
  key : null,
  index : 0,
}

//

var each = function( o )
{

  _.assert( arguments.length === 1 || arguments.length === 2 );
  if( arguments.length === 2 )
  o = { src : arguments[ 0 ], onUp : arguments[ 1 ] }

  if( o.own === undefined )
  o.own = 0;

  if( o.usingVisits === undefined )
  o.usingVisits = 0;

  if( o.recursive === undefined )
  o.recursive = 0;

  if( o.usingRootVisit === undefined )
  o.usingRootVisit = 0;

  return _each( o );
}

//

var eachOwn = function( o )
{

  _.assert( arguments.length === 1 || arguments.length === 2 );
  if( arguments.length === 2 )
  o = { src : arguments[ 0 ], onUp : arguments[ 1 ] }
  o.own = 1;

  if( o.usingVisits === undefined )
  o.usingVisits = 0;

  if( o.recursive === undefined )
  o.recursive = 0;

  if( o.usingRootVisit === undefined )
  o.usingRootVisit = 0;

  return _each( o );
}

//

var eachRecursive = function( o )
{

  _.assert( arguments.length === 1 || arguments.length === 2 );
  if( arguments.length === 2 )
  o = { src : arguments[ 0 ], onUp : arguments[ 1 ] }
  o.recursive = 1;

  if( o.own === undefined )
  o.own = 0;

  return _each( o );
}

//

var eachOwnRecursive = function( o )
{

  _.assert( arguments.length === 1 || arguments.length === 2 );
  if( arguments.length === 2 )
  o = { src : arguments[ 0 ], onEach : arguments[ 1 ] }
  o.own = 1;
  o.recursive = 1;

  return _each( o );
}

//
/*
var until = function()
{

  var i = 0;
  var found = 0;

  var onEach = arguments[ arguments.length-1 ];
  if( !_.routineIs( onEach ) ) throw '_.each : onEach is not routine';

  for( var arg = 0, l = arguments.length-1 ; arg < l ; arg++ )
  {

    var src = arguments[ arg ];

    if( _.arrayIs( src ) )
    {

      for( var a = 0 ; a < src.length ; a++ )
      {
        found = onEach.call( src,src[a],a,i );
        i++;
      }

    }
    else if( _.objectIs( src ) )
    {

      for( var a in src )
      {
        found = onEach.call( src,src[a],a,i );
        i++;
      }

    }
    else if( src !== undefined )
    {

      found = onEach.call( src,src );
      i++;

    }

    if( found ) return i;
  }

  return i;
}
*/

//

var eachSample = function( o )
{

  if( arguments.length === 2 )
  {
    o =
    {
      elementArrays : arguments[ 0 ],
      onEach : arguments[ 1 ],
    }
  }

  _.assertMapOnly( o,eachSample.defaults );
  if( o.direct === undefined )
  o.direct = true;

  /**/

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( _.routineIs( o.onEach ) || o.onEach === undefined );
  _.assert( _.arrayIs( o.elementArrays ) || o.base !== undefined || o.add !== undefined );

  /**/

  if( o.base !== undefined || o.add !== undefined )
  {

    var l = 1;
    if( _.arrayLike( o.base ) )
    l = o.base.length;
    else if( _.arrayLike( o.add ) )
    l = o.add.length;

    if( !o.base )
    o.base = 0;
    o.base = _.arrayOrNumber( o.base,l );
    o.add = _.arrayOrNumber( o.add,l );

    _.assert( o.base.length === o.add.length );
    _.assert( !o.elementArrays );

    o.elementArrays = [];

    for( var b = 0 ; b < o.base.length ; b++ )
    {
      var e = [ o.base[ b ], o.base[ b ] + o.add[ b ] ];
      o.elementArrays.push( e );
    }

  }

  /* elementArrays */

  if( !o.base )
  for( var i = 0 ; i < o.elementArrays.length ; i++ )
  {
    _.assert( _.arrayLike( o.elementArrays[ i ] ) || _.atomicIs( o.elementArrays[ i ] ) );
    if( _.atomicIs( o.elementArrays[ i ] ) )
    o.elementArrays[ i ] = [ o.elementArrays[ i ] ];
  }

  /**/

  var result = [];
  var sample = [];
  var counter = [];
  var len = [];
  var index = 0;

  /**/

  var firstSample = function()
  {

    for( var s = 0, l = o.elementArrays.length; s < l ; s++ )
    {
      len[ s ] = o.elementArrays[ s ].length;
      counter[ s ] = 0;
      sample[ s ] = o.elementArrays[ s ][ counter[ s ] ];
      if( !len[ s ] )
      return 0;
    }

    result.push( sample.slice() );

    return 1;
  }

  /**/

  var _nextSample = function( s )
  {

    counter[ s ]++;
    if( counter[ s ] >= len[ s ] )
    {
      counter[ s ] = 0;
      sample[ s ] = o.elementArrays[ s ][ counter[ s ] ];
    }
    else
    {
      sample[ s ] = o.elementArrays[ s ][ counter[ s ] ];
      index += 1;
      result.push( sample.slice() );
      return 1;
    }

    return 0;
  }

  /**/

  var nextSample = function()
  {

    if( o.direct ) for( var s = 0, l = o.elementArrays.length; s < l ; s++ )
    {
      if( _nextSample( s ) )
      return 1;
    }
    else for( var s = o.elementArrays.length - 1, l = o.elementArrays.length; s >= 0 ; s-- )
    {
      if( _nextSample( s ) )
      return 1;
    }

    return 0;
  }

  /**/

  if( !_.arrayIs( o.elementArrays ) )
  throw _.err( 'eachSample :','array only supported' );

  if( !firstSample() )
  return result;

  do
  {
    if( o.onEach )
    o.onEach.call( sample,sample,index );
  }
  while( nextSample() );

  return result;
}

eachSample.defaults =
{

  direct : 1,
  onEach : null,

  elementArrays : null,
  base : null,
  add : null,

}
//

var dup = function( times,ins,result )
{
  _.assert( arguments.length === 2 || arguments.length === 3 );
  _.assert( _.numberIs( times ) || _.arrayLike( times ),'dup expects times as number or array' );

  if( _.numberIs( times ) )
  {
    if( !result )
    result = new Array( times );
    for( var t = 0 ; t < times ; t++ )
    result[ t ] = ins;
    return result;
  }
  else if( _.arrayLike( times ) )
  {
    _.assert( times.length === 2 );
    var l = times[ 1 ] - times[ 0 ];
    if( !result )
    result = new Array( times[ 1 ] );
    for( var t = 0 ; t < l ; t++ )
    result[ times[ 0 ] + t ] = ins;
    return result;
  }

}

// --
// diagnostics
// --

  /**
   * Creates Error object based on passed options.
   * Result error contains in message detailed stack trace and error description.
   * @param {Object} o Options for creating error.
   * @param {String[]|Error[]} o.args array with messages or errors objects, from which will be created Error obj.
   * @param {number} [o.level] using for specifying in error message on which level of stack trace was caught error.
   * @returns {Error} Result Error. If in `o.args` passed Error object, result will be reference to it.
   * @private
   * @throws {Error} Expects single argument if pass les or more than one argument
   * @throws {Error} o.args should be array like, if o.args is not array.
   * @method _err
   * @memberof wTools
   */

var _err = function _err( o )
{
  var result;

  if( arguments.length !== 1 )
  throw '_err : expects single argument';

  if( !_.arrayLike( o.args ) )
  throw '_err : o.args should be array like';

  if( !_.numberIs( o.level ) )
  o.level = _err.defaults.level;

  if( o.args[ 0 ] === 'not tested' || o.args[ 0 ] === 'unexpected' )
  debugger;

  /*Error.stackTraceLimit = 99;*/

  for( var a = 0 ; a < o.args.length ; a++ )
  {
    if( o.args[ a ] instanceof Error )
    {
      result = o.args[ a ];
      if( result.attentionNeeded !== undefined )
      result.attentionNeeded = 0;
      o.args[ a ] = result.originalMessage || result.message || result.msg || result.constructor.name || 'unknown error';
      break;
    }
  }

  var originalMessage = '';
  var fileName,lineNumber;

  for( var a = 0 ; a < o.args.length ; a++ )
  {
    var argument = o.args[ a ];
    var str;

    if( argument )
    {
      if( _.routineIs( argument.toStr ) ) str = argument.toStr();
      else if( _.strIs( argument.originalMessage ) ) str = argument.originalMessage;
      else if( _.strIs( argument.message ) ) str = argument.message;
      else if( !_.atomicIs( argument ) && _.routineIs( argument.toString ) ) str = argument.toString();
      else str = String( argument );
    }
    else str = String( argument );

    if( _.objectLike( argument ) && !fileName )
    {

      if( !fileName )
      fileName = argument.fileName || argument.filename;

      if( lineNumber === undefined )
      lineNumber = argument.linenumber;

      if( lineNumber === undefined )
      lineNumber = argument.lineNumber;

      if( lineNumber === undefined )
      lineNumber = argument.lineno;

    }

    if( _.strIs( str ) && str[ str.length-1 ] === '\n' )
    originalMessage += str;
    else originalMessage += str + ' ';
  }

  /* */

  if( originalMessage[ 0 ] !== '\n' )
  originalMessage = '\n' + originalMessage;
  originalMessage = '\n' + 'caught ' + _.stack().split( '\n' )[ o.level ] + originalMessage;

  /* */

  if( !result )
  {
    var stack = new Error().stack || '';
    result = new Error( originalMessage + '\n' + stack + '\n' );
    result.originalStack = stack;
  }
  else try
  {
    result.message = '';
    result.message = originalMessage + '\n' + ( result.originalStack || result.stack || '' ) + '\n';
  }
  catch( e )
  {
    debugger;
    var stack = result.stack || new Error().stack;
    result = new Error( originalMessage + '\n' + stack + '\n' );
    result.stack = stack;
    result.originalStack = stack;
  }

  result.originalMessage = originalMessage;

  return result;
}

_err.defaults =
{
  level : 0,
  args : null,
}

//

  /**
   * Creates error object, with message created from passed `msg` parameters and contains error trace.
   * If passed several strings (or mixed error and strings) as arguments, the result error message is created by
   concatenating them.
   *
   * @example
    function divide( x, y )
    {
      if( y == 0 )
        throw wTools.err( 'divide by zero' )
      return x / y;
    }
    divide( 3, 0 );

   // Error:
   // caught     at divide (<anonymous>:2:29)
   // divide by zero
   // Error
   //   at _err (file:///.../wTools/staging/wTools.s:1418:13)
   //   at wTools.err (file:///.../wTools/staging/wTools.s:1449:10)
   //   at divide (<anonymous>:2:29)
   //   at <anonymous>:1:1
   *
   * @param {...String|Error} msg Accepts list of messeges/errors.
   * @returns {Error} Created Error. If passed existing error as one of parameters, method modified it and return
   * reference.
   * @method err
   * @memberof wTools
   */

var err = function err()
{
  return _err
  ({
    args : arguments,
    level : 2,
  });
}

//

  /**
   * Creates error object, with message created from passed `msg` parameters and contains error trace.
   * If passed several strings (or mixed error and strings) as arguments, the result error message is created by
   concatenating them. Prints the created error.
   * If _global_.logger defined, method will use it to print error, else uses console
   * @see wTools.err
   *
   *@example
     function divide( x, y )
     {
        if( y == 0 )
          throw wTools.errLog('divide by zero')
        return x / y;
     }
     divide (3, 0);

     // Error:
     // caught     at divide (<anonymous>:2:29)
     // divide by zero
     // Error
     //   at _err (file:///.../wTools/staging/wTools.s:1418:13)
     //   at wTools.errLog (file:///.../wTools/staging/wTools.s:1462:13)
     //   at divide (<anonymous>:2:29)
     //   at <anonymous>:1:1
   *
   * @param {...String|Error} msg Accepts list of messeges/errors.
   * @returns {Error} Created Error. If passed existing error as one of parameters, method modified it and return
   * @method errLog
   * @memberof wTools
   */

var errLog = function errLog()
{

  var c = _global_.logger || console;
  var err = _err
  ({
    args : arguments,
    level : 2,
  });

  err.attentionNeeded = 0;
  err.attentionGiven = 1;

  if( _.routineIs( err.toString ) )
  {

    var messageWas = err.message;

    //if( err.originalMessage )
    //err.message = err.originalMessage

    c.error( err.toString() );

    //err.message = messageWas;

  }
  else
  {

    c.error( err );

  }

  debugger;
  return err;
}

//

  /**
   * Checks condition. If condition converts to true method returns without exceptions.
   * Else If condition is false, method generates and throws exception. By default generates error with
   * message 'Assertion failed'. But method can accept messages for generate error, or even existing error objects.
   *
   * @example
     function divide ( x, y )
     {
        wTools.assert( y != 0, 'divide by zero' );
        return x / y;
     }
     divide (3, 0);

   // caught     at divide (<anonymous>:2:29)
   // divide by zero
   // Error
   //   at _err (file:///.../wTools/staging/wTools.s:1418:13)
   //   at wTools.errLog (file://.../wTools/staging/wTools.s:1462:13)
   //   at divide (<anonymous>:2:29)
   //   at <anonymous>:1:1
   * @param {*} condition
   * @param {...String|Error} msgs error messages for generated exception.
   * @throws {Error} If passed condition failed, Method throws an error.
   * @method assert
   * @memberof wTools
   */

var assert = function assert( condition )
{

  /*return;*/

  if( DEBUG === false )
  return;

  if( !condition )
  {
    debugger;
    if( arguments.length === 1 )
    throw _err
    ({
      args : [ 'Assertion failed' ],
      level : 2,
    });
    else if( arguments.length === 2 )
    throw _err
    ({
      args : [ arguments[ 1 ] ],
      level : 2,
    });
    else
    throw _err
    ({
      args : _arraySlice( arguments,1 ),
      level : 2,
    });
  }

  return;
}

//

var assertMapNoUndefine = function assertMapNoUndefine( src )
{

  if( DEBUG === false )
  return;

  _.assert( arguments.length === 1 || arguments.length === 2 )

  var l = arguments.length;
  var hasMsg = _.strIs( arguments[ l-1 ] );

  for( var s in src )
  if( src[ s ] === undefined )
  {
    debugger;
    throw _err
    ({
      args : [ ( 'Object ' + ( hasMsg ? _.arraySlice( arguments,1,arguments.length ) : '' ) + ' should have no undefines, but has' ) + ' : ' + s ],
      level : 2,
    });
  }

}

//

var assertMapOnly = function assertMapOnly( src )
{

  if( DEBUG === false )
  return;

  var l = arguments.length;
  var hasMsg = _.strIs( arguments[ l-1 ] );
  var args = hasMsg ? _.arraySlice( arguments,0,l-1 ) : arguments;
  var but = Object.keys( _.mapBut.apply( this,args ) );

  if( but.length > 0 )
  {
    if( _.strJoin )
    console.error( 'Consider extending Composes by :\n' + _.strJoin( '  ',but,' : null,' ).join( '\n' ) );
    debugger;
    throw _err
    ({
      args : [ hasMsg ? arguments[ l-1 ] : '','Object should have no fields :',but.join( ',' ) ],
      level : 2,
    });
  }

}

//

var assertMapOwnOnly = function assertMapOwnOnly( src )
{

  if( DEBUG === false )
  return;

  var l = arguments.length;
  var hasMsg = _.strIs( arguments[ l-1 ] );
  var args = hasMsg ? _.arraySlice( arguments,0,l-1 ) : arguments;
  var but = Object.keys( _.mapOwnBut.apply( this,args ) );

  if( but.length > 0 )
  {
    if( _.strJoin )
    console.error( 'Consider extending Composes by :\n' + _.strJoin( '  ',but,' : null,' ).join( '\n' ) );
    debugger;
    throw _err
    ({
      args : [ hasMsg ? arguments[ l-1 ] : '','Object should have no own fields :',but.join( ',' ) ],
      level : 2,
    });
  }

}

//

var assertMapAll = function( src,all,msg )
{

  if( DEBUG === false )
  return;

  _assert( arguments.length === 2 || arguments.length === 3 );
  _assert( arguments.length === 2 || _.strIs( msg ) );

  var l = arguments.length;
  var hasMsg = _.strIs( arguments[ l-1 ] );
  var but = Object.keys( _.mapBut( all,src ) );

  if( but.length > 0 )
  {
    debugger;
    throw _err
    ({
      args : [ hasMsg ? arguments[ l-1 ] : '','Object should have fields :',but.join( ',' ) ],
      level : 2,
    });
  }

}

//

var assertMapOwnAll = function( src,all,msg )
{

  if( DEBUG === false )
  return;

  _assert( arguments.length === 2 || arguments.length === 3 );
  _assert( arguments.length === 2 || _.strIs( msg ) );

  var l = arguments.length;
  var hasMsg = _.strIs( arguments[ l-1 ] );
  var but = Object.keys( _.mapOwnBut( all,src ) );

  if( but.length > 0 )
  {
    debugger;
    throw _err
    ({
      args : [ hasMsg ? arguments[ l-1 ] : '','Object should have own fields :',but.join( ',' ) ],
      level : 2,
    });
  }

}

//

var assertMapNone = function( src )
{

  if( DEBUG === false )
  return;

  var l = arguments.length;
  var hasMsg = _.strIs( arguments[ l-1 ] );
  var args = hasMsg ? _.arraySlice( arguments,0,l-1 ) : arguments;
  var none = _.mapScreens.apply( this,args );

  for( var n in none )
  {
    for( var a = 1 ; a < arguments.length ; a++ )
    if( arguments[ a ][ n ] !== src[ n ] )
    break;
    if( a === arguments.length )
    delete none[ n ];
  }

  if( Object.keys( none ).length )
  {
    debugger;
    throw _err
    ({
      args : [ hasMsg ? arguments[ l-1 ] : '','Object should have no fields :',none.join( ',' ) ],
      level : 2,
    });
  }

}

//

var assertMapOwnNone = function( src,none )
{

  if( DEBUG === false )
  return;

  var l = arguments.length;
  var hasMsg = _.strIs( arguments[ l-1 ] );
  if( hasMsg ) l -= 1;

  if( l > 2 )
  {
    var args =_ArraySlice.call( arguments,1,l ); debugger;
    none = _.mapCopy.apply( this,args );
  }

  var has = Object.keys( _._mapScreen
  ({
    filter : filter.srcOwn(),
    screenObjects : none,
    srcObjects : src,
  }));

  if( has.length )
  {
    debugger;
    throw _err
    ({
      args : [ hasMsg ? arguments[ l-1 ] : '','Object should have no own fields :',has.join( ',' ) ],
      level : 2,
    });
  }

}

//

  /**
   * If condition failed, method prints warning messages passed after condition argument
   * @example
    function checkAngles( a, b, c )
    {
       wTools.warn( (a + b + c) === 180, 'triangle with that angles does not exists' );
    };
    checkAngles( 120, 23, 130 );

   // triangle with that angles does not exists
   * @param condition Condition to check.
   * @param messages messages to print.
   * @method warn
   * @memberof wTools
   */

var warn = function( condition )
{

  if( !condition )
  {
    console.warn.apply( console,[].slice.call( arguments,1 ) );
  }

}

//

  /**
   * Return stack trace as string.
   * @example
    var stack;
    function function1()
    {
      function2();
    }

    function function2()
    {
      function3();
    }

    function function3()
    {
      stack = wTools.stack();
    }

    function1();
    stack
   //"    at function3 (<anonymous>:10:17)
   // at function2 (<anonymous>:6:2)
   // at function1 (<anonymous>:2:2)
   // at <anonymous>:1:1"
   *
   * @returns {String} Return stack trace from call point.
   * @method stack
   * @memberof wTools
   */

var stack = function()
{

  var e = new Error();
  var result = e.stack;

  result = result.split( '\n' );

  result.splice( 0,2 );
  result = String( result.join( '\n' ) );
  return result;
}

//

var includeAny = function()
{

  for( var a = 0 ; a < arguments.length ; a++ )
  {
    var src = arguments[ a ];

    if( a === arguments.length-1 )
    {
      if( src !== '' )
      return require( src );
    }
    else try
    {

      var result = require( src );
      return result;

    }
    catch( err )
    {
      //_.errLog( err );
    }

  }

}

//

var diagnosticWatchObject = function diagnosticWatchObject( dst,options )
{
  var options = options || {};
  if( options.fieldName )
  options.fieldNames = _.nameFielded( options.fieldNames );

  Object.observe( dst,function( changes )
  {
    for( var c in changes )
    {
      var change = changes[ c ];
      if( options.fieldNames )
      if( !options.fieldNames[ change.name ] ) return;
      console.log( change.type,change.name,change.object[ change.name ] );
      //if( !change.object[ change.name ] )
      //console.log( change.name,change.object[ change.name ] );
    }
    //debugger;
  });

}

//

/*

_.diagnosticWatchFields
({
  dst : _global_,`
  names : 'Uniforms',
});

_.diagnosticWatchFields
({
  dst : state,
  names : 'filterColor',
});

_.diagnosticWatchFields
({
  dst : _global_,
  names : 'Config',
});

*/

var diagnosticWatchFields = function( o )
{
  var o = o || {};

  if( o.names )
  o.names = _.nameFielded( o.names );
  else
  o.names = o.dst;

  _assert( arguments.length === 1 );
  _.assertMapOnly( o,diagnosticWatchFields.defaults );
  _.mapComplement( o,diagnosticWatchFields.defaults );
  _assert( o.dst );
  _assert( o.names );

  for( var f in o.names ) ( function()
  {

    var fieldName = f;
    var fieldSymbol = Symbol.for( f );
    o.dst[ fieldSymbol ] = o.dst[ f ];

    /* */

    var read = function read()
    {
      var result = o.dst[ fieldSymbol ];
      if( o.printValue )
      console.log( 'reading ' + fieldName + ' ' + _.toStr( result ) );
      else
      console.log( 'reading ' + fieldName );
      return result;
    }

    /* */

    var write = function write( src )
    {
      if( o.printValue )
      console.log( 'writing ' + fieldName + ' ' + _.toStr( src ) );
      else
      console.log( 'writing ' + fieldName );
      debugger;
      o.dst[ fieldSymbol ] = src;
    }

    /* */

    debugger;
    Object.defineProperty( o.dst, fieldName,
    {
      enumerable : true,
      configurable : true,
      get : read,
      set : write,
    });

  })();

}

diagnosticWatchFields.defaults =
{
  printValue : true,
  names : null,
  dst : null,
}

//

var diagnosticBeep = function()
{
  console.log( '\x07' );
}

// --
// type test
// --

/**
 * Function objectIs checks incoming param whether it is object.
 * Returns "true" if incoming param is object. Othervise "false" returned.
 *
 * @example
 * // returns true
 * var obj = {x : 100};
 * objectIs(obj);
 * @example
 * // returns false
 * objectIs(10);
 *
 * @param {*} src.
 * @return {Boolean}.
 * @method objectIs
 * @memberof wTools
 */

var objectIs = function( src )
{
  return _ObjectToString.call( src ) === '[object Object]';
}

//

var objectLike = function( src )
{
  if( objectIs( src ) ) return true;
  if( routineIs( src ) ) return true;
  if( atomicIs( src ) ) return false;

  for( var s in src )
  return true;

  return false; /* isObject */
}

//

  /**
   * The mapIs() method determines whether the passed value is an Object,
   * and not inherits through the prototype chain.
   *
   * If the (src) is an Object, true is returned,
   * otherwise false is.
   *
   * @param { * } src - Entity to check.
   *
   * @example
   * // returns true
   * mapIs( { a : 7, b : 13 } );
   *
   * @example
   * // returns false
   * mapIs( 13 );
   *
   * @example
   * // returns false
   * mapIs( [ 3, 7, 13 ] );
   *
   * @returns { Boolean } Returns true if (src) is an Object, and not inherits through the prototype chain.
   * @method mapIs
   * @memberof wTools
   */

var mapIs = function( src )
{

  if( !_.objectIs( src ) )
  return false;

  _.assert( Object.getPrototypeOf( src ) === null || Object.getPrototypeOf( src ),'unexpected' );

  if( Object.getPrototypeOf( src ) === null )
  return true;

  if( Object.getPrototypeOf( src ).constructor.name !== 'Object' )
  return false;

  if( Object.getPrototypeOf( Object.getPrototypeOf( src ) ) === null )
  return true;

  return false;
}

  //

/**
 * The arrayIs() method determines whether the passed value is an Array.
 *
 * If the (src) is an Array, true is returned,
 * otherwise false is.
 *
 * @param { * } src - The object to be checked.
 *
 * @example
 * // returns true
 * arrayIs( [ 1, 2 ] );
 *
 * @example
 * // returns false
 * arrayIs( 10 );
 *
 * @returns { boolean } Returns true if (src) is an Array.
 * @method arrayIs
 * @memberof wTools
 */

var arrayIs = function( src )
{
  return _ObjectToString.call( src ) === '[object Array]';
}

//

  /**
   * The arrayLike() method determines whether the passed value is an array-like or an Array.
   * Imortant : arrayLike returns false for Object, even if the object has length field.
   *
   * If (src) is an array-like or an Array, true is returned,
   * otherwise false is.
   *
   * @param { * } src - The object to be checked.
   *
   * @example
   * // returns true
   * arrayLike( [ 1, 2 ] );
   *
   * @example
   * // returns false
   * arrayLike( 10 );
   *
   * @example
   * // returns true
   * var isArr = ( function() {
   *   return _.arrayLike( arguments );
   * } )('Hello there!');
   *
   * @returns { boolean } Returns true if (src) is an array-like or an Array.
   * @method arrayLike.
   * @memberof wTools
   */

var arrayLike = function( src )
{
  if( atomicIs( src ) ) return false;

  if( _.routineIs( src ) ) return false;
  if( _.objectIs( src ) ) return false;
  if( _.strIs( src ) ) return false;

  if( !_.numberIs( src.length ) ) return false;

  return true;
}

//

  /**
   * The hasLength() method determines whether the passed value has the property (length).
   *
   * If (src) is equal to the (undefined) or (null) false is returned.
   * If (src) has the property (length) true is returned.
   * Otherwise false is.
   *
   * @param { * } src - The object to be checked.
   *
   * @example
   * // returns true
   * hasLength( [ 1, 2 ] );
   *
   * @example
   * // returns true
   * hasLength( 'Hello there!' );
   *
   * @example
   * // returns true
   * var isLength = ( function() {
   *   return _.hasLength( arguments );
   * } )('Hello there!');
   *
   * @example
   * // returns false
   * hasLength( 10 );
   *
   * @example
   * // returns false
   * hasLength( { } );
   *
   * @returns { boolean } Returns true if (src) has the property (length).
   * @method hasLength
   * @memberof wTools
   */

var hasLength = function( src )
{
  if( src === undefined || src === null ) return false;
  if( _.numberIs( src.length ) ) return true;
  return false;
}

//

/**
 * Function strIs checks incoming param whether it is string.
 * Returns "true" if incoming param is string. Othervise "false" returned
 *
 * @example
 * //returns true
 * strIsIs('song');
 * @example
 * // returns false
 * strIs(5);
 *
 * @param {*} src.
 * @return {Boolean}.
 * @method strIs.
 * @memberof wTools
 */

var strIs = function( src )
{
  var result = _ObjectToString.call( src ) === '[object String]';
  return result;
}

//

var strIsNotEmpty = function( src )
{
  if( !src )
  return false;
  var result = _ObjectToString.call( src ) === '[object String]';
  return result;
}

//

var symbolIs = function( src )
{
  var result = _ObjectToString.call( src ) === '[object Symbol]';
  return result;
}

//

/**
 * Function numberIs checks incoming param whether it is number.
 * Returns "true" if incoming param is object. Othervise "false" returned.
 *
 * @example
 * //returns true
 * numberIs( 5 );
 * @example
 * // returns false
 * numberIs( 'song' );
 *
 * @param {*} src.
 * @return {Boolean}.
 * @method numberIs.
 * @memberof wTools
 */

var numberIs = function( src )
{
  return _ObjectToString.call( src ) === '[object Number]';
}

//

var boolIs = function( src )
{
  return _ObjectToString.call( src ) === '[object Boolean]';
}

//

var numberIsRegular = function( src )
{
  return _.numberIs( src ) && !isNaN( src ) && src !== +Infinity && src !== -Infinity;
}

//

var numbersAreInt = function numbersAreInt( src )
{

  if( _.arrayLike( src ) )
  {
    for( var s = 0 ; s < src.length ; s++ )
    if( !numbersAreInt( src[ s ] ) )
    return false;
    return true;
  }

  if( !_.numberIs( src ) )
  return false;

  return Math.floor( src ) === src;
}

//

var dateIs = function( src )
{
  return _ObjectToString.call( src ) === '[object Date]';
}

//

var bufferIs = function( src )
{
  var type = _ObjectToString.call( src );

  if( !/\wArray/.test( type ) )
  return false;

  if( typeof Buffer !== 'undefined' )
  if( src instanceof Buffer )
  return false;

  return true;
}

//

var bufferViewIs = function( src )
{
  var type = _ObjectToString.call( src );
  var result = type === '[object DataView]';
  return result;
}

//

var bufferRawIs = function( src )
{
  var type = _ObjectToString.call( src );
  var result = type === '[object ArrayBuffer]';
  return result;
}

//

var bufferNodeIs = function( src )
{
  if( typeof Buffer !== 'undefined' )
  return src instanceof Buffer;
  return false;
}

//

var bufferSomeIs = function( src )
{
  return bufferIs( src ) || bufferViewIs( src )  || bufferRawIs( src ) || bufferNodeIs( src );
}

//

var argumentsIs = function( src )
{
  return _ObjectToString.call( src ) === '[object Arguments]';
}

//

var rowIs = function( src )
{
  if( src && src._rowArray )
  return true;
  else return false;
}

//

var boolIs = function( src )
{
  return _ObjectToString.call( src ) === '[object Boolean]';
}

//

var routineIs = function( src )
{
  return _ObjectToString.call( src ) === '[object Function]';
}

//

var routineWithNameIs = function( src )
{
  if( _ObjectToString.call( src ) !== '[object Function]' )
  return false;
  if( !src.name )
  return false;
  return true;
}

//

var regexpIs = function( src )
{
  return _ObjectToString.call( src ) === '[object RegExp]';
}

//

var definedIs = function( src )
{
  return src !== undefined && src !== null && src !== NaN;
}

//

var eventIs = function( src )
{
  if( src instanceof Event )
  return true;
  if( typeof jQuery === 'undefined' )
  return false;
  if( src instanceof jQuery.Event )
  return true;
  return false;
}

//

var htmlIs = function( src )
{
  return _ObjectToString.call( src ).indexOf( '[object HTML' ) !== -1;
}

//

var jqueryIs = function( src )
{
  if( typeof jQuery === 'undefined' )
  return;1
  return src instanceof jQuery;
}

//

var canvasIs = function( src )
{
  if( _.jqueryIs( src ) )
  src = src[ 0 ];
  if( !domIs( src ) )
  return false;
  return src.tagName === 'CANVAS';
}

//

var domIs = function( src )
{
  if( !_global_.Node )
  return false;
  return src instanceof Node;
  /*return src instanceof Element;*/
}

//

var domableIs = function( src )
{
  return strIs( src ) || domIs( src ) || jqueryIs( src );
}

//

var errorIs = function( src )
{
  return src instanceof Error;
  //return _ObjectToString.call( src ) === '[object Error]';
}

//

var atomicIs = function atomicIs( src )
{
  return symbolIs( src ) || numberIs( src ) || boolIs( src ) || strIs( src ) || src === null || src === undefined;
}

//

var typeOf = function( src )
{
  if( src === null || src === undefined )
  return null
  else if( numberIs( src ) || boolIs( src ) || strIs( src ) )
  return src.constructor;
  else
  {
    _assert( _.routineIs( src.constructor ) && src instanceof src.constructor );
    return src.constructor;
  }
}

//

var typeIsBuffer = function( src )
{
  if( !src ) return false;
  if( !_.numberIs( src.BYTES_PER_ELEMENT ) ) return false;
  if( !_.strIs( src.name ) ) return false;
  return src.name.indexOf( 'Array' ) !== -1;

/*
  var types = [ _global_.Int8Array, _global_.Uint8Array, _global_.Uint8ClampedArray, _global_.Int16Array, _global_.Uint16Array, _global_.Int32Array, _global_.Uint32Array, _global_.Float32Array, _global_.Float64Array ];
  for( var t = 0 ; t < types.length ; t++ )
  {
    var type = types[ t ];
    if( !type ) continue;
    if( src === type ) return true;
  }
  return false;
*/

}

// --
// bool
// --

var boolFrom = function( src )
{
  if( strIs( src ) )
  {
    src = src.toLowerCase();
    if( src == '0' ) return false;
    if( src == 'false' ) return false;
    if( src == 'null' ) return false;
    if( src == 'undefined' ) return false;
    if( src == '' ) return false;
    return true;
  }
  return Boolean( src );
}

// --
// str
// --

/*
var toStrFast = function( src ) {

  var result = '';
  if( arrayIs( src ) )
  {
    if( src.length > 0 ) result = toStr( src[0] );
    for( var i = 1 ; i < src.length ; i++ )
    result += ', ' + toStr( src[i] );
  }
  else if( src instanceof THREE.Vector2 )
  {
    result = '( ' + toStr( src.x ) + ', ' + toStr( src.y ) + ' )';
  }
  else if( src instanceof THREE.Vector3 )
  {
    result = '( ' + toStr( src.x ) + ', ' + toStr( src.y ) + ', ' + toStr( src.z ) + ' )';
  }
  else if( src instanceof THREE.Vector4 )
  {
    result = '( ' + toStr( src.x ) + ', ' + toStr( src.y ) + ', ' + toStr( src.z ) + ', ' + toStr( src.w ) + ' )';
  }
  else if( src instanceof THREE.Matrix4 )
  {
    for( var i = 0 ; i < 4*4 ; i+=4 )
    result += '\n( ' + toStr( src.elements[i+0] ) + ', ' + toStr( src.elements[i+1] ) + ', ' + toStr( src.elements[i+2] ) + ', ' + toStr( src.elements[i+3] ) + ' )';
  }
  else
  {
    result = src;
  }
  return result;

}
*/

// --
// number
// --

var numberFrom = function( src )
{
  if( strIs( src ) )
  {
    return parseFloat( src );
  }
  return Number( src );
}

//

var numberRandomInRange = function( range )
{

  _assert( arguments.length === 1 && _.arrayIs( range ),'numberRandomInRange :','expects range( array ) as argument' );
  _assert( range.length === 2 );

  return _random()*( range[ 1 ] - range[ 0 ] ) + range[ 0 ];

}

//

var numberRandomInt = function( range )
{

  _assert( _.arrayIs( range ) || _.numberIs( range ) );
  _assert( range.length === 2 );

  if( _.numberIs( range ) )
  range = range >= 0 ? [ 0,range ] : [ range,0 ];
  else if( _.arrayIs( range ) )
  range = range;
  else throw _.err( 'numberRandomInt','unexpected argument' );

  var result = Math.floor( range[ 0 ] + Math.random()*( range[ 1 ] - range[ 0 ] ) );

  return result;
}

//

var numberRandomIntBut = function( range )
{
  var result;
  var attempts = 10;

  if( _.numberIs( range ) )
  range = [ 0,range ];
  else if( _.arrayIs( range ) )
  range = range;
  else throw _.err( 'numberRandomInt','unexpected argument' );

  for( var attempt = 0 ; attempt < attempts ; attempt++ )
  {
    /*result = _.numberRandomInt( range ); */
    var result = Math.floor( range[ 0 ] + Math.random()*( range[ 1 ] - range[ 0 ] ) );

    var bad = false;
    for( var a = 1 ; a < arguments.length ; a++ )
    if( _.routineIs( arguments[ a ] ) )
    {
      if( !arguments[ a ]( result ) )
      bad = true;
    }
    else
    {
      if( result === arguments[ a ] )
      bad = true;
    }
    if( bad ) continue;
    return result;
  }

  console.warn( 'numberRandomIntBut :','NaN' );
  throw _.err( 'numberRandomIntBut :','NaN' );

  result = NaN;
  return result;
}

// --
// str
// --

/**
  * Return type of src.
  * @example
      var str = _.strTypeOf( 'testing' );
  * @param {*} src
  * @return {string}
  * string name of type src
  * @method strTypeOf
  * @memberof wTools
  */

var strTypeOf = function( src )
{

  _.assert( arguments.length === 1 );

  if( !_.atomicIs( src ) )
  if( src.constructor && src.constructor.name )
  return src.constructor.name;

  var result = _.strPrimitiveTypeOf( src );

  if( result === 'Object' )
  if( src.__proto__ !== Object.__proto__ )
  result = 'Object:Fake';

  return result;
}

//

/**
  * Return primitive type of src.
  * @example
      var str = _.strPrimitiveTypeOf('testing');
  * @param {*} src
  * @return {string}
  * string name of type src
  * @method strPrimitiveTypeOf
  * @memberof wTools
  */

var strPrimitiveTypeOf = function( src )
{

  var name = _ObjectToString.call( src );
  var result = /\[(\w+) (\w+)\]/.exec( name );

  if( !result )
  throw _.err( 'strTypeOf :','unknown type',name );
  return result[ 2 ];
}

//

/**
  * Return in one string value of all arguments.
  * @example
   var args = _.str('test2');
  * @return {string}
  * If no arguments return empty string
  * @method str
  * @memberof wTools
  */

var str = function()
{

  var result = '';
  if( !arguments.length )
  return result;

  for( var a = 0 ; a < arguments.length ; a++ )
  {
    if( arguments[ a ] && arguments[ a ].toStr ) result += arguments[ a ].toStr() + ' ';
    else result += String( arguments[ a ] ) + ' ';
  }

  return result;
}

//

  /**
    * Compares two strings.
    * @param {string} src - source string
    * @param {string} begin
    * @example
        var scr = ._strBegins("abc","a");
    * @return {Boolean}
    * If param begin is match with param src first chars than return true
    * @method strBegins
    * @memberof wTools
    */

var strBegins = function( src,begin )
{

  _.assert( _.strIs( src ),'expects string' );
  _.assert( _.strIs( begin ),'expects string' );
  _.assert( arguments.length === 2 );

  return src.lastIndexOf( begin,0 ) === 0;
}

//

  /**
    * Compares two strings.
    * @param {string} src - source string
    * @param {string} end
    * @example
        var scr = ._strEnds("abc","c");
    * @return {Boolean}
    * If param end is match with param src last chars than return true
    * @method strEnds
    * @memberof wTools
    */

var strEnds = function( src,end )
{

  _.assert( _.strIs( src ),'expects string' );
  _.assert( _.strIs( end ),'expects string' );
  _.assert( arguments.length === 2 );

  return src.indexOf( end,src.length - end.length ) !== -1;
}

//

 /**
   * Cut begin of the string.
   * @param {string} src
   * @param {string} begin
   * @example
     var scr = _.strBeginRemove( "abc","a" );
   * @return {string}
   * If result of method strBegins - false, than return src
   * else cut begin of param src
   * @method strBeginRemove
   * @memberof wTools
   */

var strBeginRemove = function( src,begin )
{
  if( !strBegins( src,begin ) )
  return src;
  return src.substr( begin.length,src.length );
}

//

  /**
   * Cut end of the string.
   * @param {string} src
   * @param {string} end
   * @example
     var scr = _.strEndRemove( "abc","c" );
   * @return {string}
   * If result of method strEnds - false, than return src
   * Else cut end of param src
   * @method strEndRemove
   * @memberof wTools
   */

var strEndRemove = function( src,end )
{
  if( !strEnds( src,end ) )
  return src;
  debugger;
  return src.substr( src.length-end.length,src.length );
}

//

  /**
    * Prepend string to begin of other string.
    * @param {string} src
    * @param {string} begin
    * @example
      var scr = ._strPrependOnce("test","test");
    * @return {string}
    * if begin match with first chars of param src, return src
    * else add param src to param begin
    * @method strPrependOnce
    * @memberof wTools
    */

var strPrependOnce = function( src,begin )
{
  if( src.lastIndexOf( begin,0 ) === 0 )
  return src;
  else
  return begin + src;
}

//

  /**
    * Append string to end of other string.
    * @param {string} src
    * @param {string} end
    * example
      var src = ._strAppendOnce("test","test");
    * @return {string}
    * if end match with last chars of param src, return src
    * else add param end to param src
    * @method strPrependOnce
    * @memberof wTools
  */

var strAppendOnce = function( src,end )
{
  if( src.indexOf( end,src.length - end.length ) !== -1 )
  return src;
  else
  return src + end;
}

// --
// regexp
// --
/*
var regexpModeNames = namesCoded
({
  includeAny : 'includeAny',
  includeAll : 'includeAll',
  excludeAny : 'excludeAny',
  excludeAll : 'excludeAll',
});

var regexpModeNamesToExtend = namesCoded
({
  includeAll : 'includeAll',
  excludeAny : 'excludeAny',
});

var regexpModeNamesToReplace = namesCoded
({
  includeAny : 'includeAny',
  excludeAll : 'excludeAll',
});
*/

/**
 * Escapes special characters with a slash (\). Supports next set of characters : .*+?^=! :${}()|[]/\
 *
 * @example
 * wTools.regexpEscape('Hello. How are you?'); // "Hello\. How are you\?"
 * @param {String} src Regexp string
 * @returns {String} Escaped string
 * @method regexpEscape
 * @memberof wTools
 */

var regexpEscape = function( src )
{
  return src.replace( /([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1" );
}

//

/**
 * Turn a *-wildcard style glob into a regular expression
 * @example
 * var glob = '* /www/*.js';
 * wTools.regexpForGlob(glob);
 * // /^.\/[^\/]*\/www\/[^\/]*\.js$/m
 * @param {String} glob *-wildcard style glob
 * @returns {RegExp} RegExp that represent passed glob
 * @throw {Error} If missed argument, or got more than one argumet
 * @throw {Error} If glob is not string
 * @method regexpForGlob
 * @memberof wTools
 */

var regexpForGlob = function( glob )
{
  var result = '';
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( glob ) );

  var w = 0;
  glob.replace( /(\*\*[\/\\]?)|\?|\*/g, function( matched,a,offset,str )
  {

    result += regexpEscape( glob.substr( w,offset-w ) );
    w = offset + matched.length;

    if( matched === '?' )
    result += '.';
    else if( matched === '*' )
    result += '[^\\\/]*';
    else if( matched.substr( 0,2 ) === '**' )
    result += '.*';
    else throw _.err( 'unexpected' );

  });

  result += regexpEscape( glob.substr( w,glob.length-w ) );
  if( result[ 0 ] !== '^' )
  {
    result = _.strPrependOnce( result,'./' );
    result = _.strPrependOnce( result,'^' );
  }
  result = _.strAppendOnce( result,'$' );

  return RegExp( result,'m' );
}

//


/**
 * Make regexp from string.
 *
 * @example
 * wTools.regexpMakeExpression('Hello. How are you?'); // /Hello\. How are you\?/
 * @param {String} src - string or regexp
 * @returns {String} Regexp
 * @throws {Error} Throw error with message 'unknown type of expression, expects regexp or string, but got' error
 if src not string or regexp
 * @method regexpMakeExpression
 * @memberof wTools
 */
var regexpMakeExpression = function( src )
{

  if( _.regexpIs( src ) )
  return src;

  if( _.strIs( src ) )
  return new RegExp( _.regexpEscape( src ) );

  debugger;
  throw _.err( 'regexpMakeExpression :','unknown type of expression, expects regexp or string, but got',src );
}

//

  /**
   *  Generates "but" regular expression pattern. Accepts a list of words, which will be used in regexp.
   *  The result regexp matches the strings that do not contain any of those words.
   *
   * @example
   * wTools.regexpBut_('yellow', 'red', 'green'); //   /^(? :(?!yellow|red|green).)+$/
   *
   * var options = {
   *    but : ['yellow', 'red', 'green'],
   *    atLeastOnce : false
   * };
   * wTools.regexpBut_(options); // /^(? :(?!yellow|red|green).)*$/
   *
   * @param {Object} [options] options for generate regexp. If this argument omitted then default options will be used
   * @param {String[]} [options.but=null] a list of words,from each will consist regexp
   * @param {boolean} [options.atLeastOne=true] indicates whether search matches at least once
   * @param {...String} [words] a list of words, from each will consist regexp. This arguments can be used instead
   * options object.
   * @returns {RegExp} Result regexp
   * @throws {Error} If passed arguments are not strings or options object.
   * @throws {Error} If options contains any different from 'but' or 'atLeastOnce' properties.
   * @method regexpBut_
   * @memberof wTools
   */

var regexpBut_ = function( options )
{
  var args = arguments;
  var atLeastOnce = regexpBut_.defaults.atLeastOnce;
  if( arguments.length === 1 && _.objectIs( options ) )
  {
    _.assertMapOnly( options,regexpBut_.defaults );
    _.mapComplement( options,regexpBut_.defaults );
    args = options.but;
    atLeastOnce = options.atLeastOnce;
  }

  var words = _.arrayFlatten( args );
  var result = '^(?:(?!';

  // !!! test me in builder
  // var result = '^(? :(?!';

  for( var w = 0 ; w < words.length ; w++ )
  _.assert( _.strIs( words[ w ] ) );

  result += words.join( '|' );

  if( atLeastOnce )
  result += ').)+$';
  else
  result += ').)*$';

  /* console.log( 'regexpBut_.result : ' + result ) */

  return new RegExp( result );
}

regexpBut_.defaults =
{
  but : null,
  atLeastOnce : true,
}

//

/**
 * Wraps regexp(s) into array and returns it. If in `src` passed string - turn it into regexp
 *
 * @example
 * wTools.regexpArrayMake( ['red', 'white', /[a-z]/] ); // [ /red/, /white/, /[a-z]/ ]
 * @param {String[]|String} src - array of strings/regexps or single string/regexp
 * @returns {RegExp[]} Array of regexps
 * @throw {Error} if `src` in not string, regexp, or array
 * @method regexpArrayMake
 * @memberof wTools
 */

var regexpArrayMake = function( src )
{

  _.assert( _.arrayIs( src ) || _.regexpIs( src ) || _.strIs( src ),'expects array/regexp/string, got ' + _.strTypeOf( src ) );

  src = _.arrayFlatten( src );

  _.each( src,function( e,k,i )
  {

    src[ k ] = _.regexpMakeExpression( e );

  });

  return src;
}

//

  /**
   * regexpArrayIndex() returns the index of the first regular expression that matches substring
    Otherwise, it returns -1.
   * @example
   *
     var str = "The RGB color model is an additive color model in which red, green, and blue light are added together in various ways to reproduce a broad array of colors";
     var regArr1 = [/white/, /green/, /blue/];
     wTools.regexpArrayIndex(regArr1, str); // 1

   * @param {RegExp[]} arr Array for regular expressions.
   * @param {String} ins String, inside which will be execute search
   * @returns {number} Index of first matching or -1.
   * @throws {Error} If first argument is not array.
   * @throws {Error} If second argument is not string.
   * @throws {Error} If element of array is not RegExp.
   * @method regexpArrayIndex
   * @memberof wTools
   */

var regexpArrayIndex = function regexpArrayIndex( arr,ins )
{
  _.assert( _.arrayIs( arr ) );
  _.assert( _.strIs( ins ) );

  for( var a = 0 ; a < arr.length ; a++ )
  {
    var regexp = arr[ a ];
    _.assert( _.regexpIs( regexp ) );
    if( regexp.test( ins ) )
    return a;
  }

  return -1;
}

//

/**
 * Checks if any regexp passed in `arr` is found in string `ins`
 * If match was found - returns match index
 * If no matches found and regexp array is not empty - returns false
 * If regexp array is empty - returns some default value passed in the `none` input param
 *
 * @example
 * var str = "The RGB color model is an additive color model in which red, green, and blue light are added together in various ways to reproduce a broad array of colors";
 *
 * var regArr2 = [/yellow/, /blue/, /red/];
 * wTools._regexpArrayAny(regArr2, str, false); // 1
 *
 * var regArr3 = [/yellow/, /white/, /greey/]
 * wTools._regexpArrayAny(regArr3, str, false); // false
 * @param {String[]} arr Array of regular expressions strings
 * @param {String} ins - string that is tested by regular expressions passed in `arr` parameter
 * @param {*} none - Default return value if array is empty
 * @returns {*} Returns the first match index, false if input array of regexp was empty or default value otherwise
 * @thows {Error} If missed one of arguments
 * @method _regexpArrayAny
 * @memberof wTools
 */

var _regexpArrayAny = function( arr,ins,none )
{

  _.assert( _.arrayIs( arr ) || _.regexpIs( src ) );
  _.assert( arguments.length === 3 );

  var arr = _.arrayAs( arr );
  for( var m = 0 ; m < arr.length ; m++ )
  {
    if( arr[ m ].test( ins ) )
    return m;
  }

  return arr.length ? false : none;
}

//

/**
 * Checks if all regexps passed in `arr` are found in string `ins`
 * If any of regex was not found - returns match index
 * If regexp array is not empty and all regexps passed test - returns true
 * If regexp array is empty - returns some default value passed in the `none` input param
 *
 * @example
 * var str = "The RGB color model is an additive color model in which red, green, and blue light are added together in various ways to reproduce a broad array of colors";
 *
 * var regArr1 = [/red/, /green/, /blue/];
 * wTools._regexpArrayAll(regArr1, str, false); // true
 *
 * var regArr2 = [/yellow/, /blue/, /red/];
 * wTools._regexpArrayAll(regArr2, str, false); // 0
 * @param {String[]} arr Array of regular expressions strings
 * @param {String} ins - string that is tested by regular expressions passed in `arr` parameter
 * @param {*} none - Default return value if array is empty
 * @returns {*} Returns the first match index, false if input array of regexp was empty or default value otherwise
 * @thows {Error} If missed one of arguments
 * @method _regexpArrayAll
 * @memberof wTools
 */

var _regexpArrayAll = function( arr,ins,none )
{
  _.assert( _.arrayIs( arr ) || _.regexpIs( src ) );
  _.assert( arguments.length === 3 );

  var arr = _.arrayAs( arr );
  for( var m = 0 ; m < arr.length ; m++ )
  {
    if( !arr[ m ].test( ins ) )
    return m;
  }

  return arr.length ? true : none;
}

//

  /**
   * Make RegexpObject from different type sources.
      If passed RegexpObject or map with properties similar to RegexpObject but with string in values, then the second
   parameter is not required;
      All strings in sources will be turned into RegExps.
      If passed single RegExp/String or array of RegExps/Strings, then method will return RegexpObject with
   `defaultMode` as key, and array of RegExps created from first parameter as value.
      If passed array of RegexpObject, mixed with ordinary RegExps/Strings, the result object will be created by merging
   with shrinking (see [shrink]{@link wTools#shrink}) RegexpObjects and RegExps that associates
   with `defaultMode` key.
   *
   * @example
     var src = [
         /hello/,
         'world',
         {
            includeAny : ['yellow', 'blue', 'red'],
            includeAll : [/red/, /green/, /brown/],
            excludeAny : [/yellow/, /white/, /grey/],
            excludeAll : [/red/, /green/, /blue/]
         }
     ];
     wTools.regexpMakeObject(src, 'excludeAll');

     // {
     //    includeAny: [/yellow/, /blue/, /red/],
     //    includeAll: [/red/, /green/, /brown/],
     //    excludeAny: [/yellow/, /white/, /grey/],
     //    excludeAll: [/hello/, /world/]
     // }
   * @param {RegexpObject|String|RegExp|RegexpObject[]|String[]|RegExp[]} src Source for making RegexpObject
   * @param {String} [defaultMode] key for result RegexpObject map. Can be one of next strings: 'includeAny',
   'includeAll','excludeAny' or 'excludeAll'.
   * @returns {RegexpObject} Result RegexpObject
   * @throws {Error} Missing arguments if call without argument
   * @throws {Error} Missing arguments if passed array without `defaultMode`
   * @throws {Error} Unknown mode `defaultMode`
   * @throws {Error} Unknown src if first argument is not array, map, string or regexp.
   * @throws {Error} Unexpected if type of array element is not string regexp or RegexpObject.
   * @throws {Error} Unknown regexp filters if passed map has unexpected properties (see RegexpObject).
   * @method regexpMakeObject
   * @memberof wTools
   */

var regexpMakeObject = function( src,defaultMode )
{

  return _.RegexpObject( src,defaultMode );

}

// --
// routine
// --

/**
 * Internal implementation.
 * @param {object} object - object to check.
 * @return {object} object - name in key/value format.
 * @method _routineBind
 * @memberof wTools
 */

var _routineBind = function _routineBind( options )
{

  _assert( arguments.length === 1 );
  _assert( _.boolIs( options.seal ) );
  _assert( _.routineIs( options.routine ),'_routineBind :','expects routine' );
  _assert( _.arrayIs( options.args ) || _.argumentsIs( options.args ) || options.args === undefined );

  var routine = options.routine;
  var args = options.args;
  var context = options.context;

  if( _FunctionBind )
  {

    if( context !== undefined && args === undefined )
    {
      if( options.seal === true )
      throw _.err( 'not tested, not clear what convetion was meant. use [] as third argument or rotineJoin' );
      return _FunctionBind.call( routine, context );
    }
    else if( context !== undefined )
    {
      if( options.seal === true )
      {
        return function sealedContextAndArguments()
        {
          return routine.apply( context, args );
        }
      }
      else
      {
        var a = _.arrayAppendMerging( [ context ],args );
        return _FunctionBind.apply( routine, a );
      }
    }
    else
    {
      if( !args )
      args = [];

      if( options.seal === true )
      return function sealedArguments()
      {
        /*throw _.err( 'not tested' );*/
        return routine.apply( undefined, args );
      }
      else
      return function boundArguments()
      {
        var a = args.slice();
        _.arrayAppendMerging( a,arguments );
        return routine.apply( this, a );
      }

    }

  }

  //

  throw _.err( 'not implemented' );

}

//

  /**
   * The routineBind() method creates a new function with its 'this' (context) set to the provided `context`
   value. Unlike Function.prototype.bind() method if `context` is undefined`, in new function 'this' context will not be
   sealed. Argumetns `args` of target function which are passed before arguments of binded function during calling of
   target function.
   * Besides the aforementioned difference, routineBind method accepts function as argument, that makes it more useful
      than Function.prototype.bind().
   * @example
      var o = {
          z: 5
      };

      var y = 4;

      function sum(x, y) {
         return x + y + this.z;
      }
      var newSum = wTools.routineBind(sum, o, [3]);
      newSum(y); // 12

     var f1 = function(){ console.log( this ) };
     var f2 = f1.bind( undefined ); // context of new function sealed to undefined (or global object);
     f2.call( o ); // try to call new function with context set to { z: 5 }
     var f3 = _.routineBind( f1 ); // new function, 'this' is undefined/global object.
     f3.call( o ) // print  { z: 5 }
   * @param {Function} routine Function which will be used as base for result function.
   * @param {Object} context The value that will be set as 'this' keyword in new function
   * @param {Array<*>} args Arguments to prepend to arguments provided to the bound function when invoking the target
   function. Must be wraped into array.
   * @returns {Function} New created function with preceding this, and args.
   * @throws {Error} When first argument is not callable throws error with text 'first argument must be a routine'
   * @thorws {Error} If passed arguments more than 3 throws error with text 'expects 3 or less arguments'
   * @method routineBind
   * @memberof wTools
   */

var routineBind = function routineBind( routine, context, args )
{

  _assert( _.routineIs( routine ),'routineBind :','first argument must be a routine' );
  _assert( arguments.length <= 3,'routineBind :','expects 3 or less arguments' );

  return _routineBind
  ({
    routine : routine,
    context : context,
    args : args,
    seal : false,
  });

}

//

  /**
   * The routineJoin() method creates a new function with its 'this' (context) set to the provided `context`
   value. Argumetns `args` of target function which are passed before arguments of binded function during
   calling of target function. Unlike routineBind method, position of `context` parameter is more intuitive.
   * @example
     var o = {
          z: 5
      };

     var y = 4;

     function sum(x, y) {
         return x + y + this.z;
      }
     var newSum = wTools.routineJoin(o, sum, [3]);
     newSum(y); // 12

     var f1 = function(){ console.log( this ) };
     var f2 = f1.bind( undefined ); // context of new function sealed to undefined (or global object);
     f2.call( o ); // try to call new function with context set to { z: 5 }
     var f3 = _.routineJoin( undefined,f1 ); // new function.
     f3.call( o ) // print  { z: 5 }

   * @param {Object} context The value that will be set as 'this' keyword in new function
   * @param {Function} routine Function which will be used as base for result function.
   * @param {Array<*>} args Argumetns of target function which are passed before arguments of binded function during
   calling of target function. Must be wraped into array.
   * @returns {Function} New created function with preceding this, and args.
   * @see wTools.routineBind
   * @throws {Error} When second argument is not callable throws error with text 'first argument must be a routine'
   * @thorws {Error} If passed arguments more than 3 throws error with text 'expects 3 or less arguments'
   * @method routineJoin
   * @memberof wTools
   */

var routineJoin = function routineJoin( context, routine, args )
{

  _assert( _.routineIs( routine ),'routineJoin :','second argument must be a routine' );
  _assert( arguments.length <= 3,'routineJoin :','expects 3 or less arguments' );

  return _routineBind
  ({
    routine : routine,
    context : context,
    args : args,
    seal : false,
  });

}

//

  /**
   * Return new function with sealed context and arguments.
   *
   * @example
   var o = {
        z: 5
    };

   function sum(x, y) {
       return x + y + this.z;
    }
   var newSum = wTools.routineSeal(o, sum, [3, 4]);
   newSum(y); // 12
   * @param {Object} context The value that will be set as 'this' keyword in new function
   * @param {Function} routine Function which will be used as base for result function.
   * @param {Array<*>} args Arguments wrapped into array. Will be used as argument to `routine` function
   * @returns {Function} Result function with sealed context and arguments.
   * @method routineJoin
   * @memberof wTools
   */

var routineSeal = function routineSeal( context, routine, args )
{

  _assert( _.routineIs( routine ),'routineSeal :','second argument must be a routine' );
  _assert( arguments.length <= 3,'routineSeal :','expects 3 or less arguments' );

  return _routineBind
  ({
    routine : routine,
    context : context,
    args : args,
    seal : true,
  });

}

//

  /**
   * Return function that will call passed routine function with delay.
   * @param {number} delay delay in milliseconds
   * @param {Function} routine function that will be called with delay.
   * @returns {Function} result function
   * @throws {Error} If arguments less then 2
   * @throws {Error} If `delay` is not a number
   * @throws {Error} If `routine` is not a function
   * @method routineDelayed
   * @memberof wTools
   */

var routineDelayed = function routineDelayed( delay,routine )
{

  _.assert( arguments.length >= 2 );
  _.assert( _.numberIs( delay ) );
  _.assert( _.routineIs( routine ) );

  if( arguments.length > 2 )
  {
    _assert( arguments.length <= 4 );
    routine = _.routineJoin.call( _,arguments[ 1 ],arguments[ 2 ],arguments[ 3 ] );
  }

  return function delayed()
  {
    _.timeOut( delay,this,routine,arguments );
  }

}
//

  /**
   * Call each routines in array with passed context and arguments.
      The context and arguments are same for each called functions.
      Can accept only routines without context and args.
      Can accept single routine instead array.
   * @example
      var x = 2, y = 3,
          o { z : 6 };

      var sum = function( x, y )
      {
          return x + y + this.z;
      },
      prod = function( x, y )
      {
          return x * y * this.z;
      },
      routines = [ sum, prod ];
      var res = wTools.routinesCall( o, routines, [ x, y ] );
   // [ 11, 36 ]
   * @param {Object} [context] Context in which calls each function.
   * @param {Function[]} routines Array of called function
   * @param {Array<*>} [args] Arguments that will be passed to each functions.
   * @returns {Array<*>} Array with results of functions invocation.
   * @method routinesCall
   * @memberof wTools
   */

var routinesCall = function routinesCall()
{
  var result = [];

  _.assert( arguments.length >= 1 && arguments.length <= 3  );

  if( arguments.length === 1 )
  {

    var routines = arguments[ 0 ];
    _.assert( _.arrayIs( routines ) || _.routineIs( routines ) );
    var routines = _.arrayAs( routines );
    for( var r = 0 ; r < routines.length ; r++ )
    {
      result[ r ] = routines[ r ]();
    }

  }
  else if( arguments.length === 2 )
  {
    var context = arguments[ 0 ];
    var routines = arguments[ 1 ];
    _.assert( _.arrayIs( routines ) || _.routineIs( routines ) );
    var routines = _.arrayAs( routines );
    for( var r = 0 ; r < routines.length ; r++ )
    {
      result[ r ] = routines[ r ].call( context );
    }
  }
  else if( arguments.length === 3 )
  {
    var context = arguments[ 0 ];
    var routines = arguments[ 1 ];
    var args = arguments[ 2 ];
    _.assert( _.arrayIs( routines ) || _.routineIs( routines ) );
    _.assert( _.arrayLike( args ) );
    var routines = _.arrayAs( routines );
    for( var r = 0 ; r < routines.length ; r++ )
    {
      result[ r ] = routines[ r ].apply( context,args );
    }
  }

  return result;
}

//

var routineOptions = function routineOptions( routine,options )
{

  if( options === undefined )
  options = {};

  _.assert( arguments.length === 2,'routineOptions : expects 2 arguments' );
  _.assert( _.routineIs( routine ),'routineOptions : expects routine' );
  _.assert( _.objectIs( routine.defaults ),'routineOptions : expects routine with defined defaults' );
  _.assert( _.objectIs( options ),'routineOptions : expects object' );

  _.assertMapNoUndefine( options );
  _.assertMapOnly( options,routine.defaults );
  _.mapComplement( options,routine.defaults );

  return options;
}

// --
// time
// --

var timeReady = function( onReady )
{
  _assert( arguments.length === 1 );
  _assert( _.routineIs( onReady ) );

  if( typeof window !== 'undefined' && typeof document !== 'undefined' && document.readyState != 'complete' )
  {
    window.addEventListener( 'load',onReady );
  }
  else
  {
    _.timeOut( 1,onReady );
  }

}

//

var timeOnce = function( delay,onBegin,onEnd )
{

  var con = new wConsequence();
  var taken = false;
  var options;
  var optionsDefault =
  {
    delay : null,
    onBegin : null,
    onEnd : null,
  }

  if( _.objectIs( delay ) )
  {
    options = delay;
    _assert( arguments.length === 1 );
    _.assertMapOnly( options,optionsDefault );
    delay = options.delay;
    onBegin = options.onBegin;
    onEnd = options.onEnd;
  }
  else
  {
    _assert( 2 <= arguments.length && arguments.length <= 3 );
  }

  _assert( delay >= 0 );
  _assert( _.atomicIs( onBegin ) || _.routineIs( onBegin ) || _.objectIs( onBegin ) );
  _assert( _.atomicIs( onEnd ) || _.routineIs( onEnd ) || _.objectIs( onEnd ) );

  return function timeOnce()
  {

    if( taken )
    {
      /*console.log( 'timeOnce :','was taken' );*/
      return;
    }
    taken = true;

    if( onBegin )
    {
      if( _.routineIs( onBegin ) ) onBegin.apply( this,arguments );
      else if( _.objectIs( onBegin ) ) onBegin.give( arguments );
      con.give();
    }

    _.timeOut( delay,function()
    {

      if( onEnd )
      {
        if( _.routineIs( onEnd ) ) onEnd.apply( this,arguments );
        else if( _.objectIs( onEnd ) ) onEnd.give( arguments );
        con.give();
      }
      taken = false;

    });

    return con;
  }

}

//

var timeOut = function( delay,onReady )
{
  var con = new wConsequence();

  if( arguments.length > 2 )
  if( !_.routineIs( arguments[ 2 ] ) )
  debugger;

  _assert( _.numberIs( delay ) );

  if( arguments.length === 2 )
  _assert( _.routineIs( onReady ) || onReady instanceof wConsequence );
  else if( arguments.length > 2 )
  _assert( _.routineIs( arguments[ 2 ] ) );

  var onEnd = function()
  {
    var result;

    if( onReady )
    con.first( onReady );
    else
    con.give();

/*
    if( _.routineIs( onReady ) )
    {
      result = onReady();
      if( result instanceof wConsequence )
      result.then_( con );
      else
      con.give( result );
    }
    else if( onReady instanceof wConsequence )
    {
      onReady.then_( con );
      onReady.give();
    }
    else
    {
      con.give();
    }
*/

  }

  if( arguments.length > 2 )
  {
    _assert( arguments.length <= 4 );
    onReady = _.routineJoin.call( _,arguments[ 1 ],arguments[ 2 ],arguments[ 3 ] );
  }

  setTimeout( onEnd,delay );

  return con;
}

//

var timePeriodic = function( delay,onReady )
{
  var con = new wConsequence();
  var id;

  if( arguments.length > 2 )
  {
    throw _.err( 'Not tested' );
    _assert( arguments.length <= 4 );
    onReady = _.routineJoin( arguments[ 2 ],onReady[ 3 ],arguments[ 4 ] );
  }

  _assert( _.numberIs( delay ) );

  var handlePeriodicCon = function( err )
  {
    if( err ) clearInterval( id );
  }

  var _onReady = null;

  if( _.routineIs( onReady ) )
  _onReady = function()
  {
    var result = onReady.call();
    if( result === false )
    clearInterval( id );
    wConsequence.give( con );
    con.then_( handlePeriodicCon );
  }
  else if( onReady instanceof wConsquence )
  _onReady = function()
  {
    var result = onReady.ping();
    if( result === false )
    clearInterval( id );
    wConsequence.give( con );
    con.then_( handlePeriodicCon );
  }
  else if( onReady === undefined )
  _onReady = function()
  {
    wConsequence.give( con );
    con.then_( handlePeriodicCon );
  }
  else throw _.err( 'unexpected type of onReady' );

  id = setInterval( _onReady,delay );

  return con;
}

//

var _timeNow_gen = function()
{
  var now;

  _assert( arguments.length === 0 );

  if( typeof performance !== 'undefined' && performance.now !== undefined )
  now = _.routineJoin( performance,performance.now );
  else if( Date.now )
  now = _.routineJoin( Date,Date.now );
  else
  now = function(){ return Date().getTime() };

  return now;
}

//

var timeSpent = function( description,time )
{
  var now = timeNow();

  if( arguments.length === 1 )
  {
    time = arguments[ 0 ];
    description = 'Spent';
  }

  _assert( 1 <= arguments.length && arguments.length <= 2 );
  _assert( _.numberIs( time ) );
  _assert( _.strIs( description ) );

  if( description && description !== ' ' )
  description = description + ' : ';

  var result = description + ( 0.001*( now-time ) ).toFixed( 3 ) + 's';

  return result;
}

//

var dateToStr = function dateToStr( date )
{
  var y = date.getFullYear();
  var m = date.getMonth() + 1;
  var d = date.getDate();
  if( m < 10 ) m = '0' + m;
  if( d < 10 ) d = '0' + d;
  var result = [ y,m,d ].join( '.' );
  return result;
}

// --
// buffer
// --

  /**
   * The bufferRelen() method returns a new or the same typed array (src) with a new or the same length (len).
   *
   * It creates the variable (result) checks, if (len) is more than (src.length),
   * if true, it creates and assigns to (result) a new typed array with the new length (len) by call the function (arrayNew(src, len))
   * and copies each element from the (src) into the (result) array while ensuring only valid data types, if data types are invalid they are replaced with zero.
   * Otherwise, if (len) is less than (src.length) it returns a new typed array from 0 to the (len) indexes, but not including (len).
   * Otherwise, it returns an initial typed array.
   *
   * @see {@link wTools.arrayNew} - See for more information.
   *
   * @param { typedArray } src - The source typed array.
   * @param { Number } len - The length of a typed array.
   *
   * @example
   * // returns [ 3, 7, 13, 0 ]
   * var ints = new Int8Array( [ 3, 7, 13 ] );
   * _.bufferRelen( ints, 4 );
   *
   * @example
   * // returns [ 3, 7, 13 ]
   * var ints2 = new Int16Array( [ 3, 7, 13, 33, 77 ] );
   * _.bufferRelen( ints2, 3 );
   *
   * @example
   * // returns [ 3, 0, 13, 0, 77, 0 ]
   * var ints3 = new Int32Array( [ 3, 7, 13, 33, 77 ] );
   * _.bufferRelen( ints3, 6 );
   *
   * @returns { typedArray } - Returns a new or the same typed array (src) with a new or the same length (len).
   * @method bufferRelen
   * @memberof wTools
   */

var bufferRelen = function( src,len )
{

  _.assert( _.bufferIs( src ) );
  _.assert( arguments.length === 2 );
  _.assert( _.numberIs( len ) );

  var result = src;

  if( len > src.length )
  {
    result = arrayNew( src, len );
    result.set( src );
  }
  else if( len < src.length )
  {
    result = src.subarray( 0,len );
  }

  return result;
}

//

var bufferResize = function bufferResize( src,size )
{
  var result = src;

  if( !( src instanceof ArrayBuffer ) )
  throw _.err( '_.bufferResize :','"src" is not instance of "ArrayBuffer"' );

  if( size > src.byteLength )
  {
    result = arrayNew( src, size );
    var resultTyped = new Uint8Array( result,0,result.byteLength );
    var srcTyped = new Uint8Array( src,0,src.byteLength );
    resultTyped.set( srcTyped );
  }
  else if( size < src.byteLength )
  {
    result = src.slice( 0,size );
  }

  return result;
}

//

var bufferBytesGet = function( src )
{

  if( src instanceof ArrayBuffer )
  {
    return new Uint8Array( src );
  }
  else if( typeof Buffer !== 'undefined' && src instanceof Buffer )
  {
    return new Uint8Array( src.buffer,src.byteOffset,src.byteLength );
  }
  else if( _.bufferIs( src ) )
  {
    return new Uint8Array( src.buffer,src.byteOffset,src.byteLength );
  }
  else if( _.strIs( src ) )
  {
    return new Uint8Array( _.utf8ToBuffer( src ) );
  }
  else throw _.err( '_.bufferBytesGet :','wrong argument' );

}

//

  /**
   * The bufferRetype() method converts and returns a new instance of (bufferType) constructor.
   *
   * @param { typedArray } src - The typed array.
   * @param { typedArray } bufferType - The type of typed array.
   *
   * @example
   * // returns [ 513, 1027, 1541 ]
   * var view1 = new Int8Array( [ 1, 2, 3, 4, 5, 6 ] );
   * _.bufferRetype(view1, Int16Array);
   *
   * @example
   * // returns [ 1, 2, 3, 4, 5, 6 ]
   * var view2 = new Int16Array( [ 513, 1027, 1541 ] );
   * _.bufferRetype(view2, Int8Array);
   *
   * @returns { typedArray } Returns a new instance of (bufferType) constructor.
   * @method bufferRetype
   * @throws { Error } Will throw an Error if (src) is not a typed array object.
   * @throws { Error } Will throw an Error if (bufferType) is not a type of the typed array.
   * @memberof wTools
   */

var bufferRetype = function( src,bufferType )
{

  _.assert( _.bufferIs( src ) );
  _.assert( _.typeIsBuffer( bufferType ) );

  var o = src.byteOffset;
  var l = Math.floor( src.byteLength / bufferType.BYTES_PER_ELEMENT );
  var result = new bufferType( src.buffer,o,l );

  return result;
}

//

var bufferMove = function( dst,src )
{

  if( arguments.length === 2 )
  {

    _.assert( _.arrayLike( dst ) );
    _.assert( _.arrayLike( src ) );

    if( dst.length !== src.length )
    throw _.err( '_.bufferMove :','"dst" and "src" must have same length' );

    if( dst.set )
    {
      dst.set( src );
      return dst;
    }

    for( var s = 0 ; s < src.length ; s++ )
    dst[ s ] = src[ s ];

  }
  else if( arguments.length === 1 )
  {

    var options = arguments[ 0 ];
    _.assertMapOnly( options,bufferMove.defaults );

    var src = options.src;
    var dst = options.dst;

    if( _.bufferRawIs( dst ) )
    {
      dst = new Uint8Array( dst );
      if( _.bufferIs( src ) && !( src instanceof Uint8Array ) )
      src = new Uint8Array( src.buffer,src.byteOffset,src.byteLength );
    }

    _.assert( _.arrayLike( dst ) );
    _.assert( _.arrayLike( src ) );

    options.dstOffset = options.dstOffset || 0;

    if( dst.set )
    {
      dst.set( src,options.dstOffset );
      return dst;
    }

    for( var s = 0, d = options.dstOffset ; s < src.length ; s++, d++ )
    dst[ d ] = src[ s ];

  }
  else throw _.err( 'unexpected' );

  return dst;
}

bufferMove.defaults =
{
  dst : null,
  src : null,
  dstOffset : null,
}

//

var bufferToStr = function( src,options )
{

  var result = '';
  var options = options || {};

  if( src instanceof ArrayBuffer ) src = new Uint8Array( src,0,src.byteLength );

  try
  {
    result = String.fromCharCode.apply( null, src );
  }
  catch( e )
  {
    for( var i = 0 ; i < src.byteLength ; i++ )
    {
      result += String.fromCharCode( src[i] );
    }
  }

  return result;
}

//

var bufferToDom = function( xmlBuffer ) {

  var result;

  if( typeof DOMParser !== 'undefined' && DOMParser.prototype.parseFromBuffer )
  {

    var parser = new DOMParser();
    result = parser.parseFromBuffer( xmlBuffer,xmlBuffer.byteLength,'text/xml' );
    throw _.err( 'not tested' );

  }
  else
  {

    var xmlStr = _.bufferToStr( xmlBuffer );
    result = this.strToDom( xmlStr );

  }

  return result;
}

//

var bufferLeftBufferIndex = function( src,ins )
{

  if( !_.bufferIs( src ) )
  src = _.bufferBytesGet( src );

  if( !_.bufferIs( ins ) )
  ins = _.bufferBytesGet( ins );

  _.assert( _.bufferIs( src ) );
  _.assert( _.bufferIs( ins ) );

/*
    var srcw = _.bufferRetype( src,Uint32Array );
    var insw = _.bufferRetype( ins,Uint32Array );
    debugger;
*/

  var o = -1
  do
  {

    o += 1;
    var o = src.indexOf( ins[ 0 ],o );

    for( var i = 0 ; i < ins.length ; i++ )
    if( src[ o+i ] !== ins[ i ] )
    break;

    if( i === ins.length )
    return o;

  }
  while( o !== -1 );

  return -1;
}

//

var bufferFromArrayOfArray = function( array,options ){

  if( _.objectIs( array ) )
  {
    options = array;
    array = options.buffer;
  }

  var options = options || {};
  var array = options.buffer = array || options.buffer;

  //

  if( options.BufferType === undefined ) options.BufferType = Float32Array;
  if( options.sameLength === undefined ) options.sameLength = 1;
  if( !options.sameLength ) throw _.err( '_.bufferFromArrayOfArray :','differemt length of arrays is not implemented' );

  if( !array.length ) return new options.BufferType();

  var atomsPerElement = _.numberIs( array[ 0 ].length ) ? array[ 0 ].length : array[ 0 ].len;

  if( !_.numberIs( atomsPerElement ) ) throw _.err( '_.bufferFromArrayOfArray :','cant find out element length' );

  var length = array.length * atomsPerElement;
  var result = new options.BufferType( length );
  var i = 0;

  for( var a = 0 ; a < array.length ; a++ )
  {

    var element = array[ a ];

    for( var e = 0 ; e < atomsPerElement ; e++ )
    {

      result[ i ] = element[ e ];
      i += 1;

    }

  }

  return result;
}

//

var bufferFrom = function( o )
{
  var result;

  _assert( arguments.length === 1 );
  _assert( _.objectIs( o ) );
  _assert( _.routineIs( o.bufferConstructor ),'expects bufferConstructor' );
  _.assertMapOnly( o,bufferFrom.defaults );

  /* buffer */

  if( _.bufferIs( o.src ) )
  {
    if( o.src.constructor === o.bufferConstructor )
    return o.src;

    debugger;

    result = new o.bufferConstructor( o.src );
    return result;
  }

  /* number */

  if( _.numberIs( o.src ) )
  o.src = [ o.src ];

  /* midverification */

  _.assert( _.objectLike( o.src ) || _.arrayLike( o.src ),'bufferFrom expects object-like or array-like as o.src' );

  /* length */

  var length = o.src.length;
  if( !_.numberIs( length ) )
  {

    var length = 0;
    while( o.src[ length ] !== undefined )
    length += 1;

  }

  /* make */

  if( _.arrayIs( o.src ) )
  result = new o.bufferConstructor( o.src );
  else if ( _.arrayLike( o.src ) )
  {
    result = new o.bufferConstructor( o.src );
    throw _.err( 'not tested' );
  }
  else
  {
    result = new o.bufferConstructor( length );
    for( var i = 0 ; i < length ; i++ )
    result[ i ] = o.src[ i ];
  }

  return result;
}

bufferFrom.defaults =
{
  src : null,
  bufferConstructor : null,
}

//
  /**
   * The bufferRawFromBuffer() method returns a new ArrayBuffer from (buffer.byteOffset) to the end of an ArrayBuffer of a typed array (buffer)
   * or returns the same ArrayBuffer of the (buffer), if (buffer.byteOffset) is not provided.
   *
   * @param { typedArray } buffer - Entity to check.
   *
   * @example
   * // returns [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]
   * var buffer1 = new ArrayBuffer(10);
   * var view1 = new Int8Array( buffer1 );
   * _.bufferRawFromBuffer( view1 );
   *
   * @example
   * // returns [ 0, 0, 0, 0, 0, 0 ]
   * var buffer2 = new ArrayBuffer(10);
   * var view2 = new Int8Array( buffer2, 2 );
   * _.bufferRawFromBuffer( view2 );
   *
   * @returns { ArrayBuffer } Returns a new or the same ArrayBuffer.
   * If (buffer) is instance of '[object ArrayBuffer]', it returns buffer.
   * @method bufferRawFromBuffer
   * @throws { Error } Will throw an Error if (arguments.length) is not equal to the 1.
   * @throws { Error } Will throw an Error if (buffer) is not a typed array.
   * @memberof wTools
   */

var bufferRawFromBuffer = function( buffer )
{

  _.assert( arguments.length === 1 );
  _.assert( _.bufferIs( buffer ) || _.bufferRawIs( buffer ) );

  if( _.bufferRawIs( buffer ) )
  return buffer;

  var result = buffer.buffer;

  if( buffer.byteOffset || buffer.byteLength !== result.byteLength )
  result = result.slice( buffer.byteOffset || 0,buffer.byteLength );

  _.assert( _.bufferRawIs( result ) );

  return result;
}

//

var bufferRawFrom = function( buffer )
{
  var result;

  _.assert( arguments.length === 1 );

  if( buffer instanceof ArrayBuffer )
  return buffer;

  if( _.bufferNodeIs( buffer ) )
  {

    result = new Uint8Array( buffer ).buffer;

  }
  else if( _.bufferIs( buffer ) || _.bufferViewIs( buffer ) )
  {

    buffer = buffer.buffer;
    if( buffer.byteOffset || buffer.byteLength !== result.byteLength )
    result = result.slice( buffer.byteOffset || 0,buffer.byteLength );

  }
  else if( _.strIs( buffer ) )
  {

    result = _.utf8ToBuffer( buffer ).buffer;

  }
  else if( _global_.File && buffer instanceof File )
  {
    var fileReader = new FileReaderSync();
    result = fileReader.readAsArrayBuffer( buffer );
    throw _.err( 'not tested' );
  }
  else throw _.err( 'bufferRawFrom : unknown source' );

  _.assert( _.bufferRawIs( result ) );

  return result;
}

//

var buffersSerialize = function buffersSerialize( o )
{
  var self = this;
  var size = 0;
  var o = o || {};

  _.assertMapNoUndefine( o );
  _.assertMapOnly( o,buffersSerialize.defaults );
  _.mapComplement( o,buffersSerialize.defaults );
  _.assert( _.objectIs( o.store ) );

  var store = o.store;
  var storeAttributes = store[ 'attributes' ] = store[ 'attributes' ] || {};
  var attributes = o.onAttributesGet.call( o.context );
  var buffers = [];

  // eval size

  for( var a = 0 ; a < attributes.length ; a++ )
  {

    var name = attributes[ a ][ 0 ];
    var attribute = attributes[ a ][ 1 ];
    var buffer = o.onBufferGet.call( o.context,attribute );

    _.assert( _.bufferIs( buffer ) || buffer === null,'expects buffer or null, got : ' + _.strTypeOf( buffer ) );

    var bufferSize = buffer ? buffer.length*buffer.BYTES_PER_ELEMENT : 0;

    if( o.dropAttribute && o.dropAttribute[ name ] )
    continue;

    var descriptor = {};
    descriptor.attribute = attribute;
    descriptor.name = name;
    descriptor.buffer = buffer;
    descriptor.bufferSize = bufferSize;
    descriptor.sizeOfAtom = buffer ? buffer.BYTES_PER_ELEMENT : 0;
    buffers.push( descriptor );

    size += bufferSize;

  }

  // make buffer

  if( !store[ 'buffer' ] )
  store[ 'buffer' ] = new ArrayBuffer( size );

  var dstBuffer = _.bufferBytesGet( store[ 'buffer' ] );

  _.assert( store[ 'buffer' ].byteLength === size );
  if( store[ 'buffer' ].byteLength < size )
  throw _.err( 'buffersSerialize :','buffer does not have enough space' );

  /* sort by atom size */

  buffers.sort( function( a,b )
  {
    return b.sizeOfAtom - a.sizeOfAtom;
  });

  // store into single buffer

  var offset = 0;
  for( var b = 0 ; b < buffers.length ; b++ )
  {

    var name = buffers[ b ].name;
    var attribute = buffers[ b ].attribute;
    var buffer = buffers[ b ].buffer;
    var bytes = buffer ? _.bufferBytesGet( buffer ) : new Uint8Array();
    var bufferSize = buffers[ b ].bufferSize;

    if( o.dropAttribute && o.dropAttribute[ name ] )
    continue;

    _.bufferMove( dstBuffer.subarray( offset,offset+bufferSize ),bytes );

    var serialized = store[ 'attributes' ][ name ] =
    {
      'bufferConstructorName' : buffer ? buffer.constructor.name : 'null',
      'sizeOfAtom' : buffer ? buffer.BYTES_PER_ELEMENT : 0,
      'offsetInCommonBuffer' : offset,
      'size' : bytes.length,
    }

    // debugger; // xxx

    if( attribute.copyCustom )
    serialized[ 'fields' ] = attribute.copyCustom
    ({

      dst : {},
      src : attribute,

      copyComposes : true,
      copyAggregates : true,
      copyAssociates : false,

      technique : 'data',

    });

    offset += bufferSize;

  }

  // return

  return store;
}

buffersSerialize.defaults =
{

  context : null,
  store : null,

  dropAttribute : {},

  onAttributesGet : function()
  {
    return _.mapPairs( this.attributes );
  },
  onBufferGet : function( attribute )
  {
    return attribute.buffer;
  },

}

//

var buffersDeserialize = function( o )
{
  var o = o || {};
  var store = o.store;
  var commonBuffer = store[ 'buffer' ];

  _.assertMapNoUndefine( o );
  _.assertMapOnly( o,buffersDeserialize.defaults );
  _.mapComplement( o,buffersDeserialize.defaults );
  _.assert( _.objectIs( o.store ) );
  _.assert( _.bufferRawIs( commonBuffer ) || _.bufferIs( commonBuffer ) );

  commonBuffer = _.bufferRawFromBuffer( commonBuffer );

  for( var a in store[ 'attributes' ] )
  {
    var attribute = store[ 'attributes' ][ a ];

    var bufferConstructor = attribute[ 'bufferConstructorName' ] === 'null' ? null : _global_[ attribute[ 'bufferConstructorName' ] ];
    var offset = attribute[ 'offsetInCommonBuffer' ];
    var size = attribute[ 'size' ];
    var sizeOfAtom = attribute[ 'sizeOfAtom' ];
    var fields = attribute[ 'fields' ];

    _.assert( _.routineIs( bufferConstructor ) || bufferConstructor === null,'unknown attribute\' constructor :',attribute[ 'bufferConstructorName' ] )
    _.assert( _.numberIs( offset ),'unknown attribute\' offset in common buffer :',offset )
    _.assert( _.numberIs( size ),'unknown attribute\' size of buffer :',size )
    _.assert( _.numberIs( sizeOfAtom ),'unknown attribute\' sizeOfAtom of buffer :',sizeOfAtom )

    if( attribute.offset+size > commonBuffer.byteLength )
    throw _.err( 'cant deserialize attribute','"'+a+'"','it is out of common buffer' );

    /* logger.log( 'bufferConstructor( ' + commonBuffer + ',' + offset + ',' + size / sizeOfAtom + ' )' ); */

    var buffer = bufferConstructor ? new bufferConstructor( commonBuffer,offset,size / sizeOfAtom ) : null;

    o.onAttribute.call( o.context,fields,buffer,a );

  }

}

buffersDeserialize.defaults =
{
  store : null,
  context : null,
  onAttribute : function( attributeOptions,buffer )
  {
    attributeOptions.buffer = buffer;
    new this.AttributeOfGeometry( attributeOptions ).addTo( this );
  },
}

//

var bufferToNodeBuffer = ( function( buffer )
{

  var toBuffer = null;

  return function bufferToNodeBuffer( buffer )
  {

    _.assert( _.bufferIs( buffer ) || _.bufferRawIs( buffer ) );

    /* */

    if( toBuffer === null )
    try
    {
      toBuffer = require( 'typedarray-to-buffer' );
    }
    catch( err )
    {
      toBuffer = false;
    }

    /* */

    if( !buffer.length && !buffer.byteLength )
    buffer = new Buffer([]);
    else if( toBuffer )
    try
    {
      buffer = toBuffer( buffer );
    }
    catch( err )
    {
      debugger;
      buffer = toBuffer( buffer );
    }
    else throw _.err( 'unexpected' );

    return buffer;
  }

})();

// --
// array
// --

/**
 * The arraySub() method returns a shallow copy of a portion of an array
 * or a new TypedArray that contains
 * the elements from (begin) index to the (end) index,
 * but not including (end).
 *
 * @param { Array } src - Source array.
 * @param { Number } begin - Index at which to begin extraction.
 * @param { Number } end - Index at which to end extraction.
 *
 * @example
 * // returns [ 3, 4 ]
 * var arr = _.arraySub( [ 1, 2, 3, 4, 5 ], 2, 4 );
 *
 * @example
 * // returns [ 2, 3 ]
 * _.arraySub( [ 1, 2, 3, 4, 5 ], -4, -2 );
 *
 * @example
 * // returns [ 1, 2, 3, 4, 5 ]
 * _.arraySub( [ 1, 2, 3, 4, 5 ] );
 *
 * @returns { Array } - Returns a shallow copy of a portion of an array into a new Array.
 * @method arraySub
 * @throws { Error } If the passed arguments is more than three.
 * @throws { Error } If the first argument is not an array.
 * @memberof wTools
 */

var arraySub = function( src,begin,end )
{

  _.assert( arguments.length <= 3 );

  if( _.atomicIs( src ) )
  throw _.err( 'arraySub','Unknown argument type' );

  if( _.routineIs( src.subarray ) )
  return src.subarray( begin,end );

  if( !_.routineIs( src.slice ) )
  throw _.err( 'arraySub','Unknown argument type' );

  return src.slice( begin,end );
}

//

/**
 * The arrayNew() method returns a new array or a new TypedArray with length equal (length)
 * or new TypedArray with the same length of the initial array if second argument is not provided.
 *
 * @param { arrayLike } ins - The instance of an array.
 * @param { Number } [ length = ins.length ] - The length of the new array.
 *
 * @example
 * // returns [ , ,  ]
 * var arr = _.arrayNew( [ 1, 2, 3 ] );
 *
 * @example
 * // returns [ , , ,  ]
 * var arr = _.arrayNew( [ 1, 2, 3 ], 4 );
 *
 * @returns { arrayLike }  Returns an array with a certain (length).
 * @method arrayNew
 * @throws { Error } If the passed arguments is less than two.
 * @throws { Error } If the (length) is not a number.
 * @throws { Error } If the first argument in not an array like object.
 * @throws { Error } If the (length === undefined) and (_.numberIs(ins.length)) is not a number.
 * @memberof wTools
 */

var arrayNew = function( ins,length )
{
  var result;

  _.assert( arguments.length <= 2); // _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( _.numberIs( length ) );

  if( length === undefined )
  {
    _assert( _.numberIs( ins.length ) );
    length = ins.length;
  }

  if( _.arrayIs( ins ) || _.bufferIs( ins ) || ins instanceof ArrayBuffer )
  result = new ins.constructor( length );
  else throw _.err( 'arrayNew :','unknown type of instance' );

  return result;
}

//

/**
 * The arrayNewOfSameLength() method returns a new empty array
 * or a new TypedArray with the same length as in (ins).
 *
 * @param { arrayLike } ins - The instance of an array.
 *
 * @example
 * // returns [ , , , , ]
 * var arr = _.arrayNewOfSameLength( [ 1, 2, 3, 4, 5 ] );
 *
 * @returns { arrayLike } - The new empty array with the same length as in (ins).
 * @method arrayNewOfSameLength
 * @throws { Error } If missed argument, or got more than one argument.
 * @throws { Error } If the first argument in not array like object.
 * @memberof wTools
 */

var arrayNewOfSameLength = function( ins )
{

  _.assert( arguments.length === 1 );

  if( _.atomicIs( ins ) ) return;
  if( !_.arrayIs( ins ) && !_.bufferIs( ins ) ) return;
  var result = arrayNew( ins,ins.length );
  return result;
}

//

/**
 * The arrayOrNumber() method returns a new array
 * which containing the static elements only type of Number.
 *
 * It takes two argument (dst) and (length)
 * checks if the (dst) is a Number, If the (length) is greater than or equal to zero.
 * If true, it returns the new array of static (dst) numbers.
 * Otherwise, if the first argument (dst) is an Array,
 * and its (dst.length) is equal to the (length),
 * it returns the original (dst) Array.
 * Otherwise, it throws an Error.
 *
 * @param { ( Number | Array ) } dst - A number or an Array.
 * @param { Number } length - The length of the new array.
 *
 * @example
 * // returns [ 3, 3, 3, 3, 3, 3, 3 ]
 * var arr = _.arrayOrNumber( 3, 7 );
 *
 * @example
 * // returns [ 3, 7, 13 ]
 * var arr = _.arrayOrNumber( [ 3, 7, 13 ], 3 );
 *
 * @returns { Number[] | Array } - Returns the new array of static numbers or the original array.
 * @method arrayOrNumber
 * @throws { Error } If missed argument, or got less or more than two argument.
 * @throws { Error } If type of the first argument is not a number or array.
 * @throws { Error } If the second argument is less than 0.
 * @throws { Error } If (dst.length) is not equal to the (length).
 * @memberof wTools
 */

var arrayOrNumber = function( dst,length )
{
  _.assert( arguments.length === 2 );
  _.assert( _.numberIs( dst ) || _.arrayIs( dst ),'expects array of number as argument' );
  _.assert( length >= 0 );

  if( _.numberIs( dst ) )
  dst = arrayFill({ times : length , value : dst });
  else if( dst.length !== length )
  throw _.err( 'expects array of length',length,'but got',dst );

  return dst;
}

//

/**
 * The arraySelect() method selects elements from (srcArray) by indexes of (indicesArray).
 *
 * @param { arrayLike } srcArray - Values for the new array.
 * @param { ( arrayLike | object ) } [ indicesArray = indicesArray.indices ] - Indexes of elements from the (srcArray) or options object.
 *
 * @example
 * // returns [ 3, 4, 5 ]
 * var arr = _.arraySelect( [ 1, 2, 3, 4, 5 ], [ 2, 3, 4 ] );
 *
 * @example
 * // returns [ undefined, undefined ]
 * var arr = _.arraySelect( [ 1, 2, 3 ], [ 4, 5 ] );
 *
 * @returns { arrayLike } - Returns a new array with the length equal (indicesArray.length) and elements from (srcArray).
   If there is no element with necessary index than the value will be undefined.
 * @method arraySelect
 * @throws { Error } If passed arguments is not array like object.
 * @throws { Error } If the atomsPerElement property is not equal to 1.
 * @memberof wTools
 */

var arraySelect = function( srcArray,indicesArray )
{
  var atomsPerElement = 1;

  if( _.objectIs( indicesArray ) )
  {
    atomsPerElement = indicesArray.atomsPerElement || 1;
    indicesArray = indicesArray.indices;
  }

  _assert( _.bufferIs( srcArray ) || _.arrayIs( srcArray ) );
  _assert( _.bufferIs( indicesArray ) || _.arrayIs( indicesArray ) );

  var result = new srcArray.constructor( indicesArray.length );

  if( atomsPerElement === 1 )
  for( var i = 0, l = indicesArray.length ; i < l ; i += 1 )
  {
    result[ i ] = srcArray[ indicesArray[ i ] ];
  }
  else
  for( var i = 0, l = indicesArray.length ; i < l ; i += 1 )
  {
    throw _.err( 'Not tested' );
    for( var a = 0 ; a < atomsPerElement ; a += 1 )
    result[ i*atomsPerElement+a ] = srcArray[ indicesArray[ i ]*atomsPerElement+a ];
  }

  return result;
}

//

var arrayIndicesOfGreatest = function( srcArray,numberOfElements,comparator )
{
  var result = [];
  var l = srcArray.length;

  if( comparator === undefined )
  comparator = function( a,b ){
    return b-a;
  };

  var rcomparator = function( a,b ){
    return comparator( srcArray[ a ],srcArray[ b ] );
  };

  for( var i = 0 ; i < l ; i += 1 )
  {

    if( result.length < numberOfElements )
    {
      _.arraySortedAdd( result, i, rcomparator );
      continue;
    }

    /*
    var index = _._arraySortedLookUpAct( result,i,rcomparator,0,result.length-1 );
    var add = index < numberOfElements;xxx
    if( add )
    result[ index ] = i;
    */

    _.arraySortedAdd( result, i, rcomparator );
    result.splice( result.length-1,1 );

  }

  return result;
}

//

/**
 * The arrayFlatten() method returns an array that contains all the passed arguments.
 *
 * It creates two variables the (result) - array and the (src) - elements of array-like object (arguments[]),
 * iterate over array-like object (arguments[]) and assigns to the (src) each element,
 * checks if (src) is not equal to the 'undefined'.
 * If true, it adds element to the result.
 * If (src) is an Array and if element(s) of the (src) is not equal to the 'undefined'.
 * If true, it adds to the (result) each element of the (src) array.
 * Otherwise, if (src) is an Array and if element(s) of the (src) is equal to the 'undefined' it throws an Error.
 *
 * @param {...*} arguments - One or more argument(s).
 *
 * @example
 * // returns [ 'str', {}, 1, 2, 5, true ]
 * var arr = _.arrayFlatten( 'str', {}, [ 1, 2 ], 5, true );
 *
 * @returns { Array } - Returns an array of the passed argument(s).
 * @method arrayFlatten
 * @throws { Error } If (arguments[...]) is an Array and has an 'undefined' element.
 * @memberof wTools
 */

var arrayFlatten = function()
{
  var result = _.arrayIs( this ) ? this : [];

  for( var a = 0 ; a < arguments.length ; a++ )
  {

    var src = arguments[ a ];

    if( !_.arrayLike( src ) )
    {
      if( src !== undefined ) result.push( src );
      continue;
    }

    for( var s = 0 ; s < src.length ; s++ )
    {
      if( _.arrayIs( src[ s ] ) )
      _.arrayFlatten.call( result,src[ s ] );
      else if( src[ s ] !== undefined )
      result.push( src[ s ] );
      else if( src[ s ] === undefined )
      throw _.err( 'array should have no undefined' );
    }

  }

  return result;
}

//

var arrayFlattenToMapUnique = function()
{
  var result = _.arrayIs( this ) ? this : {};

  var extend = function( r,s )
  {
    _.assertMapNone( r,s );
    _.mapExtend( r,s );
  }

  for( var a = 0 ; a < arguments.length ; a++ )
  {

    var src = arguments[ a ];

    if( !_.arrayLike( src ) )
    {
      _.assert( _.objectIs( src ) );
      if( src !== undefined )
      extend( result, src );
      continue;
    }

    for( var s = 0 ; s < src.length ; s++ )
    {
      if( _.arrayIs( src[ s ] ) )
      _.arrayFlattenToMapUnique.call( result,src[ s ] );
      else if( _.objectIs( src[ s ] ) )
      extend( result, src );
      else
      throw _.err( 'array should have only maps' );
    }

  }

  return result;
}

//

var arrayCopy = function arrayCopy()
{
  var result;
  var length = 0;

  // eval length

  for( var a = 0 ; a < arguments.length ; a++ )
  {
    var argument = arguments[ a ];

    if( argument === undefined )
    throw _.err( 'arrayCopy','argument is not defined' );

    if( _.arrayLike( argument ) ) length += argument.length;
    else if( _.bufferRawIs( argument ) ) length += argument.byteLength;
    else length += 1;
  }

  // make result

  if( _.arrayIs( arguments[ 0 ] ) || _.bufferIs( arguments[ 0 ] ) )
  result = arrayNew( arguments[ 0 ],length );
  else if( _.bufferRawIs( arguments[ 0 ] ) )
  result = new ArrayBuffer( length );

  var bufferDst;
  var offset = 0;
  if( _.bufferRawIs( arguments[ 0 ] ) )
  {
    bufferDst = new Uint8Array( result );
  }

  // copy

  for( var a = 0, c = 0 ; a < arguments.length ; a++ )
  {
    var argument = arguments[ a ];
    if( _.bufferRawIs( argument ) )
    {
      bufferDst.set( new Uint8Array( argument ), offset );
      offset += argument.byteLength;
    }
    else if( _.bufferIs( arguments[ 0 ] ) )
    {
      result.set( argument, offset );
      offset += argument.length;
    }
    else if( _.arrayLike( argument ) )
    for( var i = 0 ; i < argument.length ; i++ )
    {
      result[ c ] = argument[ i ];
      c += 1;
    }
    else
    {
      result[ c ] = argument;
      c += 1;
    }
  }

  // !!! not optimal

  return result;
}

//

/**
 * The arrayAppendMerging() method adds one or more elements to the end of the (dst) array
 * and returns the new length of the array.
 *
 * It creates two variables the (result) - array and the (argument) - elements of array-like object (arguments[]),
 * iterate over array-like object (arguments[]) and assigns to the (argument) each element,
 * checks, if (argument) is equal to the 'undefined'.
 * If true, it throws an Error.
 * If (argument) is an array-like.
 * If true, it merges the (argument) into the (result) array.
 * Otherwise, it adds element to the result.
 *
 * @param { Array } dst - Initial array.
 * @param {*} arguments[] - One or more argument(s) to add to the end of the (dst) array.
 *
 * @example
 * // returns [ 1, 2, 'str', false, { a : 1 }, 42, 3, 7, 13 ];
 * var arr = _.arrayAppendMerging( [ 1, 2 ], 'str', false, { a : 1 }, 42, [ 3, 7, 13 ] );
 *
 * @returns { Array } - Returns an array (dst) with all of the following argument(s) that were added to the end of the (dst) array.
 * @method arrayAppendMerging
 * @throws { Error } If the first argument is not an array.
 * @throws { Error } If type of the argument is equal undefined.
 * @memberof wTools
 */

var arrayAppendMerging = function arrayAppendMerging( dst )
{
  var result = dst;

  _assert( _.arrayIs( dst ),'arrayAppendMerging :','expects array' );

  for( var a = 1 ; a < arguments.length ; a++ )
  {
    var argument = arguments[ a ];

    if( argument === undefined )
    throw _.err( 'arrayAppendMerging','argument is not defined' );

    if( _.arrayLike( argument ) ) result.push.apply( result,argument );
    else result.push( argument );
  }

  return result;
}

//

/**
 * The arrayPrependMerging() method adds one or more elements to the beginning of the (dst) array
 * and returns the new length of the array.
 *
 * It creates two variables the (result) - array and the (argument) - elements of array-like object (arguments[]),
 * iterate over array-like object (arguments[]) from the end to the beginning and assigns to the (argument) each element,
 * checks, if (argument) is equal to the 'undefined'.
 * If true, it throws an Error.
 * if (argument) is an array-like.
 * If true, it merges the (argument) into the (result) array.
 * Otherwise, it adds element to the result.
 *
 * @param { Array } dst - Initial array.
 * @param {*} arguments[] - One or more argument(s) to add to the front of the (dst) array.
 *
 * @example
 * // returns [ 'str', false, { a : 1 }, 42, 3, 7, 13, 1, 2 ];
 * var arr = _.arrayPrependMerging( [ 1, 2 ], 'str', false, { a : 1 }, 42, [ 3, 7, 13 ] );
 *
 * @returns { arrayLike } - Returns an array (dst) with all of the following argument(s) that were added to the beginning of the (dst) array.
 * @method arrayPrependMerging
 * @throws { Error } If the first argument is not array.
 * @throws { Error } If type of the argument is equal undefined.
 * @memberof wTools
 */

var arrayPrependMerging = function arrayPrependMerging( dst )
{
  var result = dst;

  _assert( _.arrayIs( dst ),'arrayPrependMerging :','expects array' );

  for( var a = arguments.length - 1 ; a > 0 ; a-- )
  {
    var argument = arguments[ a ];

    if( argument === undefined )
    throw _.err( 'arrayPrependMerging','argument is not defined' );

    if( _.arrayLike( argument ) ) result.unshift.apply( dst,argument );
    else result.unshift( argument );
  }

  return result;
}

//

/**
 * The arrayAppendOnceMerging() method returns an array of elements from (dst)
 * and appending only unique following arguments to the end.
 *
 * It creates two variables the (result) - array and the (argument) - elements of array-like object (arguments[]),
 * iterate over array-like object (arguments[]) and assigns to the (argument) each element,
 * checks, if (argument) is equal to the 'undefined'.
 * If true, it throws an Error.
 * if (argument) is an array-like.
 * If true, it iterate over array (argument) and checks if (result) has the same values as the (argument).
 * If false, it adds elements of (argument) to the end of the (result) array.
 * Otherwise, it checks if (result) has not the same values as the (argument).
 * If true, it adds elements to the end of the (result) array.
 *
 * @param { Array } dst - Initial array.
 * @param {*} arguments[] - One or more argument(s).
 *
 * @example
 * // returns [ 1, 2, 'str', {}, 5 ]
 * var arr = _.arrayAppendOnceMerging( [ 1, 2 ], 'str', 2, {}, [ 'str', 5 ] );
 *
 * @returns { Array } - Returns an array (dst) with only unique following argument(s) that were added to the end of the (dst) array.
 * @method arrayAppendOnceMerging
 * @throws { Error } If the first argument is not array.
 * @throws { Error } If type of the argument is equal undefined.
 * @memberof wTools
 */

var arrayAppendOnceMerging = function arrayAppendOnceMerging( dst )
{
  var result = dst;

  _assert( _.arrayIs( dst ),'arrayAppendOnceMerging :','expects array' );

  for( var a = 1 ; a < arguments.length ; a++ )
  {
    var argument = arguments[ a ];

    if( argument === undefined )
    throw _.err( 'arrayAppendOnceMerging','argument is not defined' );

    if( _.arrayLike( argument ) )
    {
      for( var i = 0 ; i < argument.length ; i++ )
      if( result.indexOf( argument[ i ] ) === -1 )
      result.push( argument[ i ] );
    }
    else
    {
      if( result.indexOf( argument ) === -1 )
      result.push( argument );
    }

  }

  return result;
}

//

  // !!! @example is wrong, has to be [ 5, 'str', {}, 2, 4 ].

/**
 * The arrayPrependOnceMerging() method returns an array of elements from (dst)
 * and prepending only unique following arguments to the beginning.
 *
 * It creates two variables the (result) - array and the (argument) - elements of array-like object (arguments[]),
 * iterate over array-like object (arguments[]) from the end to the beginning and assigns to the (argument) each element,
 * checks, if (argument) is equal to the 'undefined'.
 * If true, it throws an Error.
 * if (argument) is an array-like.
 * If true, it iterate over array (argument) and checks if (result) has the same values as the (argument).
 * If false, it adds elements of (argument) to the beginning of the (result) array.
 * Otherwise, it checks if (result) has not the same values as the (argument).
 * If true, it adds elements to the beginning of the (result) array.
 *
 * @param { Array } dst - Initial array.
 * @param {*} arguments[] - One or more argument(s).
 *
 * @example
 * // returns [ {}, 'str', 5, 2, 4 ]
 * var arr = _.arrayPrependOnceMerging( [ 2, 4 ], 5, 4, 'str', {} );
 *
 * @returns { Array } - Returns an array (dst) with only unique following argument(s) that were added to the beginning of the (dst) array.
 * @method arrayPrependOnceMerging
 * @throws { Error } If the first argument is not array.
 * @throws { Error } If type of the argument is equal undefined.
 * @memberof wTools
 */

var arrayPrependOnceMerging = function arrayPrependOnceMerging( dst )
{
  var result = dst;

  _assert( _.arrayIs( dst ),'arrayPrependOnceMerging :','expects array' );

  for( var a = arguments.length-1 ; a > 0 ; a-- )
  {
    var argument = arguments[ a ];

    if( argument === undefined )
    throw _.err( 'arrayPrependOnceMerging','argument is not defined' );

    if( _.arrayLike( argument ) )
    {
      for( var i = argument.length-1 ; i >= 0 ; i-- )
      if( result.indexOf( argument[ i ] ) === -1 )
      result.unshift( argument[ i ] );
    }
    else
    {
      if( result.indexOf( argument ) === -1 )
      result.unshift( argument );
    }

  }

  return result;
}

//

/**
 * The arrayElementsSwap() method reverses the elements by indices (index1) and (index2) in the (dst) array.
 *
 * @param { Array } dst - The initial array.
 * @param { Number } index1 - The first index.
 * @param { Number } index2 - The second index.
 *
 * @example
 * // returns [ 5, 2, 3, 4, 1 ]
 * var arr = _.arrayElementsSwap( [ 1, 2, 3, 4, 5 ], 0, 4 );
 *
 * @returns { Array } - Returns the (dst) array that has been modified in place by indexes (index1) and (index2).
 * @method arrayElementsSwap
 * @throws { Error } If the first argument in not an array.
 * @throws { Error } If the second argument is less than 0 and more than a length initial array.
 * @throws { Error } If the third argument is less than 0 and more than a length initial array.
 * @memberof wTools
 */

var arrayElementsSwap = function( dst,index1,index2 )
{

  _ssert( arguments.length === 3 );
  _assert( _.arrayLike( dst ),'arrayElementsSwap :','argument must be array' );
  _assert( 0 <= index1 && index1 < dst.length,'arrayElementsSwap :','index1 is out of bound' );
  _assert( 0 <= index2 && index2 < dst.length,'arrayElementsSwap :','index2 is out of bound' );

  var e = dst[ index1 ];
  dst[ index1 ] = dst[ index2 ];
  dst[ index2 ] = e;

  return dst;
}

//

  /**
   * The arrayFrom() method converts an object-like (src) into Array.
   *
   * @param { * } src - To convert into Array.
   *
   * @example
   * // returns [ 3, 7, 13, 'abc', false, undefined, null, {} ]
   * _.arrayFrom( [ 3, 7, 13, 'abc', false, undefined, null, {} ] );
   *
   * @example
   * // returns [ [ 'a', 3 ], [ 'b', 7 ], [ 'c', 13 ] ]
   * _.arrayFrom( { a : 3, b : 7, c : 13 } );
   *
   * @example
   * // returns [ 3, 7, 13, 3.5, 5, 7.5, 13 ]
   * _.arrayFrom( "3, 7, 13, 3.5abc, 5def, 7.5ghi, 13jkl" );
   *
   * @example
   * // returns [ 3, 7, 13, 'abc', false, undefined, null, { greeting: 'Hello there!' } ]
   * var args = ( function() {
   *   return arguments;
   * } )( 3, 7, 13, 'abc', false, undefined, null, { greeting: 'Hello there!' } );
   * _.arrayFrom( args );
   *
   * @returns { Array } Returns an Array.
   * @method arrayFrom
   * @throws { Error } Will throw an Error if (src) is not an object-like.
   * @memberof wTools
   */

var arrayFrom = function( src )
{

  _.assert( arguments.length === 1 );

  if( _.arrayIs( src ) )
  return src;

  if( _.objectIs( src ) )
  return _.mapToArray( src );

  if( _.strIs( src ) )
  {
    var sep = ( src.indexOf( ',' ) !== -1 )?( ',' ) :' '; //???
    return src.split(/[, ]+/).map( function( s ){ if( s.length ) return parseFloat(s); } );
  }

  if( _.argumentsIs( src ) )
  return _ArraySlice.call( src );

  throw _.err( 'arrayFrom : unknown source : ' + _.strTypeOf( src ) ); //???
}

//

  /**
   * The arrayToMap() converts an (array) into Object.
   *
   * @param { arrayLike } array - To convert into Object.
   *
   * @example
   * // returns {  }
   * _.arrayToMap( [  ] );
   *
   * @example
   * // returns { '0' : 3, '1' : [ 1, 2, 3 ], '2' : 'abc', '3' : false, '4' : undefined, '5' : null, '6' : {} }
   * _.arrayToMap( [ 3, [ 1, 2, 3 ], 'abc', false, undefined, null, {} ] );
   *
   * @example
   * // returns { '0' : 3, '1' : 'abc', '2' : false, '3' : undefined, '4' : null, '5' : { greeting: 'Hello there!' } }
   * var args = ( function() {
   *   return arguments;
   * } )( 3, 'abc', false, undefined, null, { greeting: 'Hello there!' } );
   * _.arrayToMap( args );
   *
   * @returns { Object } Returns an Object.
   * @method arrayToMap
   * @throws { Error } Will throw an Error if (array) is not an array-like.
   * @memberof wTools
   */

var arrayToMap = function( array )
{
  var result = {};

  _.assert( arguments.length === 1 );
  _.assert( _.arrayLike( array ) );

  for( var a = 0 ; a < array.length ; a++ )
  result[ a ] = array[ a ];
  return result;
}

//
  /**
   * The callback function to compare two values.
   *
   * @callback arrayRemoveArrayOnce~onEqual
   * @param { * } el - The element of the (dstArray[n]) array.
   * @param { * } ins - The value to compare (insArray[n]).
   */

  /**
   * The arrayRemoveArrayOnce() determines whether a (dstArray) array has the same values as in a (insArray) array,
   * and returns amount of the deleted elements from the (dstArray).
   *
   * It takes two (dstArray, insArray) or three (dstArray, insArray, onEqual) arguments, creates variable (var result = 0),
   * checks if (arguments[..]) passed two, it iterates over the (insArray) array and calls for each element built in function (dstArray.indexOf(insArray[i])).
   * that looking for the value of the (insArray[i]) array in the (dstArray) array.
   * If true, it removes the value (insArray[i]) from (dstArray) array by corresponding index,
   * and incrementing the variable (result++).
   * Otherwise, if passed three (arguments[...]), it iterates over the (insArray) and calls for each element the method
   *
   * If callback function (onEqual) returns true, it returns the index that will be removed from (dstArray),
   * and then incrementing the variable (result++).
   *
   * @see wTools.arrayLeftIndexOf
   *
   * @param { arrayLike } dstArray - The target array.
   * @param { arrayLike } insArray - The source array.
   * @param { function } [ onEqual ] onEqual - The callback function.
   * By default, it checks the equality of two arguments.
   *
   * @example
   * // returns 0
   * _.arrayRemoveArrayOnce( [  ], [  ] );
   *
   * @example
   * // returns 2
   * _.arrayRemoveArrayOnce( [ 1, 2, 3, 4, 5 ], [ 6, 2, 7, 5, 8 ] );
   *
   * @example
   * // returns 4
   * var got = _.arrayRemoveArrayOnce( [ 1, 2, 3, 4, 5 ], [ 6, 2, 7, 5, 8 ], function( a, b ) {
   *   return a < b;
   * } );
   *
   * @returns { number }  Returns amount of the deleted elements from the (dstArray).
   * @method arrayRemoveArrayOnce
   * @throws { Error } Will throw an Error if (dstArray) is not an array-like.
   * @throws { Error } Will throw an Error if (insArray) is not an array-like.
   * @throws { Error } Will throw an Error if (arguments.length < 2  || arguments.length > 3).
   * @memberof wTools
   */

var arrayRemoveArrayOnce = function( dstArray,insArray,onEqual )
{
  _.assert( _.arrayLike( dstArray ) );
  _.assert( _.arrayLike( insArray ) );
  _.assert( arguments.length === 2 || arguments.length === 3 );

  var result = 0;
  var index = -1;

  if( arguments.length === 2 )
  {

    for( var i = 0 ; i < insArray.length ; i++ )
    {
      index = dstArray.indexOf( insArray[ i ] );
      if( !( index >= 0 ) )
      continue;
      dstArray.splice( index,1 );
      result += 1;
    }

  }
  else if( arguments.length === 3 )
  {

    _.assert( _.routineIs( onEqual ) );
    for( var i = 0 ; i < insArray.length ; i++ )
    {
      index = arrayLeftIndexOf( dstArray,insArray[ i ],onEqual );
      if( !( index >= 0 ) )
      continue;
      dstArray.splice( index,1 );
      result += 1;
    }

  }
  else throw _.err( 'unexpected' );

  return result;
}

//

  /**
 * The callback function to compare two values.
 *
 * @callback wTools~compareCallback
 * @param { * } el - The element of the array.
 * @param { * } ins - The value to compare.
 */

/**
 * The arrayRemovedOnce() method returns the index of the first matching element from (dstArray)
 * that corresponds to the condition in the callback function and remove this element.
 *
 * It takes two (dstArray, ins) or three (dstArray, ins, onEqual) arguments,
 * checks if arguments passed two, it calls built in function (dstArray.indexOf(ins))
 * that looking for the value of the (ins) in the (dstArray).
 * If true, it removes the value (ins) from (dstArray) array by corresponding index.
 * Otherwise, if passed three arguments, it calls the method
 * [arrayLeftIndexOf( dstArray, ins, onEqual )]{@link wTools.arrayLeftIndexOf}
 * If callback function (onEqual) returns true, it returns the index that will be removed from (dstArray).
 * @see {@link wTools.arrayLeftIndexOf} - See for more information.
 *
 * @param { Array } dstArray - The source array.
 * @param { * } ins - The value to remove.
 * @param { wTools~compareCallback } [ onEqual ] - The callback that compares (ins) with elements of the array.
 * By default, it checks the equality of two arguments.
 *
 * @example
 * // returns 1
 * var arr = _.arrayRemovedOnce( [ 2, 4, 6 ], 4, function ( el ) {
 *   return el;
 * });
 *
 * @example
 * // returns 0
 * var arr = _.arrayRemovedOnce( [ 2, 4, 6 ], 2 );
 *
 * @returns { Number } - Returns the index of the value (ins) that was removed from (dstArray).
 * @method arrayRemovedOnce
 * @throws { Error } If the first argument is not an array-like.
 * @throws { Error } If passed less than two or more than three arguments.
 * @throws { Error } If the third argument is not a function.
 * @memberof wTools
 */

var arrayRemovedOnce = function( dstArray,ins,onEqual )
{
  _.assert( _.arrayLike( dstArray ) );
  _.assert( arguments.length === 2 || arguments.length === 3 );

  var index = -1;

  if( arguments.length === 2 )
  {

    index = dstArray.indexOf( ins );

  }
  else if( arguments.length === 3 )
  {

    _.assert( _.routineIs( onEqual ) );
    _.assert( onEqual.length === 1 || onEqual.length === 2 );
    index = arrayLeftIndexOf( dstArray,ins,onEqual );

  }
  else throw _.err( 'unexpected' );

  if( index >= 0 )
  dstArray.splice( index,1 );

  return index;
}

//

/**
 * The arrayRemoveOnce() method removes the first matching element from (dstArray)
 * that corresponds to the condition in the callback function and returns a modified array.
 *
 * It takes two (dstArray, ins) or three (dstArray, ins, onEqual) arguments,
 * checks if arguments passed two, it calls the method
 * [arrayRemovedOnce( dstArray, ins )]{@link wTools.arrayRemovedOnce}
 * Otherwise, if passed three arguments, it calls the method
 * [arrayRemovedOnce( dstArray, ins, onEqual )]{@link wTools.arrayRemovedOnce}
 * @see  wTools.arrayRemovedOnce
 * @param { Array } dstArray - The source array.
 * @param { * } ins - The value to remove.
 * @param { wTools~compareCallback } [ onEqual ] - The callback that compares (ins) with elements of the array.
 * By default, it checks the equality of two arguments.
 *
 * @example
 * // returns [ 1, 2, 3, 'str' ]
 * var arr = _.arrayRemoveOnce( [ 1, 'str', 2, 3, 'str' ], 'str' );
 *
 * @example
 * // returns [ 3, 7, 13, 33 ]
 * var arr = _.arrayRemoveOnce( [ 3, 7, 33, 13, 33 ], 13, function ( el, ins ) {
 *   return el > ins;
 * });
 *
 * @returns { Array } - Returns the modified (dstArray) array with the new length.
 * @method arrayRemoveOnce
 * @throws { Error } If the first argument is not an array.
 * @throws { Error } If passed less than two or more than three arguments.
 * @throws { Error } If the third argument is not a function.
 * @memberof wTools
 */

var arrayRemoveOnce = function( dstArray,ins,onEqual )
{
  _.assert( arguments.length === 2 || arguments.length === 3 );

  if( arguments.length === 2 )
  arrayRemovedOnce( dstArray,ins );
  else if( arguments.length === 3 )
  arrayRemovedOnce( dstArray,ins,onEqual );

  return dstArray;
}

//

/**
 * Callback for compare two value.
 *
 * @callback arrayRemovedAll~compareCallback
 * @param { * } el - The element of the array.
 * @param { * } ins - The value to compare.
 */

/**
 * The arrayRemovedAll() method removes all (ins) values from (dstArray)
 * that corresponds to the condition in the callback function and returns the amount of them.
 *
 * It takes two (dstArray, ins) or three (dstArray, ins, onEqual) arguments,
 * checks if (onEqual) is equal to the 'undefined'.
 * If true, it assigns by default callback function that checks the equality of two arguments.
 * Otherwise, it uses given callback function (onEqual).
 * Then it iterates over (dstArray) from the end to the beginning, checks if (onEqual) returns true.
 * If true, it removes the value (ins) from (dstArray) array by corresponding index, and increases (result++).
 *
 * @param { Array } dstArray - The source array.
 * @param { * } ins - The value to remove.
 * @param { compareCallback } [ onEqual ] - The callback that compares (ins) with elements of the array.
 * By default, it checks the equality of two arguments.
 *
 * @example
 * // returns 4
 * var arr = _.arrayRemovedAll( [ 1, 2, 3, 4, 5, 5, 5 ], 5, function ( el, ins ) {
 *   return el < ins;
 * });
 *
 * @example
 * // returns 3
 * var arr = _.arrayRemovedAll( [ 1, 2, 3, 4, 5, 5, 5 ], 5 );
 *
 * @returns { Number } - Returns the amount of the removed elements.
 * @method arrayRemovedAll
 * @throws { Error } If the first argument is not an array-like.
 * @throws { Error } If passed less than two or more than three arguments.
 * @throws { Error } If the third argument is not a function.
 * @memberof wTools
 */

var arrayRemovedAll = function( dstArray,ins,onEqual )
{
  _.assert( _.arrayLike( dstArray ) );
  _.assert( arguments.length === 2 || arguments.length === 3 );

  if( arguments.length === 3 )
  _.assert( _.routineIs( onEqual ) );

  var result = 0;

  if( onEqual === undefined )
  onEqual = function( a,b ){ return a === b };

  for( var d = dstArray.length-1 ; d >= 0 ; d-- )
  if( onEqual( dstArray[ d ],ins ) )
  {
    dstArray.splice( d,1 );
    result += 1;
  }

  return result;
}

//

/**
 * Callback for compare two value.
 *
 * @callback arrayRemoveAll~compareCallback
 * @param { * } el - Element of the array.
 * @param { * } ins - Value to compare.
 */

/**
 * The arrayRemoveAll() method removes all (ins) values from (dstArray)
 * that corresponds to the condition in the callback function and returns the modified array.
 *
 * It takes two (dstArray, ins) or three (dstArray, ins, onEqual) arguments,
 * checks if arguments passed two, it calls the method
 * [arrayRemovedAll( dstArray, ins )]{@link wTools.arrayRemovedAll}
 * Otherwise, if passed three arguments, it calls the method
 * [arrayRemovedAll( dstArray, ins, onEqual )]{@link wTools.arrayRemovedAll}
 *
 * @see wTools.arrayRemovedAll
 *
 * @param { Array } dstArray - The source array.
 * @param { * } ins - The value to remove.
 * @param { wTools~compareCallback } [ onEqual ] - The callback that compares (ins) with elements of the array.
 * By default, it checks the equality of two arguments.
 *
 * @example
 * // returns [ 2, 2, 3, 5 ]
 * var arr = _.arrayRemoveAll( [ 1, 2, 2, 3, 5 ], 2, function ( el, ins ) {
 *   return el < ins;
 * });
 *
 * @example
 * // returns [ 1, 3, 5 ]
 * var arr = _.arrayRemoveAll( [ 1, 2, 2, 3, 5 ], 2 );
 *
 * @returns { Array } - Returns the modified (dstArray) array with the new length.
 * @method arrayRemoveAll
 * @throws { Error } If the first argument is not an array-like.
 * @throws { Error } If passed less than two or more than three arguments.
 * @throws { Error } If the third argument is not a function.
 * @memberof wTools
 */

var arrayRemoveAll = function( dstArray,ins,onEqual )
{
  _.assert( arguments.length === 2 || arguments.length === 3 );

  if( arguments.length === 2 )
  arrayRemovedAll( dstArray,ins );
  else if( arguments.length === 3 )
  arrayRemovedAll( dstArray,ins,onEqual );

  return dstArray;
}

//
  /**
   * The arrayReplaceOnce() method returns the index of the (dstArray) array which will be replaced by (sub),
   * if (dstArray) has the value (ins).
   *
   * It takes three arguments (dstArray, ins, sub), calls built in function (dstArray.indexOf(ins)),
   * that looking for value (ins) in the (dstArray).
   * If true, it replaces (ins) value of (dstArray) by (sub) and returns the index of the (ins).
   * Otherwise, it returns (-1) index.
   *
   * @param { Array } dstArray - The source array.
   * @param { * } ins - The value to find.
   * @param { * } sub - The value to replace.
   *
   * @example
   * // returns -1
   * _.arrayReplaceOnce( [ 2, 4, 6, 8, 10 ], 12, 14 );
   *
   * @example
   * // returns 1
   * _.arrayReplaceOnce( [ 1, undefined, 3, 4, 5 ], undefined, 2 );
   *
   * @example
   * // returns 3
   * _.arrayReplaceOnce( [ 'Petre', 'Mikle', 'Oleg', 'Dmitry' ], 'Dmitry', 'Bob' );
   *
   * @example
   * // returns 4
   * _.arrayReplaceOnce( [ true, true, true, true, false ], false, true );
   *
   * @returns { number }  Returns the index of the (dstArray) array which will be replaced by (sub),
   * if (dstArray) has the value (ins).
   * @method arrayReplaceOnce
   * @throws { Error } Will throw an Error if (dstArray) is not an array.
   * @throws { Error } Will throw an Error if (arguments.length) is less than three.
   * @memberof wTools
   */

var arrayReplaceOnce = function( dstArray,ins,sub )
{
  _.assert( _.arrayLike( dstArray ) );
  _.assert( arguments.length === 3 );

  var index = -1;

  index = dstArray.indexOf( ins );

  if( index >= 0 )
  dstArray.splice( index,1,sub );

  return index;
}

//
  /**
   * The arrayUpdate() method adds a value (sub) to an array (dstArray) or replaces a value (ins) of the array (dstArray) by (sub),
   * and returns the last added index or the last replaced index of the array (dstArray).
   *
   * It creates the variable (index) assigns and calls to it the function (arrayReplaceOnce( dstArray, ins, sub ).
   * [arrayReplaceOnce( dstArray, ins, sub )]{@link wTools.arrayReplaceOnce}.
   * Checks if (index) equal to the -1.
   * If true, it adds to an array (dstArray) a value (sub), and returns the last added index of the array (dstArray).
   * Otherwise, it returns the replaced (index).
   *
   * @see wTools.arrayReplaceOnce
   *
   * @param { Array } dstArray - The source array.
   * @param { * } ins - The value to change.
   * @param { * } sub - The value to add or replace.
   *
   * @example
   * // returns 3
   * var add = _.arrayUpdate( [ 'Petre', 'Mikle', 'Oleg' ], 'Dmitry', 'Dmitry' );
   * console.log( add ) = > [ 'Petre', 'Mikle', 'Oleg', 'Dmitry' ];
   *
   * @example
   * // returns 5
   * var add = _.arrayUpdate( [ 1, 2, 3, 4, 5 ], 6, 6 );
   * console.log( add ) => [ 1, 2, 3, 4, 5, 6 ];
   *
   * @example
   * // returns 4
   * var replace = _.arrayUpdate( [ true, true, true, true, false ], false, true );
   * console.log( replace ) => [ true, true true, true, true ];
   *
   * @returns { number } Returns the last added or the last replaced index.
   * @method arrayUpdate
   * @throws { Error } Will throw an Error if (dstArray) is not an array-like.
   * @throws { Error } Will throw an Error if (arguments.length) is less or more than three.
   * @memberof wTools
   */

var arrayUpdate = function( dstArray,ins,sub )
{
  _.assert( _.arrayLike( dstArray ) );
  _.assert( arguments.length === 3 );

  var index = arrayReplaceOnce( dstArray,ins,sub );

  if( index === -1 )
  {
    dstArray.push( sub );
    index = dstArray.length - 1;
  }

  return index;
}

//
  /**
   * The arrayAppendOnce() method adds at the end of an array (dst) a value (src),
   * if the array (dst) doesn't have the value (src).
   *
   * @param { Array } dst - The source array.
   * @param { * } src - The value to add.
   *
   * @example
   * // returns [ 1, 2, 3, 4, 5 ]
   * _.arrayAppendOnce( [ 1, 2, 3, 4 ], 5 );
   *
   * @example
   * // returns [ 1, 2, 3, 4, 5 ]
   * _.arrayAppendOnce( [ 1, 2, 3, 4, 5 ], 5 );
   *
   * @example
   * // returns [ 'Petre', 'Mikle', 'Oleg', 'Dmitry' ]
   * _.arrayAppendOnce( [ 'Petre', 'Mikle', 'Oleg' ], 'Dmitry' );
   *
   * @example
   * // returns [ 'Petre', 'Mikle', 'Oleg', 'Dmitry' ]
   * _.arrayAppendOnce( [ 'Petre', 'Mikle', 'Oleg', 'Dmitry' ], 'Dmitry' );
   *
   * @returns { Array } If an array (dst) doesn't have a value (src) it returns the updated array (dst) with the new length,
   * otherwise, it returns the original array (dst).
   * @method arrayAppendOnce
   * @throws { Error } Will throw an Error if (dst) is not an Array.
   * @throws { Error } Will throw an Error if (arguments.length) is less or more than two.
   * @memberof wTools
   */

var arrayAppendOnce = function( dst,src )
{

  _.assert( _.arrayIs( dst ) || dst === undefined );
  _.assert( arguments.length === 2 );

  if( !dst )
  return [ src ];

  var i = dst.indexOf( src );

  if( i === -1 )
  dst.push( src );

  return dst;
}

//
  /**
   * The arrayPrependOnce() method adds at the beginning of an array (dst) a value (src),
   * if the array (dst) doesn't have the value (src).
   *
   * @param { Array } dst - The source array.
   * @param { * } src - The value to add.
   *
   * @example
   * // returns [ 5, 1, 2, 3, 4 ]
   * _.arrayPrependOnce( [ 1, 2, 3, 4 ], 5 );
   *
   * @example
   * // returns [ 1, 2, 3, 4, 5 ]
   * _.arrayPrependOnce( [ 1, 2, 3, 4, 5 ], 5 );
   *
   * @example
   * // returns [ 'Dmitry', 'Petre', 'Mikle', 'Oleg' ]
   * _.arrayPrependOnce( [ 'Petre', 'Mikle', 'Oleg' ], 'Dmitry' );
   *
   * @example
   * // returns [ 'Petre', 'Mikle', 'Oleg', 'Dmitry' ]
   * _.arrayPrependOnce( [ 'Petre', 'Mikle', 'Oleg', 'Dmitry' ], 'Dmitry' );
   *
   * @returns { Array } If an array (dst) doesn't have a value (src) it returns the updated array (dst) with the new length,
   * otherwise, it returns the original array (dst).
   * @method arrayPrependOnce
   * @throws { Error } Will throw an Error if (dst) is not an Array.
   * @throws { Error } Will throw an Error if (arguments.length) is less or more than two.
   * @memberof wTools
   */

var arrayPrependOnce = function( dst,src )
{

  _.assert( _.arrayIs( dst ) || dst === undefined );
  _.assert( arguments.length === 2 );

  if( !dst )
  return [ src ];

  var i = dst.indexOf( src );

  if( i === -1 )
  dst.unshift( src );

  return dst;
}

//
  /**
   * The arraySpliceArray() method changes the content of an array (dstArray) by removing existing elements
   * and/or adding new elements from an array (srcArray).
   *
   * @param { Array } dstArray - The target array.
   * @param { Array } srcArray - The source array.
   * @param { Number } first - The index at which to start changing the (dstArray) array.
   * If (first) is greater than the length of the array (dstArray), actual starting index will be set to the length of the array (dstArray).
   * If (first) is negative, will begin that many elements from the end.
   * @param { Number } replace - The number of old array (dstArray) elements to remove.
   * If (replace) is greater than the number of elements left in the array (dstArray) starting at (first),
   * then all of the elements through the end of the array will be deleted.
   *
   * @example
   * // returns [ 1, 2, 3, 4, 5 ]
   * _.arraySpliceArray( [ 1, 'a', 'b', 'c', 5 ], [ 2, 3, 4 ], 1, 3 );
   *
   * @example
   * // returns [ 1, 'a', 2, 3, 4, 'd' ]
   * _.arraySpliceArray( [ 1, 'a', 'b', 'c', 'd' ], [ 2, 3, 4 ] , -3, 2 )
   *
   * @example
   * // returns [ 1, 1, 2, 3, 'a', 'b', 4, 5 ]
   * _.arraySpliceArray( [ 1, 2, 3, 4, 5 ], [ 1, 2, 3, 'a', 'b' ], 1, 2 );
   *
   * @example
   * // returns [ 1, 2, 3, 4, 5, 'a', 'b', 'c' ]
   * _.arraySpliceArray( [ 1, 2, 3, 4, 5 ], [ 'a', 'b', 'c' ], 7, 2 );
   *
   * @example
   * // returns [ 1, 'a', 'b', 'c' ]
   * _.arraySpliceArray( [ 1, 2, 3, 4, 5 ], [ 'a', 'b', 'c' ], 1, 7 );
   *
   * @example
   * // returns [ 1, 4, 5 ]
   * _.arraySpliceArray( [ 1, 2, 3, 4, 5 ], [  ], 1, 2 );
   *
   * @returns { Array } Returns the modified array (dstArray) with the new length.
   * @method arraySpliceArray
   * @throws { Error } Will throw an Error if (arguments.length) is less or more than four.
   * @throws { Error } Will throw an Error if (dstArray) is not an Array.
   * @throws { Error } Will throw an Error if (srcArray) is not an Array.
   * @throws { Error } Will throw an Error if (first) is not a Number.
   * @throws { Error } Will throw an Error if (replace) is not a Number.
   * @memberof wTools
   */

var arraySpliceArray = function( dstArray,srcArray,first,replace )
{
  _.assert( arguments.length === 4 );
  _.assert( _.arrayIs( dstArray ) );
  _.assert( _.arrayIs( srcArray ) );
  _.assert( _.numberIs( first ) );
  _.assert( _.numberIs( replace ) );

  var args = [ first,replace ];
  args.push.apply( args,srcArray );

  dstArray.splice.apply( dstArray,args );

  return dstArray;
}

/**
 * The arraySlice() returns a shallow copy of a portion of an array
 * into a new array.
 *
 * It takes three arguments (array, a, b)
 * checks if (array) is an Array, if (a) and (b) are numbers.
 * Creates variables (result, a, b) and assigns them values.
 * The arraySlice() creates a new array (result) from (a) to but not including (b),
 * and returns (result).
 *
 * @param { Array } array - An array to return a new array from begin to but not including end.
 * @param { Number } [ a = 0 ] a - begin zero-based index at which to begin extraction.
 * @param { Number } [ b = array.length ] b - end zero-based index at which to end extraction.
 * If (b) is omitted, arraySlice extracts through the end of the sequence (array.length).
 *
 * @example
 * // returns [ 3, 4, 5, 6 ]
 * _.arraySlice( [ 1, 2, 3, 4, 5, 6, 7 ], 2, 6 );
 *
 * @returns { Array } Returns a shallow copy of elements from the original array.
 * @method arraySlice
 * @throws { Error } Will throw an Error if (array) is not an Array.
 * @throws { Error } Will throw an Error if (a) is not a Number.
 * @throws { Error } Will throw an Error if (b) is not a Number.
 * @memberof wTools
*/

var arraySlice = function arraySlice( array,a,b )
{
  _.assert( _.arrayLike( array ) );

  var result;
  var a = a !== undefined ? a : 0;
  var b = b !== undefined ? b : array.length;

  _.assert( _.numberIs( a ) );
  _.assert( _.numberIs( b ) );

  if( b < a )
  b = a;

  if( _.bufferIs( array ) )
  result = new array.constructor( b-a );
  else
  result = new Array( b-a );

  for( var r = a ; r < b ; r++ )
  result[ r-a ] = array[ r ];

  return result;
}

//

var arraySplice = function arraySplice( dstArray,a,b,srcArray )
{

  _.assert( _.arrayIs( dstArray ) );
  _.assert( _.arrayIs( srcArray ) );

  var result;
  var a = a !== undefined ? a : 0;
  var b = b !== undefined ? b : dstArray.length;
  if( b < a )
  b = a;

  var srcArray = srcArray.slice();
  srcArray.unshift( b-a );
  srcArray.unshift( a );

  dstArray.splice.apply( dstArray,srcArray );

  return result;
}

//

/**
 * The arrayAs() method copies passed argument to the array.
 *
 * @param { * } src - The source value.
 *
 * @example
 * // returns [ false ]
 * var arr = _.arrayAs( false );
 *
 * @example
 * // returns [ { a : 1, b : 2 } ]
 * var arr = _.arrayAs( { a : 1, b : 2 } );
 *
 * @returns { Array } - If passed null or undefined than return the empty array. If passed an array then return it.
 * Otherwise return an array which contains the element from argument.
 * @method arrayAs
 * @memberof wTools
 */

var arrayAs = function( src )
{

  if( src === null || src === undefined ) return [];
  else if( _.arrayIs( src ) ) return src;
  else return [ src ];

}

//

var arrayUniqueIs = function arrayUniqueIs( o )
{

  if( _.arrayLike( o ) )
  o = { src : o };

  _.assert( arguments.length === 1 );
  _.assert( _.arrayLike( o.src ) );
  _.assertMapOnly( o,arrayUniqueIs.defaults );

  /**/

  if( o.onElement )
  {
    throw _.err( 'not tested' );
    o.src = _.enityMap( o.src,function( e ){ return o.onElement( e ) } );
  }

  /**/

  var number = o.src.length;
  var isUnique = arrayNewOfSameLength( o.src );
  var index;

  for( var i = 0 ; i < o.src.length ; i++ )
  isUnique[ i ] = 1;

  for( var i = 0 ; i < o.src.length ; i++ )
  {

    index = i;

    if( !isUnique[ i ] )
    continue;

    var currentUnique = 1;
    do
    {
      var index = o.src.indexOf( o.src[ i ],index+1 );
      if( index !== -1 )
      {
        isUnique[ index ] = 0;
        number -= 1;
        currentUnique = 0;
      }
    }
    while( index !== -1 );

    if( !o.includeFirst )
    if( !currentUnique )
    {
      isUnique[ i ] = 0;
      number -= 1;
    }

  }

  return { number : number, array : isUnique };
}

arrayUniqueIs.defaults =
{
  src : null,
  onElement : null,
  includeFirst : 0,
}

//

var arrayUnique = function arrayUnique( src,onElement )
{

  var isUnique = arrayUniqueIs
  ({
    src : src,
    onElement : onElement,
    includeFirst : 1,
  });
  var result = arrayNew( src,isUnique.number );

  var c = 0;
  for( var i = 0 ; i < src.length ; i++ )
  if( isUnique.array[ i ] )
  {
    result[ c ] = src[ i ];
    c += 1;
  }

  return result;
}

//
  /**
   * The arrayToStr() method joins an array (src) and returns one string containing each array element separated by space,
   * only types of integer or floating point.
   *
   * @param { arrayLike } src - The source array.
   * @param { objectLike } [ options = {  } ] options - The options.
   * @param { Number } [ options.precision = 5 ] - The precision of numbers.
   * @param { String } [ options.type = 'mixed' ] - The type of elements.
   *
   * @example
   * // returns "1 2 3 "
   * _.arrayToStr( [ 1, 2, 3 ], { type : 'int' } );
   *
   * @example
   * // returns "3.500 13.77 7.330"
   * _.arrayToStr( [ 3.5, 13.77, 7.33 ], { type : 'float', precission : 4 } );
   *
   * @returns { String } Returns one string containing each array element separated by space,
   * only types of integer or floating point.
   * If (src.length) is empty, it returns the empty string.
   * @method arrayToStr
   * @throws { Error } Will throw an Error If (options.type) is not the number or float.
   * @memberof wTools
   */

var arrayToStr = function( src,options )
{

  var result = '';
  var options = options || {};

  if( options.precission === undefined ) options.precission = 5;
  if( options.type === undefined ) options.type = 'mixed';

  if( !src.length ) return result;

  if( options.type === 'float' )
  {
    for( var s = 0 ; s < src.length-1 ; s++ )
    {
      result += src[ s ].toPrecision( options.precission ) + ' ';
    }
    result += src[ s ].toPrecision( options.precission );
  }
  else if( options.type === 'int' )
  {
    for( var s = 0 ; s < src.length-1 ; s++ )
    {
      result += String( src[ s ] ) + ' ';
    }
    result += String( src[ s ] ) + ' ';
  }
  else
  {
    throw '_.arrayToStr : not tested';
    for( var s = 0 ; s < src.length-1 ; s++ )
    {
      result += String( src[ s ] ) + ' ';
    }
    result += String( src[ s ] ) + ' ';
  }

  return result;
}

//

/**
 * The arrayPut() method puts all values of (arguments[]) after the second argument to the (dstArray)
 * in the position (dstOffset) and changes values of the following index.
 *
 * @param { arrayLike } dstArray - The source array.
 * @param { Number } [ dstOffset = 0 ] dstOffset - The index of element where need to put the new values.
 * @param {*} arguments[] - One or more argument(s).
 * If the (argument) is an array it iterates over array and adds each element to the next (dstOffset++) index of the (dstArray).
 * Otherwise, it adds each (argument) to the next (dstOffset++) index of the (dstArray).
 *
 * @example
 * // returns [ 1, 2, 'str', true, 7, 8, 9 ]
 * var arr = _.arrayPut( [ 1, 2, 3, 4, 5, 6, 9 ], 2, 'str', true, [ 7, 8 ] );
 *
 * @example
 * // returns [ 'str', true, 7, 8, 5, 6, 9 ]
 * var arr = _.arrayPut( [ 1, 2, 3, 4, 5, 6, 9 ], 0, 'str', true, [ 7, 8 ] );
 *
 * @returns { arrayLike } - Returns an array containing the changed values.
 * @method arrayPut
 * @throws { Error } Will throw an Error if (arguments.length) is less than one.
 * @throws { Error } Will throw an Error if (dstArray) is not an array-like.
 * @throws { Error } Will throw an Error if (dstOffset) is not a Number.
 * @memberof wTools
 */

var arrayPut = function arrayPut( dstArray, dstOffset )
{
  _.assert( arguments.length >= 1 );
  _.assert( _.arrayLike( dstArray ) );
  _.assert( _.numberIs( dstOffset ) );

  dstOffset = dstOffset || 0;

  for( var a = 2 ; a < arguments.length ; a++ )
  {
    var argument = arguments[ a ];
    var aIs = _.arrayIs( argument ) || _.bufferIs( argument );

    if( aIs && _.bufferIs( dstArray ) )
    {
      dstArray.set( argument,dstOffset );
      dstOffset += argument.length;
    }
    else if( aIs )
    for( var i = 0 ; i < argument.length ; i++ )
    {
      dstArray[ dstOffset ] = argument[ i ];
      dstOffset += 1;
    }
    else
    {
      dstArray[ dstOffset ] = argument;
      dstOffset += 1;
    }

  }

  return dstArray;
}

//
  /**
   * The arrayMask() method returns a new instance of array that contains the certain value(s) from array (srcArray),
   * if an array (mask) contains the truth-value(s).
   *
   * The arrayMask() method checks, how much an array (mask) contain the truth value(s),
   * and from that amount of truth values it builds a new array, that contains the certain value(s) of an array (srcArray),
   * by corresponding index(es) (the truth value(s)) of the array (mask).
   * If amount is equal 0, it returns an empty array.
   *
   * @param { arrayLike } srcArray - The source array.
   * @param { arrayLike } mask - The target array.
   *
   * @example
   * // returns [  ]
   * _.arrayMask( [ 1, 2, 3, 4 ], [ undefined, null, 0, '' ] );
   *
   * @example
   * // returns [ "c", 4, 5 ]
   * _arrayMask( [ 'a', 'b', 'c', 4, 5 ], [ 0, '', 1, 2, 3 ] );
   *
   * @example
   * // returns [ 'a', 'b', 5, 'd' ]
   * _.arrayMask( [ 'a', 'b', 'c', 4, 5, 'd' ], [ 3, 7, 0, '', 13, 33 ] );
   *
   * @returns { arrayLike } Returns a new instance of array that contains the certain value(s) from array (srcArray),
   * if an array (mask) contains the truth-value(s).
   * If (mask) contains all falsy values, it returns an empty array.
   * Otherwise, it returns a new array with certain value(s) of an array (srcArray).
   * @method arrayMask
   * @throws { Error } Will throw an Error if (arguments.length) is less or more that two.
   * @throws { Error } Will throw an Error if (srcArray) is not an array-like.
   * @throws { Error } Will throw an Error if (mask) is not an array-like.
   * @throws { Error } Will throw an Error if length of both (srcArray and mask) is not equal.
   * @memberof wTools
   */

var arrayMask = function arrayMask( srcArray, mask )
{

  _.assert( arguments.length === 2 );

  if( !_.arrayLike( srcArray ) )
  throw _.err( 'arrayMask :','expects array-like as srcArray' );
  if( !_.arrayLike( mask )  )
  throw _.err( 'arrayMask :','expects array-like as mask' );

  var atomsPerElement = mask.length;
  var length = srcArray.length / atomsPerElement;
  if( Math.floor( length ) !== length )
  throw _.err( 'arrayMask :','expects mask that has component for each atom of srcArray',_.toStr({ 'atomsPerElement' : atomsPerElement, 'srcArray.length' : srcArray.length  }) );

  var preserve = 0;
  for( var m = 0 ; m < mask.length ; m++ )
  if( mask[ m ] )
  preserve += 1;

  var dstArray = new srcArray.constructor( length*preserve );

  if( !preserve )
  return dstArray;

  var c = 0;
  for( var i = 0 ; i < length ; i++ )
  for( var m = 0 ; m < mask.length ; m++ )
  if( mask[ m ] )
  {
    dstArray[ c ] = srcArray[ i*atomsPerElement + m ];
    c += 1;
  }

  return dstArray;
}

//

var arrayUnmask = function arrayUnmask( o )
{

  _.assert( arguments.length === 1 || arguments.length === 2 );

  if( arguments.length === 2 )
  o =
  {
    src : arguments[ 0 ],
    mask : arguments[ 1 ],
  }

  _.assertMapOnly( o,arrayUnmask.defaults );
  _.assert( _.arrayLike( o.src ),'arrayUnmask : expects o.src as ArrayLike' );

  debugger;

  var atomsPerElement = o.mask.length;

  var atomsPerElementPreserved = 0;
  for( var m = 0 ; m < o.mask.length ; m++ )
  if( o.mask[ m ] )
  atomsPerElementPreserved += 1;

  var length = o.src.length / atomsPerElementPreserved;
  if( Math.floor( length ) !== length )
  throw _.err( 'arrayMask :','expects mask that has component for each atom of o.src',_.toStr({ 'atomsPerElementPreserved' : atomsPerElementPreserved, 'o.src.length' : o.src.length  }) );

  var dstArray = new o.src.constructor( atomsPerElement*length );

  var e = [];
  for( var i = 0 ; i < length ; i++ )
  {

    for( var m = 0, p = 0 ; m < o.mask.length ; m++ )
    if( o.mask[ m ] )
    {
      e[ m ] = o.src[ i*atomsPerElementPreserved + p ];
      p += 1;
    }
    else
    {
      e[ m ] = 0;
    }

    if( o.onEach )
    o.onEach( e,i );

    for( var m = 0 ; m < o.mask.length ; m++ )
    dstArray[ i*atomsPerElement + m ] = e[ m ];

  }

  return dstArray;
}

arrayUnmask.defaults =
{
  src : null,
  mask : null,
  onEach : null,
}

//
  /**
   * The arrayDuplicate() method returns an array with duplicate values of a certain number of times.
   *
   * @param { ( Array | Object ) } srcArray - The initial array or object.
   * @param { objectLike } [ options = {  } ] options - The set of arguments.
   * @param { arrayLike } options.src - The given initial array.
   * @param { arrayLike } options.result - To collect all data.
   * @param { Number } [ options.numberOfAtomsPerElement = 1 ] options.numberOfAtomsPerElement - The certain number of times
   * to append the next value from (srcArray or options.src) to the (options.result).
   * If (options.numberOfAtomsPerElement) is greater that length of a (srcArray or options.src) it appends the 'undefined'.
   * @param { Number } [ options.numberOfDuplicatesPerElement = 2 ] options.numberOfDuplicatesPerElement = 2 - The number of duplicates per element.
   *
   * @example
   * // returns [ 'a', 'a', 'b', 'b', 'c', 'c' ]
   * _.arrayDuplicate( [ 'a', 'b', 'c' ] );
   *
   * @example
   * // returns [ 'abc', 'def', 'abc', 'def', 'abc', 'def' ]
   * var options = {
   *   src : [ 'abc', 'def' ],
   *   result : [  ],
   *   numberOfAtomsPerElement : 2,
   *   numberOfDuplicatesPerElement : 3
   * };
   * _.arrayDuplicate( options, {} );
   *
   * @example
   * // returns [ 'abc', 'def', undefined, 'abc', 'def', undefined, 'abc', 'def', undefined ]
   * var options = {
   *   src : [ 'abc', 'def' ],
   *   result : [  ],
   *   numberOfAtomsPerElement : 3,
   *   numberOfDuplicatesPerElement : 3
   * };
   * _.arrayDuplicate( options, { a : 7, b : 13 } );
   *
   * @returns { Array } Returns an array with duplicate values of a certain number of times.
   * @method arrayDuplicate
   * @throws { Error } Will throw an Error if (options) is not an objectLike.
   * @memberof wTools
   */

var arrayDuplicate = function arrayDuplicate( srcArray, options )
{

  if( _.objectIs( srcArray ) )
  {
    options = srcArray;
    srcArray = options.src;
  }

  var options = options || {};
  if( options.numberOfAtomsPerElement === undefined ) options.numberOfAtomsPerElement = 1;
  if( options.numberOfDuplicatesPerElement === undefined ) options.numberOfDuplicatesPerElement = 2;

  _.assertMapOnly( options,
  {
    src : 'src',
    result : 'result',
    numberOfAtomsPerElement : 'numberOfAtomsPerElement',
    numberOfDuplicatesPerElement : 'numberOfDuplicatesPerElement',
  });

  //if( options.numberOfAtomsPerElement !== 1 )
  //throw _.err( 'not tested' );

  var length = srcArray.length * options.numberOfDuplicatesPerElement;
  var result = options.result || arrayNew( srcArray,length );
  var numberOfElements = srcArray.length / options.numberOfAtomsPerElement;

  for( var c = 0, cl = numberOfElements ; c < cl ; c++ )
  {

    for( var d = 0, dl = options.numberOfDuplicatesPerElement ; d < dl ; d++ )
    {

      for( var e = 0, el = options.numberOfAtomsPerElement ; e < el ; e++ )
      {
        var indexDst = c*options.numberOfAtomsPerElement*options.numberOfDuplicatesPerElement + d*options.numberOfAtomsPerElement + e;
        var indexSrc = c*options.numberOfAtomsPerElement+e;
        result[ indexDst ] = srcArray[ indexSrc ];
      }

    }

  }

  return result;
}

//

/**
 * The arrayFill() method fills all the elements of the given or a new array from the 0 index to an (options.times) index
 * with a static value.
 *
 * @param { ( Object | Number | Array ) } o - The options to fill the array.
 * @param { Number } [ o.times = result.length ] o.times - The count of repeats.
   If in the function passed an Array, the times will be equal the length of the array. If Number than this value.
 * @param { Number } [ o.value = 0 ] - The value for the filling.
 *
 * @example
 * // returns [ 3, 3, 3, 3, 3 ]
 * var arr = _.arrayFill( { times : 5, value : 3 } );
 *
 * @example
 * // returns [ 0, 0, 0, 0 ]
 * var arr = _.arrayFill( 4 );
 *
 * @example
 * // returns [ 0, 0, 0 ]
 * var arr = _.arrayFill( [ 1, 2, 3 ] );
 *
 * @returns { Array } - Returns an array filled with a static value.
 * @method arrayFill
 * @throws { Error } If missed argument, or got more than one argument.
 * @throws { Error } If passed argument is not an object.
 * @throws { Error } If the last element of the (o.result) is not equal to the (o.value).
 * @memberof wTools
 */

var arrayFill = function arrayFill( o )
{

  if( arguments.length === 1 )
  {
    if( _.numberIs( o ) )
    o = { times : o };
    else if( _.arrayIs( o ) )
    o = { result : o };
  }
  else
  {
    o = { result : arguments[ 0 ], value : arguments[ 1 ] };
  }

  _assert( arguments.length === 1 || arguments.length === 2 );
  _.assertMapOnly( o,arrayFill.defaults );
  _assert( _.objectIs( o ) || _.numberIs( o ) || _.arrayIs( o ),'arrayFill :','"o" must be object' );

  var result = o.result || [];
  var times = o.times !== undefined ? o.times : result.length;
  var value = o.value !== undefined ? o.value : 0;

  if( _.routineIs( result.fill ) )
  {
    if( result.length < times )
    result.length = times;
    result.fill( value,0,times );
  }
  else
  {
    for( var t = 0 ; t < times ; t++ )
    result[ t ] = value;
  }

  _assert( result[ times-1 ] === value );
  return result;
}

arrayFill.defaults =
{
  result : null,
  times : null,
  value : null,
}

/**
 * The arrayCompare() method returns the first difference between the values of the first array from the second.
 *
 * @param { arrayLike } src1 - The first array.
 * @param { arrayLike } src2 - The second array.
 *
 * @example
 * // returns 3
 * var arr = _.arrayCompare( [ 1, 5 ], [ 1, 2 ] );
 *
 * @returns { Number } - Returns the first difference between the values of the two arrays.
 * @method arrayCompare
 * @throws { Error } Will throw an Error if (arguments.length) is less or more than two.
 * @throws { Error } Will throw an Error if (src1 and src2) are not the array-like.
 * @throws { Error } Will throw an Error if (src2.length) is less or not equal to the (src1.length).
 * @memberof wTools
 */

var arrayCompare = function( src1,src2 )
{
  _.assert( arguments.length === 2 );
  _.assert( _.arrayLike( src1 ) && _.arrayLike( src2 ) );
  _.assert( src2.length >= src1.length );

  var result = 0;

  for( var s = 0 ; s < src1.length ; s++ )
  {

    result = src1[ s ] - src2[ s ];
    if( result !== 0 ) return result;

  }

  return result;
}

//

/**
 * The arraySame() method checks the equality of two arrays.
 *
 * @param { arrayLike } src1 - The first array.
 * @param { arrayLike } src2 - The second array.
 *
 * @example
 * // returns true
 * var arr = _.arraySame( [ 1, 2, 3 ], [ 1, 2, 3 ] );
 *
 * @returns { Boolean } - Returns true if all values of the two arrays are equal. Otherwise, returns false.
 * @method arraySame
 * @throws { Error } Will throw an Error if (arguments.length) is less or more than two.
 * @memberof wTools
 */

var arraySame = function( src1,src2 )
{
  _.assert( arguments.length === 2 );

  var result = true;

  if( src1.length !== src2.length )
  return false;

  for( var s = 0 ; s < src1.length ; s++ )
  {

    result = src1[ s ] === src2[ s ];

    if( result === false )
    return false;

  }

  return result;
}

//

var arraySameSet = function( src1,src2 )
{
  if( src1.length !== src2.length ) return false;
  var src = src1.slice();
  var nil = {};

  for( var s = 0 ; s < src2.length ; s++ )
  {
    var i = src.indexOf( src2[ s ] );
    if( i === -1 )
    return false;
    src[ i ] = nil;
  }

  return true;
}

//
  /**
   * The arrayLeftIndexOf() method returns the index of the first matching (ins) element in a array (arr)
   * that corresponds to the condition in the callback function.
   *
   * It iterates over an array (arr) from the left to the right,
   * and checks by callback function (equalizer(arr[a], ins)).
   * If callback function returns true, it returns corresponding index.
   * Otherwise, it returns -1.
   *
   * @param { arrayLike } arr - The target array.
   * @param { * } ins - The value to compare.
   * @param { wTools~compareCallback } [equalizer] equalizer - A callback function.
   * By default, it checks the equality of two arguments.
   *
   * @example
   * // returns 0
   * _.arrayLeftIndexOf( [ 1, 2, 3 ], 1 );
   *
   * @example
   * // returns -1
   * _.arrayLeftIndexOf( [ 1, 2, 3 ], 4 );
   *
   * @example
   * // returns 3
   * _.arrayLeftIndexOf( [ 1, 2, 3, 4 ], 3, function( el, ins ) { return el > ins } );
   *
   * @example
   * // returns 3
   * _.arrayLeftIndexOf( 'abcdef', 'd' );
   *
   * @example
   * // returns 2
   * var arr = function() {
   *   return arguments;
   * }( 3, 7, 13 );
   * _.arrayLeftIndexOf( arr, 13 );
   *
   * @returns { Number } Returns the corresponding index, if a callback function (equalizer) returns true.
   * Otherwise, it returns -1.
   * @method arrayLeftIndexOf
   * @throws { Error } Will throw an Error if (arguments.length) is not equal to the 2 or 3.
   * @throws { Error } Will throw an Error if (equalizer.length) is not equal to the 1 or 2.
   * @throws { Error } Will throw an Error if (equalizer) is not a Function.
   * @memberof wTools
   */

var arrayLeftIndexOf = function( arr,ins,equalizer )
{

  if( !equalizer )
  equalizer = function( a,b ){ return a === b };

  _.assert( arguments.length === 2 || arguments.length === 3 );
  _.assert( equalizer.length === 1 || equalizer.length === 2 );
  _.assert( _.routineIs( equalizer ) );

  if( equalizer.length === 2 )
  for( var a = 0 ; a < arr.length ; a++ )
  {

    if( equalizer( arr[ a ],ins ) )
    return a;

  }
  else
  {

    for( var a = 0 ; a < arr.length ; a++ )
    {

      if( equalizer( arr[ a ] ) === ins )
      return a;

    }

  }

  return -1;
}

//

var arrayRightIndexOf = function( arr,ins,equalizer )
{

  if( !equalizer )
  equalizer = function( a,b ){ return a === b };

  _.assert( arguments.length === 2 || arguments.length === 3 );
  _.assert( equalizer.length === 1 || equalizer.length === 2 );

  if( equalizer.length === 2 )
  for( var a = arr.length-1 ; a >= 0 ; a-- )
  {

    if( equalizer( arr[ a ],ins ) )
    return a;

  }
  else
  {

    for( var a = arr.length-1 ; a >= 0 ; a-- )
    {

      if( equalizer( arr[ a ] ) === ins )
      return a;

    }

  }

  return -1;
}

//

  /**
   * The arrayLeft() method returns a new object containing the properties, (index, element),
   * corresponding to a found value (ins) from an array (arr).
   *
   * It creates the variable (i), assigns and calls to it the function (_.arrayLeftIndexOf( arr, ins, equalizer )),
   * that returns the index of the value (ins) in the array (arr).
   * [wTools.arrayLeftIndexOf()]{@link wTools.arrayLeftIndexOf}
   * If (i) is more or equal to the zero, it returns the object containing the properties ({ index : i, element : arr[ i ] }).
   * Otherwise, it returns the empty object.
   *
   * @see {@link wTools.arrayLeftIndexOf} - See for more information.
   *
   * @param { arrayLike } arr - Entity to check.
   * @param { * } ins - Element to locate in the array.
   * @param { wTools~compareCallback } equalizer - A callback function.
   *
   * @example
   * // returns { index : 3, element : 'str' }
   * _.arrayLeft( [ 1, 2, false, 'str', 5 ], 'str', function( a, b ) { return a === b } );
   *
   * @example
   * // returns {  }
   * _.arrayLeft( [ 1, 2, 3, 4, 5 ], 6 );
   *
   * @returns { Object } Returns a new object containing the properties, (index, element),
   * corresponding to the found value (ins) from the array (arr).
   * Otherwise, it returns the empty object.
   * @method arrayLeft
   * @throws { Error } Will throw an Error if (equalizer) is not a Function.
   * @memberof wTools
   */

var arrayLeft = function( arr,ins,equalizer )
{

  var result = {};
  var i = _.arrayLeftIndexOf( arr,ins,equalizer );

  if( i >= 0 )
  {
    result.index = i;
    result.element = arr[ i ];
  }

  return result;
}

//

var arrayRight = function( arr,ins,equalizer )
{
  var result = {};
  var i = _.arrayRightIndexOf( arr,ins,equalizer );

  if( i >= 0 )
  {
    result.index = i;
    result.element = arr[ i ];
  }

  return result;
}

//

/**
 * The arrayHasAny() method checks if the (src) array has at least one value of the following arguments.
 *
 * It iterates over array-like (arguments[]) copies each argument to the array (ins) by the method
 * [arrayAs()]{@link wTools.arrayAs}
 * Checks, if (src) array has at least one value of the (ins) array.
 * If true, it returns true.
 * Otherwise, it returns false.
 *
 * @see {@link wTools.arrayAs} - See for more information.
 *
 * @param { arrayLike } src - The source array.
 * @param {...*} arguments - One or more argument(s).
 *
 * @example
 * // returns true
 * var arr = _.arrayHasAny( [ 5, 'str', 42, false ], false, 7 );
 *
 * @returns { Boolean } - Returns true, if (src) has at least one value of the following argument(s), otherwise false is returned.
 * @method arrayHasAny
 * @throws { Error } If the first argument in not an array.
 * @memberof wTools
 */

var arrayHasAny = function( src )
{
  _assert( _.arrayIs( src ) || _.bufferIs( src ),'arrayHasAny :','array expected' );

  for( var a = 1 ; a < arguments.length ; a++ )
  {

    var ins = _.arrayAs( arguments[ a ] );

    for( var i = 0 ; i < ins.length ; i++ )
    if( src.indexOf( ins[ i ] ) !== -1 )
    return true;

  }

  return false;
}

//

/**
 * The arrayCount() method returns the count of matched elements in the (src) array.
 *
 * @param { Array } src - The source array.
 * @param { * } instance - The value to search.
 *
 * @example
 * // returns 2
 * var arr = _.arrayCount( [ 1, 2, 'str', 10, 10, true ], 10 );
 *
 * @returns { Number } - Returns the count of matched elements in the (src).
 * @method arrayCount
 * @throws { Error } If passed arguments is less than two or more than two.
 * @throws { Error } If the first argument is not an array-like object.
 * @memberof wTools
 */

var arrayCount = function( src,instance )
{
  var result = 0;

  _assert( arguments.length === 2 );
  _assert( _.arrayLike( src ),'arrayCount :','expects ArrayLike' );

  var index = src.indexOf( instance );
  while( index !== -1 )
  {
    result += 1;
    index = src.indexOf( instance,index+1 );
  }

  return result;
}

//
  /**
   * The arrayCountSame() method returns the count of matched pairs ([ 1, 1, 2, 2, ., . ]) in the array (src).
   *
   * @param { arrayLike } src - The source array.
   * @param { Function } [ onElement = function( e ) { return e } ] - A callback function.
   *
   * @example
   * // returns 3
   * _.arrayCountSame( [ 1, 1, 2, 'abc', 'abc', 4, true, true ] );
   *
   * @example
   * // returns 0
   * _.arrayCountSame( [ 1, 2, 3, 4, 5 ] );
   *
   * @returns { Number } - Returns the count of matched pairs ([ 1, 1, 2, 2, ., . ]) in the array (src).
   * @method arrayCountSame
   * @throws { Error } If passed arguments is less than one or more than two.
   * @throws { Error } If the first argument is not an array-like object.
   * @throws { Error } If the second argument is not a Function.
   * @memberof wTools
   */

var arrayCountSame = function( src,onElement )
{
  var result = 0;
  var found = [];
  var onElement = onElement || function( e ){ return e };

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( _.arrayLike( src ),'arrayCountSame :','expects ArrayLike' );
  _.assert( _.routineIs( onElement ) );
  _.assert( onElement.length === 1 );

  for( var i1 = 0 ; i1 < src.length ; i1++ )
  {
    var element1 = onElement( src[ i1 ] );
    if( found.indexOf( element1 ) !== -1 )
    continue;

    for( var i2 = i1+1 ; i2 < src.length ; i2++ )
    {

      var element2 = onElement( src[ i2 ] );
      if( found.indexOf( element2 ) !== -1 )
      continue;

      if( element1 === element2 )
      found.push( element1 );

    }

  }

  return found.length;
}

//
  /**
   * The arraySum() method returns the sum of an array (src).
   *
   * @param { arrayLike } src - The source array.
   * @param { Function } [ onElement = function( e ) { return e } ] - A callback function.
   *
   * @example
   * // returns 15
   * _.arraySum( [ 1, 2, 3, 4, 5 ] );
   *
   * @example
   * // returns 29
   * _.arraySum( [ 1, 2, 3, 4, 5 ], function( e ) { return e * 2 } );
   *
   * @example
   * // returns 94
   * _.arraySum( [ true, false, 13, '33' ], function( e ) { return e * 2 } );
   *
   * @returns { Number } - Returns the sum of an array (src).
   * @method arraySum
   * @throws { Error } If passed arguments is less than one or more than two.
   * @throws { Error } If the first argument is not an array-like object.
   * @throws { Error } If the second argument is not a Function.
   * @memberof wTools
   */


var arraySum = function( src,onElement )
{
  var result = 0;

  _assert( arguments.length === 1 || arguments.length === 2 );
  _assert( _.arrayLike( src ),'arraySum :','expects ArrayLike' );

  if( onElement === undefined )
  onElement = function( e ){ return e; };

  _.assert( _.routineIs( onElement ) );

  for( var i = 0 ; i < src.length ; i++ )
  {
    result += onElement( src[ i ],i,src );
  }

  return result;
}

//

  /**
   * The arraySupplement() method returns an array (dstArray), that contains values from following arrays only type of numbers.
   * If the initial (dstArray) isn't contain numbers, they are replaced.
   *
   * It finds among the arrays the biggest array, and assigns to the variable (length), iterates over from 0 to the (length),
   * creates inner loop that iterates over (arguments[...]) from the right (arguments.length - 1) to the (arguments[0]) left,
   * checks each element of the arrays, if it contains only type of number.
   * If true, it adds element to the array (dstArray) by corresponding index.
   * Otherwise, it skips and checks following array from the last executable index, previous array.
   * If the last executable index doesn't exist, it adds 'undefined' to the array (dstArray).
   * After that it returns to the previous array, and executes again, until (length).
   *
   * @param { arrayLike } dstArray - The initial array.
   * @param { ...arrayLike } arguments[...] - The following array(s).
   *
   * @example
   * // returns [ 4, 5, 33, 13, 9, 7 ]
   * _.arraySupplement( [ 4, 5 ], [ 1, 2, 3 ], [ 6, 7, 8, true, 9 ], [ 'a', 'b', 33, 13, 'e', 7 ] );
   *
   * @example
   * // returns [ 4, 5, 33, 13, undefined, 7 ];
   * _.arraySupplement( [ 4, 5 ], [ 1, 2, 3 ], [ 6, 7, true, 9 ], [ 'a', 'b', 33, 13, 'e', 7 ] );
   *
   * @example
   * // returns [ 6, 7, 33, 13, 9, 7 ];
   * _.arraySupplement( [ 'a', 'b' ], [ 1, 2, 3 ], [ 6, 7, 8, true, 9 ], [ 'a', 'b', 33, 13, 'e', 7 ] );
   *
   * @returns { arrayLike } - Returns an array that contains values only type of numbers.
   * @method arraySupplement
   * @throws { Error } Will throw an Error if (dstArray) is not an array-like.
   * @throws { Error } Will throw an Error if (arguments[...]) is/are not the array-like.
   * @memberof wTools
   */

var arraySupplement = function arraySupplement( dstArray )
{
  var result = dstArray;
  if( result === null )
  result = [];

  var length = result.length;
  _assert( _.arrayLike( result ) || _.numberIs( result ),'expects object as argument' );

  for( a = arguments.length-1 ; a >= 1 ; a-- )
  {
    _assert( _.arrayLike( arguments[ a ] ),'argument is not defined :',a );
    length = Math.max( length,arguments[ a ].length );
  }

  if( _.numberIs( result ) )
  result = arrayFill
  ({
    value : result,
    times : length,
  });

  for( var k = 0 ; k < length ; k++ )
  {

    if( k in dstArray && isFinite( dstArray[ k ] ) )
    continue;

    var a;
    for( a = arguments.length-1 ; a >= 1 ; a-- )
    if( k in arguments[ a ] && !isNaN( arguments[ a ][ k ] ) )
    break;

    if( a === 0 )
    continue;

    result[ k ] = arguments[ a ][ k ];

  }

  return result;
}

//
  /**
   * The arrayExtendScreening() method iterates over (arguments[...]) from the right to the left (arguments[1]),
   * and returns a (dstArray) containing the values of the following arrays,
   * if the following arrays contains the indexes of the (screenArray).
   *
   * @param { arrayLike } screenArray - The source array.
   * @param { arrayLike } dstArray - To add the values from the following arrays,
   * if the following arrays contains indexes of the (screenArray).
   * If (dstArray) contains values, the certain values will be replaced.
   * @param { ...arrayLike } arguments[...] - The following arrays.
   *
   * @example
   * // returns [ 5, 6, 2 ]
   * _.arrayExtendScreening( [ 1, 2, 3 ], [  ], [ 0, 1, 2 ], [ 3, 4 ], [ 5, 6 ] );
   *
   * @example
   * // returns [ 'a', 6, 2, 13 ]
   * _.arrayExtendScreening( [ 1, 2, 3 ], [ 3, 'abc', 7, 13 ], [ 0, 1, 2 ], [ 3, 4 ], [ 'a', 6 ] );
   *
   * @example
   * // returns [ 3, 'abc', 7, 13 ]
   * _.arrayExtendScreening( [  ], [ 3, 'abc', 7, 13 ], [ 0, 1, 2 ], [ 3, 4 ], [ 'a', 6 ] )
   *
   * @returns { arrayLike } Returns a (dstArray) containing the values of the following arrays,
   * if the following arrays contains the indexes of the (screenArray).
   * If (screenArray) is empty, it returns a (dstArray).
   * If (dstArray) is equal to the null, it creates a new array,
   * and returns the corresponding values of the following arrays by the indexes of a (screenArray).
   * @method arrayExtendScreening
   * @throws { Error } Will throw an Error if (screenArray) is not an array-like.
   * @throws { Error } Will throw an Error if (dstArray) is not an array-like.
   * @throws { Error } Will throw an Error if (arguments[...]) is/are not an array-like.
   * @memberof wTools
   */

var arrayExtendScreening = function arrayExtendScreening( screenArray,dstArray )
{
  var result = dstArray;
  if( result === null ) result = [];

  _assert( _.arrayLike( screenArray ),'expects object as screenArray' );
  _assert( _.arrayLike( result ),'expects object as argument' );
  for( a = arguments.length-1 ; a >= 2 ; a-- )
  _assert( arguments[ a ],'argument is not defined :',a );

  for( var k = 0 ; k < screenArray.length ; k++ )
  {

    if( screenArray[ k ] === undefined )
    continue;

    var a;
    for( a = arguments.length-1 ; a >= 2 ; a-- )
    if( k in arguments[ a ] ) break;
    if( a === 1 )
    continue;

    result[ k ] = arguments[ a ][ k ];

  }

  return result;
}

//

var arrayShuffle = function arrayShuffle( dst,times )
{
  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( _.arrayLike( dst ) );

  if( times === undefined )
  times = dst.length;

  var l = dst.length;
  var e1,e2;
  for( var t1 = 0 ; t1 < times ; t1++ )
  {
    var t2 = Math.floor( Math.random() * l );
    e1 = dst[ t1 ];
    e2 = dst[ t2 ];
    dst[ t1 ] = e2;
    dst[ t2 ] = e1;
  }

  return dst;
}

//

/**
 * The arrayRandom() method returns an array which contains random numbers.
 *
 * @param { Object } o - The options for getting random numbers.
 * @param { Number } o.length - The length of an array.
 * @param { Array } [ o.range = [ 0, 1 ] ] - The range of numbers.
 * @param { Boolean } [ o.int = false ] - Floating point numbers or not.
 *
 * @example
 * // returns [ 6, 2, 4, 7, 8 ]
 * var arr = _.arrayRandom( {
 *   length : 5,
 *   range : [ 1, 9 ],
 *   int : true
 * } );
 *
 * @returns { Array } - Returns an array of random numbers.
 * @method arrayRandom
 * @memberof wTools
 */

var arrayRandom = function( o )
{
  var result = [];

  _.assert( arguments.length === 1 );

  if( _.numberIs( o ) )
  {
    o = { length : o };
  }

  if( o.int === undefined )
  o.int = false;

  if( o.range === undefined )
  o.range = [ 0,1 ];

  for( var i = 0 ; i < o.length ; i++ )
  {
    result[ i ] = o.range[ 0 ] + Math.random()*( o.range[ 1 ] - o.range[ 0 ] );
    if( o.int )
    result[ i ] = Math.floor(  result[ i ] );
  }

  return result;
}

//

/**
 * The arrayRange() method generate array of arithmetic progression series,
 * from the range[ 0 ] to the range[ 1 ] with increment 1.
 *
 * It iterates over loop from (range[0]) to the (range[ 1 ] - range[ 0 ]),
 * and assigns to the each index of the (result) array (range[ 0 ] + 1).
 *
 * @param { arrayLike } range - The first (range[ 0 ]) and the last (range[ 1 ] - range[ 0 ]) elements of the progression.
 *
 * @example
 * // returns [ 1, 2, 3, 4 ]
 * var range = _.arrayRange( [ 1, 5 ] );
 *
 * @example
 * // returns [ 0, 1, 2, 3, 4 ]
 * var range = _.arrayRange( 5 );
 *
 * @returns { array } Returns an array of numbers for the requested range with increment 1.
 * May be an empty array if adding the step would not converge toward the end value.
 * @method arrayRange
 * @throws { Error } If passed arguments is less than one or more than one.
 * @throws { Error } If the first argument is not an array-like object.
 * @throws { Error } If the length of the (range) is not equal to the two.
 * @memberof wTools
 */

var arrayRange = function( range )
{

  if( _.numberIs( range ) )
  range = [ 0,range ];

  _.assert( arguments.length === 1 );
  _.assert( _.arrayLike( range ) );
  _.assert( range.length === 2 );

  var result = [];
  var first = range[ 0 ];
  var len = range[ 1 ] - range[ 0 ];

  for( var i = 0 ; i < len ; i++ )
  result[ i ] = first + i;

  return result;
}

// --
// array set
// --

var arraySetIntersection = function( src )
{
  var result = [];

  _.assert( _.arrayLike( src ) );

  for( var i = 0 ; i < src.length ; i++ )
  {

    for( var a = 1 ; a < arguments.length ; a++ )
    {

      _.assert( _.arrayLike( arguments[ a ] ) );

      throw _.err( 'Not tested' );
      if( arguments[ a ].indexOf( src[ i ] ) !== -1 )
      {
        throw _.err( 'Not tested' );
        break;
      }
    }

    if( a === arguments.length )
    result.push( src[ i ] );

  }

  return result;
}

//
/*
var arraySetContainAll = function( src )
{
  var result = [];

  _.assert( _.arrayLike( src ) );

  for( var a = 1 ; a < arguments.length ; a++ )
  {

    _.assert( _.arrayLike( arguments[ a ] ) );

    if( src.length > arguments[ a ].length )
    return false;

    for( var i = 0 ; i < src.length ; i++ )
    {

      throw _.err( 'Not tested' );
      if( arguments[ a ].indexOf( src[ i ] ) !== -1 )
      {
        throw _.err( 'Not tested' );
        return false;
      }

    }

  }

  return true;
}
*/
//
  /**
   * The arraySetContainAll() method returns true, if at least one of the following arrays (arguments[...]),
   * contains all the same values as in the (src) array.
   *
   * @param { arrayLike } src - The source array.
   * @param { ...arrayLike } arguments[...] - The target array.
   *
   * @example
   * // returns true
   * _.arraySetContainAll( [ 1, 'b', 'c', 4 ], [ 1, 2, 3, 4, 5, 'b', 'c' ] );
   *
   * @example
   * // returns false
   * _.arraySetContainAll( [ 'abc', 'def', true, 26 ], [ 1, 2, 3, 4 ], [ 26, 'abc', 'def', true ] );
   *
   * @returns { boolean } Returns true, if at least one of the following arrays (arguments[...]),
   * contains all the same values as in the (src) array.
   * If length of the (src) is more than the next argument, it returns false.
   * Otherwise, it returns false.
   * @method arraySetContainAll
   * @throws { Error } Will throw an Error if (src) is not an array-like.
   * @throws { Error } Will throw an Error if (arguments[...]) is not an array-like.
   * @memberof wTools
   */

var arraySetContainAll = function( src )
{
  _.assert( _.arrayLike( src ) );

  for( var a = 1 ; a < arguments.length ; a++ )
  {

    _.assert( _.arrayLike( arguments[ a ] ) );

    if( src.length > arguments[ a ].length )
    return false;

    for( var i = 0 ; i < src.length ; i++ )
    {

      if( arguments[ a ].indexOf( src[ i ] ) === -1 )
      return false;

    }

  }

  return true; // return false
}

//
  /**
   * The arraySetContainSomething() method returns true, if at least one of the following arrays (arguments[...]),
   * contains the first matching value from (src).
   *
   * @param { arrayLike } src - The source array.
   * @param { ...arrayLike } arguments[...] - The target array.
   *
   * @example
   * // returns true
   * _.arraySetContainSomething( [ 33, 4, 5, 'b', 'c' ], [ 1, 'b', 'c', 4 ], [ 33, 13, 3 ] );
   *
   * @example
   * // returns true
   * _.arraySetContainSomething( [ 'abc', 'def', true, 26 ], [ 1, 2, 3, 4 ], [ 26, 'abc', 'def', true ] );
   *
   * @example
   * // returns false
   * _.arraySetContainSomething( [ 1, 'b', 'c', 4 ], [ 3, 5, 'd', 'e' ], [ 'abc', 33, 7 ] );
   *
   * @returns { Boolean } Returns true, if at least one of the following arrays (arguments[...]),
   * contains the first matching value from (src).
   * Otherwise, it returns false.
   * @method arraySetContainSomething
   * @throws { Error } Will throw an Error if (src) is not an array-like.
   * @throws { Error } Will throw an Error if (arguments[...]) is not an array-like.
   * @memberof wTools
   */

var arraySetContainSomething = function( src )
{
  _.assert( _.arrayLike( src ) );

  for( var a = 1 ; a < arguments.length ; a++ )
  {

    _.assert( _.arrayLike( arguments[ a ] ) );

    for( var i = 0 ; i < src.length ; i++ )
    {

      if( arguments[ a ].indexOf( src[ i ] ) !== -1 )
      {
        return true;
      }

    }

  }

  return false;
}

// --
// array sorted
// --

  /**
   * The _arraySortedLookUpAct() method returns the first index at which a given element (ins)
   * can be found in the array (arr).
   *
   * @param { arrayLike } arr - Entity to check.
   * @param { Number } ins - Element to locate in the array.
   * @param { Function } comparator - A callback function.
   * @param { Number } left - The index to start the search at.
   * @param { Number } right - The index to end the search at.
   *
   * @example
   * // returns 4
   * _arraySortedLookUpAct( [ 1, 2, 3, 4, 5 ], 5, function( a, b ) { return a - b }, 0, 5 );
   *
   * @example
   * // returns 5
   * _arraySortedLookUpAct( [ 1, 2, 3, 4, 5 ], 55, function( a, b ) { return a - b }, 0, 5 );
   *
   * @returns { Number } Returns the first index at which a given element (ins)
   * can be found in the array (arr).
   * Otherwise, if (ins) was not found, it returns the length of the array (arr) or the index from which it ended search at.
   * @method _arraySortedLookUpAct
   * @memberof wTools
   */

var _arraySortedLookUpAct = function( arr,ins,comparator,left,right )
{

  var d = 0;
  var current = Math.floor( ( left + right + 1 ) / 2 );

  while( left < right )
  {

    //var current = Math.floor( ( left + right + 1 ) / 2 );

    var d = comparator( arr[ current ],ins );

    if( d < 0 )
    {
      left = current + 1;
      current = Math.floor( ( left + right ) / 2 );
    }
    else if( d > 0 )
    {
      right = current - 1;
      current = Math.ceil( ( left + right ) / 2 );
    }
    else return current;

  }

  if( current < arr.length )
  {
    var d = comparator( arr[ current ],ins );
    if( d < 0 ) current += 1;
    //else if( d > 0 ) current -= 1;
  }

  return current;
}

//
  /**
   * The arraySortedLookUp() method returns a new object containing the properties, (value, index),
   * corresponding to the found value (ins) from array (arr).
   *
   * It calls the method (_._arraySortedLookUpAct( arr, ins, comparator, 0, arr.length - 1 )),
   * that returns the index of the value (ins) in the array (arr).
   * [wTools._arraySortedLookUpAct()]{@link wTools._arraySortedLookUpAct}.
   * If (index) is equal to the one, it returns 'undefined'.
   * If call callback function (comparator( ins, arr[ index ]) returns a value that is not equal to the zero, it returns 'undefined'.
   * Otherwise, it returns the object containing the properties ({ value : arr[ index ], index : index }).
   *
   * @see {@link wTools._arraySortedLookUpAct} - See for more information.
   *
   * @param { arrayLike } arr - Entity to check.
   * @param { Number } ins - Element to locate in the array.
   * @param { wTools~compareCallback } [comparator=function( a, b ) { return a - b }] comparator - A callback function.
   *
   * @example
   * // returns { value : 5, index : 4 }
   * arraySortedLookUp( [ 1, 2, 3, 4, 5 ], 5, function( a, b ) { return a - b } );
   *
   * @example
   * // returns undefined
   * arraySortedLookUp( [ 1, 2, 3, 4, 5 ], 55, function( a, b ) { return a - b } );
   *
   * @returns { Object } Returns a new object containing the properties, (value, index),
   * corresponding to the found value (ins) from the array (arr).
   * Otherwise, it returns 'undefined'.
   * @method arraySortedLookUp
   * @throws { Error } Will throw an Error if (arguments.length) is less than two or more than three.
   * @throws { Error } Will throw an Error if (arr) is not an array-like.
   * @memberof wTools
   */

var arraySortedLookUp = function( arr,ins,comparator )
{

  _.assert( arguments.length === 2 || arguments.length === 3 );
  _.assert( _.arrayLike( arr ) );

  if( comparator === undefined )
  comparator = function( a,b ){ return a-b };

  var l = arr.length;
  var index = _._arraySortedLookUpAct( arr,ins,comparator,0,l-1 );

  if( index === l )
  return;

  if( comparator( ins,arr[ index ] ) !== 0 )
  return;

  return { value : arr[ index ], index : index };
}

//

var arraySortedClosest = function( arr,ins,comparator )
{

  _.assert( arguments.length === 2 || arguments.length === 3 );
  _.assert( _.arrayLike( arr ) );

  if( !arr.length )
  return { index : 0 };

  if( comparator === undefined )
  comparator = function( a,b ){ return a-b };

  var l = arr.length;
  var index = _._arraySortedLookUpAct( arr,ins,comparator,0,l-1 );

  if( index === l ) return { index : l-1, value : arr[ l-1 ] };

  var c = comparator( arr[ index ],ins );
  if( c  === 0 ) return { value : arr[ index ], index : index };
  if( c < 0 )
  {
    throw _.err( 'redundant branch?' );
    if( ( arr.length-1 ) === index )
    return { value : arr[ index ], index : index };
    else if( Math.abs( comparator( arr[ index + 1 ],ins ) ) < Math.abs( c ) )
    return { value : arr[ index + 1 ], index : index + 1 };
    else
    return { value : arr[ index ], index : index };
  }
  if( c > 0 )
  {
    if( 0 === index )
    return { value : arr[ index ], index : index };
    else if( Math.abs( comparator( arr[ index - 1 ],ins ) ) < Math.abs( c ) )
    return { value : arr[ index - 1 ], index : index - 1 };
    else
    return { value : arr[ index ], index : index };
  }

}

//
  /**
   * The arraySortedRemove() method returns true, if a value (ins) was removed from an array (arr).
   * Otherwise, it returns false.
   *
   * It calls the method (_._arraySortedLookUpAct( arr, ins, comparator, 0, arr.length - 1 )),
   * that returns the index of the value (ins) in the array (arr).
   * [wTools._arraySortedLookUpAct()]{@link wTools._arraySortedLookUpAct}.
   * If (index) is not equal to the one, and call callback function (comparator( ins, arr[ index ])
   * returns a value that is equal to the zero (i.e the array (arr) contains the value (ins)), it removes the value (ins) from the array (arr), and returns true.
   * Otherwise, it returns false.
   *
   * @see {@link wTools._arraySortedLookUpAct} - See for more information.
   *
   * @param { arrayLike } arr - Entity to check.
   * @param { Number } ins - Element to locate in the array.
   * @param { wTools~compareCallback } [ comparator = function( a, b ) { return a - b } ] comparator - A callback function.
   *
   * @example
   * // returns true
   * arraySortedRemove( [ 1, 2, 3, 4, 5 ], 5, function( a, b ) { return a - b } ); // => [ 1, 2, 3, 4 ]
   *
   * @example
   * // returns false
   * arraySortedRemove( [ 1, 2, 3, 4, 5 ], 55, function( a, b ) { return a - b } ); // => [ 1, 2, 3, 4, 5 ]
   *
   * @returns { Boolean } Returns true, if a value (ins) was removed from an array (arr).
   * Otherwise, it returns false.
   * @method arraySortedRemove
   * @throws { Error } Will throw an Error if (arguments.length) is less than two or more than three.
   * @throws { Error } Will throw an Error if (arr) is not an array-like.
   * @memberof wTools
   */

var arraySortedRemove = function( arr,ins,comparator )
{

  _.assert( arguments.length === 2 || arguments.length === 3 );
  _.assert( _.arrayLike( arr ) );

  if( comparator === undefined ) comparator = function( a,b ){ return a-b };
  var l = arr.length;
  var index = _._arraySortedLookUpAct( arr,ins,comparator,0,l-1 );

  var remove = index !== l && comparator( ins,arr[ index ] ) === 0;

  if( remove ) arr.splice( index,1 );

  return remove;
}

//
  /**
   * The arraySortedAddOnce() method returns true, if a value (ins) was added to an array (arr).
   * Otherwise, it returns false.
   *
   * It calls the method (_._arraySortedLookUpAct( arr, ins, comparator, 0, arr.length - 1 )),
   * that returns the index of the value (ins) in the array (arr).
   * [wTools._arraySortedLookUpAct() ]{@link wTools._arraySortedLookUpAct}.
   * If (index) is equal to the one, and call callback function (comparator( ins, arr[ index ])
   * returns a value that is not equal to the zero (i.e the array (arr) doesn't contain the value (ins)), it adds the value (ins) to the array (arr), and returns true.
   * Otherwise, it returns false.
   *
   * @see {@link wTools._arraySortedLookUpAct} - See for more information.
   *
   * @param { arrayLike } arr - Entity to check.
   * @param { Number } ins - Element to locate in the array.
   * @param { wTools~compareCallback } [ comparator = function( a, b ) { return a - b } ] comparator - A callback function.
   *
   * @example
   * // returns false
   * arraySortedAddOnce( [ 1, 2, 3, 4, 5 ], 5, function( a, b ) { return a - b } ); // => [ 1, 2, 3, 4, 5 ]
   *
   * @example
   * // returns true
   * arraySortedAddOnce( [ 1, 2, 3, 4, 5 ], 55, function( a, b ) { return a - b } ); // => [ 1, 2, 3, 4, 5, 55 ]
   *
   * @returns { Boolean } Returns true, if a value (ins) was added to an array (arr).
   * Otherwise, it returns false.
   * @method arraySortedAddOnce
   * @throws { Error } Will throw an Error if (arguments.length) is less than two or more than three.
   * @throws { Error } Will throw an Error if (arr) is not an array-like.
   * @memberof wTools
   */

var arraySortedAddOnce = function( arr,ins,comparator )
{

  _.assert( arguments.length === 2 || arguments.length === 3 );
  _.assert( _.arrayLike( arr ) );

  if( comparator === undefined ) comparator = function( a,b ){ return a-b };
  var l = arr.length;
  var index = _._arraySortedLookUpAct( arr,ins,comparator,0,l-1 );

  var add = index === l || comparator( ins,arr[ index ] ) !== 0;

  if( add ) arr.splice( index,0,ins );

  return add;
}

//

  /**
   * The arraySortedAdd() method adds the value (ins) to the array (arr), no matter whether it has there or hasn't,
   * and returns the new added or the updated index.
   *
   * It calls the method (_._arraySortedLookUpAct( arr, ins, comparator, 0, arr.length - 1 )),
   * that returns the index of the value (ins) in the array (arr).
   * [wTools._arraySortedLookUpAct() ]{@link wTools._arraySortedLookUpAct}.
   * If value (ins) has in the array (arr), it adds (ins) to that found index and offsets the old values in the (arr).
   * Otherwise, it adds the new index.
   *
   * @see {@link wTools._arraySortedLookUpAct} - See for more information.
   *
   * @param { arrayLike } arr - Entity to check.
   * @param { Number } ins - Element to locate in the array.
   * @param { wTools~compareCallback } [ comparator = function( a, b ) { return a - b } ] comparator - A callback function.
   *
   * @example
   * // returns 5
   * arraySortedAdd( [ 1, 2, 3, 4, 5 ], 5, function( a, b ) { return a - b } ); // => [ 1, 2, 3, 4, 5, 5 ]
   *
   * @example
   * // returns 4
   * arraySortedAdd( [ 1, 2, 3, 4 ], 2, function( a, b ) { return a - b } ); // => [ 1, 2, 2, 3, 4 ]
   *
   * @returns { Number } Returns the new added or the updated index.
   * @method arraySortedAdd
   * @throws { Error } Will throw an Error if (arguments.length) is less than two or more than three.
   * @throws { Error } Will throw an Error if (arr) is not an array-like.
   * @memberof wTools
   */

var arraySortedAdd = function( arr,ins,comparator )
  {

    _.assert( arguments.length === 2 || arguments.length === 3 );
    _.assert( _.arrayLike( arr ) );

    if( comparator === undefined ) comparator = function( a,b ){ return a-b };
    var l = arr.length;
    var index = _._arraySortedLookUpAct( arr,ins,comparator,0,l-1 );

    arr.splice( index,0,ins );

    return index;
  }

//
  /**
   * The arraySortedAddArray() method returns the sum of the added indexes from an array (src) to an array (dst).
   *
   * It creates variable (result = 0), iterates over an array (src),
   * adds to the (result +=) each call the function (arraySortedAdd( dst, src[ s ], comparator ))
   * that returns the new added or the updated index.
   *
   * @see {@link wTools_.arraySortedAdd} - See for more information.
   *
   * @param { arrayLike } dst - Entity to check.
   * @param { arrayLike } src - Entity to check.
   * @param { wTools~compareCallback } [ comparator = function( a, b ) { return a - b } ] comparator - A callback function.
   *
   * @example
   * // returns 19
   * arraySortedAddArray( [ 1, 2, 3, 4, 5 ], [ 6, 7, 8, 2 ], function( a, b ) { return a - b } ); // => [ 1, 2, 2, 3, 4, 5, 6, 7, 8 ]
   *
   * @example
   * // returns 3
   * arraySortedAddArray( [  ], [ 1, 2, 3 ], function( a, b ) { return a - b } ); // => [ 1, 2, 3 ]
   *
   * @returns { Number } Returns the sum of the added indexes from an array (src) to an array (dst).
   * @method arraySortedAddArray
   * @throws { Error } Will throw an Error if (arguments.length) is less than two or more than three.
   * @throws { Error } Will throw an Error if (dst and src) are not an array-like.
   * @memberof wTools
   */

var arraySortedAddArray = function( dst,src,comparator )
{

  _.assert( arguments.length === 2 || arguments.length === 3 );
  _.assert( _.arrayLike( dst ) && _.arrayLike( src ) );

  var result = 0;

  //throw _.err( 'not tested' );

  if( comparator === undefined ) comparator = function( a,b ){ return a-b };

  for( var s = 0 ; s < src.length ; s++ )
  result += arraySortedAdd( dst,src[ s ],comparator );

  return result;
}

// --
// map
// --

  /**
   * @callback mapClone~onCopyField
   * @param { objectLike } dstContainer - The target object.
   * @param { objectLike } srcContainer - The source object.
   * @param { string } key - The key of the (srcObject) target object.
   */

  /**
   * The mapClone() method is used to clone the values of all
   * enumerable own properties from (srcObject) object to an (options.dst) object.
   *
   * It creates two variables:
   * var options = options || {}, result = options.dst || {}.
   * Iterate over (srcObject) object, checks if (srcObject) object has own properties.
   * If true, it calls the provided callback function ( options.onCopyField( result, srcObject, k ) ) for each key (k),
   * and copies each [ key, value ] of the (srcObject) to the (result),
   * and after cycle, returns clone with prototype of srcObject.
   *
   * @param { objectLike } srcObject - The source object.
   * @param { Object } o - The options.
   * @param { objectLike } [options.dst = {}] - The target object.
   * @param { mapClone~onCopyField } [options.onCopyField()] - The callback function to copy each [ key, value ]
   * of the (srcObject) to the (result).
   *
   * @example
   * // returns Example { sex : 'Male', name : 'Peter', age : 27 }
   * var Example = function() {
   *   this.name = 'Peter';
   *   this.age = 27;
   * }
   * mapClone( new Example(), { dst : { sex : 'Male' } } );
   *
   * @returns { objectLike }  The (result) object gets returned.
   * @method mapClone
   * @throws { Error } Will throw an Error if ( o ) is not an Object,
   * if ( arguments.length > 2 ), if (key) is not a String or
   * if (srcObject) has not own properties.
   * @memberof wTools
   */

var mapClone = function( srcObject,o )
{
  var o = o || {};
  var result = o.dst || {};

  _assert( _.mapIs( o ) );
  _assert( arguments.length <= 2,'mapClone :','expects srcObject as argument' );
  _assert( objectLike( srcObject ),'mapClone :','expects srcObject as argument' );

  if( !o.onCopyField )
  o.onCopyField = function( dstContainer,srcContainer,key )
  {
    _.assert( _.strIs( key ) );
    dstContainer[ key ] = srcContainer[ key ];
  }

  for( var k in srcObject )
  {
    if( _ObjectHasOwnProperty.call( srcObject,k ) )
    o.onCopyField( result,srcObject,k,o.onCopyField );
  }

  Object.setPrototypeOf( result, Object.getPrototypeOf( srcObject ) );

  return result;
}

  // /**
  //  * @callback _.filter.supplementary()
  //  * @param { objectLike } dstObject - The target object.
  //  * @param { objectLike } argument - The next object.
  //  * @param { string } key - The key of the (argument) object.
  //  */

  /**
   * The mapExtendFiltering() creates a new [ key, value ]
   * from the next objects if callback function (filter) returns true.
   *
   * It calls a provided callback function (filter) once for each key in an (argument),
   * and adds to the (srcObject) all the [ key, value ] for which callback
   * function (filter) returns true.
   *
   * @param { function } filter - The callback function to test each [ key, value ]
   * of the (dstObject) object.
   * @param { objectLike } dstObject - The target object.
   * @param { ...objectLike } arguments[] - The next object.
   *
   * @example
   * // returns { a : 1, b : 2, c : 3 }
   * _.mapExtendFiltering( _.filter.supplementary(), { a : 1, b : 2 }, { a : 1 , c : 3 } );
   *
   * @returns { objectLike } Returns the unique [ key, value ].
   * @method mapExtendFiltering
   * @throws { Error } Will throw an Error if ( arguments.length < 3 ), (filter)
   * is not a Function, (result) and (argument) are not the objects.
   * @memberof wTools
   */

var mapExtendFiltering = function( filter,dstObject )
{
  var result = dstObject;
  var filter = _.filter.makeMapper( filter );

  if( result === null ) result = {};

  _assert( arguments.length >= 3 );
  _assert( _.routineIs( filter ) );
  _assert( _.objectLike( result ),'mapExtendFiltering :','expects object as argument' );

  for( var a = 2 ; a < arguments.length ; a++ )
  {

    var argument = arguments[ a ];

    _.assert( !_.atomicIs( argument ),'mapExtendFiltering : expects object-like entity to extend, but got :',_.strTypeOf( argument ) );

    for( var k in argument )
    {

      filter.call( this,dstObject,argument,k );

    }

  }

  return result;
}

//

/**
 * The mapExtend() is used to copy the values of all properties
 * from one or more source objects to a target object.
 *
 * It takes first object (dstObject)
 * creates variable (result) and assign first object.
 * Checks if arguments equal two or more and if (result) is an object.
 * If true,
 * it extends (result) from the next objects.
 *
 * @param{ objectLike } dstObject - The target object.
 * @param{ ...objectLike } arguments[] - The source object(s).
 *
 * @example
 * // returns { a : 7, b : 13, c : 3, d : 33, e : 77 }
 * mapExtend( { a : 7, b : 13 }, { c : 3, d : 33 }, { e : 77 } );
 *
 * @returns { objectLike } It will return the target object.
 * @method mapExtend
 * @throws { Error } Will throw an error if ( arguments.length < 2 ),
 * if the (dstObject) is not an Object.
 * @memberof wTools
 */

var mapExtend = function mapExtend( dstObject )
{
  var result = dstObject;

  if( result === null ) result = {};

  assert( arguments.length >= 2 );
  assert( objectLike( result ),'mapExtend :','expects object as argument' );

  for( var a = 1 ; a < arguments.length ; a++ )
  {

    var argument = arguments[ a ];

    for( var k in argument )
    {
      result[ k ] = argument[ k ];
    }

  }

  return result;
}
  //

  // /**
  //  * @callback  _.filter.supplementary()
  //  * @param { objectLike } dstObject - The target object.
  //  * @param { objectLike } argument - The next object.
  //  * @param { string } key - The key of the (argument) object.
  //  */

  /**
   * The mapSupplement() method returns an object with unique [ key, value ].
   *
   * It creates the variable (args), assign to a copy of pseudo array (arguments),
   * adds a callback function ( _.filter.supplementary() ) to the beginning of the (args)
   * and returns an object with unique [ key, value ].
   *
   * @param { ...objectLike } arguments[] - The source object(s).
   *
   * @example
   * // returns { a : 1, b : 2, c : 3 }
   * mapSupplement( { a : 1, b : 2 }, { a : 1, c : 3 } );
   *
   * @returns { objectLike } Returns an object with unique [ key, value ].
   * @method mapSupplement
   * @memberof wTools
   */

var mapSupplement = function( dst )
{

  var args = _.arraySlice( arguments );
  args.unshift( _.filter.supplementary() );
  return mapExtendFiltering.apply( this,args );

/*
  var result = dst;

  if( result === null ) result = {};

  _assert( arguments.length >= 2 );
  _assert( _.objectLike( result ),'mapSupplement :','expects object as argument' );

  for( var a = 1 ; a < arguments.length ; a++ )
  {

    var argument = arguments[ a ];

    for( var k in argument )
    {
      if( k in result )
      continue;
      result[ k ] = argument[ k ];
    }

  }

  return result;
*/
}

//

// /**
//  * @callback  _.filter.supplementaryCloning()
//  * @param { objectLike } dstContainer - The target object.
//  * @param { objectLike } srcContainer - The next object.
//  * @param { string } key - The key of the (srcContainer) object.
//  */

/**
 * The mapComplement() method returns an object
 * filled by all unique, clone [ key, value ].
 *
 * It creates the variable (args), assign to a copy of pseudo array (arguments),
 * adds a specific callback function (_.filter.supplementaryCloning())
 * to the beginning of the (args)
 * and returns an object filled by all unique clone [key, value].
 *
 * @param { ...objectLike } arguments[] - The source object(s).
 *
 * @example
 * // returns { a : 1, b : 'yyy', c : 3 };
 * _.mapComplement( { a : 1, b : 'yyy' }, { a : 12 , c : 3 } );
 *
 * @returns { objectLike } Returns an object filled by all unique, clone [ key, value ].
 * @method mapComplement
 * @memberof wTools
 */

var mapComplement = function( dst )
{

  var args = _.arraySlice( arguments );
  args.unshift( _.filter.supplementaryCloning() ); // ??? own
  return mapExtendFiltering.apply( this,args );

}

  /**
   * The mapCopy() method is used to copy the values of all properties
   * from one or more source objects to the new object.
   *
   * @param { ...objectLike } arguments[] - The source object(s).
   *
   * @example
   * // returns { a : 7, b : 13, c : 3, d : 33, e : 77 }
   * _.mapCopy( { a : 7, b : 13 }, { c : 3, d : 33 }, { e : 77 } );
   *
   * @returns { objectLike } It will return the new object filled by [ key, value ]
   * from one or more source objects.
   * @method mapCopy
   * @memberof wTools
   */

var mapCopy = function mapCopy()
{
  var args = _.arrayAppendMerging( [],{},arguments );
  return _.mapExtend.apply( _,args );
}

// --
// map test
// --

var mapSatisfy = function mapSatisfy( o )
{

  if( arguments.length === 2 )
  o = { template : arguments[ 0 ], src : arguments[ 1 ] };

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( _.objectIs( o.template ) || _.routineIs( o.template ) );
  _.assert( o.src !== undefined );

  _.routineOptions( mapSatisfy,o );

  return _mapSatisfy( o.template,o.src,o.src,o.levels );
}

mapSatisfy.defaults =
{
  template : null,
  src : null,
  levels : 256,
}

//

var _mapSatisfy = function _mapSatisfy( template,src,root,levels )
{

  if( levels <= 0 )
  throw _.err( '_mapSatisfy : too deep structure' );

  if( _.routineIs( template ) )
  return template( src );

  if( objectIs( template ) )
  {
    for( var t in template )
    return _mapSatisfy( template[ t ],src[ t ],root,levels-1 );
  }

  return template === src;
}

// --
// map converter
// --

  /**
   * The mapFirstPair() method returns first pair [ key, value ] as array.
   *
   * @param { objectLike } srcObject - An object like entity of get first pair.
   *
   * @example
   * // returns [ 'a', 3 ]
   * _.mapFirstPair( { a : 3, b : 13 } );
   *
   * @example
   * // returns 'undefined'
   * _.mapFirstPair( {  } );
   *
   * @example
   * // returns [ '0', [ 'a', 7 ] ]
   * _.mapFirstPair( [ [ 'a', 7 ] ] );
   *
   * @returns { Array } Returns pair [ key, value ] as array if (srcObject) has fields, otherwise, undefined.
   * @method mapFirstPair
   * @throws { Error } Will throw an Error if (arguments.length) less than one, if (srcObject) is not an object-like.
   * @memberof wTools
   */

var mapFirstPair = function mapFirstPair( srcObject )
{

  _.assert( arguments.length === 1 );
  _.assert( _.objectLike( srcObject ) );

  for( var s in srcObject )
  {
    return [ s,srcObject[ s ] ];
  }

}

//

  /**
   * The mapToArray() converts an object (src) into array [ [ key, value ] ... ].
   *
   * It takes an object (src) creates an empty array,
   * checks if ( arguments.length === 1 ) and (src) is an object.
   * If true, it returns a list of [ [ key, value ] ... ] pairs.
   * Otherwise it throws an Error.
   *
   * @param { objectLike } src - object to get a list of [ key, value ] pairs.
   *
   * @example
   * // returns [ [ 'a', 3 ], [ 'b', 13 ], [ 'c', 7 ] ]
   * _.mapToArray( { a : 3, b : 13, c : 7 } );
   *
   * @returns { array } Returns a list of [ [ key, value ] ... ] pairs.
   * @method mapToArray
   * @throws { Error } Will throw an Error if( arguments.length !== 1 ) or (src) is not an object.
   * @memberof wTools
   */

var mapToArray = function( src )
{
  var result = [];

  _.assert( arguments.length === 1 );
  _.assert( _.objectIs( src ) );

  for( var s in src )
  {
    result.push( [ s,src[s] ] );
  }

  return result;
}

//

  // +++ param (src) may be not only an array.
  // +++ throws is not defined in the function.

  /**
   * The mapValWithIndex() returns value of (src) by corresponding (index).
   *
   * It takes (src) and (index), creates a variable ( i = 0 ),
   * checks if ( index > 0 ), iterate over (src) object-like and match
   * if ( i == index ).
   * If true, it returns value of (src).
   * Otherwise it increment ( i++ ) and iterate over (src) until it doesn't match index.
   *
   * @param { objectLike } src - An object-like.
   * @param { number } index - To find the position an element.
   *
   * @example
   * // returns 7
   * _.mapValWithIndex( [ 3, 13, 'c', 7 ], 3 );
   *
   * @returns { * } Returns value of (src) by corresponding (index).
   * @method mapValWithIndex
   * @throws { Error } Will throw an Error if( arguments.length > 2 ) or (src) is not an Object.
   * @memberof wTools
   */

var mapValWithIndex = function( src,index )
{

  _.assert( arguments.length === 2 );
  _.assert( _.objectLike( src ) );


  if( index < 0 ) return;

  var i = 0;
  for( var s in src )
  {
    if( i == index ) return src[s];
    i++;
  }
}

//

  /**
   * The mapKeyWithIndex() returns key of (src) by corresponding (index).
   *
   * It takes (src) and (index), creates a variable ( i = 0 ),
   * checks if ( index > 0 ), iterate over (src) object-like and match
   * if ( i == index ).
   * If true, it returns value of (src).
   * Otherwise it increment ( i++ ) and iterate over (src) until it doesn't match index.
   *
   * @param { objectLike } src - An object-like.
   * @param { number } index - To find the position an element.
   *
   * @example
   * // returns '1'
   * _.mapKeyWithIndex( [ 'a', 'b', 'c', 'd' ], 1 );
   *
   * @returns { string } Returns key of (src) by corresponding (index).
   * @method mapKeyWithIndex
   * @throws { Error } Will throw an Error if( arguments.length > 2 ) or (src) is not an Object.
   * @memberof wTools
   */

var mapKeyWithIndex = function( src,index )
{

   _.assert( arguments.length === 2 );
   _.assert( _.objectLike( src ) );

  if( index < 0 ) return;

  var i = 0;
  for( var s in src )
  {
    if( i == index ) return s;
    i++;
  }

}

//

  /**
   * The mapToString() method converts and returns the passed object (src) to the string.
   *
   * It takes an object and two strings (keyValSep) and (tupleSep),
   * checks if (keyValSep and tupleSep) are strings.
   * If false, it assigns them defaults (' : ') to the (keyValSep) and
   * ('; ') to the tupleSep.
   * Otherwise, it returns a string representing the passed object (src).
   *
   * @param { objectLike } src - The object to convert to the string.
   * @param { string } [ keyValSep = ' : ' ] keyValSep - colon.
   * @param { string } [ tupleSep = '; ' ] tupleSep - semicolon.
   *
   * @example
   * // returns 'a : 1; b : 2; c : 3; d : 4'
   * _.mapToString( { a : 1, b : 2, c : 3, d : 4 }, ' : ', '; ' );
   *
   * @example
   * // returns '0 : 1; 1 : 2; 2 : 3';
   * _.mapToString( [ 1, 2, 3 ], ' : ', '; ' );
   *
   * @example
   * // returns '0 : a; 1 : b; 2 : c';
   * _.mapToString( 'abc', ' : ', '; ' );
   *
   * @returns { string } Returns a string (result) representing the passed object (src).
   * @method mapToString
   * @memberof wTools
   */

var mapToString = function( src,keyValSep,tupleSep )
{

  if( !_.strIs( keyValSep ) )
  keyValSep = ' : ';

  if( !_.strIs( tupleSep ) )
  tupleSep = '; ';

  var result = '';
  for( var s in src )
  {
    result += s + keyValSep + src[ s ] + tupleSep;
  }

  result = result.substr( 0,result.length-tupleSep.length );

  return result
}

//

/**
 * The mapOwnKeys() returns an array of a given objects own enumerable properties,
 * in the same order as that provided by a for...in loop.
 *
 * @param { ...objectLike } src - The object whose properties are to be returned.
 *
 * @example
 * // returns [ "a", "b" ]
 * _.mapOwnKeys({ a : 7, b : 13 });
 *
 * @return { array } Returns an array whose elements are strings
 * corresponding to the enumerable properties found directly upon object.
 * @method mapOwnKeys
 * @throws { Error } Will throw an Error if (src) is not an Object.
 * @memberof wTools
*/

var mapOwnKeys = function mapOwnKeys( src )
{
  var result = [];

  if( arguments.length === 0 )
  return result;

  _.assert( _.objectLike( src ) || _.errorIs( src ) );

  if( arguments.length === 1 )
  if( _.objectIs( src ) || _.errorIs( src ) && Object.keys )
  return Object.keys( src );

  for( var s in src )
  if( _ObjectHasOwnProperty.call( src,s ) )
  result.push( s );

  for( var a = 1 ; a < arguments.length ; a++ )
  {
    var src = arguments[ a ];
    for( var s in src )
    if( _ObjectHasOwnProperty.call( src,s ) )
    _.arrayAppendOnce( result,s );
  }

  return result;
}

//

/**
 * This routine returns an array of a given objects enumerable properties,
 * in the same order as that provided by a for...in loop.
 * Accept several objects or single. Each element of result array is unique.
 * Unlike standard [Object.keys]{@https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Global_Objects/Object/keys}
 * which accept object only mapKeys accept any object-like entity.
 *
 * @see {@link wTools.mapOwnKeys} - Similar routine taking into account own elements only.
 * @see {@link wTools.mapValues} - Similar routine returning values.
 *
 * @example
 * // returns [ "a", "b" ]
 * _.mapKeys({ a : 7, b : 13 });
 *
 * @param { ...objectLike } src - objects of interest to extract keys.
 * @return { array } Returns an array with unique string elements.
 * corresponding to the enumerable properties found directly upon object.
 * @method mapKeys
 * @throws { Exception } Throw an exception if (src) is not an object-like entity.
 * @memberof wTools
 */

var mapKeys = function mapKeys( src )
{
  var result = [];

  if( arguments.length === 0 )
  return result;

  _.assert( _.objectLike( src ) || errorIs( src ));

  for( var s in src )
  result.push( s );

  for( var a = 1 ; a < arguments.length ; a++ )
  {
    var src = arguments[ a ];
    _.assert( _.objectLike( src ) || errorIs( src ) );
    for( var s in src )
    _.arrayAppendOnce( result,s );
  }

  return result;
}

//

var mapOwnValues = function( src )
{
  var result = [];

  _.assert( arguments.length === 1 );
  _.assert( _.objectLike( src ) );

  for( var s in src )
  {
    if( _ObjectHasOwnProperty.call( src,s ) )
    result.push( src[ s ] );
  }

  return result;
}

//

/**
 * The mapValues() method returns an array of a given object's
 * own enumerable property values,
 * in the same order as that provided by a for...in loop.
 *
 * It takes an object (src) creates an empty array,
 * checks if (src) is an object.
 * If true, it returns an array of values,
 * otherwise it returns an empty array.
 *
 * @param { objectLike } src - The object whose property values are to be returned.
 *
 * @example
 * // returns [ "7", "13" ]
 * _.mapValues( { a : 7, b : 13 } );
 *
 * @returns { array } Returns an array whose elements are strings.
 * corresponding to the enumerable property values found directly upon object.
 * @method mapValues
 * @throws { Error } Will throw an Error if (src) is not an Object.
 * @memberof wTools
*/

var mapValues = function( src )
{
  var result = [];

  _.assert( arguments.length === 1 );
  _.assert( _.objectLike( src ) );

  for( var s in src )
  result.push( src[ s ] );

  return result;
}

//

/**
 * The mapPairs() converts an object into a list of [ key, value ] pairs.
 *
 * It takes an object (src) creates an empty array,
 * checks if (src) is an object.
 * If true, it returns a list of [ key, value ] pairs,
 * otherwise it returns an empty array.
 *
 * @param { objectLike } src - Object to get a list of [ key, value ] pairs.
 *
 * @example
 * // returns [ [ "a", 7 ], [ "b", 13 ] ]
 * _.mapPairs( { a : 7, b : 13 } );
 *
 * @returns { array } A list of [ key, value ] pairs.
 * @method mapPairs
 * @throws { Error } Will throw an Error if (src) is not an Object.
 * @memberof wTools
*/

var mapPairs = function( src )
{
  var result = [];

  _.assert( _.objectLike( src ) );

  for( var s in src )
  result.push([ s, src[ s ] ]);

  return result;
}

//

var mapInvertKeyValue = function( src )
{
  var result = {};

  _.assert( _.objectLike( src ) );

  for( var s in src )
  {
    _.assert( result[ src[ s ] ] === undefined,'cant invert key value of the map' );
    result[ src[ s ] ] = s;
  }

  return result;
}

//
/*
var mapsPluck = function( srcMaps,filterName )
{
  var result = new srcMaps.constructor();
  var filterName = _.nameUnfielded( filterName ).coded;

  _assert( _.arrayIs( srcMaps ) || _.objectIs( srcMaps ) );

  _.each( srcMaps,function( e,k )
  {

    result[ k ] = e[ filterName ];

  });

  return result;
}
*/

// --
// map filter
// --

/**
 * The mapSame() returns true, if the second object (src2)
 * has the same values as the first object(src1).
 *
 * It takes two objects (scr1, src2), checks
 * if both object have the same length and [key, value] return true
 * otherwise it returns undefined.
 *
 * @param { objectLike } src1 - First object.
 * @param { objectLike } src2 - Target object.
 * Objects to compare values.
 *
 * @example
 * // returns true
 * mapSame( { a : 7, b : 13 }, { a : 7, b : 13 } );
 *
 * @example
 * returns undefined
 * _.mapSame( { a : 7, b : 13 }, { a : 33, b : 13 } );
 *
 * @example
 * returns undefined
 * _.mapSame( { a : 7, b : 13, c : 33 }, { a : 7, b : 13 } );
 *
 * @returns { boolean } Returns true, if the second object (src2)
 * has the same values as the first object(src1).
 * @method mapSame
 * @throws Will throw an error if ( arguments.length !== 2 ).
 * @memberof wTools
 */

var mapSame = function( src1,src2 ){

  _.assert( arguments.length === 2 );

  if( Object.keys( src1 ).length !== Object.keys( src2 ).length ) return;

  for( var s in src1 )
  {
    if( src1[ s ] !== src2[ s ] ) return;
  }

  return true;
}

//

/**
 * The mapContain() returns true, if the first object (src)
 * has the same values as the second object(ins).
 *
 * It takes two objects (scr, ins),
 * checks if the first object (src) has the same [key, value] as
 * the second object (ins).
 * If true, it returns true,
 * otherwise it returns false.
 *
 * @param { objectLike } src - Target object.
 * @param { objectLike } ins - Second object.
 * Objects to compare values.
 *
 * @example
 * // returns true
 * mapContain( { a : 7, b : 13, c : 15 }, { a : 7, b : 13 } );
 *
 * @example
 * returns false
 * mapContain( { a : 7, b : 13 }, { a : 7, b : 13, c : 15 } );
 *
 * @returns { boolean } Returns true, if the first object (src)
 * has the same values as the second object(ins).
 * @method mapContain
 * @throws Will throw an error if ( arguments.length !== 2 ).
 * @memberof wTools
 */

var mapContain = function( src,ins )
{
  _.assert( arguments.length === 2 );

/*
  if( Object.keys( src ).length < Object.keys( ins ).length )
  return false;
*/

  for( var s in ins )
  {

    if( ins[ s ] === undefined )
    continue;

    if( src[ s ] !== ins[ s ] )
    return false;

  }

  return true;
}

//

// !!! update documentation

/**
 * The mapOwn() returns true if (object) has own property.
 *
 * It takes (name) checks if (name) is a String,
 * if (object) has own property with the (name).
 * If true, it returns true.
 *
 * @param { Object } object - Object that will be check.
 * @param { name } name - Target property.
 *
 * @example
 * // returns true
 * _.mapOwn( { a : 7, b : 13 }, 'a' );
 *
 * @example
 * // returns false
 * _.mapOwn( { a : 7, b : 13 }, 'c' );
 *
 * @returns { boolean } Returns true if (object) has own property.
 * @method mapOwn
 * @throws { mapOwn } Will throw an error if the (name) is unknown.
 * @memberof wTools
 */

var mapOwn = function( object,name )
{

  if( arguments.length === 1 )
  {
    var result = _.mapExtendFiltering( _.filter.srcOwn(),{},object );
    return result;
  }

  _.assert( arguments.length === 2 );

  if( _.strIs( name ) )
  return _ObjectHasOwnProperty.call( object, name );
  else if( _.mapIs( name ) )
  return _ObjectHasOwnProperty.call( object, _.nameUnfielded( name ).coded );
  else if( _.symbolIs( name ) )
  return _ObjectHasOwnProperty.call( object, name );

  _.assert( 0,'mapOwn :','unknown type of name :',_.strTypeOf( name ) );
}

//

var mapHas = function mapHas( object,name )
{
  var name = _.nameUnfielded( name ).coded;

  var descriptor = Object.getOwnPropertyDescriptor( object,name );

  if( !descriptor )
  return false;

  if( descriptor.set && descriptor.set.forbid )
  return false;

  return true;
}

//

  /**
   * Returns new object with unique keys.
   *
   * Takes any number of objects.
   * Returns new object filled by unique keys
   * from the first (srcMap) original object.
   * Values for result object come from original object (srcMap)
   * not from second or other one.
   * If the first object has same key any other object has
   * then this pair( key/value ) will not be included into result object.
   * Otherwise pair( key/value ) from the first object goes into result object.
   *
   * @param{ objectLike } srcMap - original object.
   * @param{ ...objectLike } arguments[] - one or more objects.
   * Objects to return an object without repeating keys.
   *
   * @example
   * // returns { c : 3 }
   * mapBut( { a : 7, b : 13, c : 3 }, { a : 7, b : 13 } );
   *
   * @throws { Error }
   *  In debug mode it throws an error if any argument is not object like.
   * @returns { object } Returns new object made by unique keys.
   * @method mapBut
   * @memberof wTools
   */

var mapBut = function( srcMap )
{
  var result = {};
  var a,k;

  _assert( _.objectLike( srcMap ),'mapBut :','expects object as argument' );

  for( k in srcMap )
  {
    for( a = 1 ; a < arguments.length ; a++ )
    {
      var argument = arguments[ a ];

      _assert( _.objectLike( argument ),'argument','#'+a,'is not object' );

      if( k in argument )
      break;

    }
    if( a === arguments.length )
    {
      result[ k ] = srcMap[ k ];
    }
  }

  return result;
}

//

  /**
   * The mapOwnBut() returns new object with unique own keys.
   *
   * Takes any number of objects.
   * Returns new object filled by unique own keys
   * from the first (srcMap) original object.
   * Values for (result) object come from original object (srcMap)
   * not from second or other one.
   * If (srcMap) does not have own properties it skips rest of code and checks another properties.
   * If the first object has same key any other object has
   * then this pair( key/value ) will not be included into result object.
   * Otherwise pair( key/value ) from the first object goes into result object.
   *
   * @param { objectLike } srcMap - The original object.
   * @param { ...objectLike } arguments[] - One or more objects.
   *
   * @example
   * // returns { a : 7 }
   * mapBut( { a : 7, 'toString' : 5 }, { b : 33, c : 77 } );
   *
   * @returns { object } Returns new (result) object with unique own keys.
   * @method mapOwnBut
   * @throws { Error } Will throw an Error if (srcMap) is not an object.
   * @memberof wTools
   */

var mapOwnBut = function mapOwnBut( srcMap )
{
  var result = {};
  var a,k;

  /*console.warn( 'fuzzy!' ); debugger;*/

  assert( objectLike( srcMap ),'mapOwnBut :','expects object as argument' );

  for( k in srcMap )
  {
    if( !_ObjectHasOwnProperty.call( srcMap, k ) )
    continue;

    for( a = 1 ; a < arguments.length ; a++ )
    {
      var argument = arguments[ a ];

      if( k in argument )
      break;

    }
    if( a === arguments.length )
    {
      result[ k ] = srcMap[ k ];
    }
  }

  return result;
}

  // /**
  //  * @callback  _.filter.atomic()
  //  * @param { object } result - The new object.
  //  * @param { objectLike } srcMap - The target object.
  //  * @param { string } k - The key of the (srcMap) object.
  //  */

  /**
   * The mapButFiltering() method returns a new object (result)
   * whose (values) are not equal to the arrays or objects.
   *
   * Takes any number of objects.
   * If the first object has same key any other object has
   * then this pair [ key, value ] will not be included into (result) object.
   * Otherwise,
   * it calls a provided callback function ( _.filter.atomic() )
   * once for each key in the (srcMap), and adds to the (result) object
   * all the [ key, value ],
   * if values are not equal to the array or object.
   *
   * @param { function } filter.atomic() - Callback function to test each [ key, value ] of the (srcMap) object.
   * @param { objectLike } srcMap - The target object.
   * @param { ...objectLike } arguments[] - The next objects.
   *
   * @example
   * // returns { a : 1, b : "b" }
   * mapButFiltering( _.filter.atomic(), { a : 1, b : 'b', c : [ 1, 2, 3 ] } );
   *
   * @returns { object } Returns an object whose (values) are not equal to the arrays or objects.
   * @method mapButFiltering
   * @throws { Error } Will throw an Error if (srcMap) is not an object.
   * @memberof wTools
   */

var mapButFiltering = function( filter,srcMap )
{
  var result = {};
  var filter = _.filter.makeMapper( filter );
  var a,k;

  assert( objectLike( srcMap ),'mapButFiltering :','expects object as argument' );

  for( k in srcMap )
  {
    for( a = 2 ; a < arguments.length ; a++ )
    {
      var argument = arguments[ a ];

      if( k in argument )
      break;

    }
    if( a === arguments.length )
    {
      filter.call( this,result,srcMap,k );
    }
  }

  return result;
}

//

var mapOwnButFiltering = function( filter,srcMap )
{
  var result = {};
  var filter = _.filter.makeMapper( filter );
  var a,k;

  assert( objectLike( srcMap ),'mapOwnButFiltering :','expects object as argument' );

  for( k in srcMap )
  {
    for( a = 2 ; a < arguments.length ; a++ )
    {
      var argument = arguments[ a ];

      if( _ObjectHasOwnProperty.call( argument,k ) )
      break;

    }
    if( a === arguments.length )
    {
      filter.call( this,result,srcMap,k );
    }
  }

  return result;
}

//

/**
 * @property { objectLike } srcObjects.srcObject - The target object.
 * @property { objectLike } screenObjects.screenObject - The source object.
 * @property { Object } dstObject - The empty object.
 */

/**
 * The mapScreens() returns an object filled by unique [ key, value ]
 * from (srcObject) object.
 *
 * It creates the variable (dstObject) assignes and calls the method (_mapScreen( { } ) )
 * with three properties.
 *
 * @see {@link wTools._mapScreen} - See for more information.
 *
 * @param { objectLike } srcObject - The target object.
 * @param { objectLike } screenObject - The source object.
 *
 * @example
 * // returns { a : "abc", c : 33, d : "name" };
 * _.mapScreens( { d : 'name', c : 33, a : 'abc' }, [ { a : 13 }, { b : 77 }, { c : 3 }, { d : 'name' } ] );
 *
 * @returns { Object } Returns an (dstObject) object filled by unique [ key, value ]
 * from (srcObject) objects.
 * @method mapScreens
 * @throws { Error } Will throw an Error if (arguments.length) more that two,
 * if (srcObject or screenObject) are not objects-like.
 * @memberof wTools
 */

var mapScreens = function( srcObject,screenObject )
{

  _assert( arguments.length >= 2,'mapScreens :','expects at least 2 arguments' );
  _assert( _.objectLike( srcObject ),'mapScreens :','expects object as argument' );
  _assert( _.objectLike( screenObject ),'mapScreens :','expects object as screenObject' );

  if( arguments.length > 2 )
  {
    //debugger;
    screenObject =_ArraySlice.call( arguments,1 );
/*
    var args =_ArraySlice.call( arguments,1 );
    screenObject = _.mapCopy.apply( this,args );
*/
  }

  var dstObject = _mapScreen
  ({
    screenObjects : screenObject,
    srcObjects : srcObject,
    dstObject : {},
  });

  return dstObject;
}

//
  /**
   * @namespace
   * @property { objectLike } screenObjects.screenObject - The first object.
   * @property { ...objectLike } srcObject.arguments[1,...] -
   * The pseudo array (arguments[]) from the first [1] index to the end.
   * @property { object } dstObject - The empty object.
   */

  /**
   * The mapScreen() returns an object filled by unique [ key, value ]
   * from others objects.
   *
   * It takes number of objects, creates a new object by three properties
   * and calls the _mapScreen( {} ) with created object.
   *
   * @see  {@link wTools._mapScreen} - See for more information.
   *
   * @param { objectLike } screenObject - The first object.
   * @param { ...objectLike } arguments[] - One or more objects.
   *
   * @example
   * // returns { a : "abc", c : 33, d : "name" };
   * _.mapScreen( { a : 13, b : 77, c : 3, d : 'name' }, { d : 'name', c : 33, a : 'abc' } );
   *
   * @returns { Object } Returns the object filled by unique [ key, value ]
   * from others objects.
   * @method mapScreen
   * @throws { Error } Will throw an Error if (arguments.length < 2) or (arguments.length !== 2).
   * @memberof wTools
   */

var mapScreen = function( screenObject )
{

  _.assert( arguments.length >= 2 );
  _.assert( arguments.length === 2 );

  return _mapScreen
  ({
    screenObjects : screenObject,
    srcObjects : _.arraySlice( arguments,1 ),
    dstObject : {},
  });

}

//

  // /**
  //  * @callback  options.filter
  //  * @param { objectLike } dstObject - An empty object.
  //  * @param { objectLike } srcObjects - The target object.
  //  * @param { string } - The key of the (screenObject).
  //  */

  /**
   * The _mapScreen() returns an object filled by unique [ key, value]
   * from others objects.
   *
   * The _mapScreen() checks whether there are the keys of
   * the (screenObject) in the list of (srcObjects).
   * If true, it calls a provided callback function (filter)
   * and adds to the (dstObject) all the [ key, value ]
   * for which callback function returns true.
   *
   * @param { function } [options.filter = filter.bypass()] options.filter - The callback function.
   * @param { objectLike } options.srcObjects - The target object.
   * @param { objectLike } options.screenObjects - The source object.
   * @param { Object } [options.dstObject = {}] options.dstObject - The empty object.
   *
   * @example
   * // returns { a : 33, c : 33, name : "Mikle" };
   * var options = {};
   * options.dstObject = {};
   * options.screenObjects = { 'a' : 13, 'b' : 77, 'c' : 3, 'name' : 'Mikle' };
   * options.srcObjects = { 'a' : 33, 'd' : 'name', 'name' : 'Mikle', 'c' : 33 };
   * _mapScreen( options );
   *
   * @example
   * // returns { a : "abc", c : 33, d : "name" };
   * var options = {};
   * options.dstObject = {};
   * options.screenObjects = { a : 13, b : 77, c : 3, d : 'name' };
   * options.srcObjects = { d : 'name', c : 33, a : 'abc' };
   * _mapScreen( options );
   *
   * @returns { Object } Returns an object filled by unique [ key, value ]
   * from others objects.
   * @method _mapScreen
   * @throws { Error } Will throw an Error if (options.dstObject or screenObject) are not objects,
   * or if (srcObjects) is not an array
   * @memberof wTools
   */

var _mapScreen = function( options )
{

  var dstObject = options.dstObject || {};
  var screenObject = options.screenObjects;
  var srcObjects = options.srcObjects;

  if( _.arrayIs( screenObject ) )
  screenObject = _.mapCopy.apply( this,screenObject );

  if( !_.arrayIs( srcObjects ) )
  srcObjects = [ srcObjects ];

  if( !options.filter )
  options.filter = filter.bypass();
  options.filter = _.filter.makeMapper( options.filter );

  _.assert( arguments.length === 1 );
  _assert( _.objectLike( dstObject ),'_mapScreen :','expects object as argument' );
  _assert( _.objectLike( screenObject ),'_mapScreen :','expects object as screenObject' );
  _assert( _.arrayIs( srcObjects ),'_mapScreen :','expects array of object as screenObject' );
  _.assertMapOnly( options,_mapScreen.defaults );

  for( a = srcObjects.length-1 ; a >= 0 ; a-- )
  _assert( _.objectLike( srcObjects[ a ] ),'_mapScreen :','expects object as argument' );

  for( var k in screenObject )
  {

    if( screenObject[ k ] === undefined )
    continue;

    var a;
    for( a = srcObjects.length-1 ; a >= 0 ; a-- )
    if( k in srcObjects[ a ] )
    break;

    if( a === -1 )
    continue;

    options.filter.call( this,dstObject,srcObjects[ a ],k );

  }

  return dstObject;
}

_mapScreen.defaults =
{
  filter : null,
  screenObjects : null,
  srcObjects : null,
  dstObject : null,
}

// --
// map filter
// --

var bypass = function()
{

  var routine = function bypass( dstContainer,srcContainer,key )
  {
    /*dstContainer[ key ] = srcContainer[ key ];*/
    return true;
  }

  routine.functionKind = 'field-filter';
  return routine;
}

//

var srcAndDstOwn = function()
{

  var routine = function srcAndDstOwn( dstContainer,srcContainer,key )
  {
    if( !_ObjectHasOwnProperty.call( srcContainer, key ) )
    return false;
    if( !_ObjectHasOwnProperty.call( dstContainer, key ) )
    return false;

    return true;
  }

  routine.functionKind = 'field-filter';
  return routine;
}

//

var srcOwn = function()
{

  var routine = function srcOwn( dstContainer,srcContainer,key )
  {
    if( !_ObjectHasOwnProperty.call( srcContainer, key ) )
    return false;

    /*dstContainer[ key ] = srcContainer[ key ];*/
    return true;
  }

  routine.functionKind = 'field-filter';
  return routine;
}

//

var srcOwnRoutines = function()
{

  var routine = function srcOwnRoutines( dstContainer,srcContainer,key )
  {
    if( !_ObjectHasOwnProperty.call( srcContainer, key ) )
    return false;
    if( !_.routineIs( srcContainer[ key ] ) )
    return false;

    /*dstContainer[ key ] = srcContainer[ key ];*/
    return true;
  }

  routine.functionKind = 'field-filter'; ;
  return routine;
}

//

var supplementarySrcOwnRoutines = function()
{

  var routine = function supplementarySrcOwnRoutines( dstContainer,srcContainer,key )
  {
    if( !_ObjectHasOwnProperty.call( srcContainer, key ) )
    return false;
    if( !_.routineIs( srcContainer[ key ] ) )
    return false;
    if( !dstContainer[ key ] !== undefined )
    return false;

    /*dstContainer[ key ] = srcContainer[ key ];*/
    return true;
  }

  routine.functionKind = 'field-filter';
  return routine;
}

//

var supplementary = function()
{

  var routine = function supplementary( dstContainer,srcContainer,key )
  {
    if( dstContainer[ key ] !== undefined )
    return false;

    /*dstContainer[ key ] = srcContainer[ key ];*/
    return true;
  }

  routine.functionKind = 'field-filter';
  return routine;
}

//

var supplementaryCloning = function()
{

  var routine = function supplementaryCloning( dstContainer,srcContainer,key )
  {
    if( dstContainer[ key ] !== undefined )
    return;

    _.entityCopyField( dstContainer,srcContainer,key );
  }

  routine.functionKind = 'field-mapper';
  return routine;
}

//

var supplementarySrcOwn = function()
{

  var routine = function supplementarySrcOwn( dstContainer,srcContainer,key )
  {
    if( !_ObjectHasOwnProperty.call( srcContainer, key ) )
    return false;
    if( dstContainer[ key ] !== undefined )
    return false;

    /*dstContainer[ key ] = srcContainer[ key ];*/
    return true;
  }

  routine.functionKind = 'field-filter';
  return routine;
}

//

var supplementaryCloningSrcOwn = function()
{

  var routine = function supplementaryCloningSrcOwn( dstContainer,srcContainer,key )
  {
    if( !_ObjectHasOwnProperty.call( srcContainer, key ) )
    return;
    if( dstContainer[ key ] !== undefined )
    return;

    _.entityCopyField( dstContainer,srcContainer,key );
  }

  routine.functionKind = 'field-mapper';
  return routine;
}

//

var cloningSrcOwnDstNotOwn = function()
{

  var routine = function cloningSrcOwnDstNotOwn( dstContainer,srcContainer,key )
  {
    if( !_ObjectHasOwnProperty.call( srcContainer, key ) )
    return;

    if( _ObjectHasOwnProperty.call( dstContainer, key ) )
    return;

    _.entityCopyField( dstContainer,srcContainer,key );
  }

  routine.functionKind = 'field-mapper';
  return routine;
}

//

var cloning = function()
{

  var routine = function cloning( dstContainer,srcContainer,key )
  {
    _.entityCopyField( dstContainer,srcContainer,key );
  }

  routine.functionKind = 'field-mapper';
  return routine;
}

//

var cloningSrcOwn = function()
{

  var routine = function cloning( dstContainer,srcContainer,key )
  {
    if( !_ObjectHasOwnProperty.call( srcContainer, key ) )
    return;

    _.entityCopyField( dstContainer,srcContainer,key );
  }

  routine.functionKind = 'field-mapper';
  return routine;
}

//

var atomic = function()
{

  var routine = function atomic( dstContainer,srcContainer,key )
  {
    if( !_.atomicIs( srcContainer[ key ] ) )
    return false;

    /*dstContainer[ key ] = srcContainer[ key ];*/
    return true;
  }

  routine.functionKind = 'field-filter';
  return routine;
}

//

var atomicSrcOwn = function()
{

  var routine = function atomicSrcOwn( dstContainer,srcContainer,key )
  {
    if( !_ObjectHasOwnProperty.call( srcContainer, key ) )
    return false;
    if( !_.atomicIs( srcContainer[ key ] ) )
    return false;

    /*dstContainer[ key ] = srcContainer[ key ];*/
    return true;
  }

  routine.functionKind = 'field-filter';
  return routine;
}

//

var notAtomicCloning = function()
{

  var routine = function notAtomicCloning( dstContainer,srcContainer,key )
  {
    if( _.atomicIs( srcContainer[ key ] ) )
    return;

    _.entityCopyField( dstContainer,srcContainer,key );
  }

  routine.functionKind = 'field-mapper';
  return routine;
}

//

var notAtomicCloningSrcOwn = function()
{

  var routine = function notAtomicCloningSrcOwn( dstContainer,srcContainer,key )
  {
    if( !_ObjectHasOwnProperty.call( srcContainer, key ) )
    return;
    if( _.atomicIs( srcContainer[ key ] ) )
    return;

    _.entityCopyField( dstContainer,srcContainer,key );
  }

  routine.functionKind = 'field-mapper';
  return routine;
}

//

var notAtomicCloningRecursiveSrcOwn = function()
{

  var routine = function notAtomicCloningRecursiveSrcOwn( dstContainer,srcContainer,key )
  {
    if( !_ObjectHasOwnProperty.call( srcContainer, key ) )
    return;
    if( _.atomicIs( srcContainer[ key ] ) )
    return;

    _.entityCopyField( dstContainer,srcContainer,key,_.entityCopyField );
  }

  routine.functionKind = 'field-mapper';
  return routine;
}

//

var recursiveClonning = function()
{

  var routine = function recursiveClonning( dstContainer,srcContainer,key )
  {
    _.entityCopyField( dstContainer,srcContainer,key,_.entityCopyField );
  }

  routine.functionKind = 'field-mapper';
  return routine;
}

//

var recursiveCloningSrcOwn = function()
{

  var routine = function recursiveCloningSrcOwn( dstContainer,srcContainer,key )
  {
    if( !_ObjectHasOwnProperty.call( srcContainer, key ) )
    return;

    _.entityCopyField( dstContainer,srcContainer,key,_.entityCopyField );
  }

  routine.functionKind = 'field-mapper';
  return routine;
}

//

var drop = function( dropContainer )
{

  _.assert( _.objectIs( dropContainer ) );

  var routine = function drop( dstContainer,srcContainer,key )
  {
    if( dropContainer[ key ] !== undefined )
    return false

    /*dstContainer[ key ] = srcContainer[ key ];*/
    return true;
  }

  routine.functionKind = 'field-filter';
  return routine;
}

//

var and = function()
{

  var filters = [];
  var mappers = [];
  for( var a = 0 ; a < arguments.length ; a++ )
  {
    var routine = arguments[ a ];
    _.assert( _.routineIs( routine ) );
    _.assert( _.strIs( routine.functionKind ) );
    if( routine.functionKind === 'field-filter' )
    filters.push( routine );
    else if( routine.functionKind === 'field-mapper' )
    mappers.push( routine );
    else throw _.err( 'expects routine.functionKind' );
  }

  if( mappers.length > 1 )
  throw _.err( 'can combine only one mapper with any number of filters' );

  var routine = function and( dstContainer,srcContainer,key )
  {

    for( var f = 0 ; f < filters.length ; f++ )
    {
      var filter = filters[ f ];

      var result = filter( dstContainer,srcContainer,key );
      _.assert( _.boolIs( result ) );
      if( result === false )
      return mappers.length ? undefined : false;
    }

    for( var m = 0 ; m < mappers.length ; m++ )
    {
      var mapper = mappers[ m ];

      var result = mapper( dstContainer,srcContainer,key );
      _.assert( result === undefined );
      return;
    }

    return mappers.length ? undefined : true;
  }

  routine.functionKind = mappers.length ? 'field-mapper' : 'field-filter';
  return routine;
}

//

var makeMapper = function( routine )
{

  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( routine ) );
  _.assert( _.strIs( routine.functionKind ) );

  if( routine.functionKind === 'field-filter' )
  {
    var r = function( dstContainer,srcContainer,key )
    {
      var result = routine( dstContainer,srcContainer,key );
      _.assert( _.boolIs( result ) );
      if( result === false )
      return;
      dstContainer[ key ] = srcContainer[ key ];
    }
    r.functionKind = 'field-mapper';
    return r;
  }
  else if( routine.functionKind === 'field-mapper' )
  {
    return routine;
  }
  else throw _.err( 'expects routine.functionKind' );

}

//

var filter =
{

  bypass : bypass,

  srcAndDstOwn : srcAndDstOwn,

  srcOwn : srcOwn,
  srcOwnRoutines : srcOwnRoutines,
  supplementarySrcOwnRoutines : supplementarySrcOwnRoutines,

  supplementary : supplementary,
  supplementaryCloning : supplementaryCloning,
  supplementarySrcOwn : supplementarySrcOwn,
  supplementaryCloningSrcOwn : supplementaryCloningSrcOwn,
  cloningSrcOwnDstNotOwn : cloningSrcOwnDstNotOwn,

  cloning : cloning,
  cloningSrcOwn : cloningSrcOwn,

  atomic : atomic,
  atomicSrcOwn : atomicSrcOwn,

  notAtomicCloning : notAtomicCloning,
  notAtomicCloningSrcOwn : notAtomicCloningSrcOwn,
  notAtomicCloningRecursiveSrcOwn : notAtomicCloningRecursiveSrcOwn,

  recursiveClonning : recursiveClonning,
  recursiveCloningSrcOwn : recursiveCloningSrcOwn,

  drop : drop,

  and : and,
  makeMapper : makeMapper,

}

// --
// var
// --

/**
 * Throwen to indicate that operation was aborted by user or other subject.
 *
 * @error ErrorAbort
 * @memberof wTools
 */

function ErrorAbort()
{
  this.message = arguments.length ? _.arrayFrom( arguments ) : 'Aborted';
}

ErrorAbort.prototype = Object.create( Error.prototype );

var error =
{
  ErrorAbort : ErrorAbort,
}

Error.stackTraceLimit = Infinity;

/**
 * Some Event
 *
 * @event wTools#init
 * @property {string} kind - kind of event( 'init' ).
 * @memberof wTools
 */

// --
// prototype
// --

var Proto =
{

  // init

  _initConfig : _initConfig,


  // entity modifier

  enityExtend : enityExtend, /* deprecated */
  entityClone : entityClone, /* deprecated */

  _entityCloneAct : _entityCloneAct,
  _entityClone : _entityClone,
  entityCloneObject : entityCloneObject,
  entityCloneObjectMergingBuffers : entityCloneObjectMergingBuffers,
  entityCloneData : entityCloneData,
  entityCloneDataSeparatingBuffers : entityCloneDataSeparatingBuffers,

  entityCopy : entityCopy,
  entityCopyField : entityCopyField,
  entityAssignField : entityAssignField,

  entityCoerceTo : entityCoerceTo,

  entityWrap : entityWrap,


  // entity checker

  entityHasNan : entityHasNan,
  entityHasUndef : entityHasUndef,

  _entitySame : _entitySame,
  entitySame : entitySame,
  entityDiff : entityDiff,

  entityIdentical : entityIdentical,
  entityEquivalent : entityEquivalent,
  entityContain : entityContain,


  // entity selector

  entityLength : entityLength,

  entityWithKeyRecursive : entityWithKeyRecursive, /* deprecated */
  entityValueWithIndex : entityValueWithIndex,
  entityKeyWithValue : entityKeyWithValue,

  entitySelectUnique : entitySelectUnique,
  entitySelect : entitySelect,
  entitySelectSet : entitySelectSet,
  _entitySelectOptions : _entitySelectOptions,
  _entitySelect : _entitySelect,
  __entitySelectAct : __entitySelectAct,

  _entityConditionMake : _entityConditionMake,
  entityMap : entityMap,
  entityFilter : entityFilter,
  entityGroup : entityGroup,

  _entityMost : _entityMost,
  entityMin : entityMin,
  entityMax : entityMax,

  entitySearch : entitySearch,


  // iterator

  __eachAct : __eachAct,
  _each : _each,

  each : each,
  eachOwn : eachOwn,
  eachRecursive : eachRecursive,
  eachOwnRecursive : eachOwnRecursive,

  eachSample : eachSample, /* experimental */

  dup : dup,


  // diagnostics

  _err : _err,
  err : err,
  errLog : errLog,

  assert : assert,
  assertMapNoUndefine : assertMapNoUndefine,
  assertMapOnly : assertMapOnly,
  assertMapOwnOnly : assertMapOwnOnly,
  assertMapNone : assertMapNone,
  assertMapOwnNone : assertMapOwnNone,
  assertMapAll : assertMapAll,
  assertMapOwnAll : assertMapOwnAll,
  warn : warn,
  stack : stack,

  includeAny : includeAny,  /* experimental */

  diagnosticWatchObject : diagnosticWatchObject, /* experimental */
  diagnosticWatchFields : diagnosticWatchFields, /* experimental */
  diagnosticBeep : diagnosticBeep,


  // type test

  arrayIs : arrayIs,
  arrayLike : arrayLike,
  hasLength : hasLength,

  objectIs : objectIs,
  objectLike : objectLike,
  mapIs : mapIs,

  strIs : strIs,
  strIsNotEmpty : strIsNotEmpty,
  symbolIs : symbolIs,

  bufferIs : bufferIs,
  bufferViewIs : bufferViewIs,
  bufferRawIs : bufferRawIs,
  bufferNodeIs : bufferNodeIs,
  bufferSomeIs : bufferSomeIs,

  argumentsIs : argumentsIs,

  rowIs : rowIs,

  numberIs : numberIs,
  numberIsRegular : numberIsRegular,
  numbersAreInt : numbersAreInt,

  dateIs : dateIs,
  boolIs : boolIs,
  routineIs : routineIs,
  routineWithNameIs : routineWithNameIs,
  regexpIs : regexpIs,
  definedIs : definedIs,

  eventIs : eventIs,
  htmlIs : htmlIs,
  jqueryIs : jqueryIs,
  canvasIs : canvasIs,
  domIs : domIs,
  domableIs : domableIs,

  errorIs : errorIs,

  atomicIs : atomicIs,
  primitiveIs : atomicIs,

  typeOf : typeOf,
  typeIsBuffer : typeIsBuffer,


  // bool

  boolFrom : boolFrom,


  // number

  numberFrom : numberFrom,

  numberRandomInRange : numberRandomInRange,
  numberRandomInt : numberRandomInt,
  numberRandomIntBut : numberRandomIntBut, /* experimental */


  // str

  strTypeOf : strTypeOf,
  strPrimitiveTypeOf : strPrimitiveTypeOf,

  str : str,

  strBegins : strBegins,
  strEnds : strEnds,
  strBeginRemove : strBeginRemove,
  strEndRemove : strEndRemove,

  strPrependOnce : strPrependOnce,
  strAppendOnce : strAppendOnce,


  // regexp

  regexpEscape : regexpEscape,
  regexpForGlob : regexpForGlob,

  regexpMakeObject : regexpMakeObject,
  regexpMakeArray : regexpArrayMake,
  regexpMakeExpression : regexpMakeExpression,

  regexpBut_ : regexpBut_,

  regexpArrayMake : regexpArrayMake,
  regexpArrayIndex : regexpArrayIndex,
  _regexpArrayAny : _regexpArrayAny,
  _regexpArrayAll : _regexpArrayAll,


  // routine

  _routineBind : _routineBind,
  routineBind : routineBind, /* deprecated */
  routineJoin : routineJoin,
  routineSeal : routineSeal,
  routineDelayed : routineDelayed,

  routinesCall : routinesCall,
  routineOptions : routineOptions,

  bind : null,


  // time

  timeReady : timeReady,
  timeOnce : timeOnce,
  timeOut : timeOut,

  timePeriodic : timePeriodic,

  _timeNow_gen : _timeNow_gen,
  timeSpent : timeSpent,
  dateToStr : dateToStr,


  // buffer

  bufferRelen : bufferRelen,
  bufferResize : bufferResize,
  bufferBytesGet : bufferBytesGet,
  bufferRetype : bufferRetype,

  bufferMove : bufferMove,
  bufferToStr : bufferToStr,
  bufferToDom : bufferToDom,

  bufferLeftBufferIndex : bufferLeftBufferIndex,

  bufferFromArrayOfArray : bufferFromArrayOfArray,
  bufferFrom : bufferFrom,
  bufferRawFromBuffer : bufferRawFromBuffer,
  bufferRawFrom : bufferRawFrom,

  buffersSerialize : buffersSerialize, /* deprecated */
  buffersDeserialize : buffersDeserialize, /* deprecated */

  bufferToNodeBuffer : bufferToNodeBuffer,


  // array

  arraySub : arraySub,
  arrayNew : arrayNew,
  arrayNewOfSameLength : arrayNewOfSameLength,
  arrayOrNumber : arrayOrNumber,

  arraySelect : arraySelect,
  arrayIndicesOfGreatest : arrayIndicesOfGreatest, /* experimental */

  arrayFlatten : arrayFlatten,
  arrayFlattenToMapUnique : arrayFlattenToMapUnique,

  arrayCopy : arrayCopy,
  arrayAppendMerging : arrayAppendMerging,
  arrayPrependMerging : arrayPrependMerging,

  arrayAppendOnceMerging : arrayAppendOnceMerging,
  arrayPrependOnceMerging : arrayPrependOnceMerging,

  arrayAppendOnce : arrayAppendOnce,
  arrayPrependOnce : arrayPrependOnce,

  arrayElementsSwap : arrayElementsSwap,

  arrayRemoveArrayOnce : arrayRemoveArrayOnce,

  arrayRemovedOnce : arrayRemovedOnce,
  arrayRemoveOnce : arrayRemoveOnce,

  arrayRemovedAll : arrayRemovedAll,
  arrayRemoveAll : arrayRemoveAll,

  arrayReplaceOnce : arrayReplaceOnce,
  arrayUpdate : arrayUpdate,

  arrayFrom : arrayFrom,
  arrayToMap : arrayToMap,

  arraySpliceArray : arraySpliceArray,

  arraySlice : arraySlice,
  arraySplice : arraySplice,
  arrayAs : arrayAs,

  arrayUniqueIs : arrayUniqueIs,
  arrayUnique : arrayUnique,

  arrayToStr : arrayToStr,

  arrayPut : arrayPut, /* experimental */

  arrayMask : arrayMask,
  arrayUnmask : arrayUnmask,

  arrayDuplicate : arrayDuplicate,
  arrayFill : arrayFill,

  arrayCompare : arrayCompare,
  arraySame : arraySame,
  arraySameSet : arraySameSet,

  arrayLeftIndexOf : arrayLeftIndexOf,
  arrayRightIndexOf : arrayRightIndexOf,

  arrayLeft : arrayLeft,
  arrayRight : arrayRight,

  arrayHasAny : arrayHasAny,
  arrayCount : arrayCount,
  arrayCountSame : arrayCountSame,

  arraySum : arraySum,

  arraySupplement : arraySupplement,
  arrayExtendScreening : arrayExtendScreening,

  arrayShuffle : arrayShuffle,
  arrayRandom : arrayRandom,
  arrayRange : arrayRange,


  // array set

  arraySetIntersection : arraySetIntersection,
  arraySetContainAll : arraySetContainAll,
  arraySetContainSomething : arraySetContainSomething,


  // array sorted

  _arraySortedLookUpAct : _arraySortedLookUpAct,
  arraySortedLookUp : arraySortedLookUp,
  arraySortedClosest : arraySortedClosest,
  arraySortedRemove : arraySortedRemove,
  arraySortedAdd : arraySortedAdd,
  arraySortedAddOnce : arraySortedAddOnce,
  arraySortedAddArray : arraySortedAddArray,


  // map extend

  mapClone : mapClone, /* experimental */

  mapExtendFiltering : mapExtendFiltering,
  mapExtend : mapExtend,
  mapSupplement : mapSupplement,
  mapComplement : mapComplement,
  mapCopy : mapCopy,


  // map test

  mapSatisfy : mapSatisfy,
  _mapSatisfy : _mapSatisfy,


  // map converter

  mapFirstPair : mapFirstPair,

  mapToArray : mapToArray,
  mapValWithIndex : mapValWithIndex,
  mapKeyWithIndex : mapKeyWithIndex,
  mapToString : mapToString, /* deprecated */

  mapOwnKeys : mapOwnKeys,
  mapKeys : mapKeys,
  mapOwnValues : mapOwnValues,
  mapValues : mapValues,
  mapPairs : mapPairs,

  mapInvertKeyValue : mapInvertKeyValue,

  /* mapsPluck : mapsPluck, */


  // map logic

  mapOwn : mapOwn,
  mapHas : mapHas,

  mapSame : mapSame,
  mapContain : mapContain,

  mapBut : mapBut,
  mapOwnBut : mapOwnBut,

  mapButFiltering : mapButFiltering,
  mapOwnButFiltering : mapOwnButFiltering,

  mapScreens : mapScreens,
  mapScreen : mapScreen,
  _mapScreen : _mapScreen,


  // map filter

  filter : filter,

  // var

  error : error,

}

_global_.wBase = Proto;

mapExtend( Self, Proto );

/*Self.constructor = function wTools() {};*/

//

var _assert = _.assert;
var _arraySlice = _.arraySlice;
var timeNow = Self.timeNow = Self._timeNow_gen();

//

_global_[ 'wTools' ] = Self;
_global_.wTools = Self;

//debugger;

if( typeof module !== 'undefined' && module !== null )
try
{
  require( '../ServerTools.ss' );
}
catch( err )
{
}

//debugger;

if( _global_.wToolsInitConfigExpected !== false )
_._initConfig();

if( typeof module !== 'undefined' && module !== null )
{

  module[ 'exports' ] = Self;

  require( './component/NameTools.s' );
  require( './component/ExecTools.s' );
  require( './component/StringTools.s' );
  //require( './object/RegexpObject.s' );

}

})();
