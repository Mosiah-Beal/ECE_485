# farts.txt
# n address
# 0 846DE107
# 0 32
# 9 5
# 1 846DE107
# 2 846DE107
# 3 846DE107

# Open the file (manual)
set file [open "farts.txt" r]

# Get the file name from the command line arguments
#set filename [lindex $argv 0]

# Open the file
#set file [open $filename r]


# Initialize an empty array
set array {}

# Loop through each line in the file
while {[gets $file line] >= 0} {
    # Split the line into n value and address
    set parts [split $line]
    set n [lindex $parts 0]
    set address [lindex $parts 1]

    # Convert n value and address into binary format
    set n_binary [string reverse [format %04b $n]]
    
    # not reversed version
    #set n_binary [format %04b $n]

    # Convert the address from hexadecimal to decimal
    scan $address %x address_decimal

    #set address_binary [string reverse [format %032b $address_decimal]]

    # not reversed version
    set address_binary [format %032b $address_decimal]

    # Create a dictionary to represent the struct
    set struct [dict create n $n_binary address $address_binary]

    # Store the struct into the array
    lappend array $struct
}

puts "Sending to module"

set index 0
run 1ns

# Loop through each struct in the array
foreach struct $array {
    set n_binary [dict get $struct n]
    set address_binary [dict get $struct address]

    # Split n_binary and address_binary into individual bits
    set n_bits [split $n_binary ""]
    set address_bits [split $address_binary ""]

    # Split address_bits into tag, set_index, and byte_offset
    set tag_bits [lreverse [lrange $address_bits 0 11]]
    set set_index_bits [lreverse [lrange $address_bits 12 25]]
    set byte_offset_bits [lreverse [lrange $address_bits 26 end]]

    # Force the values
    for {set i 3} {$i >= 0} {incr i -1} {
        force -deposit /top/instructions[$index].n[$i] 1'b[lindex $n_bits $i]
    }
    for {set i 11} {$i >= 0} {incr i -1} {
        force -deposit /top/instructions[$index].address.tag[$i] 1'b[lindex $tag_bits $i]
    }
    for {set i 13} {$i >= 0} {incr i -1} {
        force -deposit /top/instructions[$index].address.set_index[$i] 1'b[lindex $set_index_bits $i]
    }
    for {set i 5} {$i >= 0} {incr i -1} {
        force -deposit /top/instructions[$index].address.byte_offset[$i] 1'b[lindex $byte_offset_bits $i]
    }

    # Print the values sent
    puts "Sent n: $n_binary"
    puts "Sent address: $address_binary"

    incr index
}

stop