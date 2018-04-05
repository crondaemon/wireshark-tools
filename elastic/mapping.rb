#!/usr/bin/env ruby

require 'json'

if ARGV.size < 2
	puts "\n  Usage: #{$0} <tshark exe> <output>\n\n"
	exit 1
end

# TODO: improve the case
# https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-types.html
def convert_type(type)
	case type
	when "FT_INT8", "FT_UINT8", "FT_UINT16", "FT_INT16", "FT_INT32", "FT_UINT32", "FT_UINT24", "FT_UINT64", "FT_INT64", "FT_FRAMENUM", "FT_UINT48", "FT_INT48", "FT_INT24", "FT_UINT24", "FT_UINT40", "FT_UINT56"
		"integer"
	when "FT_IPv6", "FT_IPv4"
		"ip"
	when "FT_ABSOLUTE_TIME", "FT_RELATIVE_TIME"
		"date"
	when "FT_BOOLEAN", "FT_BYTES", "FT_FLOAT", "FT_NONE", "FT_STRING", "FT_ETHER", "FT_DOUBLE", "FT_GUID", "FT_OID", "FT_STRINGZ", "FT_UINT_STRING", "FT_CHAR", "FT_UINT_BYTES", "FT_AX25", "FT_REL_OID", "FT_IEEE_11073_SFLOAT", "FT_IEEE_11073_FLOAT", "FT_STRINGZPAD", "FT_PROTOCOL", "FT_EUI64", "FT_IPXNET", "FT_SYSTEM_ID", "FT_FCWWN", "FT_VINES"
		nil
	else
		raise "Type #{type} not supported."
	end
end

elastic = {}

elastic = {
	'template': "packets-*",
	'settings': {
		"index.mapping.total_fields.limit": 1000000
  },
  "mappings": {
    "pcap_file": {
      "dynamic":"false",
      "properties": {
        "timestamp": {
          "type":"date"
        },
        "layers": {
          "properties": {
          }
        }
      }
    }
  }
}

lines = `#{ARGV[0]} -G fields`.split("\n")

lines.each do |line|
	next if !line.include?("FT_")
	tokens = line.split("\t")
	filter = tokens[2]
	type = tokens[3]
	proto = tokens[4]

	filter.gsub!(/[-.]/,'_')
	proto.gsub!(/[-.]/,'_')

	ctype = convert_type(type)
	if ctype
		elastic[:mappings][:pcap_file][:properties][:layers][:properties][proto] = { properties: {}} if !elastic[:mappings][:pcap_file][:properties][:layers][:properties][proto]
		elastic[:mappings][:pcap_file][:properties][:layers][:properties][proto][:properties][filter] = { type: ctype } 
	end
end

output = File.new(ARGV[1], 'w')
output.write(JSON.pretty_generate(elastic))
output.close
