# Procedure to add signals to the wave window
proc add_signals {} {
    add wave -position insertpoint /top/*
}

# Procedure to add cache-related signals to the wave window
proc add_cache_signals {} {
    add wave -position insertpoint  \
    /top/clk \
    /top/instruction \
    /top/cache_input_d \
    /top/cache_output_d \
    /top/cache_input_i \
    /top/cache_output_i 
}

# Main procedure
proc main {mode trace_file} {
    
    #End previous simulation
    quit -sim
    
    # Hide window
    noview source

    # Select a project to compile
    project open [glob *85*.mpf | *85.mpf]

    # Check the status of the compilation
    if {[catch {project compileall} errmsg]} {
        # If there was an error during compilation, print the error message and exit
        puts stderr "Error during compilation: $errmsg"
        quit -f
    }

    # refresh the library
    vlog -work work -refresh -force_refresh -suppress 8386

    # simulate the design
    vsim work.top -suppress 12003 -voptargs=+acc

    # Add signals to the wave window
    add_cache_signals

    # Set the width of the signal names
    configure wave -signalnamewidth 1

    view wave
    # Run the simulation
    run -all

    # Check if simulation ran successfully
    if {[runStatus] eq "Stopped"} {
        puts "Initialization complete"
    } else {
        puts "Initialization failed"
    }

    # Run again
    run -all
}




# Check if the number of command-line arguments is correct
if {[llength $argv] != 3} {
    puts  $argv
    puts "Usage: $argv0 <mode> <trace_file>"
    exit 1
}

# Extract mode and trace file from command-line arguments
set mode [lindex $argv 1]
set trace_file [lindex $argv 2]

# Execute the main procedure
main $mode $trace_file
