#TODO: sublists in list style
#TODO: skip empty lines in lists
#TODO: add vendor name based on VCS field

# Add lib to load path
$LOAD_PATH << "./leemd"

# Require Gems
require 'csv'
require 'htmlentities'
require 'optparse'
require 'ostruct'

# Require Classes
require 'LeeMDConvert'

class Parser

	FORMATS = ["all","t","med","lg","sw"]

	def self.parse(args)
		options = OpenStruct.new
		options.format = ["all"]
		options.eci = false
		options.source = nil
		options.dest = nil
		options.verbose = false

		opt_parser = OptionParser.new do |opt|
			opt.banner = "Usage: limg.rb [options]"
			opt.separator ""
			opt.separator "Options:"

			opt.on("--source SOURCE", "Sets source file or directory", "  default is Downloads/WebAssets") do |source|
				# Validate source
				if !File.directory?(source)
					if File.exist?(source)
						options.source = { "file"=>source }
					end
				else
					options.source = { "dir"=>source }
				end

				if options.source.nil?
					puts "error" #error
				end
			end

			opt.separator ""

			opt.on("--dest DEST", "Sets destination directory", "  defaults are R:/RETAIL/IMAGES/4Web", "  and R:/RETAIL/RPRO/Images/Inven") do |dest|
				if !Dir.exist?(dest)
					puts "error" #error
				else
					options.dest = dest
				end
			end

			opt.separator ""

			opt.on("-e", "--eci", "Parses pic(s) to ECI's directory", "  as well as to default or selected destination") do
				options.eci = true
			end

			opt.separator ""

			opt.on("-fFORMAT", "--format FORMAT", Array, "Select output formats", "  accepts comma-separated string", "  output sizes are t,sw,med,lg", "  default is \"all\"") do |formats|
				formats.each do |format|
					if FORMATS.index(format.downcase).nil?
						puts "error" #error
						exit
					end
					options.format = formats
				end
			end

			opt.separator ""

			opt.on("-v", "--verbose", "Run chattily (or not)", "  default runs not verbosely") do |v|
				options.verbose = true
			end

			opt.separator ""

			opt.on_tail("-h","--help","Prints this help") do
				puts opt
				exit
			end
		end

		opt_parser.parse!(args)
		options
	end
end

if __FILE__ == $0

options = Parser.parse(ARGV)
puts options.to_h
#Image_Chopper.new(options)

end



=begin
$csv_source = ARGV[0]
path = $csv_source.slice(0,$csv_source.index(/\/[A-Za-z0-9\-\_]+\.csv$/)+1)
file = $csv_source.slice(/[A-Za-z0-9\-\_]+\.csv$/)
$csv_target = "#{path}FILTERED#{file}"

doit($csv_source, $csv_target)
=end