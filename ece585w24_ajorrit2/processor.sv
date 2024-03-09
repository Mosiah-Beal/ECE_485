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
    int way_select_i, way_select_d, invalid_select_i, invalid_select_d;
    int invalid_LRU_i, invalid_LRU_d;
    cache_line_t way_line_i, way_line_d;

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
        for (i = 0; i < 8; i++) begin
            data_read_bus[i] = 0;    // Assume this cache has no hit        

            // check if there is a match in the way, using the set index passed in (updates read_bus)
            if (instruction.address.tag == current_line_d[i].tag) begin
                case (instruction.n)  // which instruction is this?
                    0: begin // data read
                        data_read_bus[i] = 1;   // if read instruction -> hit;
                    end
                    1: begin // data write
                        data_read_bus[i] = 'z;   // if write instruction -> hitM;
                    end
                    2: begin // instruction fetch
                        data_read_bus[i] = 1;
                    end
                    3: begin // L2 invalidate
                        data_read_bus[i] = 'z;   // if hit found on other caches
                    end
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
                    0: begin // data read
                        instruction_read_bus[j] = 1;   // if read instruction -> hit;
                    end
                    1: begin // data write
                        instruction_read_bus[j] = 'z;   // if write instruction -> hitM;
                    end
                    2: begin // instruction fetch
                        instruction_read_bus[j] = 1;
                    end
                    3: begin // L2 invalidate
                        instruction_read_bus[j] = 'z;   // if hit found on other caches
                    end
                    default: begin
                        instruction_read_bus[j] = '0;   // dont care
                    end
                endcase
            end
        end
    end 

    // Encode to select column of cache for instruction cache
    always_comb begin
        case(instruction_read_bus) 
            4'b1000, 4'bz000: i_select = 2'b11;
            4'b0100, 4'b0z00: i_select = 2'b10;
            4'b0010, 4'b00z0: i_select = 2'b01;
            4'b0001, 4'b000z: i_select = 2'b00;
            
            default: begin
                if(i_select === 'x)begin
                    i_select = 3;
                end
                else begin
                    // Display the current line
                    // $display("current_line_i = ");
                    // for(int i = 0; i < 4; i++) begin
                    //     $display("%p", current_line_i[i]);
                    // end

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
                        if((way_line_i.MESI_bits == 0) && (way_line_i.LRU > invalid_LRU_i)) begin
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

                    // Display the current line
                    // $display("current_line_d = ");
                    // for(int i = 0; i < 8; i++) begin
                    //     $display("%p", current_line_d[i]);
                    // end
                    
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


    // compare current instruction to previous instruction
    always_ff@(negedge clk) begin: Sequential_Logic
        prev_instruction <= current_instruction;
        current_instruction <= instruction;
    end

    // Update the cache line
    always_comb begin 
        case(instruction.n)
            0, 1: begin // Data read or write
                // Send the selected way to the FSM
                block_out = current_line_d[d_select];
		        block_out.tag = instruction.address.tag;
                
                // Update the internal cache line with a copy of the current line
                internal_d = current_line_d;
		     
		        // Update it with the MESI bits from the FSM
                internal_d[d_select] = block_in;
			
                // Make sure this is a new instruction
		        if(current_instruction !== prev_instruction) begin 
                    // Check if there are any hits in the data cache
                    if(|data_read_bus == 1) begin 
                        for(int i = 0; i < 8; i++) begin
                            if(internal_d[i].LRU < internal_d[d_select].LRU) begin
                                internal_d[i].LRU = internal_d[i].LRU + 1;
                            end
                        end
                    end
                    // If there are no hits, update the LRU
                    else begin
                        for(int i = 0; i<8; i++) begin
                            internal_d[i].LRU = current_line_d[i].LRU +1;
                        end 
                    end
                end
                
                // Update the LRU of the selected way
		        internal_d[d_select].LRU = 3'b0;

                // Send the cache lines back out to the top module
                return_line_d = internal_d;
                return_line_i = current_line_i;
            end

            2: begin    // Instruction fetch
                // Send the selected way to the FSM
                block_out = current_line_i[i_select];
                block_out.tag = instruction.address.tag;

                // Update the internal cache line with a copy of the current line
		        internal_i = current_line_i;   
                    
                // Update it with the MESI bits from the FSM
                internal_i[i_select] = block_in;
                 

                // Make sure this is a new instruction
    		    if(current_instruction !== prev_instruction) begin 
                    // Check if there are any hits in the instruction cache
                    if(|instruction_read_bus == 1) begin 
                        for(int i = 0; i < 4; i++) begin
                            if(internal_i[i].LRU < internal_i[i_select].LRU) begin
                                internal_i[i].LRU = internal_i[i].LRU + 1;
                            end
                        end
                    end
                    // If there are no hits, update the LRU
                    else begin
                        for(int i = 0; i < 4; i++) begin
                            internal_i[i].LRU = current_line_i[i].LRU +1;
                        end 
                    end	
	    	    end

                // Update the LRU of the selected way
                internal_i[i_select].LRU = 3'b0;

                // Send the cache lines back out to the top module
                return_line_i = internal_i;	    
		        return_line_d = current_line_d;
            end

            3: begin    // L2 invalidate
                // Send the selected way to the FSM
                block_out = current_line_d[d_select];
                block_out.tag = instruction.address.tag;
                
                // Update the internal cache line with a copy of the current line
		        internal_d = current_line_d;

                // Update it with the MESI bits from the FSM
                internal_d[d_select]= block_in;
                    

                // Make sure this is a new instruction
                if(current_instruction !== prev_instruction) begin 
                    // Check if there are any hits in the data cache
                    if(|data_read_bus == 1) begin 
                        for(int i = 0; i < 8; i++) begin
                            if(internal_d[i].LRU < internal_d[d_select].LRU) begin
                                internal_d[i].LRU = internal_d[i].LRU + 1;
                            end
                        end
                    end
                    // If there are no hits, update the LRU
                    else begin
                        for(int i = 0; i<8; i++) begin
                            internal_d[i].LRU = current_line_d[i].LRU +1;
                        end 
                    end
                end
                    
                // Update the LRU of the selected way
                internal_d[d_select].LRU = 3'b0;

                // Send the cache lines back out to the top module
                return_line_d = internal_d;
                return_line_i = current_line_i;
            end

            4: begin    // L2 data request
                // Send the selected way to the FSM
                block_out = current_line_d[d_select];
                block_out.tag = instruction.address.tag;

                // Update the internal cache line with a copy of the current line
		        internal_d = current_line_d;

                // Update it with the MESI bits from the FSM
                internal_d[d_select] = block_in;

                // Make sure this is a new instruction
                if(current_instruction !== prev_instruction) begin 
                    // Check if there are any hits in the data cache
                    if(|data_read_bus == 1) begin 
                        for(int i = 0; i < 8; i++) begin
                            if(internal_d[i].LRU < internal_d[d_select].LRU) begin
                                internal_d[i].LRU = internal_d[i].LRU + 1;
                            end
                        end
                    end
                    // If there are no hits, update the LRU
                    else begin
                        for(int i = 0; i<8; i++) begin
                            internal_d[i].LRU = current_line_d[i].LRU +1;
                        end 
                    end
                end

                // Update the LRU of the selected way
                internal_d[d_select].LRU = 3'b0;

                // Send the cache lines back out to the top module
                return_line_d = internal_d;
		        return_line_i = current_line_i;              
            end

            8, 9: begin
                // Do nothing 
            end
        endcase
    end       

endmodule