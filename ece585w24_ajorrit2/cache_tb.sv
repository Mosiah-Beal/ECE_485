`include "my_struct_package.sv"

module cache_tb;

    // Parameters
    parameter sets = 16384;
    parameter ways = 8;
 
    import my_struct_package::*;

    // Declare signals
    logic clk;
    logic we;
    logic re;
    logic [31:0] instr_address;
    my_struct_package::cache_line_t cache_out[1][ways];
    my_struct_package::cache_line_t cache_in[1][ways];
    my_struct_package::command_t instruction;
    
    // Instantiate the cache module
    cache #(
        .sets(sets),
        .ways(ways)
    ) dut (
        .clk(clk),
        .we(we),
        .re(re),
        .instruction(instruction),
        .cache_in(cache_in),
        .cache_out(cache_out)
    );
	
    // Clock generation
    always #5 clk = ~clk;

    // Assign instructions
    assign instruction = {4'b0000, instr_address, 3'b0, 2'b0};
    // Initialize signals
    initial begin
	clk = 0;
        we = 1;
        re = 0;

	  for(int i = 0; i < sets; i++) begin
            // Initialize each way
            for(int j = 0; j < ways; j++) begin
                cache_in[0][j].LRU = j;           // LRU = way of the cache line (0, 1, 2, 3, 4, 5, 6, 7)
                cache_in[0][j].MESI_bits = 2'b11; // Initialize MESI bits to Invalid
                cache_in[0][j].tag = 12'b0;        // Initialize tag to 0
                cache_in[0][j].data = 32'b0;     // Initialize mem to 0
            end
        end

	#10
        // Initialize instruction address
	instr_address = 32'h0000_0000;
        cache_in[0][0].data = 32'h0000_0000; 
	 $display("Time = %0t: cache_out = %p\n", $time, cache_out);
	$display ("Time = %0t: cache_in = %p\n", $time,  cache_in);   // Initialize instruction data
	#20;

	we = 0;
        re = 1;
        instr_address = 32'h0000_0000; // Initialize instruction address
        cache_in[0][0].data = 32'h0000_0000;
        $display("Time = %0t: cache_out = %p\n", $time, cache_out);
	$display ("Time = %0t: cache_in = %p\n", $time,  cache_in);
	// Apply some dummy instructions
        #20;
	re = 0;
        we = 1;
        instr_address = 32'hABCD_EF01;
       	cache_in[0][0].data = 32'hABCD_EF01;
	$display("Time = %0t: cache_out = %p\n", $time, cache_out);
	$display ("Time = %0t: cache_in = %p\n", $time,  cache_in);
	#20;
        we = 0;
	re = 1;
	instr_address = 32'hABCD_EF01;
       	cache_in[0][0].data = 32'hABCD_EF01;
        $display("Time = %0t: cache_out = %p\n", $time, cache_out);
	$display ("Time = %0t: cache_in = %p\n", $time,  cache_in);
	#20;
	we = 1;
        re = 0;
	instr_address = 32'hFEDC_BA98;
	cache_in[0][0].data = 32'hFEDC_BA98;
	 $display("Time = %0t: cache_out = %p\n", $time, cache_out);
	$display ("Time = %0t: cache_in = %p\n", $time,  cache_in);
	#20
	we = 0;
        re = 1;
        instr_address = 32'hFEDC_BA98;
	cache_in[0][0].data = 32'hFEDC_BA98;
         $display("Time = %0t: cache_out = %p\n", $time, cache_out);
	$display ("Time = %0t: cache_in = %p\n", $time,  cache_in);
	#20;
        we = 1;
	re = 0;
        instr_address = 32'h1357_9BDF;
        cache_in[0][0].data = 32'h1357_9BDF;
         $display("Time = %0t: cache_out = %p\n", $time, cache_out);
	$display ("Time = %0t: cache_in = %p\n", $time,  cache_in);
	#20;
	we = 0;
	re = 1;
	instr_address = 32'h1357_9BDF;
        cache_in[0][0].data = 32'h1357_9BDF;
         $display("Time = %0t: cache_out = %p\n", $time, cache_out);
	$display ("Time = %0t: cache_in = %p\n", $time,  cache_in);
	#20;
	we = 1;
        instr_address = 32'h1357_9BDF;
        cache_in[0][0].data = 32'h1357_9BDF;
        $display("Time = %0t: cache_out = %p\n", $time, cache_out);
	$display ("Time = %0t: cache_in = %p\n", $time,  cache_in);
	#20;
	we = 1;
        instr_address = 32'h1357_9BDF;
        cache_in[0][0].data = 32'h1357_9BDF;
         $display("Time = %0t: cache_out = %p\n", $time, cache_out);
	$display ("Time = %0t: cache_in = %p\n", $time,  cache_in);
	#20;

        // Add more instructions as needed
        
        // Monitor cache_out
        $display("Time = %0t: cache_out = %p\n", $time, cache_out);
    end

endmodule