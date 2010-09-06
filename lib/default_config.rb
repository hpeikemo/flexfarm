module Flexfarm   
      
   # Note that mxmlc do not handle (even escaped) spaces in any path.
   #     (symlink to resolve related issues)
   
   FLEX_HOME = "/usr/share/flex/sdks/3.4.0"
   FDB_BIN = "#{FLEX_HOME}/bin/fdb"
   FCSH_BIN = "#{FLEX_HOME}/bin/fcsh"
   ADL_BIN = "#{FLEX_HOME}/bin/adl"
   ADT_BIN = "#{FLEX_HOME}/bin/adt"
      
   ADL_RUNTIME = "#{FLEX_HOME}/runtimes/air/mac"      
   FLEX_COMPILER = "ffcompile"
   
   COMPILER_PORT = 4200
   $verbose_level = 1
   
end