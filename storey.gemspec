# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "storey/version"

Gem::Specification.new do |s|
  s.name        = "storey"
  s.version     = Storey::VERSION
  s.authors     = ["Ramon Tayag"]
  s.email       = ["ramon@tayag.net"]
  s.homepage    = "https://github.com/ramontayag/storey"
  s.summary     = %q{Manage multiple PostgreSQL schemas in your multi-tenant app.}
  s.description = %q{Storey aims to simplify the implementation of managing a multi-tenant application.}
  s.license = 'MIT'

  s.rubyforge_project = "storey"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "database_cleaner"
  s.add_runtime_dependency 'easy_class_to_instance_method', '~> 0.0.2'
  s.add_runtime_dependency "rails", ">= 4.0.0"
  s.add_runtime_dependency "pg"
end
