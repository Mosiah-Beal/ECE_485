# source resimulate.tcl

# Main procedure
proc main {} {
    # End simulation
    quit -sim

    # (re)Compile the design
    set files [glob *.sv]
    foreach file $files {
        puts "Compiling $file"
        vlog -work work $file
    }
    
    # simulate the design
    vsim work.top -suppress 12003
    
    # Add signals to the wave window
    add_signals3

    # Run the simulation
    run -all

}

// Add all signals in the top level to the wave window
proc add_signals {} {
    add wave -position insertpoint /top/*
}

// Add every signal in the design to the wave window
proc add_signals2 {} {
    add wave -position insertpoint -recursive /top/*
}

// Explicitly add signals to the wave window
proc add_signals3 {} {
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
    /top/write_enable \
    /top/read_enable \
    /top/start \
    /top/sum \
    /top/instructions
}

# Execute the main procedure
main