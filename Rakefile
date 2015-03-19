#!/usr/bin/env rake

require 'rainbow/ext/string'

desc 'Lintme'
task :build do
  # check ruby syntax
  puts 'Running rubocop'.color(:blue)
  sh 'rubocop'
end

task default: 'build'
