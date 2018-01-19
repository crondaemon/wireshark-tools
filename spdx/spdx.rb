#!/usr/bin/env ruby

if ARGV.size == 0
	puts "Usage: #{$0} <root dir>"
	exit 1
end

licenses = {}

Dir.glob("#{File.dirname($0)}/licenses/*").each do |file|
	licenses[File.basename(file)] = File.read(file)
end

Dir.glob("#{ARGV.first}/*").each do |filename|
	next if File.directory?(filename)
	licenses.each_pair do |spdx, license|
		content = File.read(filename)
		if content[0..1000].include?(license)
			puts "Fixing file #{File.basename(filename)} with spdx #{spdx}"
			placeholder = " * SPDX-License-Identifier: #{spdx}"
			File.open(filename, 'w').write(content.gsub(license, placeholder))
		end
	end
end
