// Import the struct package
import my_struct_package::*;

module processor(
    /* Signal ports
    * top: clk, instruction, current_line, return_line
    * FSM: block_in, block_out
    */

    input  clk,
    input  command_t instruction,
    input  cache_line_t current_line_i[I_WAYS],
    input  cache_line_t current_line_d[D_WAYS],
    input  cache_line_t block_in,
    output cache_line_t return_line_i[I_WAYS],
    output cache_line_t return_line_d[D_WAYS],
    output cache_line_t block_out
    
    );
    // repeat instructions
    command_t prev_instruction;
    command_t current_instruction;

    // way select
    logic [LRU_BITS-1:0] d_select;
    logic [LRU_BITS-1:0] i_select;
    static logic hit_found_d = 0;
    static logic hit_found_i = 0;
    
    // Invalid LRU variables
    int way_select_i;
    int invalid_select_i;
    int way_select_d;
    int invalid_select_d;
    cache_line_t way_line_d;
    cache_line_t way_line_i;
    int invalid_LRU_i;
    int invalid_LRU_d;

    // top module flags
    static int evict_d = 0;
    static int evict_i = 0;



    // cache indexing
    int i = 0; 
    int j = 0;
    
    // hit buses
    logic [D_WAYS-1:0] data_read_bus;
    logic [I_WAYS-1:0] instruction_read_bus;
    
    // internal cache lines
    cache_line_t internal_d[D_WAYS];
    cache_line_t internal_i[I_WAYS];


    // Loop through the ways to check for hits
    always_comb begin : check_hits
        // Check data cache ways for hits
        for (int i = 0; i < D_WAYS; i++) begin
            data_read_bus[i] = 0;    // Assume this cache has no hit        

            // check if there is a match in the way, using the set index passed in (updates read_bus)
            if (instruction.address.tag == current_line_d[i].tag) begin
                case (instruction.n)  // which instruction is this?
                    0,1,2,3,4: data_read_bus[i] = 1;   // if read instruction -> hit;
                    default: begin
                        data_read_bus[i] = '0;   // dont care
                    end

                endcase
            end
        end

        // Check instruction cache ways for hits
        for (j = 0; j < I_WAYS; j++) begin
            
            instruction_read_bus[j] = 0;    // Assume this cache has no hit

            // check if there is a match in the way, using the set index passed in (updates read_bus)
            if (instruction.address.tag == current_line_i[j].tag) begin
                case (instruction.n)  // which instruction is this?
                    0,1,2,3,4: instruction_read_bus[j] = 1;   // if read instruction -> hit;
                    default: begin
                        instruction_read_bus[j] = '0;   // dont care
                    end
                endcase
            end
        end
    end 

    // Update the current instruction (prev_instruction is used to check if the instruction has changed)
    always_ff@(negedge clk) begin: Sequential_Logic
        prev_instruction <= instruction;
    end

    // Encode to select column of cache for instruction cache
    always_comb begin
        hit_found_i = 0;
        // Look for a hit in the instruction cache
        for (int i = I_WAYS-1; i >= 0; i--) begin
            if (instruction_read_bus[i] === 1'b1 || instruction_read_bus[i] === 1'bz) begin
                i_select = i;
                hit_found_i = 1;
                break;
            end
        end

        // No hit in the cache
        if (hit_found_i == 0) begin
            // The way_select is uninitialized
            if(i_select === 'x)begin
                i_select = I_WAYS-1;
            end
            // The way_select is initialized
            else begin

                // Initialize housekeeping variables    (highest = oldest value)
                way_select_i = 0;       // Holds the index of the way with the current oldest LRU way
                invalid_select_i = -1;  // Holds the index of the oldest invalid way (initially impossible value)
                invalid_LRU_i = 0;      // Holds the LRU value of the oldest invalid way (initially most recent LRU value)


                // Loop through the ways to find the highest LRU way and the highest invalid way
                for(int i = 0; i < I_WAYS; i++) begin

                    // grab 1 way
                    way_line_i = current_line_i[i];

                    // The current way has older LRU value
                    if(way_line_i.LRU > current_line_i[way_select_i].LRU) begin
                        way_select_i = i;
                    end
                    
                    // The current way is invalid and has an older LRU value
                    if((way_line_i.MESI_bits == I) && (way_line_i.LRU > invalid_LRU_i)) begin

                        invalid_select_i = i;
                        invalid_LRU_i = way_line_i.LRU;
                    end
                end
                    
                // After looping through all ways, if the invalid_select_i is still the impossible value
                // use the way_select_i to overwrite the oldest valid way
                if(invalid_select_i == -1) begin
                    i_select = way_select_i;
                end
                // otherwise, use the invalid_select_i to overwrite the oldest invalid way
                else begin
                    i_select = invalid_select_i;
                end
            end
        end
    end

    // Encode to select column of cache for data cache
    always_comb begin
        hit_found_d = 0;
        // Look for a hit in the data cache
        for (int i = D_WAYS-1; i >= 0; i--) begin
            if (data_read_bus[i] === 1'b1 || data_read_bus[i] === 1'bz) begin
                d_select = i;
                hit_found_d = 1;
                break;
            end
        end

        // No hit in the cache
        if (hit_found_d == 0) begin
            if(d_select === 'x)begin
                d_select = D_WAYS-1;
            end
            else begin
                
                // Initialize housekeeping variables    (highest = oldest value)
                way_select_d = 0;       // Holds the index of the way with the current oldest LRU way
                invalid_select_d = -1;  // Holds the index of the oldest invalid way (initially impossible value)
                invalid_LRU_d = 0;      // Holds the LRU value of the oldest invalid way (initially most recent LRU value)

                // Loop through the ways to find the highest LRU way and the highest invalid way
                for(int i = 0; i < D_WAYS; i++) begin

                    // grab 1 way
                    way_line_d = current_line_d[i];

                    // The current way has older LRU value
                    if(way_line_d.LRU > current_line_d[way_select_d].LRU) begin
                        way_select_d = i;
                    end
                    
                    // The current way is invalid and has an older LRU value
                    if((way_line_d.MESI_bits == 0) && (way_line_d.LRU > invalid_LRU_d)) begin
                        invalid_select_d = i;
                        invalid_LRU_d = way_line_d.LRU;
                    end
                end


                // After looping through all ways, if the invalid_select_d is still the impossible value
                // use the way_select_d to overwrite the oldest valid way
                if(invalid_select_d == -1) begin
                    d_select = way_select_d;
                end
                // Otherwise, use the invalid_select_d to overwrite the oldest invalid way
                else begin
                    d_select = invalid_select_d;
                end 
            end
        end
    end

    // Update the cache line
    always_comb begin
        case(instruction.n)
            // Data cache
            0, 1, 3, 4: begin
                // Copy the current cache line to the internal cache line
                internal_d = current_line_d;
                
                // Send the selected way to the FSM to update the MESI bits
                block_out = current_line_d[d_select];
                
                // Update it with the MESI bits from the FSM
                internal_d[d_select].MESI_bits = block_in.MESI_bits;
                internal_d[d_select].tag = instruction.address.tag;
        
                // Update the LRU if this is a new instruction
                if(instruction !== prev_instruction) begin 
                    if(|data_read_bus) begin 
                        for(int i = 0; i< D_WAYS; i++) begin
                            if(internal_d[i].LRU < current_line_d[d_select].LRU) begin
                                internal_d[i].LRU++;
                            end
                        end
                    end
                    
                    // If there are no hits, update the LRU
                    else begin
                        for(int i = 0; i<D_WAYS; i++) begin
                            internal_d[i].LRU++;

                            // mod 8 to keep the LRU value within the range of 0-7
                            internal_d[i].LRU = internal_d[i].LRU % D_WAYS;
                        end
                        evict_d++;
                    end
                
                    // Set the LRU of the selected way to 0 only if this is a new instruction
                    internal_d[d_select].LRU = 0;
                end

                // Return the updated cache line(s)
                return_line_d = internal_d;
                return_line_i = current_line_i;
            end

            // Instruction cache
            2: begin
                // Copy the current cache line to the internal cache line
                internal_i = current_line_i;

                // Send the selected way to the FSM to update the MESI bits
                block_out = current_line_i[i_select];

                // Update it with the MESI bits from the FSM
                internal_i[i_select].MESI_bits = block_in.MESI_bits;

                // Update the tag of the selected way
                internal_i[i_select].tag = instruction.address.tag;

                // Check if there are any hits in the instruction cache
                if(current_instruction !== prev_instruction) begin
                    if(|instruction_read_bus) begin 
                        for(int i = 0; i < I_WAYS; i++) begin
                            // If the way has a lower LRU value than the selected way, increment the LRU
                            if(internal_i[i].LRU < current_line_i[i_select].LRU) begin
                                internal_i[i].LRU++;
                            end
                        end
                    end
                    // If there are no hits, update the LRU
                    else begin
                        for(int i = 0; i < I_WAYS; i++) begin

                            // Keep the LRU value within the range of 0-3
                            if(internal_i[i].LRU == I_WAYS-1) begin
                                internal_i[i].LRU = 0;
                            end
                            else begin
                                internal_i[i].LRU++;
                            end
                        end
                        evict_i++;
                    end

                    // Set the LRU of the selected way to 0 only if this is a new instruction
                    internal_i[i_select].LRU = 0;
                end

                // Return the updated cache line(s)
                return_line_i = internal_i;
                return_line_d = current_line_d;

            end

            8, 9: begin
                // Do nothing 
            end
        endcase
    end       
endmodule