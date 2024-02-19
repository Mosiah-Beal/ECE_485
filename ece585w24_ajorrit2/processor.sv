module processor(
	input  clk,
	input  my_struct_package::command_t instruction,
	output my_struct_package::cache_line_t current_line_i[1][4],
        output my_struct_package::cache_line_t current_line_d[1][8],
	output [11:0] p_bus
	//add cache line output for fsm
);

  // Import the struct package
    import my_struct_package::*;

    address_t desired_address;
    int i = 0; 
    int j = 0;
    logic [7:0] data_read_bus;
    logic [3:0] instruction_read_bus;
    logic [11:0] bus;	
    
   // Instantiate the data cache with sets = 16384 and ways = 8
    cache #(.sets(16384), .ways(8)) data_cache (
        .clk(clk),
        .instruction(instruction),
        .cache_out(current_line_d)
    );

    // Instantiate the instruction cache with sets = 16384 and ways = 4
    cache #(.sets(16384), .ways(4)) instruction_cache (
        .clk(clk),
        .instruction(instruction),
        .cache_out(current_line_i)
    );
    
always_comb begin : check_hits
	

    desired_address = instruction.address;   // get the address we are looking for
    
    //NEEDS TO MAKE OWNER CACHE AN X OUTPUT
    for (i = 0; i < 8; i++) begin
        data_read_bus[i] = 0;    // Assume this cache has no hit

        // check if there is a match in the way, using the set index passed in (updates read_bus)
        if (desired_address.tag == current_line_d[0][i]) begin
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
                    data_read_bus[i] = 'x;   // dont care
                end

            endcase
        end
    end

    //! higher level repeat for all caches !!! not done!!!!
    //NEEDS TO MAKE OWNER CACHE AN X OUTPUT

    for (j = 0; j < 4; j++) begin
        
	instruction_read_bus[j] = 0;    // Assume this cache has no hit

        // check if there is a match in the way, using the set index passed in (updates read_bus)
        if (desired_address.tag == current_line_i[0][j]) begin
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
                    instruction_read_bus[j] = 'x;   // dont care
                end
            endcase
        end
    end
end 

always_ff@(posedge clk) begin

bus <= {instruction_read_bus, data_read_bus}; // Continuous assignment

end

assign p_bus = bus;

endmodule