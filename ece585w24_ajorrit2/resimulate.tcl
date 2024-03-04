# source resimulate.tcl

# Main procedure
proc main {} {
    # End simulation
    quit -sim

    # (re)Compile the design
    set files [glob *.sv]
    foreach file $files {
        vlog -work work $file
    }
    
    # simulate the design
    vsim work.top -suppress 12003
    
    # Add signals to the wave window
    add_signals

    # Run the simulation
    run -all

}

proc add_signals {} {
    add wave -position insertpoint  \
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
    /top/write_enable \
    /top/read_enable \
    /top/start \
    /top/sum
}

# Execute the main procedure
main