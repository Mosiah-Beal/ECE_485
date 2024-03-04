import my_struct_package::*;

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
    logic start;
    logic [2:0] sum;

// Parameters
parameter sets = 16384;
parameter ways = 8;

 
// Instantiate the data cache with sets = 16384 and ways = 8
cache #(.sets(16384), .ways(8)) data_cache (
        .clk(clk),
        .instruction(instruction),
	    .cache_in(cache_input_d),
        .cache_out(cache_output_d),
	    .write_enable(write_enable),
	    .read_enable(read_enable)
    );

 // Instantiate the instruction cache with sets = 16384 and ways = 4
cache #(.sets(16384), .ways(4)) instruction_cache (
        .clk(clk),
        .instruction(instruction),
	    .cache_in(cache_input_i),
        .cache_out(cache_output_i),
	    .write_enable(write_enable),
	    .read_enable(read_enable)
    );

processor processor(
        .clk(clk),
        .instruction(instruction),
        .current_line_i(cache_output_i),
        .current_line_d(cache_output_d),
        .return_line_i(cache_input_i),
        .return_line_d(cache_input_d),
        .block_in(fsm_input_line),
        .block_out(fsm_output_line),
        .count(sum)
        );


mesi_fsm fsm(
        .clk(clk), 
        .rst(rst), 
        .instruction(instruction),
        .internal_line(fsm_output_line), 
        .return_line(fsm_input_line), 
        .hit(hit),
        .hitM(hitM)
        );

count LRU(.start(start),.rst(rst), .sum(sum));


// Clock generation
always #5 clk = ~clk;

initial begin
    // Initialize inputs
    clk = 0;
    rst = 1;
    instruction = {4'b1000,32'b0,3'b0,2'b0};
    hit = 0;
    hitM = 0;
    write_enable = 0; 
    start = 1;
    read_enable = 1;
 
for(int i = 0; i<8; i++)begin
	cache_input_d[i].LRU = i;           // LRU = way of the cache line (0, 1, 2, 3, 4, 5, 6, 7)
	cache_input_d[i].MESI_bits = I;     // Initialize MESI bits to Invalid
	cache_input_d[i].tag = 12'b0;        // Initialize tag to 0
	cache_input_d[i].data = 32'b0;       // Initialize mem to 0
end

for(int i = 0; i<4; i++)begin
	cache_input_i[i].LRU = i;           // LRU = way of the cache line (0, 1, 2, 3, 4, 5, 6, 7)
	cache_input_i[i].MESI_bits = I;     // Initialize MESI bits to Invalid
	cache_input_i[i].tag = 12'b0;        // Initialize tag to 0
	cache_input_i[i].data = 32'b0;       // Initialize mem to 0
end



#10;
    instruction = {4'b0000,32'b0,3'b0,2'b0};
    // De-assert reset
    rst = 0;
    write_enable = 0;
    read_enable = 1;
    start = 1;
    
#5; 
    // Apply test vectors
    // You can modify the test vectors as per your requirements
    // For example, you can change the instructions, block_in values, etc.
    rst = 0;
    write_enable = 0;
    read_enable = 1;
    start = 0;
    // Test case 1

#5; 
    $display("Test Case 1:");
    start = 0;
    write_enable = 1;
    read_enable = 0;
    //0 984DE132
    instruction = {4'b0,32'h984DE132,3'b0,2'b0};

#5;
    start = 0;
    write_enable = 0;
    read_enable = 1;
    //0 984DE132
    instruction = {4'b0,32'h984DE132,3'b0,2'b0};
#5;
    start = 1;
    write_enable = 1;
    read_enable = 0;
    //0 116DE12F
    instruction = {4'b0,32'h116DE12F,3'b0,2'b0};

#5;
    start = 0;
    write_enable = 0;
    read_enable = 1;
    //0 116DE12F
    instruction = {4'b0,32'h116DE12F,3'b0,2'b0};

#5;

    start = 1;
    write_enable = 1;
    read_enable = 0;
    //0 100DE130
    instruction = {4'b0,32'h100DE130,3'b0,2'b0};

#5;

    start = 0;
    write_enable = 0;
    read_enable = 1;
    //0 100DE130
    instruction = {4'b0,32'h100DE130,3'b0,2'b0};

#5;

    start = 1;
    write_enable = 1;
    read_enable = 0;
    //0 999DE12E
    instruction = {4'b0,32'h999DE12E,3'b0,2'b0};

#5;
    start = 0;
    write_enable = 0;
    read_enable = 1;
    //0 999DE12E
    instruction = {4'b0,32'h999DE12E,3'b0,2'b0};

#5;
    start = 1;
    write_enable = 1;
    read_enable = 0;
    //0 645DE10A
    instruction = {4'b0,32'h645DE10A,3'b0,2'b0};

#5;
    start = 0;
    write_enable = 0;
    read_enable = 1;
    //0 645DE10A
    instruction = {4'b0,32'h645DE10A,3'b0,2'b0};

#5;
    start = 1;
    write_enable = 1;
    read_enable = 0;
    //0 846DE107
    instruction = {4'b0,32'h846DE107,3'b0,2'b0};

#5;
    start = 0;
    write_enable = 0;
    read_enable = 1;
    //0 846DE107
    instruction = {4'b0,32'h846DE107,3'b0,2'b0};

#5;
    start = 1;
    write_enable = 1;
    read_enable = 0;
    //0 211DE128
    instruction = {4'b0,32'h211DE128,3'b0,2'b0};

#5;
    start = 0;
    write_enable = 0;
    read_enable = 1;
    //0 211DE128
    instruction = {4'b0,32'h211DE128,3'b0,2'b0};

#5;
    write_enable = 1;
    read_enable = 0;
    start = 1;
    //0 777DE133
    instruction = {4'b0,32'h777DE133,3'b0,2'b0};

#5;
    write_enable = 0;
    read_enable = 1;
    start = 0;
    //0 777DE133
    instruction = {4'b0,32'h777DE133,3'b0,2'b0};

#5;
    instruction = {4'b1001,32'h777DE133,3'b0,2'b0};

#10;
    start = 1;
    write_enable = 1;
    read_enable = 0;
    //0 846DE107
    instruction = {4'b0,32'h846DE107,3'b0,2'b0};

#5;
    start = 0;
    write_enable = 0;
    read_enable = 1;
    //0 846DE107
    instruction = {4'b0,32'h846DE107,3'b0,2'b0};

#5;
    instruction = {4'b1001,32'h777DE133,3'b0,2'b0};

#10;

/*   $display("Test Case 2:");    
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
*/ 


$finish;
end


endmodule