# Main procedure
proc main {} {
        
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

}

# Execute the main procedure
main