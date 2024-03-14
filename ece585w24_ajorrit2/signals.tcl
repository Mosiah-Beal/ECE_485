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
    /top.processor/data_read_bus\
    /top.processor/instruction_read_bus
}

proc main {} {
    # add the signals to the wave
    add_cache_signals

    # Set the width of the signal names
    configure wave -signalnamewidth 1

    # Open the wave window
    view wave
    
    # Run the simulation (get to the end of the initialization phase)
    run -all

    # Check if simulation ran successfully
    if {[runStatus] eq "Stopped"} {
        puts "Initialization complete"
    } else {
        puts "Initialization failed"
    }

    # Run again (now start the actual simulation)
    run -all
}

# run the main Procedure
main