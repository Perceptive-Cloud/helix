require "rake"

spec = Gem::Specification.new do |s|
  s.name        = "helix"
  s.version     = "0.0.5.1.pre"
  s.summary     = "Wrapper library for the video API"
  s.description = "Provides helper libraries for Ruby access to the Twistage API"
  s.authors     = ["Twistage, Inc"]
  s.email       = "kevin.baird@perceptivesoftware.com, michael.wood@perceptivesoftware.com"
  s.files       = FileList["lib/helix.rb", "lib/helix/*.rb", "spec/**.rb", "LICENSE", "README.md"]
  s.has_rdoc    = 'yard'
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.platform    = Gem::Platform::RUBY
  s.license     = "3-Clause BSD"
  s.homepage    = 'https://github.com/Twistage/helix/'
  s.add_dependency 'json', '~> 1.8.2'
  s.add_dependency 'rest-client', '~> 1.7.3'
  s.add_dependency 'nori', '~> 2.4.0'
  s.add_development_dependency 'rspec', '~> 3.2.0'
  s.add_development_dependency 'rspec-its', '~> 1.2.0'
  s.add_development_dependency 'simplecov', '~> 0.9.2'
end

