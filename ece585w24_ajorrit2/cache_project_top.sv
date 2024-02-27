`include "my_struct_package.sv"

import my_struct_package::*;

module top;
    
    logic clk;
    logic rst;
    command_t instruction;
    cache_line_t cache_input_i[1][4];
    cache_line_t cache_output_i[1][4];
    cache_line_t cache_input_d[1][8];
    cache_line_t cache_output_d[1][8];
    cache_line_t fsm_input_line[1][1];
    cache_line_t fsm_output_line[1][1];
    logic hit;
    logic hitM;

// Parameters
parameter sets = 16384;
parameter ways = 8;

 
// Instantiate the data cache with sets = 16384 and ways = 8
cache #(.sets(16384), .ways(8)) data_cache (
        .clk(clk),
        .instruction(instruction),
	    .cache_in(cache_input_d),
        .cache_out(cache_output_d)
    );

 // Instantiate the instruction cache with sets = 16384 and ways = 4
cache #(.sets(16384), .ways(4)) instruction_cache (
        .clk(clk),
        .instruction(instruction),
	    .cache_in(cache_input_i),
        .cache_out(cache_output_i)
    );

processor processor(
        .clk(clk),
        .instruction(instruction),
        .current_line_i(cache_output_i),
        .current_line_d(cache_output_d),
        .return_line_i(cache_input_i),
        .return_line_d(cache_input_d),
        .block_in(fsm_input_line),
        .block_out(fsm_output_line));


mesi_fsm fsm(
        .clk(clk), 
        .rst(rst), 
        .instruction(instruction),
        .internal_line(fsm_output_line), 
        .return_line(fsm_input_line), 
        .hit(hit),
        .hitM(hitM));

// Clock generation
always #5 clk = ~clk;

initial begin
    // Initialize inputs
    clk = 0;
    rst = 1;
    instruction = {4'b0,32'b0,3'b0,2'b0};
    hit = 0;
    hitM = 0;



    for(int i = 0; i < sets; i++) begin
        // Initialize each way
        for(int j = 0; j < 4; j++) begin
            cache_input_i[0][j].LRU = j;           // LRU = way of the cache line (0, 1, 2, 3, 4, 5, 6, 7)
            cache_input_i[0][j].MESI_bits = I; // Initialize MESI bits to Invalid
            cache_input_i[0][j].tag = 12'b0;        // Initialize tag to 0
            cache_input_i[0][j].data = 32'b0;     // Initialize mem to 0
        end
    end


    for(int i = 0; i < sets; i++) begin
        // Initialize each way
        for(int j = 0; j < 8; j++) begin
            cache_input_d[0][j].LRU = j;           // LRU = way of the cache line (0, 1, 2, 3, 4, 5, 6, 7)
            cache_input_d[0][j].MESI_bits = I; // Initialize MESI bits to Invalid
            cache_input_d[0][j].tag = 12'b0;        // Initialize tag to 0
            cache_input_d[0][j].data = 32'b0;     // Initialize mem to 0
        end
    end
        
    // Wait for some time
    #10;

    // De-assert reset
    rst = 0;

    // Apply test vectors
    // You can modify the test vectors as per your requirements
    // For example, you can change the instructions, block_in values, etc.

    // Test case 1
    $display("Test Case 1:");
    
    // Set instruction, block_in, hit, hitM values accordingly
    instruction = {4'b1,32'h8FA2B7C4,3'b0,2'b0};
    

    // Apply some clock cycles
    #10;

    // Print outputs
    instruction = {4'b1,32'h8FA2B7C4,3'b0,2'b0};

    // Apply some clock cycles
    #10;

    // Print outputs
    instruction = {4'b1,32'h3C8D4EAF,3'b0,2'b0};

    // Continue with more test cases if needed

    // End simulation after test cases
    #10;
	
	instruction = {4'b1,32'h8FA2B7C4,3'b0,2'b0};
	
	#10; 

	// Test case 1
    $display("Test Case 2:");
    // Set instruction, block_in, hit, hitM values accordingly
    instruction = {4'b0,32'h8FA2B7C4,3'b0,2'b0};
    

    // Apply some clock cycles
    #10;

    // Print outputs
    instruction = {4'b0,32'h8FA2B7C4,3'b0,2'b0};

    // Apply some clock cycles
    #10;

    // Print outputs
    instruction = {4'b0,32'h3C8D4EAF,3'b0,2'b0};

    // Continue with more test cases if needed

    // End simulation after test cases
    #10;

	instruction = {4'b0,32'h8FA2B7C4,3'b0,2'b0};
	#10; 


    $finish;
    end


endmodule