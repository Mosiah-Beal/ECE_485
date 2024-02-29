// Import the struct package
import my_struct_package::*;

module processor(
    input  clk,
    input  cache_line_t current_line_i[4],
    input  cache_line_t current_line_d[8],
    input  command_t instruction,
    input  cache_line_t block_in,
    output cache_line_t return_line_i[4],
    output cache_line_t return_line_d[8],
    output cache_line_t block_out
    //add cache line output for fsm
);

    logic [2:0] d_select;
    logic [1:0] i_select;
    int i = 0; 
    int j = 0;
    logic [7:0] data_read_bus;
    logic [3:0] instruction_read_bus;
    cache_line_t dummy_d[8];
    cache_line_t dummy_i[4];

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
            // Choose the LRU line if no valid way is found
            automatic int way_select_i = 0; // default to way 0, keeps track of lowest LRU way
            automatic int invalid_select_i = -1; // default to impossible value, keeps track of lowest invalid way (Invalid = 2'b00)
            cache_line_t way_line_i;
            // choose the lowest LRU way, unless there are 1+ invalid ways, then choose the lowest invalid way
            for(int i = 0; i < 4; i++) begin
                way_line_i = current_line_i[i];
                // update way_select if the current way has a lower LRU value
                if(way_line_i.LRU < current_line_i[way_select_i].LRU) begin
                    way_select_i = i;
                end
                
                // update invalid_select if the current way is invalid and has a lower LRU value
                if(way_line_i.MESI_bits == 0 && way_line_i.LRU < current_line_i[invalid_select_i].LRU) begin
                    invalid_select_i = i;
                end

                // if the invalid_select is still the impossible value, use the way_select
                if(invalid_select_i == -1) begin
                    i_select = way_select_i;
                end
                // otherwise, use the invalid_select
                else begin
                    i_select = invalid_select_i;
                end
            end
        end
        endcase
    end

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
            // Choose the LRU line if no valid way is found
            automatic int way_select_d = 0; // default to way 0, keeps track of lowest LRU way
            automatic int invalid_select_d = -1; // default to impossible value, keeps track of lowest invalid way (Invalid = 2'b00)
            cache_line_t way_line_d;
            // choose the lowest LRU way, unless there are 1+ invalid ways, then choose the lowest invalid way
            for(int i = 0; i < 8; i++) begin
                way_line_d = current_line_i[i];
                // update way_select if the current way has a lower LRU value
                if(way_line_d.LRU < current_line_i[way_select_d].LRU) begin
                    way_select_d = i;
                end
                // update invalid_select if the current way is invalid and has a lower LRU value
                if(way_line_d.MESI_bits == 0 && way_line_d.LRU < current_line_i[invalid_select_d].LRU) begin
                    invalid_select_d = i;
                end

                // if the invalid_select is still the impossible value, use the way_select
                if(invalid_select_d == -1) begin
                    d_select = way_select_d;
                end
                // otherwise, use the invalid_select
                else begin
                    d_select = invalid_select_d;
                end
            end
            end
        endcase
    end

    // Update the cache line
    always_comb begin 
        $display("d_select = %d\n", d_select);
        $display("i_select = %d\n", i_select);

        $display(" current_line_i.tag = %h\t : current_line_i.LRU = %h \t current_line_i.MESI_bits = %h\t : current_line_i.data = %h\n", current_line_i[i_select].tag,current_line_i[i_select].LRU,current_line_i[i_select].MESI_bits,current_line_i[i_select].data); 
        $display(" return_line_i.tag = %h \t : return_line_i.LRU = %h \t return_line_i.MESI_bits = %h\t : return_line_i.data = %h\n", return_line_i[i_select].tag,return_line_i[i_select].LRU,return_line_i[i_select].MESI_bits,return_line_i[i_select].data);

        $display(" current_line_d.tag = %h\t : current_line_d.LRU = %h \t current_line_d.MESI_bits = %h\t : current_line_d.data = %h\n", current_line_d[d_select].tag,current_line_d[d_select].LRU,current_line_d[d_select].MESI_bits,current_line_d[d_select].data); 
        $display(" return_line_d.tag = %h \t : return_line_d.LRU = %h \t return_line_d.MESI_bits = %h\t : return_line_d.data = %h\n", return_line_d[d_select].tag,return_line_d[d_select].LRU,return_line_d[d_select].MESI_bits,return_line_d[d_select].data);

        case(instruction.n)
            0, 1: begin
                $display("Read/Write data cache");
                block_out = current_line_d[d_select];
                block_out.tag = instruction.address.tag;

		dummy_d = current_line_d;
		dummy_d[d_select] = block_in;
                return_line_d = dummy_d;
                end
            2: begin
                $display("Read instruction cache");
                block_out = current_line_i[i_select];
                block_out.tag = instruction.address.tag;
                return_line_i[i_select] = block_in;	    
                end
            3: begin 
                block_out = current_line_d[d_select];
                block_out.tag = instruction.address.tag;
                return_line_d[d_select] = block_in;
                end
            4: begin
                block_out = current_line_d[d_select];
                block_out.tag = instruction.address.tag;
                return_line_d[d_select] = block_in;                
                end
            8, 9: begin
                // Do nothing or add specific functionality based on your design
                end
        endcase
    end       

endmodule