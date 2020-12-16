# peek is a cli utility for peeking at files
# useful for peeking at large csv files or json files
# this allows you to quickly deduce what is inside the file before opening
# it in excel or the like and having to wait for it to render and load in
#

require "option_parser"


peek : Peek # this is our instance that the whole program uses
lines : Int32 = 0
filename : String = ""


# TODO add in --help flag support


# handle all the parsing
OptionParser.parse do |parser|
  parser.banner = "peek"
  parser.on "-f", "--file", "pass the file you want to peek into" do |file|
    filename = file[1..-1]
  end

  parser.on "-l", "--lines", "the number of lines to take a peek at" do |l|
    # handle non numeric input entered
    begin
      chopped = l[1..-1]
      lines = chopped.to_i
    rescue
      puts "non numeric input was entered with the -l or --lines param"
      exit
    end
  end
end


if filename == ""
  puts "No filename passed in with the -f/--file param"
  puts "eg. usage '-f=test.csv'"
  exit
elsif lines == 0
  puts "No line count passed in with the -l/--lines param"
  puts "eg. usage '-l=10'"
  exit
end

peek = Peek.new(filename, lines) # create our class instance

peek.displayFile()
peek.closeFile()



# end of main code


# this is the class that handles all the data displaying etc...
class Peek
  @filename : String
  @fileType : String = ""
  @linesToDisplay : Int32
  # currentLine : Int32 = 0 # store the current line we are on
  @file : File # store the file
  
  def initialize(filename f : String, lines l : Int32)
    @linesToDisplay = l
    @filename = f
    if !File.exists?(f)
       puts "failed to open file, make sure the filename or filepath is correct"
      exit
    end
    @file = File.open(@filename) # open the file
    puts "taking a quick peek at #{l} line(s) of #{f}"

  end

  def displayFile
    # if @filetype == "json"
    #   puts "file is a json file"
    #   display_json()
    # elsif @filetype == "csv"
    #   display_csv()
    # else
    #   display_other()
    # end
    puts ""
    display_csv()
  end


  private def display_csv
    # @file.readlines do |line|
    #   puts line
    #   self.currentLine += 1
    # end
    currentLine : Int32 = 0
    @file.each_line { |line|
      if currentLine >= @linesToDisplay
        puts "<-- End peek -->"
        break
        end
      puts line
      currentLine += 1
    }
    
  end


  private def display_json
  end
  
  private def display_other
  end

  def closeFile
    @file.close()
  end

  
end
