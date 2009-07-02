require "cliwrapper.rb"

module Flexfarm


class FCSH < CliWrapper
   
   MAX_TARGETS = 15
   
   SILENT = /^\(fcsh\) /
   INPUT_PROMPT = /^\(fcsh\) /
   ASSIGNED_TARGET = /Assigned (\d+) as the compile target id/
   
   INIT_MODE = :init
   IDLE_MODE = :idle       
   COMPILE_MODE = :compile
      
   def initialize(*args)
      super(*args)
      self.mode = INIT_MODE
      @currentCommand = nil      
      clean_targets
   end
   
   def getOutput      
      lines = FCSH::getLines(@stdout)
      lines.each do |line| 
         yield(line) unless line =~ SILENT         
         if line =~ ASSIGNED_TARGET
            target = $1.to_i
            @compileTargets[@currentCommand] = $1
         end
      end      
      if lines.last && lines.last =~ INPUT_PROMPT
         @available = true         
         clean_targets if @compileTargets.length > MAX_TARGETS
      end
      self.mode = IDLE_MODE if available && self.mode == COMPILE_MODE
   end
   
   def compile(command)
      self.mode = COMPILE_MODE
      @currentCommand = command
      target = @compileTargets[@currentCommand]
      if target
         dispatch("compile #{target}")
      else
         dispatch(command)
      end      
   end
   
   private
   def clean_targets
      if @compileTargets
         verbose_puts("Too many targets (#{@compileTargets.length}), cleaning up..")
         dispatch( "clear" ) 
      end
      @compileTargets = {}      
   end
   

      
end

end