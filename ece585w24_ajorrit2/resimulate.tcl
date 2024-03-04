# source resimulate.tcl

# Directory where you want to compile the files (usually the work library)
set compile_directory "work"

# Main procedure
proc main {} {
    # End simulation
    quit -sim

    # (re)Compile the design
    vcom -work work -refresh -force_refresh
    
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

proc recompile {} {
    foreach file [glob *.sv] {
    vcom -work $compile_directory $file
    }
}

# Execute the main procedure
main