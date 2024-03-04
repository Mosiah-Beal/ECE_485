// Import the struct package
import my_struct_package::*;

module processor(
    /* Signal ports
    * top: clk, instruction, current_line, return_line
    * count: count
    * FSM: block_in, block_out
    */

    input  clk,
    input  command_t instruction,
    input  logic [2:0] count,
    input  cache_line_t current_line_i[4],
    input  cache_line_t current_line_d[8],
    input  cache_line_t block_in,
    output cache_line_t return_line_i[4],
    output cache_line_t return_line_d[8],
    output cache_line_t block_out
    
);
    // way select
    logic [2:0] d_select;
    logic [1:0] i_select;

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
                $display("current_line_i = ");
                for(int i = 0; i < 4; i++) begin
                    $display("%p\n", current_line_d[i]);
                end

                for(int i = 3; i>=0; i--) begin
            
                    if(current_line_i[i].LRU == 3)begin
                        i_select = i;
                    break;
                    end
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
            if(d_select === 'x)begin
                d_select = 7;
            end
            else begin
                $display("current_line_d = %p\n", current_line_d);
                for(int i = 7; i>=0; i--) begin
            
                    if(current_line_d[i].LRU == 7)begin
                        d_select = i;
                        break;
                    end

                end
            end
        end 
        endcase
    end


    // Update the cache line
    always_comb begin 
        // Display selected ways
        $display("d_select = %d", d_select);
        $display("i_select = %d\n", i_select);

        // Display the hit buses
 	    $display("d_bus = %b", data_read_bus);
        $display("i_bus = %b\n", instruction_read_bus);


        case(instruction.n)
            0, 1: begin
                $display("Read/Write data cache");
                block_out = current_line_d[d_select];
                block_out.tag = instruction.address.tag; 
		        internal_d = current_line_d;
                
                // Check if there are any hits in the data cache
                if(|data_read_bus == 1) begin 
                    for(int i = 0; i< d_select; i++) begin
                        internal_d[i].LRU = current_line_d[i].LRU +1;
                    end
                end
                // If there are no hits, update the LRU
		        else begin
			        for(int i = 0; i<8; i++) begin
				        internal_d[i].LRU = current_line_d[i].LRU +1;
			        end 
		        end
		        
                internal_d[d_select] = block_in;
		        internal_d[d_select].LRU = 3'b0;
                return_line_d = internal_d;
                
                end
            2: begin
                $display("Read instruction cache");
                block_out = current_line_i[i_select];
                block_out.tag = instruction.address.tag;
                internal_i = current_line_i;

                // Check if there are any hits in the instruction cache
                if(|instruction_read_bus == 1) begin 
                    for(int i = 0; i< i_select; i++) begin
                        internal_i[i].LRU = current_line_i[i].LRU +1;
                    end
                end
                // If there are no hits, update the LRU
                else begin
                    for(int i = 0; i<4; i++) begin
                        internal_i[i].LRU = current_line_i[i].LRU +1;
                    end 
                end

                internal_i[i_select] = block_in;
                internal_i[i_select].LRU = 3'b0;
                return_line_i = internal_i;	    

                end
            3: begin 
                block_out = current_line_d[d_select];
                block_out.tag = instruction.address.tag;
                internal_d = current_line_d;

                // Check if there are any hits in the data cache
                if(|data_read_bus == 1) begin 
                    for(int i = 0; i< d_select; i++) begin
                        internal_d[i].LRU = current_line_d[i].LRU +1;
                    end
                end
                // If there are no hits, update the LRU
                else begin
                    for(int i = 0; i<8; i++) begin
                        internal_d[i].LRU = current_line_d[i].LRU +1;
                    end 
                end

                internal_d[d_select] = block_in;
                internal_d[d_select].LRU = 3'b0;
                return_line_d = internal_d;

                end
            4: begin
                block_out = current_line_d[d_select];
                block_out.tag = instruction.address.tag;
                internal_d = current_line_d;

                // Check if there are any hits in the data cache
                if(|data_read_bus == 1) begin 
                    for(int i = 0; i< d_select; i++) begin
                        internal_d[i].LRU = current_line_d[i].LRU +1;
                    end
                end
                // If there are no hits, update the LRU
                else begin
                    for(int i = 0; i<8; i++) begin
                        internal_d[i].LRU = current_line_d[i].LRU +1;
                    end 
                end

                internal_d[d_select] = block_in;
                internal_d[d_select].LRU = 3'b0;
                return_line_d = internal_d;              

                end
            8, 9: begin
                // Do nothing 
                end
        endcase
    end       

endmodule