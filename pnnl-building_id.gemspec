$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "pnnl/building_id/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "pnnl-building_id"
  s.version     = PNNL::BuildingId::VERSION
  s.authors     = ["Mark Borkum"]
  s.email       = ["mark.borkum@pnnl.gov"]
  s.homepage    = "https://buildingid.pnnl.gov/"
  s.summary     = "Unique Building Identification (UBID) for Ruby"
  s.description = "Unique Building Identification (UBID) for Ruby"
  s.license     = "BSD-3-Clause"

  s.files = Dir["lib/**/*", "LICENSE", "Rakefile", "README.md"]

  s.add_dependency "plus_codes", "~> 0.2.1"
end
