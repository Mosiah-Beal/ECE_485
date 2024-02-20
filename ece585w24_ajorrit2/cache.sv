
`include "my_struct_package.sv"

module cache #(parameter sets = 16384, parameter ways = 8)(
	input  clk,
	input  we,
	input  re,	  
	input  my_struct_package::command_t instruction,
	input  my_struct_package::cache_line_t cache_in[1][ways],
	output my_struct_package::cache_line_t cache_out[1][ways]
);


import my_struct_package::*; // import structs

// cache module
    /** Initialize data cache as a 2D array of cache lines
    *  cache_line contains tag, LRU, MESI bits, and data
    **/

// Declare the cache as an array of cache lines
cache_line_t [48:0] cache[sets-1:0][ways-1:0];   // L1 cache

// Declare flag variable
logic [1:0] flag;

//concatenate read write signals into flag
assign flag = {re,we};

//sequential logic to produce cache line
always_ff@(posedge clk, re, we)begin

    for (int i = 0; i < ways; i++) begin
	
		case(flag)
		2'b10: begin
		//$display("set_index = %h : flag = %b\n", instruction.address.set_index, flag);

       		cache_out[0][i] <= cache[instruction.address.set_index][i];
		
		// Print cache_out manually	
		//$display("Time = %t: cache_out = %p\n", $time, cache_out);
		//$display ("Time = %t: cache_in = %p\n", $time,  cache_in);
	
		end
	
		2'b01:begin
		//$display("set_index = %h : flag = %b\n", instruction.address.set_index, flag);

		cache[instruction.address.set_index][i] <= cache_in[0][i];
 
		//$display("Time = %t: cache_out = %p\n", $time, cache_out);
		//$display ("Time = %t: cache_in = %p\n", $time,  cache_in);
	
		end

		default: begin
		//$display("fell through\n"); 
		//do nothing
		end

	endcase
    end
end
endmodule