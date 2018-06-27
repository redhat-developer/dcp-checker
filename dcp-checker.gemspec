lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dcp-checker/version'

Gem::Specification.new do |spec|
  spec.name = 'dcp-checker'
  spec.version = DcpChecker::VERSION
  spec.authors = ['Ian Hamilton']
  spec.email = ['ihamilto@redhat.com']

  spec.summary = %q{Test for broken links in Red Hat Developer Search Engine content.}
  spec.description = %q{Test for broken links in Red Hat Developer Search Engine content.}
  spec.homepage = 'https://github.com/redhat-developer/rhd-dcp-checker'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split('\x0').reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) {|f| File.basename(f)}
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'webmock', '~> 3.3'
  spec.add_development_dependency 'builder', '~> 3.2', '>= 3.2.3'
  spec.add_development_dependency 'colorize', '~> 0.8.1'
  spec.add_development_dependency 'rounding', '~> 1.0', '>= 1.0.1'
  spec.add_development_dependency 'typhoeus', '~> 1.3'
  spec.add_development_dependency 'slim', '~> 3.0', '>= 3.0.9'
end