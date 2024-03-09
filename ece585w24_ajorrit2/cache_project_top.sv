import my_struct_package::*;

// Debugging define
//`define DEBUG

// Mode select defines
`define SILENT 0
`define STATS 1
`define VERBOSE 2

module top;
    // Ports
    logic clk;
    logic rst;
    command_t instruction;
    cache_line_t cache_input_i[4];
    cache_line_t cache_output_i[4];
    cache_line_t cache_input_d[8];
    cache_line_t cache_output_d[8];
    cache_line_t fsm_input_line;
    cache_line_t fsm_output_line;
    
    // Helper variables
    logic mode_select;
    int sum_d;
    int sum_i;
    real hit_sum = 0;
    real miss_sum = 0; 
    int read_sum = 0;
    int write_sum = 0;
    real ratio;
    int instruction_index = 0;

// Parameters
parameter SETS = 16384;
parameter I_WAYS = 4;
parameter D_WAYS = 8;
parameter TIME_DURATION = 5;

parameter TEST_INSTRUCTIONS = 100;
parameter MODE_SILENT = 0;
parameter MODE_STATS = 1;
parameter MODE_VERBOSE = 2;

// Instantiate the data cache with sets = 16384 and ways = 8
cache #(.sets(SETS), .ways(D_WAYS)) data_cache (
        .clk(clk),
        .instruction(instruction),
	    .cache_in(cache_input_d),
        .cache_out(cache_output_d)
    );

 // Instantiate the instruction cache with sets = 16384 and ways = 4
cache #(.sets(SETS), .ways(I_WAYS)) instruction_cache (
        .clk(clk),
        .instruction(instruction),
	    .cache_in(cache_input_i),
        .cache_out(cache_output_i)
    );
processor processor(
        .clk(clk),
        .instruction(instruction),
        .current_line_i(cache_output_i),
        .current_line_d(cache_output_d),
        .return_line_i(cache_input_i),
        .return_line_d(cache_input_d),
        .block_in(fsm_input_line),
        .block_out(fsm_output_line)
        );
mesi_fsm fsm(
        .clk(clk), 
        .rst(rst), 
        .instruction(instruction),
        .internal_line(fsm_output_line), 
        .return_line(fsm_input_line)
        );


// Define an array of instructions: n = 4 bits, address = 32 bits; 4+32 = 36 bits
logic [35:0] instructions [TEST_INSTRUCTIONS];
initial begin
    instructions[0] = {4'd8, 32'b0};         // reset
    instructions[1] = {35'b0};                  // read data
    instructions[2] = {4'd0,32'h984DE132};      // read data
    instructions[3] = {4'd0,32'h116DE12F};      // read data
    instructions[4] = {4'd0,32'h100DE130};      // read data
    instructions[5] = {4'd0,32'h999DE12E};      // read data
    instructions[6] = {4'd0,32'h645DE10A};      // read data
    instructions[7] = {4'd0,32'h846DE107};      // read data
    instructions[8] = {4'd0,32'h211DE128};      // read data
    instructions[9] = {4'd0,32'h777DE133};      // read data
    instructions[10] = {4'd9,32'h777DE133};     // print stats
    instructions[11] = {4'd0,32'h846DE107};     // read data
    instructions[12] = {4'd0,32'h846DE107};     // read data
    instructions[13] = {4'd0,32'h846DE107};     // read data
    instructions[14] = {4'd9,32'h777DE133};     // print stats
    instructions[15] = {4'd2,32'h846DE107};     // read instruction
    instructions[16] = {4'd2,32'h984DE132};     // read instruction
    instructions[17] = {4'd2,32'h116DE12F};     // read instruction
    instructions[18] = {4'd2,32'h100DE130};     // read instruction
    instructions[19] = {4'd2,32'h999DE12E};     // read instruction
    instructions[20] = {4'd2,32'h645DE10A};     // read instruction
    instructions[21] = {4'd2,32'h846DE107};     // read instruction

end

// Check if the MODE argument is provided
initial begin
    // Check if MODE argument is provided
    if ($test$plusargs("MODE=VERBOSE")) begin
        mode_select = MODE_VERBOSE;
    end 
    else if ($test$plusargs("MODE=STATS")) begin
        mode_select = MODE_STATS;     
    end
    else begin
        mode_select = MODE_SILENT;
    end
    $display("Mode = %d", mode_select);
end

 
// Clock generation
// Reads occur on the positive edge of the clock
// Writes occur on the negative edge of the clock
always #TIME_DURATION clk = ~clk;


// Set initial values
initial begin
    // Initialize the caches
    clk = 0;    // Start with a low clock (write mode)
    rst = 1;    // Initialize the reset signal
    instruction = {4'd8,32'b0,3'b0,2'b0};    // Send a reset instruction
 
    // Give a clock pulse to propogate the initial values
    #TIME_DURATION; // Clock will be 1 after this (read mode)

    // End reset
    rst = 0;

    #TIME_DURATION; // Clock will be 0 after this (write mode)
    #TIME_DURATION; // Clock will be 1 after this (read mode)

    // Stop the simulation so the mode can be selected
    $stop;
end

// Feed instructions to the processor on the negative edge of the clock
always @(negedge clk) begin
    // Send instructions once we leave silent mode)
    if (mode_select != MODE_SILENT) begin
        // Check if there are no more instructions left
        if($isunknown(instructions[instruction_index])) begin
            $display("Invalid / last instruction reached.");
            $stop;
            // See if we need to reset the index? (future work)
        end
        else begin
            // Send the instruction to the processor
            instruction = instructions[instruction_index++];
            // $display("Time = %t : Instruction = %p", $time, instruction);
        end   
    end
end

// Check if we are changing the mode
always @(mode_select) begin
    // Check if we are in silent mode
    if(mode_select == MODE_SILENT) begin
        $display("Mode = SILENT");
        // Reset the instruction index
        instruction_index = 0;
    end
    else if(mode_select == MODE_STATS) begin
        $display("Mode = STATS");
    end
    else if(mode_select == MODE_VERBOSE) begin
        $display("Mode = VERBOSE");
    end
end

// Whenever the instruction changes
always @(instruction) begin
   
   // Check if we are in silent mode
    if(mode_select >= MODE_STATS) begin
            
        // Hit and miss statistics
        case(instruction.n)
            // Check if there were any hits on the data cache
            0,1,3,4: begin

                if(|processor.data_read_bus)begin
                    hit_sum += 1;
                end
                else begin
                    // Increment the miss counter
                    miss_sum += 1;

                    // Check if we need to print the address
                    if (mode_select == MODE_VERBOSE) begin
                        $display("Read from L2 <%h> (data)", instruction.address);
                    end
                end
            end

            // Check if there were any hits on the instruction cache
            2: begin
                if(|processor.instruction_read_bus) begin
                    hit_sum += 1;
                end
                else begin
                    // Increment the miss counter
                    miss_sum += 1;

                    // Check if we need to print the address
                    if (mode_select == MODE_VERBOSE) begin
                        $display("Read from L2 <%h> (instruction)", instruction.address);
                    end
                end
            end

            8: begin
                // Reset the statistics
                hit_sum = 0;
                miss_sum = 0;
                read_sum = 0;
                write_sum = 0;
                ratio = 0;
            end

            9: begin
                `ifdef DEBUG
                    // Print the statistics
                    $display("read_sum = %d", read_sum);
                    $display("write_sum = %d", write_sum);
                    $display("miss_sum = %d", miss_sum);
                    $display("hit_sum = %d", hit_sum);
                    $display("ratio = %f", ratio);
                `endif
            end

            default: begin
                // Invalid instruction
                // $display("Invalid instruction.");
            end
        endcase

        // Read and write statistics
        case(instruction.n) 

            0,2,4: read_sum += 1;
            1,3:   write_sum += 1;
            
            default: begin
                //do nothing
            end
        endcase

        // Calculate the hit ratio
        if(hit_sum + miss_sum != 0) begin
            ratio = (hit_sum/hit_sum + miss_sum);
        end

        // If we are in verbose mode, also print the statistics on each instruction
        if (mode_select >= MODE_VERBOSE) begin
            $display("read_sum = %d", read_sum);
            $display("write_sum = %d", write_sum);
            $display("miss_sum = %d", miss_sum);
            $display("hit_sum = %d", hit_sum);
            $display("ratio = %f", ratio);
        end

        // Now check if we need to print the transition
        if (mode_select >= MODE_VERBOSE) begin
            $display("Transitioning from %p to %p", fsm.internal_line.MESI_bits, fsm.nextstate);
            
            case(fsm.internal_line.MESI_bits)
                // Current state is M
                M: begin
                    case(fsm.nextstate)
                        // Next state is M
                        M: begin
                            $display("Write to L2 <%h>",instruction.address);
                        end
                        
                        // Next state is I
                        I: begin 
                            if(instruction.n == 4) begin
                            $display("Return data to L2 <%h>", instruction.address);			
                            end
                            else begin
                            $display("Write to L2 <%h>", instruction.address);
                            end
                        end

                        // Next state is S
                        // Next state is E

                        // Invalid states
                        default: begin
                        // do nothing
                        end
                    endcase
                end 
                
                // Current state is E
                // Current state is S
                // Current state is I

                // Invalid states
                default: begin
                // do nothing
                end
            endcase
        end
    end

    // Check if the LRU bits are unique
    `ifdef DEBUG
        // Display the time, instruction, and cache line LRU bits
        $display("Time = %t", $time);
        $display("\tInstruction = %p", instruction);
        $display("\tCache Line LRU (instruction) = %p %p %p %p", cache_input_i[0].LRU, cache_input_i[1].LRU, cache_input_i[2].LRU, cache_input_i[3].LRU);
        $display("\tCache Line LRU (data) = %p %p %p %p %p %p %p %p", cache_input_d[0].LRU, cache_input_d[1].LRU, cache_input_d[2].LRU, cache_input_d[3].LRU, cache_input_d[4].LRU, cache_input_d[5].LRU, cache_input_d[6].LRU, cache_input_d[7].LRU);
    `endif

    // Check for duplicate LRU bits by summing them
    sum_i = int'(cache_input_i[0].LRU) + int'(cache_input_i[1].LRU) + int'(cache_input_i[2].LRU) + int'(cache_input_i[3].LRU);
    sum_d = int'(cache_input_d[0].LRU) + int'(cache_input_d[1].LRU) + int'(cache_input_d[2].LRU) + int'(cache_input_d[3].LRU) + int'(cache_input_d[4].LRU) + int'(cache_input_d[5].LRU) + int'(cache_input_d[6].LRU) + int'(cache_input_d[7].LRU);

    // Check if we need to display the sum
    `ifdef DEBUG
        $display("\tSum (instruction) = %d", sum_i);
        $display("\tSum (data) = %d", sum_d);
    `endif

    // Check if the sum is not equal to the expected value
    if (sum_i != 6) begin
        $display("PROBLEM (top): %0t Duplicate LRU bits found in instruction cache.", $time);
    end
    if (sum_d != 28) begin
        $display("PROBLEM (top): %0t Duplicate LRU bits found in data cache.", $time);
    end

end


endmodule