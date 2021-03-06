
# Converts the product description into a hash
# with the "product_name",
# "description", "features", and "specs"
def hashify(string)
  hash = Hash.new
  if string != nil
    string = string.split(/\n(?=\{)/)
    string.each do |section|
      hash[ ( section.slice(/[\w\d\_\#]+(?=\})/) ) ] = section[(section.index('}')+1)..-1].strip
    end
  end
  return hash
end

# encode special characters for HTML
def html_sanitizer(string, set=:basic)
  if set == :basic
    $htmlmap = MAPPINGS[:base]
  else
    $htmlmap = MAPPINGS[:base].merge!(MAPPINGS[:title])
  end

  string = string.split("")
  string.map! { |char|
    ( $htmlmap.has_key?(char.unpack('U')[0]) ) ? $htmlmap[char.unpack('U')[0]] : char
  }


  return string.join
end

# replace \r\n line endings with \n line endings
# check encoding, if not UTF-8, transcode
def file_sanitizer(file)
  file = File.open(file, mode="r+")
  content = File.read(file)
	content.force_encoding(Encoding::Windows_1252)
	content = content.encode!(Encoding::UTF_8, :universal_newline => true)
  content.gsub!("\r\n","\n")
  file.write(content)
end

# Capitalize all words in title
# except those in no_cap and with "*" in front of them
def title_case(string)
  no = 0
  no_cap = ["a","an","the","with","and","but","or","on","in","at","to"]
  split = string.split.map! do |word|
    no += 1
    if no < 2
      word.downcase.capitalize
    elsif word[0] == "*"
      word.sub!("*","")
    elsif word.include?('-')
      word.split('-').each{|i| i.capitalize!}.join('-')
    elsif no_cap.include?(word.downcase)
      word.downcase
    else
      word.capitalize
    end
   end
   split.join(' ')
end


# sanitize and capitalize
def product_name(string)
  string = html_sanitizer(title_case(string),:title)
end


# Make it a list
def listify(string)
  output = "<ul>\n"
  string.gsub!(/\:\n/, ":")
  arrayify = string.split("\n")
  arrayify.each do |line|
    line.strip!
    if line.length>0
      output << "\t<li>#{line}</li>\n"
    end
  end
  output << "</ul>\n"
end

# Make it segments
def segmentify(string)
  output = "<br>"
  array = string.split(/\n/)
  array.each do |x|
    if x.match(":")
      output << "#{x}<br>\n"
    else
      output << "<strong>#{x}</strong><br>\n"
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
    if !x.nil?
      output << "\t<tr>\n"
      x.gsub!("  ","\t")
      row = x.split(/\t/)
      row.each do |y|
        if r>0
          output << "\t\t<td>#{y}</td>\n"
        else
          output << "\t\t<th>#{y}</th>\n"
        end
      end
      output << "\t</tr>\n"
      r += 1
    end
  end
  output << "</table>\n\n"
  return output
end

# makes it a paragraph
def grafify(string)
  string.strip!
  string.gsub!("\n","<br>")
end


def format_section(string,format)
  string=html_sanitizer(string)
  case format
  when "table"
    string = tablify(string)
  when "seg"
    string = segmentify(string)
  when "graf"
    string = grafify(string)
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
      temp_data[k] = "<p id=\"description\">#{html_sanitizer(v)}</p>\n"
    when "features"
      temp_data[k] = "<p id=\"features\">\n<u>Features</u>\n#{format_section(v,format)}\n</p>\n"
    when "specs"
      temp_data[k] = "<p id=\"specifications\">\n<u>Specifications</u>\n#{format_section(v,format)}\n</p>\n"
    end
  end
  output << body_format(temp_data)
  return output
end


def body_format(hash)
  product_name = hash["product_name"]
  description = hash["description"]
  features = hash["features"]
  specs = hash["specs"]

  body_format = "<ECI>\n<font face='verdana'>\n"
  body_format << "<h2 id=\"product_name\">#{hash['product_name']}</h2>\n"
  if hash.has_key? 'description'
    body_format << hash['description']
  end
  if hash.has_key? 'features'
    body_format << hash['features']
  end
  if hash.has_key? 'specs'
    body_format << hash['specs']
  end

  body_format << "</font>"

end

def doit(csv_source, csv_target)
  begin
    # open CSV file
    csv_data = CSV.read(csv_source, :headers => true, :skip_blanks => true, :header_converters => :symbol, :encoding => 'UTF-8')
  rescue
    csv_data = CSV.read(csv_source, :headers => true, :skip_blanks => true, :header_converters => :symbol, :encoding => 'Windows-1252:UTF-8')
  rescue Exception => e
    puts e
    exit
  end

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
end
