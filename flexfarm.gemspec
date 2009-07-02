# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{flexfarm}
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Hans Petter Eikemo"]
  s.cert_chain = ["/Users/hp/.gem/gem-public_cert.pem"]
  s.date = %q{2009-07-02}
  s.description = %q{flexFarm is a set of tools to charge and improve ActionScript development.}
  s.email = ["hpeikemo@me.com"]
  s.executables = ["ffarm", "ffcompile", "ffdebugger", "fffcshd"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "rakefile.rb.example", "bin/ffarm", "bin/ffcompile", "bin/ffdebugger", "bin/fffcshd", "lib/flexfarm.rb", "lib/cliwrapper.rb", "lib/fcsh.rb", "lib/fdb.rb", "lib/flashmate.rb", "lib/flexfarm_config.rb", "lib/flexrake.rb", "lib/generator.rb", "lib/default_config.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://code.google.com/p/flexfarm/}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{flexfarm}
  s.rubygems_version = %q{1.3.1}
  s.signing_key = %q{/Users/hp/.gem/gem-private_key.pem}
  s.summary = %q{flexFarm is a set of tools to charge and improve ActionScript development.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 2.3.2"])
    else
      s.add_dependency(%q<hoe>, [">= 2.3.2"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 2.3.2"])
  end
end
