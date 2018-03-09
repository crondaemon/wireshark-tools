$patterns = [
	"build-",
	"gz$",
	"pcap$",
	"packet-dcerpc",
	"idl$",
	"cnf$",
	"README",
	"LICENSE",
	"Makefile",
	"Makefile.in",
	"gtk",
	"cnf.c$",
	"packet-fix.h",
	"asn$",
	"/image/",
	".po$",
	"/debian/",
	"jsmn",
	"speex",
	"qcustomplot",
	"COPYING",
	".git",
	".bzrignore",
	".gitignore",
	"install-sh"
]

def skip(filename)
	return true if File.directory?(filename)
	$patterns.each do |pattern|
		return true if filename.match(pattern)
	end
	false
end
