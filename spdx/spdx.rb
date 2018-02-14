#!/usr/bin/env ruby

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
		puts "Licence file #{file} is invalid, skipping."
		exit 1
	end
	
	texts = licenses.map{|lic| lic[:text] }
	if texts.include?(text)
		puts "Licence from file #{file} is duplicated"
		next
	end

	puts "Loading license #{spdx} from #{file}"
	licenses << { spdx: spdx.strip, text: text.strip, filename: file }
end

Dir.glob("#{ARGV.first}/**/*").each do |filename|
	next if File.directory?(filename)
	next if filename.include?('build-')
	next if filename.include?('Make')
	next if filename.include?('gtk')
	next if filename.match(/.l$/)
	next if File.basename(filename).match(/^README/)
	next if pattern && filename.match(pattern)
	
	content = File.read(filename)

	if !content[0..5000].include?('SPDX-License-Identifier')
		licenses.each do |license|
			if content[0..5000].include?(license[:text])
				puts "\tPatching #{filename} with spdx #{license[:spdx]} (#{license[:filename]})"
				File.open(filename, 'w').write(content.gsub(license[:text], license[:spdx]))
			end
		end
	else
		guess = `licensecheck #{filename}`
		next if guess.include?("UNKNOWN")
		next if guess.include?("GENERATED")
		puts "############## #{filename} needs SPDX #{guess}"
	end
end
