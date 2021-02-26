( function _l5_Countable_s_()
{

'use strict';

let _global = _global_;
let _ = _global_.wTools;
_global_.wTools.countable = _global_.wTools.countable || Object.create( null );

// --
// implementation
// --

function areIdenticalShallow( src1, src2 )
{
  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( _.countable.is( src1 ) );
  _.assert( _.countable.is( src2 ) );

  let length1 = src1.length || 0;
  let length2 = src2.length || 0;

  if( length1 !== length2 )
  return false;

  if( _.longLike( src1 ) && _.longLike( src2 ) )
  {
    return _.longAreIdenticalShallow( src1, src2 );
  }

  /*
    object with method iterator,
    vector
  */
  return _.mapsAreIdentical( src1, src2 )
}

// --
// extension
// --

var Extension =
{
  areIdenticalShallow
}

//

Object.assign( _.countable, Extension );

// --
// export
// --

if( typeof module !== 'undefined' )
module[ 'exports' ] = _;

})();
