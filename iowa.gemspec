#####
# Swiftcore Swiftiply
#   http://swiftiply.swiftcore.org
#   Copyright 2007-2017 Kirk Haines
#   wyhaines@gmail.com
#
#   Licensed under the Ruby License.  See the README for details.
#
#####
lib = File.expand_path('../src', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iowa/version'

spec = Gem::Specification.new do |s|
  s.name              = 'IOWA'
  s.author            = %q(Kirk Haines)
  s.email             = %q(wyhaines@gmail.com)
  s.version           = Iowa::VERSION
  s.summary           = %q(Internet Objects for Web Applications - A unique and
  capable framework for quickly building web applications with Ruby)
  s.platform          = Gem::Platform::RUBY

  s.has_rdoc          = true
  s.rdoc_options      = %w(--title IOWA --main README.md --line-numbers)
  s.extra_rdoc_files  = %w(README.md)
  s.extensions        << 'ext/Classifier/extconf.rb'
  s.extensions        << 'ext/http11/extconf.rb'
  s.files             = Dir['**/*']
  s.executables = %w()
  s.require_paths = %w(src)

  s.test_files = []

  s.rubyforge_project = %q(iowa)
  s.homepage          = %q(http://iowa.swiftcore.org/)
  description         = []
  File.open("README.md") do |file|
    file.each do |line|
      line.chomp!
      break if line.empty?
      description << "#{line.gsub(/\[\d\]/, '')}"
    end
  end
  s.description = description[1..-1].join(" ")

  s.add_runtime_dependency "eventmachine"
  s.add_runtime_dependency "mail"
  s.add_runtime_dependency "mime-types"
end
