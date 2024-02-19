module processor_block_tb;

    // Parameters
    localparam CLK_PERIOD = 10; // Clock period in time units

    import my_struct_package::*;

    // Declare signals
    logic clk = 0;
    my_struct_package::command_t instruction;
    my_struct_package::cache_line_t p0current_line_i[1][4];
    my_struct_package::cache_line_t p0current_line_d[1][8];
    my_struct_package::cache_line_t p1current_line_i[1][4];
    my_struct_package::cache_line_t p1current_line_d[1][8];
    my_struct_package::cache_line_t p2current_line_i[1][4];
    my_struct_package::cache_line_t p2current_line_d[1][8];
    logic [35:0] hit_bus;

    // Instantiate the processor_block module
    processor_block dut (
        .clk(clk),
        .instruction(instruction),
        .p0current_line_i(p0current_line_i),
        .p0current_line_d(p0current_line_d),
        .p1current_line_i(p1current_line_i),
        .p1current_line_d(p1current_line_d),
        .p2current_line_i(p2current_line_i),
        .p2current_line_d(p2current_line_d),
        .hit_bus(hit_bus)
    );

    // Clock generation
    always #((CLK_PERIOD)/2) clk = ~clk;

    // Initialize signals
    initial begin
        // Apply some dummy instructions
        instruction = '{4'b0, 32'b0,3'b0,2'b0};

        // Add more dummy instructions as needed

        // Run simulation for a certain period
 $monitor("Time = %0t: hit_bus = %h p0data cache = %p p0instr cache = %p, p1data cache = %p p1instr cache = %p, p2data cache = %p p2instr cache = %p",
         $time, hit_bus, p0current_line_d, p0current_line_i, p1current_line_d, p1current_line_i, p2current_line_d, p2current_line_i);
        #1000;
        // Add more simulation time as needed
    end

endmodule