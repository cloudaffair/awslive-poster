lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "awslive-poster"
  spec.version       = File.read(File.expand_path('../VERSION',__FILE__)).strip
  spec.authors       = ["Maheshwaran G"]
  spec.email         = ["maheshwarang@ooyala.com"]

  spec.summary       = "Utility that generates the Poster Image URL for the running AWS medialive channel"
  spec.description   = "Utility that generates the Poster Image URL for the running AWS medialive channel"
  spec.homepage      = "https://github.com/cloudaffair/awslive-poster"
  spec.license       = "MIT"


  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/cloudaffair/awslive-poster"

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.files         = Dir['lib/**/*.rb']

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency 'aws-sdk-medialive', '~>1.40'
  spec.add_runtime_dependency 'aws-sdk-s3', '~>1.40'
end
