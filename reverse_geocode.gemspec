# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{reverse_geocode}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tommy Campbell", "Rein Henrichs"]
  s.autorequire = %q{reverse_geocode}
  s.date = %q{2009-03-20}
  s.description = %q{A gem that provides Reverse Geocoding using the Google Maps API}
  s.email = %q{tommycampbell@mindspring.com}
  s.extra_rdoc_files = ["README", "LICENSE", "TODO"]
  s.files = ["LICENSE", "README", "Rakefile", "lib/reverse_geocode.rb", "spec/reverse_geocode_spec.rb", "spec/spec_helper.rb", "TODO"]
  s.has_rdoc = true
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A gem that provides Reverse Geocoding using the Google Maps API}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, [">= 1.1.3"])
    else
      s.add_dependency(%q<json>, [">= 1.1.3"])
    end
  else
    s.add_dependency(%q<json>, [">= 1.1.3"])
  end
end
