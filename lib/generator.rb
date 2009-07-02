require 'fileutils'

module Flexfarm   

   def self.create_userconfig
     require "flexfarm_config"              
     FileUtils.copy(CONFIG_FILES.first,CONFIG_FILES.last) if !File.exist? CONFIG_FILES.last
     return File.expand_path(CONFIG_FILES.last)
   end

   def self.create_rakefile
      target_file = "./rakefile.rb"
      if File.exist? target_file
         puts "Rakefile already exist. #{target_file}"
      else
         source_file = "#{File.dirname(__FILE__)}/../rakefile.rb.example"
         FileUtils.copy(source_file,target_file)
      end
      return File.expand_path(target_file)
   end



end