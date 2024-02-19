`include "my_struct_package.sv"

module cache_tb;

    // Parameters
    parameter sets = 16384;
    parameter ways = 8;
 
    import my_struct_package::*;

    // Declare signals
    logic clk;
    logic [31:0] instr_address;
    logic [31:0] instr_data;
    my_struct_package::cache_line_t cache_out[1][ways];
    my_struct_package::command_t instruction;
    // Instantiate the cache module
    cache #(
    .sets(sets),
    .ways(ways)
) dut (
    .clk(clk),
    .instruction(instruction),
    .cache_out(cache_out)
);


    // Clock generation
    always #5 clk = ~clk;
    assign instruction = {4'b0000, instr_address, 3'b0, 2'b0};
    // Initialize signals
    initial begin
        clk = 0;
        instr_address = 32'h0000_0000; // Initialize instruction address
        instr_data = 32'h0000_0000;    // Initialize instruction data

        // Apply some dummy instructions
        #10;
        instr_address = 32'h1234_5678;
        instr_data = 32'hABCD_EF01;
        #10;
        instr_address = 32'h8765_4321;
        instr_data = 32'hFEDC_BA98;
        #10;
        instr_address = 32'h2468_ACE0;
        instr_data = 32'h1357_9BDF;
        #10;
        // Add more instructions as needed
        
        // Monitor cache_out
        $monitor("Time = %0t: cache_out = %p", $time, cache_out);
    end

endmodule