#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__))

require 'skip.rb'
require 'find'

Find.fine(ARGV.first).each do |filename|
	next if skip(filename)
	content = File.read(filename)
	puts "File #{filename} requires spdx" if !content.include?("SPDX-License-Identifier")
end
