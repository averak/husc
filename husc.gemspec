require_relative 'lib/husc/version'

Gem::Specification.new do |spec|
  spec.name          = "husc"
  spec.version       = Husc::VERSION
  spec.authors       = ["Tatsuya Abe"]
  spec.email         = ["abe12@mccc.jp"]

  spec.summary       = %q{A simple crawler library for Ruby.}
  spec.description   = %q{This project enables site crawling and data extraction with xpath and css selectors. You can also send forms such as text data, files, and checkboxes.}
  spec.homepage      = "https://github.com/AjxLab/husc"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/AjxLab/Crawler."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "mechanize"
  spec.add_dependency "nokogiri"
end
