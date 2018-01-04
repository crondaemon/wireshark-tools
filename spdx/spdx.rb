#!/usr/bin/env ruby

if ARGV.size == 0
	puts "Usage: #{$0} <source file> <licence file> <spdx file>"
	exit 1
end

source = File.read(ARGV[0])
licence = File.read(ARGV[1])
spdx = File.read(ARGV[2])

source.gsub!(licence, spdx)

File.open(ARGV[0], 'w').write(source)
