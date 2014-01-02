# -*- encoding: utf-8 -*-
# require File.expand_path('../lib/sql_query_executor/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Caio Torres"]
  gem.email         = ["efreesen@gmail.com"]
  gem.description   = %q{Gem to run SQL like queries on array of hashes}
  gem.summary       = %q{With SqlQueryExecutor you can run SQL like queries on any array of hashes}
  gem.homepage      = "http://github.com/efreesen/sql_query_executor"

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.name          = "sql_query_executor"
  gem.require_paths = ["lib"]
  gem.version       = '0.0.1'
  gem.license       = "GPLv2"
  gem.files         = [
    "LICENSE",
    "README.md",
    "sql_query_executor.gemspec",
    Dir.glob("lib/**/*")
  ].flatten
  gem.test_files = [
    "Gemfile",
    "spec/sql_query_executor/base_spec.rb"
  ]

  gem.add_development_dependency(%q<rspec>, [">= 2.2.0"])
  gem.add_development_dependency('coveralls')
end