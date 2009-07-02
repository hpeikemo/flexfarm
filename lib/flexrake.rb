$: << File.expand_path(File.dirname(__FILE__))
require "flexfarm_config.rb"
require 'rake'

module Flexfarm
module Rake
   
   module Tasks 
      start_time = Time.new
      task :benchmark do
         puts "Rake completed in %.2f seconds." % (Time.new-start_time)
      end
      
      task :default => :debug
      
      desc "Compile for debugging and preview project"
      task :debug => [:compileDebug,:copyAssetsDebug,:preview,:benchmark]
   
      desc "Compile project for release"
      task :release => [:clean,:compileRelease,:copyAssetsRelease,:benchmark]
   
      desc "Output project settings."
      task :info do
         Flexfarm::Rake::each_project do |project|
            puts heading("Project info for #{project.name}",35),"",project.info   
         end         
      end
            
      namespace :info do 
         
         desc "Output project assets"
         task :assets do 
            Flexfarm::Rake::each_project do |project|
               puts "## #{project.name} (#{project.expand_path(project.basedir)})"
               project.assets.each { |source_dir| 
                  puts source_dir.collect {|file| "\t#{file}" }                
               }
            end
         end
         
         namespace :command do

            desc "Output compiler-command for debug-build"
            task :debug do 
               Flexfarm::Rake::each_project do |project|
                  project[:debug] = true
                  project[:optimize] = false
                  project.define["CONFIG::debug"] = true
                  project.targets { |target|
                     puts "","## #{project.name}, #{target.main_src} => #{target.output_file}",target.compile_to(project.debug_dir),""
                  }
                  
               end
            end

            desc "Output compiler-command for release-build"
            task :release do 
               Flexfarm::Rake::each_project do |project|
                  project[:debug] = false
                  project[:optimize] = true   
                  project.define["CONFIG::debug"] = false
                  project.targets { |target|
                     puts "","## #{project.name}, #{target.main_src} => #{target.output_file}",target.compile_to(project.debug_dir),""
                  }
                  
               end
            end


         end
      end
   
      desc "Previews project by opening preview file. Requires project to be compiled for debugging."
      task :preview do
         project = Flexfarm::Rake::each_project.last
         if project 
            if project.air_descriptor
               system("#{Flexfarm::ADL_BIN} -runtime #{Flexfarm::ADL_RUNTIME} #{project.expand_path("#{project.debug_dir}/#{project.air_descriptor}",true)} #{project.expand_path(project.debug_dir)} &")
            else
               system("open", project.expand_path("#{project.debug_dir}/#{project.preview_file}",true) )   
            end
         end                           
      end
   
      desc "Compile project for debugging."
      task :compileDebug do 
         Flexfarm::Rake::each_project do |project|
            project[:debug] = true
            project[:optimize] = false
            project.define["CONFIG::debug"] = true
            project.compile_to(project.debug_dir)
            sleep 0.05
         end
      end
   
      desc "Compile project for release."
      task :compileRelease do
         Flexfarm::Rake::each_project do |project|
            project[:debug] = false
            project[:optimize] = true   
            project.define["CONFIG::debug"] = false
            project.compile_to(project.release_dir)   
            sleep 0.05
         end
      end
      
      desc "Package air application."
      task :package => [:compileRelease] do
         puts "Not implemented"
         project = Flexfarm::Rake::each_project.last         
         if project && project.air_descriptor
            app_file = "app.air"
            password = ""
            certificate = ""
            system("#{Flexfarm::ADT_BIN} -package -storetype pkcs12 -storepass #{password} -keystore #{certificate} -keypass #{password} #{app_file} bin-release/Application-app.xml -C #{project.expand_path(project.release_dir)} .")
         
         end
      end
   
      desc "Copy all assets to debug-dir."
      task :copyAssetsDebug do
         Flexfarm::Rake::each_project do |project|
            project.assets.each {|a| a.copy_to(project.debug_dir) }
         end
      end
   
      desc "Copy all assets to release-dir."
      task :copyAssetsRelease do
         Flexfarm::Rake::each_project do |project|
            project.assets.each {|a| a.copy_to(project.release_dir) }
         end
      end
   
      desc "Remove release-dir and debug-dir."
      task :clean do
         Flexfarm::Rake::each_project do |project|
            time = Time.new.to_i
            [project.debug_dir,project.release_dir].each do |dir|
               path = project.expand_path(dir)               
               FileUtils.mv(path,"/tmp/deleted_#{project.name}_#{File.basename(dir)}_#{time}") if File.exist? path
            end
         end
      end
   end


   @defined_projects = []   
   def self.each_project(&block)
      projects = @defined_projects.reverse
      projects.each(&block) if block_given?
      projects
   end      
   def self.define_project(&block)
      @defined_projects.push(Project.new(&block))
   end
   
   MXMLC_DEFAULT_ARGS = {
      :defaultSize => [800,600], 
      :defaultFrameRate => 25, 
      :defaultBackgroundColor => "0x9CCA43",
      :defaultScriptLimits => [15000,60],
      :strict => true,
      :benchmark => true
   }

   class Project
      
      attr_accessor :basedir, :release_dir, :debug_dir, :doc_dir, :air_descriptor
      attr_reader :assets, :libs, :srcs, :args, :define
      
      def initialize
         @basedir = "."
         @release_dir = "bin-release"
         @debug_dir = "bin-debug"
         @doc_dir = "doc"
         @targets = []
         @assets = []
         @libs = []
         @srcs = []
         @args = MXMLC_DEFAULT_ARGS
         @define = {}
         yield(self) if block_given?
      end
      
      def compile_to(dir)
         targets do |target|
            success = system(FLEX_COMPILER,target.compile_to(dir));
            raise "Compile error." unless success
         end
      end
      
      def name
         File.basename(expand_path(@basedir))
      end
      
      def info
         spacer = " "*14
         
         [  color("Basedir     : ",33)+expand_path(@basedir),
            color("Release-dir : ",33)+@release_dir,
            color("Debug-dir   : ",33)+@debug_dir,
            color("Doc-dir     : ",33)+@doc_dir,
            color("Source-dirs :",33),
            @srcs.map { |l| spacer+l },
            color("Libraries   :",33),
            @libs.map { |l| spacer+l },         
            color("Arguments   :",33),
            @args.map{|k,v| spacer+"-#{k}=#{v}" },
            @define.map{|k,v| "-define=#{k},#{v}" },
            color("Assets      :",33),
            @assets.map { |a| spacer+a.to_s  },
            color("Targets     :",33),
            @targets.map { |t| spacer+"#{t.main_src} => #{t.output_file}"  },
            color("Preview     : ",33)+preview_file
         ]
      end
      
      
      def []=(k,v)
         @args[k] = v
      end
      def [](k)
         @args[k]
      end
      
      def preview_file=(str)
         @preview = str
      end
      
      def preview_file()
         @preview || targets.last.output_file rescue nil
      end
      
      def add_target(output_file,main_src)
         target = Target.new(self)
         target.output_file = output_file
         target.main_src = main_src
         @targets << target
      end
      
      def targets(&block)
         tgts = @targets.reverse
         tgts.each(&block) if block_given?
         tgts
      end
      
      def expand_path(path,ensure_existence=false)
         path = File.expand_path(path,@basedir)
         raise Exception.new("#{path} was not found") if ensure_existence && !File.exists?(path)
         raise Exception.new("compiler does not support paths with whitespace (#{path})") if path =~ /\s/
         return path
      end   
      
   end
   
   class Target
      
      attr_accessor :output_file
      attr_accessor :main_src
      
      def initialize(project)
         @project = project
      end
      
      def compile_to(dir)
         cmd = ["mxmlc"]
         cmd.push *@project.args.map{|k,v| "-#{transformArgumentKey(k)}=#{transformArgumentValue(v)}" }
         cmd.push *@project.define.map{|k,v| "-define=#{transformArgumentKey(k)},#{transformArgumentValue(v)}" }
         cmd.push "-sp", *@project.srcs.map{|p| @project.expand_path(p,true) }
         cmd.push "-l",  *@project.libs.map{|p| @project.expand_path(p,true) }
         cmd.push "-o", @project.expand_path("#{dir}/#{output_file}")
         cmd.push "--", @project.expand_path(main_src,true)
         cmd.join(" ")      
      end
      
         
      private
      
      def transformArgumentKey(key)
         if key.class == Symbol
            key.to_s.gsub(/[A-Z]/,'-\0').downcase 
         else
            key
         end
      end
      def transformArgumentValue(value)
         if value.respond_to? :join
            value.join(",")
         else
            value.to_s
         end
      end      
      
   end
   
   class SourceDir < FileList
      TO_S_ITEMS = 3
      
      attr_reader :root_dir
      
      def initialize(rootDir,&block)
         @root_dir = rootDir
         @root_dir.taint
         super(&block)
      end
         
      def resolve_add(fn)      
         super(@root_dir+"/"+fn)
      end
      
      def to_s()         
         existing = collect.select { |item| File.exist?(item) }
         files = existing.select { |item| File.file? item }
         dirs = existing.select { |item| File.directory? item }
         combined = (files+dirs)
         combined[0...TO_S_ITEMS].join(", ")+ (combined.length > TO_S_ITEMS ? "..." : "") +" (#{files.length} files, #{dirs.length} dirs)"
      end
      
      def copy_to(targetdir)
         targetdir = File.expand_path(targetdir)
         basedir = File.expand_path(@root_dir)
         each do |source|
            target = File.expand_path(source).gsub(basedir,targetdir)
            copy_item(source,target)
         end
      end
      
      private
      def copy_item(source,target)
         if File.directory?(source) && !File.exist?(target)
            FileUtils.mkdir_p( target )
         elsif File.file? source            
            FileUtils.rm(target) if File.exist?(target) && File.mtime(source) != File.mtime(target)               
            FileUtils.copy_file(source,target, :preserve => true) unless File.exist? target
         end      
      end
      
   end
   
end
end