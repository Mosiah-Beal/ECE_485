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
    add_signals

    # Run the simulation
    run -all

}

proc add_signals {} {
    add wave -position insertpoint /top/*
}

proc add_signals2 {} {
    add wave -position insertpoint -recursive /top/*
}

# Execute the main procedure
main