
use std::cmp::PartialEq;

//

pub fn append_vectors_once<'a, T: PartialEq + Copy, F: FnMut(T)>( dst : &'a mut Vec<T>, src : &'a Vec<Vec<T>>, on_evaluate : Option<F> ) -> &'a mut Vec<T>
{
  if on_evaluate.is_none()
  {
    for vec in src
    {
      for el in vec
      {
        if !dst.contains( el )
        {
          dst.push( *el );
        }
      }
    }
  }
  else
  {
    unimplemented!( "callbacks is not implemented" );
  }

  dst
}

