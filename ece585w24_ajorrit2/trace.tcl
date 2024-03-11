# Open the file
set file [open "your_file.txt" r]

# Loop through each line in the file
while {[gets $file line] >= 0} {
    # Print the line to the console
    puts $line
}

# Close the file
close $file