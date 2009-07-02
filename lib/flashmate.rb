module FlexMate
   
   ERROR_REGEX = /(\/.*?)(?:(\(([0-9]+)\)|): col: (\d+)|:).*(Error|Warning):\s*(.*)$/
   GENERIC_ERROR_REGEX = /Error/   
   
   
      
   def self.execute_build
      require "open3"
      @project_path = ENV['TM_PROJECT_DIRECTORY']
      @build_command = "rake"

      
      
      @stdin, @stdout, @stderr = Open3.popen3(@build_command)      
      compileErrors = []
      genericErrors = []
      while out = @stderr.gets
         # puts out
         m = ERROR_REGEX.match( out )
         m2 = GENERIC_ERROR_REGEX.match( out )
         
         if m
            compileErrors << {
               "message" => m[6],
               "filepath" => m[1],
               "file" => File.basename(m[1]),
               "line" => m[3] || "1",
               "column" => m[4] || "0"
            } 
         elsif m2
            
            compileErrors << {
               "message" => out
            }
         end
         
      end
      # while out = @stdout.gets 
      #    puts out
      # end
      
      return compileErrors
   end
   
   def self.compile_project()
      return unless ENV["TM_SUPPORT_PATH"]
      
      tm_path = ENV["TM_SUPPORT_PATH"] || ""
      require tm_path+"/lib/textmate.rb"
      require tm_path+"/lib/exit_codes"
      require tm_path+"/lib/progress"
      require tm_path+"/lib/web_preview"
      
      
      TextMate.call_with_progress({
         :title => "Rake",
         :summary => 'Starting Up...',
         :indeterminate => false,
      #   :cancel => lambda { puts "Canceled compile!"; Process.kill('SIGUSR1') }
      }) do |dialog|
            
         dialog.parameters = {'summary' => 'Compiling','progressValue' => 10 }            
         @errors = execute_build
         # sleep(10)
         dialog.parameters = {'summary' => 'Compile complete','progressValue' => 100 }            
         
            
      end
      
         
                           
      if @errors && @errors.length > 0
         #maxchars = @errors.map{ |c| c["file"].to_s.length }.max
         @errors.each { |choice|
            if (choice["file"])
               choice["title"] =  choice["file"] + ":" +choice["line"] + "  "+ choice["message"]
            else
               choice["title"] = choice["message"]
            end
         }
         choice = TextMate::UI.menu(@errors[0..9])    
         if choice && choice["filepath"]                
            TextMate.go_to :file => choice["filepath"] , :line => choice["line"], :column => choice["column"]
         end
      end
   end
   
end