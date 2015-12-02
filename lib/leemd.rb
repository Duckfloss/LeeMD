#TODO: sublists in list style
#TODO: skip empty lines in lists
#TODO: add vendor name based on VCS field

# Add lib to load path
$LOAD_PATH << "./leemd"

# Require Gems
require 'csv'
require 'htmlentities'
require 'yaml'

# Require Classes
require 'LeeMDConvert'

$csv_source = ARGV[0]
path = $csv_source.slice(0,$csv_source.index(/\/[A-Za-z0-9\-\_]+\.csv$/)+1)
file = $csv_source.slice(/[A-Za-z0-9\-\_]+\.csv$/)
$csv_target = "#{path}FILTERED#{file}"

doit($csv_source, $csv_target)
