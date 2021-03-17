( function _l5_Buffer_s_()
{

'use strict';

let _global = _global_;
let _ = _global_.wTools;
let Self = _global_.wTools;

// --
// buffer checker
// --

function constructorIsBuffer( src )
{
  if( !src )
  return false;
  if( !_.number.is( src.BYTES_PER_ELEMENT ) )
  return false;
  if( !_.strIs( src.name ) )
  return false;
  return src.name.indexOf( 'Array' ) !== -1;
}


// --
// extension
// --

let Extension =
{
  constructorIsBuffer
}

_.mapSupplement( Self, Extension );

// --
// export
// --

if( typeof module !== 'undefined' )
module[ 'exports' ] = _;

})();
