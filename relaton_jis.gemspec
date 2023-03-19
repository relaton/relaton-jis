# frozen_string_literal: true

require_relative "lib/relaton_jis/version"

Gem::Specification.new do |spec|
  spec.name = "relaton-jis"
  spec.version = RelatonJis::VERSION
  spec.authors = ["Ribose Inc."]
  spec.email = ["open.source@ribose.com"]

  spec.summary = "RelatonJis: retrieve IETF Standards for bibliographic " \
                 "use using the BibliographicItem model"
  spec.description = "RelatonJis: retrieve IETF Standards for bibliographic " \
                     "use using the BibliographicItem model"
  spec.homepage = "https://github.com/relaton/relaton-jis"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "mechanize", "~> 2.8.0"
  spec.add_dependency "relaton-iso-bib", "~> 1.14.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
