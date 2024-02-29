
`include "my_struct_package.sv"

module cache #(parameter sets = 16384, parameter ways = 8)(
	input  clk,  
	input  my_struct_package::command_t instruction,
	input  write_enable,
	input  read_enable,
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

always_comb begin

for (int i = 0; i < ways; i++) begin
    
if(read_enable) begin
  case (instruction.n)
        0, 1, 2, 3, 4: begin // Read or write instructions    
	 cache_out[0][i] = cache[instruction.address.set_index][i];
        end

        8: begin // Reset cache
            for (int j = 0; j < sets;j++) begin
                cache[j][i].LRU = i;           // LRU = way of the cache line (0, 1, 2, 3, 4, 5, 6, 7)
                cache[j][i].MESI_bits = I;     // Initialize MESI bits to Invalid
                cache[j][i].tag = 12'b0;        // Initialize tag to 0
                cache[j][i].data = 32'b0;       // Initialize mem to 0
            end
	$display("reset");
        end
        9: begin // Display cache line
            $display("Time = %t : Cache Line[%h] = %p", $time, instruction.address.set_index, cache[instruction.address.set_index][i]);
        end
        default: begin
            // Do nothing or add specific functionality based on your design
        end
    endcase
end
else if(write_enable) begin
case (instruction.n)
        0, 1, 2, 3, 4: begin // Read or write instructions   
            cache[instruction.address.set_index][i] = cache_in[0][i];
        end
        8: begin // Reset cache
            for (int j = 0; j < sets;j++) begin
                cache[j][i].LRU = i;           // LRU = way of the cache line (0, 1, 2, 3, 4, 5, 6, 7)
                cache[j][i].MESI_bits = I;     // Initialize MESI bits to Invalid
                cache[j][i].tag = 12'b0;        // Initialize tag to 0
                cache[j][i].data = 32'b0;       // Initialize mem to 0
            end
	$display("reset");
        end
        9: begin // Display cache line
            $display("Time = %t : Cache Line[%h] = %p", $time, instruction.address.set_index, cache[instruction.address.set_index][i]);
        end
        default: begin
            // Do nothing or add specific functionality based on your design
        end
    endcase
end

end
end
endmodule