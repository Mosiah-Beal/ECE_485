
import my_struct_package::*; // import structs
module cache #(parameter sets = 16384, parameter ways = 8)(
	input  clk,  
	input  command_t instruction,
	input  cache_line_t cache_in[ways],
	output cache_line_t cache_out[ways]
);


// cache module
    /** Initialize data cache as a 2D array of cache lines
    *  cache_line contains tag, LRU, MESI bits, and data
    **/

// Declare the cache as an array of cache lines
cache_line_t cache[sets-1:0][ways-1:0];   // L1 cache

always_comb begin
    // Initialize cache
    if(cache[0][0] === 'x) begin    // if the first way of the first cache line is invalid
        for (int i = 0; i < sets; i++) begin
            for (int j = 0; j < ways; j++) begin
                cache[i][j].LRU = j;            // LRU = way of the cache line (0, 1, 2, 3, 4, 5, 6, 7)
                cache[i][j].MESI_bits = I;      // Initialize MESI bits to Invalid
                cache[i][j].tag = 12'b0;        // Initialize tag to 0
                cache[i][j].data = i;           // Initialize mem to set index
            end
        end
    end

    // Cache operations
    for (int i = 0; i < ways; i++) begin
        // read
        if(clk == 0) begin
            case (instruction.n)
                0, 1, 2, 3, 4: begin // Read or write instructions    
                    cache_out[i] = cache[instruction.address.set_index][i];
                end
                
                8: begin // Reset cache
                    for (int j = 0; j < sets;j++) begin
                        cache[j][i].LRU = i;           // LRU = way of the cache line (0, 1, 2, 3, 4, 5, 6, 7)
                        cache[j][i].MESI_bits = I;     // Initialize MESI bits to Invalid
                        cache[j][i].tag = 12'b0;        // Initialize tag to 0
                        cache[j][i].data = j;       // Initialize mem to 0
                    end
                end
                
                9: begin // Display cache line(currently, doesn't have a gap between instruction and data lines)
                    // $display("Time = %0t: \t\tInput Cache Line[%h] = %p", $time, instruction.address.set_index, cache[instruction.address.set_index][i]);
                end
                
                default: begin
                    // Do nothing or add specific functionality based on your design
                end
            endcase
        end
        //write
        else if(clk == 1) begin
            case (instruction.n)
                0, 1, 2, 3, 4: begin // Read or write instructions   
                    cache[instruction.address.set_index][i] = cache_in[i];
                end
               		
                8: begin // Reset cache
                    for (int j = 0; j < sets;j++) begin
                        cache[j][i].LRU = i;           // LRU = way of the cache line (0, 1, 2, 3, 4, 5, 6, 7)
                        cache[j][i].MESI_bits = I;     // Initialize MESI bits to Invalid
                        cache[j][i].tag = 12'b0;        // Initialize tag to 0
                        cache[j][i].data = j;       // Initialize mem to 0
                    end
                end
                
                9: begin // Display cache line

                    // $display("Time = %0t: \t\tOutput Cache Line[%h] = %p", $time, instruction.address.set_index, cache[instruction.address.set_index][i]);
                end
                
                default: begin
                    // Do nothing or add specific functionality based on your design
                end
            endcase
        end
    end

    // Add a newline after printing the instruction and data cache lines
    if(instruction.n == 9) begin
        $display("");
    end
end
endmodule