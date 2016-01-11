#!/usr/bin/env ruby

#TODO: sublists in list style
#TODO: skip empty lines in lists
#TODO: add vendor name based on VCS field

# Require Gems
require 'csv'
require 'htmlentities'
require 'optparse'
require 'ostruct'

# Require Scripts
scriptdir = File.dirname(__FILE__)
require "#{scriptdir}/lib/leemdconvert.rb"

# TEMPS
$file = "C:/Documents and Settings/pos/desktop/out.csv"
ARGV = [ $file ]

def valid_file?(file)
	if file.nil?
		puts "Please provide a file to format"
		exit 0
	end
	if !file =~ /\.csv$/
		puts "Requires a CSV-formated spreadsheet"
		exit 0
	end
	if !File.exists?(file)
		puts "#{file} doesn't seem to exist. Please check\nyour file path and try again."
		exit 0
	end
	true
end

def parse_args

	options = OpenStruct.new
	options.source = nil
	options.verbose = false

	if ARGV.include?("-h")
		print_help
	end

	if ARGV.include?("-v")
		ARGV.delete("-v")
		options.verbose = true
	end

	if valid_file?(ARGV[0])
		options.source = File.absolute_path(ARGV[0])
	end

	options

end

def print_help
	puts "Command takes a CSV-formated file, parses the \"desc\"\n"
	puts "field and, returns a new file formated for posting on\n"
	puts "the web. See the online manual for LeeMD shortcode rules.\n"
	puts "\n"
	puts "Usage: leemd.rb FILE.csv [options]\n"
	puts "\n"
	puts "Options:\n"
	puts "\t-v\t\t\tRuns verbosely\n"
	puts "\t-h\t\t\tPrints this help\n"
	exit 0
end

if __FILE__ == $0

	options = parse_args

	path = options.source.slice(0,options.source.index(/\/[A-Za-z0-9\-\_]+\.csv$/)+1)
	file = options.source.slice(/[A-Za-z0-9\-\_]+\.csv$/)
	csv_target = "#{path}FILTERED#{file}"

	doit(options.source, csv_target)

end
