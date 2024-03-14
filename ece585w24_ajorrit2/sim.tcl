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
    /top/cache_output_i \
    /top/instructions \
    /top/mode_select
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
        # quit -f
    }

    # Suppress the ghost errors of deleted testbenches: 8386 

    # refresh the library
    vlog -work work -refresh -force_refresh -suppress 8386

    # simulate the design
    vsim work.top -suppress 12003 -voptargs=+acc +MODE=$mode +FILENAME=$trace_file


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


# Check if the script has arguments from ModelSim when being run as a macro
if {[info exists mode] && [info exists trace_file]} {
    # If the script has arguments, execute the main procedure
    main $mode $trace_file
} else {
    # If the script does not have arguments, print an error message and exit
    puts "Error: This script must be run from ModelSim"
    puts "Usage: vsim -do \"set trace_file trace1.txt; set mode STATS; source sim.tcl\" work.top"
    exit 1

}

# Command to run the simulation
# vsim -do "set trace_file trace1.txt; set mode STATS; source sim.tcl" work.top

