lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'perimeter-activerecord'
  spec.version       = '0.0.4'
  spec.authors       = %w{ Bukowskis }
  spec.description   = %q{Repository/Entity pattern conventions. This is an adapter for ActiveRecord.}
  spec.summary       = %q{Repository/Entity pattern conventions. This is an adapter for ActiveRecord.}
  spec.homepage      = 'https://github.com/bukowskis/perimeter-activerecord'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/) - ['.travis.yml']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w{ lib }

  spec.add_dependency 'perimeter', '~> 0.0.1'

  spec.add_development_dependency 'activerecord'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'sqlite3'
end
