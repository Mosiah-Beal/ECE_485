module processor_tb;

    // Parameters
    localparam CLK_PERIOD = 10; // Clock period in time units

// Import the struct package
    import my_struct_package::*;

    // Declare signals
    logic clk = 0;
    my_struct_package::command_t instruction;
    my_struct_package::cache_line_t current_line_i[1][4];
    my_struct_package::cache_line_t current_line_d[1][8];
    logic [11:0] p_bus;

    // Instantiate the processor module
    processor dut (
        .clk(clk),
        .instruction(instruction),
	.current_line_i(current_line_i),
        .current_line_d(current_line_d),
        .p_bus(p_bus)
    );

    // Clock generation
    always #((CLK_PERIOD)/2) clk = ~clk;

    // Initialize signals
    initial begin
        // Apply some dummy instructions
        instruction = '{4'b0, 32'b0,3'b0,2'b0}; // Sample instruction type
           
        // Add more dummy instructions as needed
        
        // Monitor p_bus
        $monitor("Time = %0t: p_bus = %h data cache = %p instr cache = %p",
         $time, p_bus, current_line_d, current_line_i);

        // Run simulation for a certain period
        #1000;
        // Add more simulation time as needed
    end

endmodule