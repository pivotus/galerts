require File.expand_path('../lib/galerts/version', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'galerts'
  s.version       = Galerts::VERSION.dup
  s.date          = '2014-09-16'
  s.summary       = 'Ruby library to manage google alerts'
  s.description   = %q{Manage to Google Alerts}
  s.authors       = ["Emre Can Yılmaz"]
  s.email         = ['emrecan@ecylmz.com']
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
  s.homepage      = 'https://github.com/pivotus/galerts'
  s.license       = 'MIT'
  s.add_runtime_dependency('mechanize', '~> 2.7')
end
