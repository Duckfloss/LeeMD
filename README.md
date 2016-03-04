# LeeMD
Sortuva Markdown style converter for putting products up on the website


## leemd.rb FILE [OPTIONS]

This tool takes a CSV-formatted document, parses the "desc" field, and returns a new file with the "desc" field reformatted for the web. The name is short for "Lee's MarkDown". You can call the tool by typing leemd.rb. You can access help by typing leemd.rb -h


### default
Requires a file name. Will take a CSV-formatted file and convert the "desc" field to a web-formatted version.

##### ```-v```
Runs code verbosely.


### Example

```leemd.rb "c:/Documents and Settings/pos/somefile.csv" -v```

This code will take a file somefile.csv, extract the "desc" field, reformat it for the web, and save a new file named "FILTEREDsomefile.csv". The "-v" flag will make it give you feedback as it's processing.

### NOTES:

LeeMD is a shortcode-style formatting tool. It requires certain format headers and style guides. See the documentation on LeeMD format for more details. (TODO: Write instructions on LeeMD format.)

### TODO:
sublists in list style
skip empty lines in lists
add vendor name based on VCS field
