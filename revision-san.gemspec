# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{revision-san}
  s.version = "0.2.0"

  s.authors = ["Eloy Duran"]
  s.description = %q{A simple Rails plugin which creates revisions of your model and comes with an equally simple HTML differ.}
  s.email = %q{eloy.de.enige@gmail.com}
  s.files = ["README.rdoc", "VERSION.yml", "lib/revision_san", "lib/revision_san/diff.rb", "lib/revision_san.rb", "test/diff_test.rb", "test/revision_san_test.rb", "test/test_helper.rb"]
  s.homepage = %q{http://github.com/Fingertips/revision_san}
  s.require_paths = ["lib"]
  s.summary = %q{A simple Rails plugin which creates revisions of your model and comes with an equally simple HTML differ.}

  s.add_dependency 'activerecord', '~> 3.2'
  s.add_dependency 'diff-lcs'
  s.add_development_dependency 'bacon'
  s.add_development_dependency 'sqlite3'
end
