#! ruby

Gem::Specification.new do |spec|
  spec.name = 'google-chrome-client'
  spec.version = '0.3'
  spec.summary = 'Ruby client of Google Chrome Developer Tools Protocol'
  spec.author = 'KATO Kazuyoshi'
  spec.email = 'kato.kazuyoshi@gmail.com'
  spec.homepage = 'http://github.com/kzys/chromerepl/'
  spec.add_dependency('json')

  spec.has_rdoc = true

  spec.files = Dir.glob('lib/**/*.rb')
  spec.executables = ['chromerepl']
end
