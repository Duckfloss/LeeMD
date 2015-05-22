#!/ruby200/bin

require 'csv'
require 'htmlentities'
require 'yaml'

settings = YAML::load_file "settings.yml"

os = settings["os"]
csv_source = settings[os]["path"]+settings[os]["csv_source"]
csv_target = settings[os]["path"]+settings[os]["csv_target"]

#--BEGIN temporary placeholders
$vendor = ""
temp = "TEMP_TEXT"
product_name = temp
description = temp
features = temp
specs = temp
#--END temporary placeholders


# Converts the product description into a hash
# with the "product_name",
# "description", "features", and "specs"
def hashify(string)
  hash = Hash.new
  if string != nil
    string = string.split(/\n(?=\{)/)
    string.each do |section|
      hash[ ( section.slice(/[\w\d\_\#]+(?=\})/) ) ] = section.slice( /(?<=\})[^\{\}]+/ ).strip
    end
  end
  return hash
end

# encode special characters for HTML
# remove trademark, registered symbols and repeated quotes
def product_sanitizer(string)
  items = {
    "&quot;&quot;" => "&quot;",
    "&trade;" => "",
    "&reg;" => ""
  }
  coder = HTMLEntities.new
  string = coder.encode(string, :named)
  items.each do |k,v|
    string.gsub! k, v
  end
  return string
end

# Title Case
def product_name(string)
  string = product_sanitizer(string.split.map(&:capitalize).join(' '))
end

# Make it a list
def listify(string)
  output = "<ul>\n"
  string.gsub!(/\:\n/, ":")
  arrayify = string.split("\n")
  arrayify.each do |line|
    line.strip!
    output += "\t<li>#{line}</li>\n"
  end
  output += "</ul>\n"
end

# Make it segments
def segmentify(string)
  output = "<br>"
  array = string.split(/\n/)
  array.each do |x|
    if x.match(":")
      output += "#{x}<br>\n"
    else
      output += "<strong>#{x}</strong><br>\n"
    end
  end
  return output
end

# Make it a table
def tablify(string)
  output = "<table>\n"
  r = 0
  array = string.split(/\n/)
  array.each do |x|
    output += "\t<tr>\n"
    x.gsub!("  ","\t").
    row = x.split(/\t/)
    row.each do |y|
      if r>0
        output += "\t\t<td>#{y}</td>\n"
      else
        output += "\t\t<th>#{y}</th>\n"
      end
    end
    output += "\t</tr>\n"
    r += 1
  end
  output += "</table>\n\n"
  return output
end


def format_section(string,format)
  string=product_sanitizer(string)
  case format
  when "table"
    string = tablify(string)
  when "seg"
    string = segmentify(string)
  when "graf"
    return string
  when "list" # is default
    string=listify(string)
  else
    string=listify(string)
  end
  return string
end


def formatify(string)
    output = ""
    product_data = hashify(string)
    temp_data = Hash.new
    product_data.each do |k,v|
      format = "" # marks what format to put section into
      if k.match("#")
        split = k.split("#")
        k = split[0]
        format = split[1]
      end

      case k #checks key
      when "product_name"
        temp_data[k]=product_name(v)
      when "description"
        temp_data[k]=product_sanitizer(v)
      when "features"
        temp_data[k]=format_section(v,format)
      when "specs"
        temp_data[k]=format_section(v,format)
      end
      output = body_format(temp_data)
    end
    return output
end


def body_format(hash)
  product_name = hash["product_name"]
  description = hash["description"]
  features = hash["features"]
  specs = hash["specs"]
  product_name.prepend("#{$vendor} ")

  body_format = "<ECI>\n<font face=\'verdana\'>\n<h2>#{product_name}</h2>\n<p>#{description}</p>\n<p>\n<u>Features</u>\n#{features}\n</p>\n<p>\n<u>Specifications</u>\n#{specs}\n</p>\n</font>"
end

# open CSV file
csv_data = CSV.read(csv_source, :headers => true,:skip_blanks => true,:header_converters => :symbol)

# open a new file
File.open(csv_target, 'a') do |file|
  csv_data.each do |row|
    if row[:desc] != nil
      row.each do |head,field|
        if head == :desc
          row[:desc] = formatify(field)
        end
      end
      file.puts row
    else
      file.puts row
    end
  end
end
