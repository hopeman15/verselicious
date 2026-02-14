# frozen_string_literal: true

require_relative 'lib/verselicious/version'

Gem::Specification.new do |spec|
  spec.name = 'verselicious'
  spec.version = Verselicious::VERSION
  spec.authors = ['Kyle Roe']
  spec.email = ['info@hello-curiosity.com']
  spec.summary = 'GitHub Action to automate semantic versioning with labels'
  spec.homepage = 'https://github.com/hopeman15/verselicious'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.4.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/releases"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.add_dependency 'octokit', '~> 9.0'
end
