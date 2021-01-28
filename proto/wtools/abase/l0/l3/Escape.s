( function _l3_Escape_s_()
{

'use strict';

let _global = _global_;
let _ = _global_.wTools;

// --
// implement
// --

function is( src )
{
  if( !src )
  return false;
  return src instanceof _.Escape;
}

//

function make( src )
{
  if( arguments.length !== 1 )
  throw new Error( 'Expects exactly one argument' );
  return new Escape( src );
}

//

function from( src )
{
  if( arguments.length !== 1 )
  throw new Error( 'Expects exactly one argument' );
  if( _.escape.is( src ) )
  return src;
  return _.escape.make( src );
}

//

function shallow()
{
  debugger;
  return this;
}

//

function deep()
{
  debugger;
  return this;
}

//

function equalAre( it )
{
  let self = this;

  _.assert( arguments.length === 1 ); debugger;

  it.continue = false;

  if( !it.srcEffective )
  return false;
  if( !it.srcEffective2 )
  return false;
  if( !it.srcEffective instanceof _.Escape )
  return false;
  if( !it.srcEffective2 instanceof _.Escape )
  return false;

  return it.srcEffective.val === it.srcEffective2.val;
}

// --
// declare
// --

const iteratorSymbol = Symbol.iterator;
const equalAreSymbol = Symbol.for( 'equalAre' );
const shallowSymbol = Symbol.for( 'shallow' );
const deepSymbol = Symbol.for( 'deep' );

function Escape( val )
{
  if( arguments.length !== 1 )
  throw new Error( 'Expects exactly 1 argument' );
  this.val = val;
  Object.freeze( this );
  return this;
}

// class Escape
// {
//   constructor( val )
//   {
//     if( arguments.length !== 1 )
//     throw new Error( 'Expects exactly 1 argument' );
//     this.val = val;
//     Object.freeze( this );
//     return this;
//   }
// }

Object.setPrototypeOf( Escape.prototype, null );
Escape.prototype = Object.create( null );
Escape.prototype[ shallowSymbol ] = shallow;
Escape.prototype[ deepSymbol ] = deep;
Escape.prototype[ equalAreSymbol ] = equalAre;
Escape.prototype.constructor = Escape;

//

var Extension =
{
  is,
  make,
  from,
}

//

_.assert( _.escape === undefined );
_.escape = Object.create( null );
_.assert( _.Escape === undefined );
_.Escape = Escape;
Object.assign( _.escape, Extension );

// --
// export
// --

if( typeof module !== 'undefined' )
module[ 'exports' ] = _;

})();