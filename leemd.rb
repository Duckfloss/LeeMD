#TODO: sublists in list style
#TODO: skip empty lines in lists
#TODO: add vendor name based on VCS field

# Add lib to load path
$LOAD_PATH << "./lib"

# Require Gems
require 'csv'
require 'htmlentities'
require 'yaml'
require 'Charlock_Holmes'

# Require Classes
require 'LeeMDConvert'

# Load presets
$settings = YAML::load_file "settings/settings.yml"

$os = settings["os"]
$csv_source = settings[os]["path"]+settings[os]["csv_source"]
$csv_target = settings[os]["path"]+settings[os]["csv_target"]
