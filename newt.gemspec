# -*- encoding: utf-8 -*-

require "./lib/version"

Gem::Specification.new do |s|
  s.name = "newt"
  s.version = ::Newt::VERSION

  s.authors = ["Noritsugu Nakamura", "Eric Sperano", "Lukas Zapletal"]
  s.summary = "Ruby bindings for newt"
  s.description = "Ruby bindings for newt TUI library"
  s.homepage = "https://github.com/theforeman/ruby-newt"
  s.licenses = ["MIT"]
  s.email = "foreman-dev@googlegroups.com"

  s.files = [
    "lib/newt.rb",
    "lib/version.rb",
    "ext/ruby_newt/extconf.rb",
    "ext/ruby_newt/ruby_newt.c",
    "README.rdoc"
  ]
  s.extra_rdoc_files = ['README.rdoc']
  s.extensions = ["ext/ruby_newt/extconf.rb"]
  s.require_paths = ["lib", "ext"]
end
