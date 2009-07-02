require "open3"
require 'readline'

module Flexfarm
         
         
class CliWrapper
            
   attr_reader :mode
   attr_reader :available
   
   CLEANUP_MODE = :cleanup
      
   def initialize(executable_path)
      @stdin, @stdout, @stderr = Open3.popen3(executable_path)
      @running = true
      @available = false
   end
   
   def cleanup
      return unless @running
      self.mode = CLEANUP_MODE
      verbose_puts("Quiting #{self.class}",1)
      @running = false
      @stdin.close unless @stdin.closed?
      @stdout.close unless @stdout.closed?
      @stderr.close unless @stderr.closed?      
   end
   
   def running?
      @running && @stdin.syswrite(nil)==0 rescue false
   end   
   
   def getErrors
      CliWrapper::getLines(@stderr).each {|line| yield(line) }
   end
   
   def getOutput      
      CliWrapper::getLines(@stdout).each {|line| yield(line) }
   end
   
   def dispatch(command="")      
      if available && !command.empty?
         verbose_puts("[command: #{command}] ",2)
         @stdin.puts command
         @available = false
      else
         verbose_puts("[blocked command: #{command}] ",2)
      end
   end
   
   def mode= (value)
      if (@mode != value)
         @mode=value
         verbose_puts("[Mode is #{@mode}]",2)
      end
   end
      
   def self.getLines(io)
      buffer = ""
      buffer += io.read_nonblock(1024) while true rescue buffer.to_a      
   end
      
end

end