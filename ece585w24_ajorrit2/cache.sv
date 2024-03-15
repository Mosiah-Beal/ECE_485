
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
static logic reset = 0;                   // Reset signal

always_comb begin
    //read
    if(clk == 0) begin
        case (instruction.n)
            0, 1, 2, 3, 4: begin // Read or write instructions    
                cache_out = cache[instruction.address.set_index];
            end
            
            8: begin // Reset cache
                reset = 1;
            end
            
            9: begin // Display cache line(currently, doesn't have a gap between instruction and data lines)
                for (int i = 0; i < ways; i++) begin
                    // $display("Time = %0t: \t\tInput Cache Line[%h] = %p", $time, instruction.address.set_index, cache[instruction.address.set_index][i]);
                end
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
                cache[instruction.address.set_index] = cache_in;
            end
                
            8: begin // Reset cache
                for (int j = 0; j < sets;j++) begin
                    reset = 1;
                end
            end
            
            9: begin // Display cache line
                for (int i = 0; i < ways; i++) begin
                    // $display("Time = %0t: \t\tInput Cache Line[%h] = %p", $time, instruction.address.set_index, cache[instruction.address.set_index][i]);
                end
            end
            
            default: begin
                // Do nothing or add specific functionality based on your design
            end
        endcase
    end

    // Reset cache (with a flag)
    if(reset) begin
        for (int i = 0; i < sets; i++) begin
            for (int j = 0; j < ways; j++) begin
                cache[i][j].LRU = (ways-1)-j;            // LRU = way of the cache line (0, 1, 2, 3, 4, 5, 6, 7)
                cache[i][j].MESI_bits = I;      // Initialize MESI bits to Invalid
                cache[i][j].tag = 'x;            // Initialize tag to set index
                cache[i][j].data = i;           // Initialize mem to set index
            end
        end
        reset = 0;
    end

end
endmodule