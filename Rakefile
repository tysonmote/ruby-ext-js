require 'rubygems'
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "ruby-ext-js"
  gem.homepage = "http://github.com/help/ruby-ext-js"
  gem.license = "MIT"
  gem.summary = %Q{Ultra-basic classes for working with Ext.js requests and translating them to DataMapper / Mongood query opts.}
  gem.description = %Q{Ultra-basic classes for working with Ext.js requests and translating them to DataMapper / Mongood query opts.}
  gem.email = "tyson@doloreslabs.com"
  gem.authors = ["Tyson Tate"]
  gem.add_development_dependency "rspec", "~> 1.3.1"
  gem.add_development_dependency "jeweler", "~> 1.5.2"
end
Jeweler::RubygemsDotOrgTasks.new

require 'spec'
require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "ruby-ext-js #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
