#!/usr/bin/env ruby

if ARGV.size == 0
	puts "Usage: #{$0} <root dir>"
	exit 1
end

licenses = []

Dir.glob("#{File.dirname($0)}/licenses/*").each do |file|
	tokens = File.read(file).split("---")
	text = tokens.first
	spdx = tokens.last.strip
	if !spdx
		puts "Licence file #{file} is invalid, skipping."
		next
	end
	
	texts = licenses.map{|lic| lic[:text] }
	if texts.include?(text)
		puts "Licence from file #{file} is duplicated"
		next
	end

	puts "Loading license #{spdx} from #{file}"
	licenses << { spdx: spdx, text: text }
end

Dir.glob("#{ARGV.first}/*").each do |filename|
	next if File.directory?(filename)
	
	content = File.read(filename)

	needs = true

	if content[0..1000].include?('SPDX-License-Identifier')
		needs = false
	end

	licenses.each do |license|
		# puts "AAAAAAAAAAAAAAAAAAAA"
		# puts content[0..1000]
		# puts "BBBBBBBBBBBBBBBBBBBBBB"
		# puts license[:text]
		# puts "CCCCCCCCCCCCCCCCCCCCC"
		if content[0..3000].include?(license[:text])
			puts "\tPatching #{filename} with spdx #{license[:spdx]}"
			File.open(filename, 'w').write(content.gsub(license[:text], license[:spdx]))
			needs = false
		end
	end

	if needs
		puts "\t############## #{filename} needs SPDX"
	end
end
