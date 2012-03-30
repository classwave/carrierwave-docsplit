# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "carrierwave-docsplit/version"

Gem::Specification.new do |s|
  s.name        = "carrierwave-docsplit"
  s.version     = Carrierwave::Docsplit::VERSION
  s.authors     = ["Justin Woodbridge"]
  s.email       = ["jwoodbridge@me.com"]
  s.homepage    = ""
  s.summary     = %q{Bring together docsplit and carrierwave in a loving union.}
  s.description = %q{Bring together docsplit and carrierwave in a loving union.}

  s.rubyforge_project = "carrierwave-docsplit"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "turn"
  s.add_runtime_dependency "docsplit"
  s.add_runtime_dependency "carrierwave"
end
