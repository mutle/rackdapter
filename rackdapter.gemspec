# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rackdapter}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mutwin Kraus"]
  s.date = %q{2008-12-05}
  s.description = %q{rackdapter}
  s.email = %q{mutwin.kraus@gmail.com}
  s.executables = ["rackdapter", "rackdapter_proxy"]
  s.extra_rdoc_files = ["bin/rackdapter", "bin/rackdapter_proxy", "lib/rackdapter/config.rb", "lib/rackdapter/master.rb", "lib/rackdapter/proxy.rb", "lib/rackdapter/rackdapter.rb", "lib/rackdapter/spawner.rb", "lib/rackdapter.rb", "README.rdoc"]
  s.files = ["bin/rackdapter", "bin/rackdapter_proxy", "lib/rackdapter/config.rb", "lib/rackdapter/master.rb", "lib/rackdapter/proxy.rb", "lib/rackdapter/rackdapter.rb", "lib/rackdapter/spawner.rb", "lib/rackdapter.rb", "Manifest", "MIT-LICENSE", "Rakefile", "README.rdoc", "test/rackdapter.yml", "test/test_helper.rb", "test/unit/test_config.rb", "rackdapter.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/mutle/rackdapter}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Rackdapter", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rackdapter}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{rackdapter}
  s.test_files = ["test/test_helper.rb", "test/unit/test_config.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<eventmachine>, [">= 0"])
    else
      s.add_dependency(%q<eventmachine>, [">= 0"])
    end
  else
    s.add_dependency(%q<eventmachine>, [">= 0"])
  end
end
