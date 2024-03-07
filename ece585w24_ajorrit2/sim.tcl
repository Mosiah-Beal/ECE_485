# source resimulate.tcl

# Main procedure
proc main {} {
    
    # End previous simulation
    quit -sim
    
    # Hide window
    noview source

    # (Compile the design
    project open 485_Project.mpf
    project compileall


    # Check the status of the compilation
    if {[catch {project compileall} errmsg]} {
        # If there was an error during compilation, print the error message and exit
        puts stderr "Error during compilation: $errmsg"
        quit -f
    }

    # refresh the library
    vlog -work work -refresh -force_refresh

    # simulate the design
    vsim work.top -suppress 12003

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
    add wave -position insertpoint -recursive /top/*
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
    /top/instruction \
    /top/cache_input_d \
    /top/cache_output_d \
}

# Execute the main procedure
main