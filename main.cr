# peek is a cli utility for peeking at files
# useful for peeking at large csv files or json files
# this allows you to quickly deduce what is inside the file before opening
# it in excel or the like and having to wait for it to render and load in
#

require "option_parser"


peek : Peek # this is our instance that the whole program uses
lines : Int32 = 0
filename : String = ""
cellWidth : Int32 = 0


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
  
  parser.on "--format", "--format", "used to define the cell width when displaying a csv file" do |w|
    begin
      cellWidth = w.to_i
      puts "cell width #{w}"
    rescue
      puts "non-numeric input was entered with the --format flag"
      exit
    end
  end

  parser.on "-h","--help", "the help command" do
    puts "
Usage => peek -f=[filename here] -l=[the number of lines you want to print here]
-f or --file
-l or --lines

if looking at csv files you can use the '--format' flag to specify the cell width
         "
    exit
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

peek = Peek.new(filename, lines, cellWidth == 0 ? 20 : cellWidth) # create our class instance
peek.displayFile()
peek.closeFile()



# end of main code


# this is the class that handles all the data displaying etc...
class Peek
  @filename : String
  @fileType : String = ""
  @linesToDisplay : Int32
  @file : File # store the file
  property format_gap : Int32 # the default value
  
  def initialize(filename f : String, lines l : Int32, format_gap gap : Int32)
    @linesToDisplay = l
    @filename = f
    @format_gap = gap
    # check if the file exists before opening it
    if !File.exists?(f)
       puts "failed to open file, make sure the filename or filepath is correct"
      exit
    end
    @file = File.open(@filename) # open the file
    puts "taking a quick peek at #{l} line(s) of #{f}"
    @filetype = File.extname(@filename) # this will get the file extension
  end

  
  def displayFile
    puts ""
    if @filetype == ".csv"
      display_csv()
    else
      display_other()
    end
  end


  private def display_csv
    currentLine : Int32 = 0
    
    @file.each_line { |line|
      if currentLine >= @linesToDisplay
        puts "<-- End peek -->"
        break
      end

      # here we want to display the header
      if currentLine == 0
        header = line.split(',')
        
        display = ""
        (header.size()).times do |index|
          # puts header[index]
          display += "%-#{@format_gap}s|" % [header[index]]
        end
        # the end part of this line basically just concatnates the "-" character n times by the format_gap variable
        # and the number of headers displayed, this gives us a nice dotted line that's not hardcoded in
        puts "#{display}\n#{"-"*@format_gap*header.size()}"
      else
        header = line.split(',')
        display = ""
        (header.size()).times do |index|
          display += "%-#{@format_gap}s|" % [header[index]]
        end
        puts display
      end
      currentLine += 1
    }
    
  end
  
  private def display_other
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

  # close the file, this should be called at the end of the program
  def closeFile
    @file.close()
  end

  
end
