# @see http://www.devalot.com/articles/2012/04/gem-versions.html
# for a good description of gem version specs.
#
# Use range operators for clarity.
# In general, use the range version operators (<, >, <=, >=)
# instead of the pessimistic version operator (~>) when possible.
#
Gem::Specification.new do |gem|
  gem.name          = 'wormhole test suite'
  gem.homepage      = 'https://github.com/jumanjiman/wormhole'
  gem.description   = %q{'This gemspec is a helper for Bundler so that we can have smarter environments'}
  gem.summary       = %q{'Test harness for this repo'}
  gem.license       = 'GPLv3'

  gem.add_development_dependency 'docker-api'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'mocha'
  gem.add_development_dependency 'rspec-core'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rspec-expectations'
  gem.add_development_dependency 'rspec-mocks'
  gem.add_development_dependency 'rubocop'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.authors       = `git log --format='%aN' | sort -u`.split($/)
  gem.email         = `git log --format='%aE' | sort -u`.split($/)
  gem.require_paths = ['lib']
  # Leave at zero
  gem.version       = '0.0.0'
end
