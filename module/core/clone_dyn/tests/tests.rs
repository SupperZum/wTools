
#[ allow( unused_imports ) ]
use clone_dyn as TheModule;
#[ allow( unused_imports ) ]
use test_tools::exposed::*;

#[ cfg( all( feature = "enabled", any( not( feature = "no_std" ), feature = "use_alloc" ) ) ) ]
mod inc;
