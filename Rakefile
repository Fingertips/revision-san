require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the RevisionSan plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the RevisionSan plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'RevisionSan'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name     = "revision-san"
    s.homepage = "http://github.com/Fingertips/revision_san"
    s.authors  = ["Eloy Duran"]
    s.email    = "eloy.de.enige@gmail.com"
    s.summary  = s.description = "A simple Rails plugin which creates revisions of your model and comes with an equally simple HTML differ."
  end
  
  begin
    require 'jewelry_portfolio/tasks'
    JewelryPortfolio::Tasks.new do |t|
      t.account = 'Fingertips'
    end
  rescue LoadError
    puts "JewelryPortfolio not available. Install it with: sudo gem install Fingertips-jewelry_portfolio -s http://gems.github.com"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end