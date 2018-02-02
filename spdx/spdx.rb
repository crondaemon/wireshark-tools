#!/usr/bin/env ruby

require 'string-similarity'

if ARGV.size == 0
	puts "Usage: #{$0} <root dir>"
	exit 1
end

licenses = []

Dir.glob("#{File.dirname($0)}/licenses/*").each do |file|
	tokens = File.read(file).split("---")
	text = tokens.first#.gsub(/\n$/,'')
	spdx = tokens.last.gsub("\n",'')
	if !spdx || !spdx.include?('SPDX-License-Identifier')
		puts "Licence file #{file} is invalid, skipping."
		exit 1
	end
	
	texts = licenses.map{|lic| lic[:text] }
	if texts.include?(text)
		puts "Licence from file #{file} is duplicated"
		next
	end

	puts "Loading license #{spdx} from #{file}"
	licenses << { spdx: spdx, text: text, filename: file }
end

Dir.glob("#{ARGV.first}/**/*").each do |filename|
	next if File.directory?(filename)
	next if filename.include?('build-')
	next if filename.include?('Make')
	next if filename.match(/.l$/)
	next if File.basename(filename).match(/^README/)
	
	content = File.read(filename)

	needs = true

	if !content[0..1000].include?('SPDX-License-Identifier')
		licenses.each do |license|
			# puts "AAAAAAAAAAAAAAAAAAAA"
			# puts content[0..1000]
			# puts "BBBBBBBBBBBBBBBBBBBBBB"
			# puts license[:text]
			# puts "CCCCCCCCCCCCCCCCCCCCC"
			if content[0..3000].include?(license[:text])
				puts "\tPatching #{filename} with spdx #{license[:spdx]} (#{license[:filename]})"
				File.open(filename, 'w').write(content.gsub(license[:text], license[:spdx]))
				needs = false
			else
				if String::Similarity.cosine(content[0..3000], license[:text]) > 0.99
					puts ">>>>>>>>>> Guess: #{license[:spdx]}"
				end
			end
		end
	else
		needs = false
	end

	if needs
		puts "\t############## #{filename} needs SPDX"
	end
end
