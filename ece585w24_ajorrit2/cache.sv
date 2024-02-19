
`include "my_struct_package.sv"

module cache #(parameter sets = 16384, parameter ways = 8)(
	input  clk,
	input  my_struct_package::command_t instruction,
	output my_struct_package::cache_line_t cache_out[1][ways]
);


import my_struct_package::*; // import structs

// cache module
    /** Initialize data cache as a 2D array of cache lines
    *  cache_line contains tag, LRU, MESI bits, and data
    **/

    // Declare the cache as an array of cache lines
    cache_line_t cache[sets-1:0][ways-1:0];   // L1 cache
   
    // Initialize the cache
    initial begin
        // Initialize each set
        for(int i = 0; i < sets; i++) begin
            // Initialize each way
            for(int j = 0; j < ways; j++) begin
                cache[i][j].LRU = j;           // LRU = way of the cache line (0, 1, 2, 3, 4, 5, 6, 7)
                cache[i][j].MESI_bits = 2'b11; // Initialize MESI bits to Invalid
                cache[i][j].tag = 12'b0;        // Initialize tag to 0
                cache[i][j].data = 512'b0;     // Initialize mem to 0
            end
        end
    end

always_ff@(posedge clk)begin

    for (int i = 0; i < ways; i++) begin
        cache_out[0][i] = cache[instruction.address.set_index][i];
    end
end
endmodule