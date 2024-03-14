// Import the struct package
import my_struct_package::*;

module processor(
    /* Signal ports
    * top: clk, instruction, current_line, return_line
    * FSM: block_in, block_out
    */

    input  clk,
    input  command_t instruction,
    input  cache_line_t current_line_i[4],
    input  cache_line_t current_line_d[8],
    input  cache_line_t block_in,
    output cache_line_t return_line_i[4],
    output cache_line_t return_line_d[8],
    output cache_line_t block_out
    
);
    // repeat instructions
    command_t prev_instruction;
    command_t current_instruction;

    // way select
    logic [2:0] d_select;
    logic [1:0] i_select;
    
    // Invalid LRU variables
    int way_select_i;
    int invalid_select_i;
    int way_select_d;
    int invalid_select_d;
    cache_line_t way_line_d;
    cache_line_t way_line_i;
    int invalid_LRU_i;
    int invalid_LRU_d;


    // cache indexing
    int i = 0; 
    int j = 0;
    
    // hit buses
    logic [7:0] data_read_bus;
    logic [3:0] instruction_read_bus;
    
    // internal cache lines
    cache_line_t internal_d[8];
    cache_line_t internal_i[4];


    // Loop through the ways to check for hits
    always_comb begin : check_hits
        // Check data cache ways for hits
        for (int i = 0; i < 8; i++) begin
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
        for (j = 0; j < 4; j++) begin
            
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
        case(instruction_read_bus)

            // Found a hit in the cache 
            4'b1000, 4'bz000: i_select = 2'b11;
            4'b0100, 4'b0z00: i_select = 2'b10;
            4'b0010, 4'b00z0: i_select = 2'b01;
            4'b0001, 4'b000z: i_select = 2'b00;
            
            // No hit in the cache
            default: begin
                // The way_select is uninitialized
                if(i_select === 'x)begin
                    i_select = 3;
                end
                // The way_select is initialized
                else begin
                    
                    // Initialize housekeeping variables    (highest = oldest value)
                    way_select_i = 0;       // Holds the index of the way with the current oldest LRU way
                    invalid_select_i = -1;  // Holds the index of the oldest invalid way (initially impossible value)
                    invalid_LRU_i = 0;      // Holds the LRU value of the oldest invalid way (initially most recent LRU value)


                    // Loop through the ways to find the highest LRU way and the highest invalid way
                    for(int i = 0; i < 4; i++) begin

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
                end // end else
            end // end default
        endcase
    end // end comb

    // Encode to select column of cache for data cache
    always_comb begin
        case(data_read_bus) 
            8'b1000_0000, 8'bz000_0000: d_select = 3'b111;
            8'b0100_0000, 8'b0z00_0000: d_select = 3'b110;
            8'b0010_0000, 8'b00z0_0000: d_select = 3'b101;
            8'b0001_0000, 8'b000z_0000: d_select = 3'b100;
            8'b0000_1000, 8'b0000_z000: d_select = 3'b011;
            8'b0000_0100, 8'b0000_0z00: d_select = 3'b010;
            8'b0000_0010, 8'b0000_00z0: d_select = 3'b001;
            8'b0000_0001, 8'b0000_000z: d_select = 3'b000;


        default: begin 
            if(d_select === 'x)begin
                d_select = 7;
            end
            else begin
                
                // Initialize housekeeping variables    (highest = oldest value)
                way_select_d = 0;       // Holds the index of the way with the current oldest LRU way
                invalid_select_d = -1;  // Holds the index of the oldest invalid way (initially impossible value)
                invalid_LRU_d = 0;      // Holds the LRU value of the oldest invalid way (initially most recent LRU value)

                // Loop through the ways to find the highest LRU way and the highest invalid way
                for(int i = 0; i < 8; i++) begin

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
        endcase
    end

    // Update the cache line
    always_comb begin
        // Update the internal cache lines
        internal_d = current_line_d;
        internal_i = current_line_i;

        case(instruction.n)
            // Data cache
            0, 1, 3, 4: begin
                // Send the selected way to the FSM to update the MESI bits
                block_out = current_line_d[d_select];
            
                // Update it with the MESI bits from the FSM
                internal_d[d_select].MESI_bits = block_in.MESI_bits;
                internal_d[d_select].tag = instruction.address.tag;
        
                // Update the LRU if this is a new instruction
                if(instruction !== prev_instruction) begin 
                    if(|data_read_bus) begin 
                        for(int i = 0; i< 8; i++) begin
                            if(internal_d[i].LRU < current_line_d[d_select].LRU) begin
                                internal_d[i].LRU++;
                            end
                        end
                    end
                    
                    // If there are no hits, update the LRU
                    else begin
                        for(int i = 0; i<8; i++) begin
                            internal_d[i].LRU++;
                        end 
                    end
                
                    // Set the LRU of the selected way to 0 only if this is a new instruction
                    internal_d[d_select].LRU = 3'b0;
                end
            end

            // Instruction cache
            2: begin
                // Send the selected way to the FSM to update the MESI bits
                block_out = current_line_i[i_select];

                // Update it with the MESI bits from the FSM
                internal_i[i_select].MESI_bits = block_in.MESI_bits;

                // Update the tag of the selected way
                internal_i[i_select].tag = instruction.address.tag;

                // Check if there are any hits in the instruction cache
                if(current_instruction !== prev_instruction) begin
                    if(|instruction_read_bus) begin 
                        for(int i = 0; i < 4; i++) begin
                            // If the way has a lower LRU value than the selected way, increment the LRU
                            if(internal_i[i].LRU < current_line_i[i_select].LRU) begin
                                internal_i[i].LRU++;
                            end
                        end
                    end
                    // If there are no hits, update the LRU
                    else begin
                        for(int i = 0; i < 4; i++) begin
                            internal_i[i].LRU++;
                        end 
                    end

                    // Set the LRU of the selected way to 0 only if this is a new instruction
                    internal_i[i_select].LRU = 3'b0;
                end
            end

            8, 9: begin
                // Do nothing 
            end
        endcase

        // Return the updated cache line(s)
        return_line_d = internal_d;
        return_line_i = internal_i;
    end       

endmodule