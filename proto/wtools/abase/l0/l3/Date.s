( function _l3_Date_s_()
{

'use strict';

const _global = _global_;
const _ = _global_.wTools;
const Self = _global_.wTools.date = _global_.wTools.date || Object.create( null );

// --
// typing
// --

function is( src )
{
  return Object.prototype.toString.call( src ) === '[object Date]';
}

//

function identicalShallow( src1, src2 )
{
  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

  if( !_.date.is( src1 ) )
  return false;
  if( !_.date.is( src2 ) )
  return false;

  return _.date._identicalShallow( src1, src2 );
}

//

function _identicalShallow( src1, src2 )
{
  src1 = src1.getTime();
  src2 = src2.getTime();

  return src1 === src2;
}

//

function exportStringShallowDiagnostic( src )
{
  _.assert( arguments.length === 1, 'Expects exactly one argument' );
  _.assert( _.date.is( src ) );

  return src.toISOString();
}

//

function exportStringShallowCode( src )
{
  _.assert( arguments.length === 1, 'Expects exactly one argument' );
  _.assert( _.date.is( src ) );

  return `new Date( '${src.toISOString()}' )`;
}

// --
// extension
// --

let ToolsExtension =
{
  dateIs : is,
  datesAreIdentical : identicalShallow,
}

//

let Extension =
{
  is,
  identicalShallow,
  _identicalShallow,
  areIdentical : identicalShallow,
  equivalentShallow : identicalShallow,

  // export string

  exportString : exportStringShallowDiagnostic,
  exportStringShallow : exportStringShallowDiagnostic,
  exportStringShallowCode,
  exportStringShallowDiagnostic,
  exportStringDiagnostic : exportStringShallowDiagnostic,
  exportStringCode : exportStringShallowCode
}

//

Object.assign( _, ToolsExtension );
Object.assign( Self, Extension );

})();
