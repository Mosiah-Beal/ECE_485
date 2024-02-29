//`include "my_struct_package.sv"

import my_struct_package::*;

interface global_signals_if(
    logic clk,
    logic rst,
    command_t instruction,
   
    logic hit,
    logic hitM,
    logic write_enable,
    logic read_enable
);

    modport d_cache_port (
        input clk,
        input instruction,
        input write_enable,
        input read_enable
    );

    modport i_cache_port (
        input clk,
        input instruction,
        input write_enable,
        input read_enable
    );

    modport processor_port (
        input clk,
        input instruction
    );

    modport fsm_port (
        input clk,
        input rst,
        input instruction,
        input hit,
        input hitM
    );



endinterface

module top;

    logic clk;
    logic rst;
    command_t instruction;
    cache_line_t cache_input_i[4];
    cache_line_t cache_output_i[4];
    cache_line_t cache_input_d[8];
    cache_line_t cache_output_d[8];
    cache_line_t fsm_input_line;
    cache_line_t fsm_output_line;
    logic hit;
    logic hitM;
    logic write_enable;
    logic read_enable;

    global_signals_if global_signals(
        .clk(clk),
        .rst(rst),
        .instruction(instruction),
        .hit(hit),
        .hitM(hitM),
        .write_enable(write_enable),
        .read_enable(read_enable)
    );


// Parameters
parameter sets = 16384;
parameter ways = 8;

 
// Instantiate the data cache with sets = 16384 and ways = 8
cache #(.sets(16384), .ways(8)) data_cache (
        global_signals.d_cache_port,
	    .cache_in(cache_input_d),
        .cache_out(cache_output_d),
    );

 // Instantiate the instruction cache with sets = 16384 and ways = 4
cache #(.sets(16384), .ways(4)) instruction_cache (
        global_signals.i_cache_port,
        .cache_in(cache_input_i),
        .cache_out(cache_output_i)
    );

processor processor(
        global_signals.processor_port,
        .current_line_i(cache_output_i),
        .current_line_d(cache_output_d),
        .return_line_i(cache_input_i),
        .return_line_d(cache_input_d),
        .block_in(fsm_output_line),
        .block_out(fsm_input_line)
    );


mesi_fsm fsm(
        global_signals.fsm_port,
        .block_in(fsm_input_line),
        .block_out(fsm_output_line)
    );

// Clock generation
always #5 clk = ~clk;

initial begin
    // Initialize inputs
    clk = 0;
    rst = 1;
    instruction = {4'b1000,32'b0,3'b0,2'b0};
    hit = 0;
    hitM = 0;
    write_enable = 1; 
    

    
    #90;

    // De-assert reset
    rst = 0;
    write_enable = 0;
    read_enable = 1;
    // Apply test vectors
    // You can modify the test vectors as per your requirements
    // For example, you can change the instructions, block_in values, etc.

    // Test case 1
    $display("Test Case 1:");

//0 984DE132
 instruction = {4'b0,32'h984DE132,3'b0,2'b0};
#10;
//0 116DE12F
 instruction = {4'b0,32'h116DE12F,3'b0,2'b0};
#10;
//0 100DE130
 instruction = {4'b0,32'h100DE130,3'b0,2'b0};
#10;
//0 999DE12E
 instruction = {4'b0,32'h999DE12E,3'b0,2'b0};
#10;
//0 645DE10A
 instruction = {4'b0,32'h645DE10A,3'b0,2'b0};
#10;
//0 846DE107
 instruction = {4'b0,32'h846DE107,3'b0,2'b0};
#10;
//0 211DE128
 instruction = {4'b0,32'h211DE128,3'b0,2'b0};
#10;
//0 777DE133
 instruction = {4'b0,32'h777DE133,3'b0,2'b0};
#10;





    $display("Test Case 2:");    
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