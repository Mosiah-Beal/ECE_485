
`include "my_struct_package.sv"

module cache #(parameter sets = 16384, parameter ways = 8)(
	input  clk,  
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
cache_line_t cache[sets-1:0][ways-1:0];   // L1 cache

//sequential logic to produce cache line
always_ff@(posedge clk, instruction.n)begin

    for (int i = 0; i < ways; i++) begin
	
		case(instruction.n)
		0: begin// read instruction
		//$display("set_index = %h : flag = %b\n", instruction.address.set_index, flag);

       		cache_out[0][i] <= cache[instruction.address.set_index][i];
		cache[instruction.address.set_index][i] <= cache_in[0][i];
		// Print cache_out manually	
		//$display("Time = %t: cache_out = %p\n", $time, cache_out);
		//$display ("Time = %t: cache_in = %p\n", $time,  cache_in);
	
		end
	
		1:begin//write instruction
		//$display("set_index = %h : flag = %b\n", instruction.address.set_index, flag);
		
		cache_out[0][i] <= cache[instruction.address.set_index][i];
		cache[instruction.address.set_index][i] <= cache_in[0][i];
 
		//$display("Time = %t: cache_out = %p\n", $time, cache_out);
		//$display ("Time = %t: cache_in = %p\n", $time,  cache_in);
	
		end

		2:begin //read instruction

		cache_out[0][i] <= cache[instruction.address.set_index][i]; 
		cache[instruction.address.set_index][i] <= cache_in[0][i];
		end

		3:begin //write/invalidate instruction
		
		cache_out[0][i] <= cache[instruction.address.set_index][i];
		cache[instruction.address.set_index][i] <= cache_in[0][i];
		
		end
		
		4:begin //read instruction
		
		cache_out[0][i] <= cache[instruction.address.set_index][i];
		cache[instruction.address.set_index][i] <= cache_in[0][i];
		end

		8:begin //reset cache
			for(int j = 0; j < sets; j++) begin
     
                		cache[j][i].LRU = i;           // LRU = way of the cache line (0, 1, 2, 3, 4, 5, 6, 7)
              	  		cache[j][i].MESI_bits = I; // Initialize MESI bits to Invalid
               			cache[j][i].tag = 12'b0;        // Initialize tag to 0
                		cache[j][i].data = 32'b0;     // Initialize mem to 0
            			
        		end
		end

		9:begin //display cache line
                
		$display("Time = %t : Cache Line[%h] = %p", $time, instruction.address.set_index, cache[instruction.address.set_index][i]);
            			
		end	
			

		default: begin
		//$display("fell through\n"); 
		//do nothing
		end

	endcase

    end
end
endmodule