#!/ruby200/bin

require 'csv'
require 'htmlentities'


#--BEGIN temporary placeholders
$vendor = "The North Face"
temp = "TEMP_TEXT"
product_name = temp
description = temp
features = temp
specs = temp

path = "../"
csv_file_name = "tnf.csv"
csv_file = path+csv_file_name
new_csv_file = path+csv_file_name.sub(/\.csv/,'NEW.csv')
#--END temporary placeholders


# open CSV file
csv_data = CSV.read(csv_file, :headers => true)


# Converts the product description into a hash
# with the "product_name",
# "description", "features", and "specs"
def hashify(string)
  hash = Hash.new
  if string != nil
    string = string.split(/\n(?=\{)/)
    string.each do |section|
      hash[ ( section.slice(/[\w\d\_]+(?=\})/) ) ] = section.slice( /(?<=\})[^\{\}]+/ ).strip
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

def product_name(string)
  string = product_sanitizer(string.split.map(&:capitalize).join(' '))
end

def product_body(string)
end

def body_format(hash)
  product_name = hash["product_name"]
  description = hash["description"]
  features = hash["features"]
  specs = hash["specs"]
  product_name.prepend("#{$vendor} ")

  body_format = "<ECI>\n<font face=\"verdana\">\n<h2>#{product_name}</h2>\n<p>#{description}</p>\n<p>\n<u>Features</u></br>\n#{features}\n</p>\n<p>\n<u>Specifications</u></br>\n#{specs}\n</p>\n</font>"
end


# open a new file
File.open(new_csv_file, 'a') do |file|
  csv_data.each do |row|
    if row["desc"] != nil
      row.each do |head,field|
        if head == "desc"
          product_data = hashify(field)
          temp_data = Hash.new
          product_data.each do |k,v|
            case k
            when "product_name"
              temp_data[k]=product_name(v)
            when "description"
              temp_data[k]=product_sanitizer(v)
            when "features"
              temp_data[k]=product_sanitizer(v)
            when "specs"
              temp_data[k]=product_sanitizer(v)
            end
          end
          row["desc"] = body_format(temp_data)
        end
      end
      file.puts row
    else
      file.puts row
    end
  end
end
