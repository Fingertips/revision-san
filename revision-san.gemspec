# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{revision-san}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Eloy Duran"]
  s.date = %q{2009-03-09}
  s.description = %q{A simple Rails plugin which creates revisions of your model and comes with an equally simple HTML differ.}
  s.email = %q{eloy.de.enige@gmail.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["README.rdoc", "VERSION.yml", "lib/revision_san", "lib/revision_san/diff.rb", "lib/revision_san.rb", "test/diff_test.rb", "test/revision_san_test.rb", "test/test_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/Fingertips/revision_san}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A simple Rails plugin which creates revisions of your model and comes with an equally simple HTML differ.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
