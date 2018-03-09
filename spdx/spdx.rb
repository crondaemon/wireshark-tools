#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__))

require 'skip.rb'
require 'find'

if ARGV.size < 1
	puts "Usage: #{$0} <root dir> [pattern to skip]"
	exit 1
end

licenses = []
pattern = ARGV[1]

Dir.glob("#{File.dirname($0)}/licenses/*").each do |file|
	tokens = File.read(file).split("---")
	text = tokens.first#.gsub(/\n$/,'')
	spdx = tokens.last.gsub("\n",'')
	if !spdx || !spdx.include?('SPDX-License-Identifier')
		puts "Licence file #{file} is missing SPDX-License-Identifier."
		exit 1
	end
	
	texts = licenses.map{|lic| lic[:text] }
	if texts.include?(text)
		puts "Licence from file #{file} is duplicated"
		next
	end

	#puts "Loading license #{spdx} from #{file}"
	licenses << { spdx: spdx.strip, text: text.strip, filename: file }
end

Find.find(ARGV.first).each do |filename|
	next if skip(filename)
	
	content = File.read(filename)

	guess = false
	if !content.include?('SPDX-License-Identifier')
		guess = true
		licenses.each do |license|
			if content.include?(license[:text])
				puts "\tPatching #{filename} with spdx #{license[:spdx]} (#{license[:filename]})"
				File.open(filename, 'w').write(content.gsub(license[:text], license[:spdx]))
				guess = false
			end
		end
	end

	if guess
		guess = `licensecheck #{filename}`
		next if guess.include?("UNKNOWN")
		next if guess.include?("GENERATED")
		next if guess.include?("Public domain")
		puts "############## #{filename} needs SPDX #{guess}"
	end
end
