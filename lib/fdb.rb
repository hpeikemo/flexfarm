require "cliwrapper.rb"

module Flexfarm


class FDB < CliWrapper
   
   SILENT = /^\(fdb\) |Do you want to attempt to halt execution|To help out, try nudging the Player/      
   INPUT_PROMPT = /^\(fdb\) |\(y or n\)/
   WAITING_FOR_PLAYER = /Waiting for Player to connect/
   ALREADY_IN_USE = /Another Flash debugger is probably running/
   FAILED_TO_CONNECT = /Failed to connect\; session timed out/
   SESSION_STARTED = /Player connected\; session starting/
   SESSION_TERMINATED = /Player session terminated/
   NOT_CONFIRMED = /Not confirmed/
   EXECUTION_HALTED = /^(Execution halted|Fault)/   
      
   IDLE_MODE = :idle          # Not waiting for anything, debugger just started or session just ended.
   WAITING_MODE = :waiting    # Waiting for player to connect
   STARTING_MODE = :starting  # Player connected; session starting.
   RUNNING_MODE = :running    # Session running.
   BREAK_MODE = :break        # Enter debugger. Interactive mode.
   
   def initialize(*args)
      super(*args)
      self.mode = IDLE_MODE
   end

   def getOutput      
      lines = FDB::getLines(@stdout)
      lines.each do |line| 
         yield(line) unless line =~ SILENT       
         self.mode = WAITING_MODE   if line =~ WAITING_FOR_PLAYER
         self.mode = IDLE_MODE      if line =~ FAILED_TO_CONNECT  || line =~ SESSION_TERMINATED         
         self.mode = BREAK_MODE     if line =~ EXECUTION_HALTED
         init_session               if line =~ SESSION_STARTED                  
         return cleanup             if line =~ ALREADY_IN_USE         
      end
      
      if lines.last && lines.last =~ INPUT_PROMPT
         @available = true
      else
         # self.mode = RUNNING_MODE
         @available = false
      end
   end
         
   def break
      @stdin.puts("","y") #if self.mode == RUNNING_MODE
   end
            
   private
   
   def init_session
      self.mode = RUNNING_MODE
   end
   
end

end