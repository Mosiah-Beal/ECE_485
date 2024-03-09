# source resimulate.tcl

# Main procedure
proc main {} {
    
    # End previous simulation
    quit -sim
    
    # Hide window
    noview source

    # (Compile the design
    set project_name [glob *85*.mpf | *85.mpf]
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
    # suppressing the following errors:
    # 12003: Variable is written by continuous and procedural assignments
    # 3839: Signal is driven via a port connection
    vsim work.top -suppress 12003 -suppress 8386 -suppress 3839 

    # Add signals to the wave window
    add_cache_signals

    # Set the width of the signal names
    configure wave -signalnamewidth 1

    view wave
    # Run the simulation
    run -all

}

proc add_signals {} {
    add wave -position insertpoint /top/*
    //add wave -position insertpoint -recursive /top/*
}

proc add_manual {} {
    add wave -position insertpoint  \
    /top/sets \
    /top/ways \
    /top/clk \
    /top/rst \
    /top/instruction \
    /top/cache_input_i \
    /top/cache_output_i \
    /top/cache_input_d \
    /top/cache_output_d \
    /top/fsm_input_line \
    /top/fsm_output_line \
    /top/hit \
    /top/hitM \
    /top/sum \
    /top/instructions
}

proc add_cache_signals {} {
    add wave -position insertpoint  \
    /top/clk \
    /top/mode_select \
    /top/instruction \
    /top/cache_input_d \
    /top/cache_output_d \
    /top/cache_input_i \
    /top/cache_output_i 
}

# Execute the main procedure
main

# Change to STATS mode
force -deposit /top/mode_select 1

# Run the simulation to the end of the instructions array
run -all

# Change to VERBOSE mode
force -deposit /top/mode_select 2

# Run the simulation to the end of the instructions array
run -all
