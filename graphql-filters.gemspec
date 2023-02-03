require_relative 'lib/graphql/filters/version'

Gem::Specification.new do |spec|
  spec.name = 'graphql-filters'
  spec.version = GraphQL::Filters::VERSION
  spec.authors = ['Riccardo Agatea']
  spec.email = ['riccardo@moku.io']

  spec.summary = 'Provide a fully typed interface to filter lists in a GraphQL API.'
  spec.description = 'Provide a fully typed interface to filter lists in a GraphQL API.'
  spec.homepage = 'https://moku.io' # TODO
  spec.required_ruby_version = '>= 2.6.0' # Maybe we should check (?)

  spec.metadata['allowed_push_host'] = "TODO: Set to your gem server 'https://example.com'" # TODO

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://moku.io' # TODO
  spec.metadata['changelog_uri'] = 'https://moku.io' # TODO

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir File.expand_path(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'graphql'
end
