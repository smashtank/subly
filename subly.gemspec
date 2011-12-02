# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "subly/version"

Gem::Specification.new do |s|
  s.name        = "subly"
  s.version     = Subly::VERSION
  s.authors     = ['SmashTank Apps, LLC','Eric Harrison']
  s.email       = ['dev@smashtankapps.com']
  s.homepage    = "http://github.com/smashtank/subly"
  s.summary     = %q{Add subscriptions to a model that are controlled externally}
  s.description = %q{This was purpose built to extend models with subscriptions that were controlled via SalesForce}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.required_rubygems_version = ">= 1.3.6"
  s.add_development_dependency "activerecord", "~> 2.3.12"
  s.add_development_dependency "rspec"
  s.add_development_dependency "sqlite3"

end
