

# Main procedure
proc main {mode trace_file} {
    


     #End previous simulation
    quit -sim
    
    # Hide window
    noview source

<<<<<<< Updated upstream
    # (Compile the design
    project open ECE485.mpf
    #project open ECE485.mpf
    #project open ECE485.mpf

    # Check the status of the compilation
    if {[catch {project compioleall} errmsg]} {
        # If there was an error during compilation, print the error message and exit
        puts stderr "Error during compilation: $errmsg"
        quit -f
    }

    # refresh the library
    vlog -work work -refresh -force_refresh

    # simulate the design
    vsim work.top -suppress 12003
=======
    # Compile the design
    set project_name [glob *85*.mpf | *85.mpf]
   
 
    # Refresh the library
    vlog -work work -refresh -force_refresh     
>>>>>>> Stashed changes

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

<<<<<<< Updated upstream
# Execute the main procedure
main
=======
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
>>>>>>> Stashed changes
