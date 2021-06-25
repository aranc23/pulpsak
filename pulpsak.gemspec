require_relative 'lib/pulpsak/version'

Gem::Specification.new do |spec|
  spec.name          = "pulpsak"
  spec.version       = Pulpsak::VERSION
  spec.licenses      = ['GPL-3.0-or-later']
  spec.authors       = ["Aran Cox"]
  spec.email         = ["arancox@gmail.com"]

  spec.summary       = %q{command line interface to pulp3}
  spec.description   = %q{mostly focusing on the rpm plugin}
  spec.homepage      = 'https://github.com/aranc23/pulpsak'
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  #spec.metadata["allowed_push_host"] = 'https://github.com/aranc23/pulpsak'

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/commits/"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = ['pulpsak']
  spec.require_paths = ["lib"]
  spec.add_development_dependency "bundler", "~> 2.1.4"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "thor", "~> 1.0"
  spec.add_development_dependency "text-table", "~> 1.2"
end
