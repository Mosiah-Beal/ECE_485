module processor(
	input  clk,
        input my_struct_package::cache_line_t current_line_i[1][4],
        input my_struct_package::cache_line_t current_line_d[1][8],
	input my_struct_package::command_t instruction,
	input my_struct_package::cache_line_t block_in[1][1],
	output my_struct_package::cache_line_t return_line_i[1][4],
        output my_struct_package::cache_line_t return_line_d[1][8],
        output my_struct_package::cache_line_t block_out[1][1]
	//add cache line output for fsm
);



  // Import the struct package
    import my_struct_package::*;

  // Statistic Variables
    struct {
        int cache_reads =  0;
        int cache_writes = 0;
        int cache_hits = 0;
        int cache_misses = 0;
        int cache_ratio = cache_hits / cache_misses;
    } stats;

    logic [2:0] d_select;
    logic [1:0] i_select;
    int i = 0; 
    int j = 0;
    logic [7:0] data_read_bus;
    logic [3:0] instruction_read_bus;
  
    
always_comb begin : check_hits
	
    
   
    for (i = 0; i < 8; i++) begin
        data_read_bus[i] = 0;    // Assume this cache has no hit        

// check if there is a match in the way, using the set index passed in (updates read_bus)
        if (instruction.address.tag == current_line_d[0][i].tag) begin
            case (instruction.n)  // which instruction is this?
                0: begin // data read
                    data_read_bus[i] = 1;   // if read instruction -> hit;
                    cache_reads++;
                end
                1: begin // data write
                    data_read_bus[i] = 'z;   // if write instruction -> hitM;
                    cache_writes++;
                end
                2: begin // instruction fetch
                    data_read_bus[i] = 1;
                end
                3: begin // L2 invalidate
                    data_read_bus[i] = 'z;   // if hit found on other caches
                    cache_reads++;
                end
                default: begin
                    data_read_bus[i] = '0;   // dont care
                end

            endcase
        end
    end


    for (j = 0; j < 4; j++) begin
        
	instruction_read_bus[j] = 0;    // Assume this cache has no hit

        // check if there is a match in the way, using the set index passed in (updates read_bus)
        if (instruction.address.tag == current_line_i[0][j].tag) begin
            case (instruction.n)  // which instruction is this?
                0: begin // data read
                    instruction_read_bus[j] = 1;   // if read instruction -> hit;
                    cache_reads++;
                end
                1: begin // data write
                    instruction_read_bus[j] = 'z;   // if write instruction -> hitM;
                    cache_writes++;
                end
                2: begin // instruction fetch
                    instruction_read_bus[j] = 1;
                end
                3: begin // L2 invalidate
                    instruction_read_bus[j] = 'z;   // if hit found on other caches
                    cache_writes++;
                end
                default: begin
                    instruction_read_bus[j] = '0;   // dont care
                end
            endcase
        end
    end
end 


always_comb begin
    case(instruction_read_bus) 
        4'b1000: i_select = 2'b00;
        4'b0100: i_select = 2'b01;
        4'b0010: i_select = 2'b10;
        4'b0001: i_select = 2'b11;
        4'bz000: i_select = 2'b00;
        4'b0z00: i_select = 2'b01;
        4'b00z0: i_select = 2'b10;
        4'b000z: i_select = 2'b11;
        default: begin
            // Choose the LRU line if no valid way is found
            for(int i = 0; i < 4; i++) begin
                if(current_line_i[instruction.address.set_index][i].LRU == 0) begin
                  i_select = i;
                  break;
		end
		else
		  i_select = 0;
            end
        end
    endcase
end

// Encode to select column of cache for p0 data cache
always_comb begin
    case(data_read_bus) 
        8'b1000_0000: d_select = 3'b000;
        8'b0100_0000: d_select = 3'b001;
        8'b0010_0000: d_select = 3'b010;
        8'b0001_0000: d_select = 3'b011;
        8'b0000_1000: d_select = 3'b100;
        8'b0000_0100: d_select = 3'b101;
        8'b0000_0010: d_select = 3'b110;
        8'b0000_0001: d_select = 3'b111;
        8'bz000_0000: d_select = 3'b000;
        8'b0z00_0000: d_select = 3'b001;
        8'b00z0_0000: d_select = 3'b010;
        8'b000z_0000: d_select = 3'b011;
        8'b0000_z000: d_select = 3'b100;
        8'b0000_0z00: d_select = 3'b101;
        8'b0000_00z0: d_select = 3'b110;
        8'b0000_000z: d_select = 3'b111;
        default: begin
            // Choose the LRU line if no valid way is found
            for(int i = 0; i < 8; i++) begin
                if(current_line_d[instruction.address.set_index][i].LRU == 0) begin
                    d_select = i;
                    break;
		end
		else
		d_select = 0;
            end
        end
    endcase
end

always_ff@(posedge clk) begin 
$display("time = %t : instruction = %p\n", $time, instruction);
$display("current_line_d = %p\n", current_line_d);


$display("time = %t : instruction = %p\n", $time, instruction);
$display("current_line_i = %p\n", current_line_d);

$display("d_select = %d\n", d_select);
$display("i_select = %d\n", i_select);
            case(instruction.n)
                0, 1: begin
		    $display("Read/Write data cache");
                    block_out[0][0] <= current_line_d[instruction.address.set_index][d_select];
		    block_out[0][0].tag <= instruction.address.tag;
		    return_line_d[instruction.address.set_index][d_select] <= block_in[0][0];
                end
                2: begin
		    $display("Read instruction cache");
                    block_out[0][0] <= current_line_i[instruction.address.set_index][i_select];
		    block_out[0][0].tag <= instruction.address.tag;
	            return_line_i[instruction.address.set_index][i_select] <= block_in[0][0];
		    
                end
                3: begin 
                    block_out[0][0] <= current_line_d[instruction.address.set_index][d_select];
		    block_out[0][0].tag <= instruction.address.tag;
		    return_line_d[instruction.address.set_index][d_select] <= block_in[0][0];
                end
                4: begin
                    block_out[0][0] <= current_line_d[instruction.address.set_index][d_select];
		    block_out[0][0].tag <= instruction.address.tag;
		    return_line_d[instruction.address.set_index][d_select] <= block_in[0][0];                
		end
                8, 9: begin
                    // Do nothing or add specific functionality based on your design
                end
            endcase
 end       

endmodule