module Flexfarm   
               
   CONFIG_FILES = [File.expand_path("#{File.dirname(__FILE__)}/default_config.rb"),"/etc/ffarm.conf.rb",File.expand_path("~/.ffarm.conf.rb")]
   CONFIG_FILES.reverse.each do |file| 
      if File.exists?(file) 
         require file 
         break
      end
   end

   def heading( msg, padding=1 )   
      style = [47,30]
      heading = "--#{" "*padding}#{msg}#{" "*padding}--"   
      return "",color("="*(heading.length),*style),color(heading,*style),color("-"*(heading.length),*style)
   end
   
   
   def color(input,*args)   
      return input if args.length==0 || ENV["TERM"] !~ /color/
      "\e[#{args.join(";")}m#{input}\e[0m"
   end
   
   COLOR_MODES = [[30,42],[33],[33]]
   def verbose_puts(str,mode=0)
      puts color(str,*COLOR_MODES[mode]) if $verbose_level >= mode
   end
   
   def debugger_output(line)      
      if m = line.match(/^(\[[^\]]+\])\s?(.+)/)
         printContext = true
         argsMessage = [0]
         args = [33]
         if (m[1]=="[Fault]")
            args = [32,41]
            argsMessage = [31]
         end
         if (m[1]=="[trace]")
            printContext = false
            argsMessage = [32]
         end
         if m[2].match(/^Error/)              
            argsMessage = [31]
         end
         
         puts (printContext ? color(m[1],*args)+" " : "")+color(m[2],*argsMessage)      
      else
         puts color(line.chomp)
      end
   end
   
end