require "rake"

spec = Gem::Specification.new do |s|
  s.name        = "helix"
  s.version     = "0.0.0"
  s.summary     = "Wrapper library for the video API"
  s.description = "Provides helper libraries for Ruby access to the Twistage API"
  s.authors     = ["Twistage"]
  s.email       = "kbaird@twistage.com"
  s.files       = FileList["lib/**.rb", "spec/**.rb", "LICENSE", "README.md"]
  s.has_rdoc    = true
  s.platform    = Gem::Platform::RUBY
  s.license     = "3-Clause BSD"
  s.add_dependency "json", ">= 1.5.4"
end

