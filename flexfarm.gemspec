# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{flexfarm}
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Hans Petter Eikemo"]
  s.date = %q{2009-07-02}
  s.email = %q{hpeikemo@me.com}
  s.executables = ["ffarm", "ffcompile", "ffdebugger", "fffcshd"]
  s.extra_rdoc_files = [
    "README.txt"
  ]
  s.files = [
    "History.txt",
     "Manifest.txt",
     "README.txt",
     "Rakefile",
     "VERSION",
     "bin/ffarm",
     "bin/ffcompile",
     "bin/ffdebugger",
     "bin/fffcshd",
     "flexfarm.gemspec",
     "lib/cliwrapper.rb",
     "lib/default_config.rb",
     "lib/fcsh.rb",
     "lib/fdb.rb",
     "lib/flashmate.rb",
     "lib/flexfarm.rb",
     "lib/flexfarm_config.rb",
     "lib/flexrake.rb",
     "lib/generator.rb",
     "rakefile.rb.example"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/hpeikemo/flexfarm}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{flexFarm is a set of tools to charge and improve ActionScript development.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
