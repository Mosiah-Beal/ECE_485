
import my_struct_package::*;

// Debugging define
//`define DEBUG

`define TRAILING_ZEROS


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

    // Parameters
    parameter SETS = 16384;
    parameter I_WAYS = 4;
    parameter D_WAYS = 8;
    parameter TIME_DURATION = 5;

    parameter TEST_INSTRUCTIONS = 100;
    parameter MODE_SILENT = 0;
    parameter MODE_STATS = 1;
    parameter MODE_VERBOSE = 2;
    
    // Helper variables
    int instruction_index = 0;
    logic [2:0] mode_select;
    int sum_d;
    int sum_i;
    static int i_safe = 1; // Assume the instruction cache is safe
    static int d_safe = 1; // Assume the data cache is safe
    
    // Flags for the processor (evict/writeback/writethrough)
    int num_evicts_d = 0;
    int num_evicts_i = 0;
    int num_writethroughs_d = 0;
    int num_writethroughs_i = 0;
    int num_writebacks_d = 0;
    int num_writebacks_i = 0;


    // Statistics
    static real hit_sum = 0;    // Number of hits
    static real miss_sum = 0;   // Number of misses
    static real ratio;          // Hit ratio
    static int read_sum = 0;    // Number of reads
    static int write_sum = 0;   // Number of writes
    static int total_sum = 0;   // Total number of reads and writes
    
    

// Define an array of instructions: n = 4 bits, address = 32 bits; 4+32 = 36 bits
command_t instructions [TEST_INSTRUCTIONS];

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

// Takes a line of text and returns a string with only the first 9 valid hex characters (pads address with 0s if necessary)
function automatic string find(ref string a);
    int len_a= a.len();
    int missing;    // number of missing characters
    string s;       // substring for valid hex characters
    string v;       // string to store valid hex characters
    string r;       // string to store the first 9 valid hex characters (will be returned)

    // Strip the string of all non-hex characters
    for(int i = 0; i < len_a; i++) begin

        // Get the current character
        s = a.substr(i,i);
        case(s)
            "0","1","2","3","4","5","6","7",
            "8","9","A","B","C","D","E","F",
            "a","b","c","d","e","f": begin
                // Add the valid hex character to the string
                v = {v,s};
            end
            default: begin
                // $display("WARNING(string_parsing): Removing invalid character (%s) from the line", s);
                continue;
            end
        endcase 
        //$display("s = %s", s);
        //$display("v = %s", v);
    end

    // Check if there are no valid hex characters
    if(v.len() == 0) begin
        // $display("WARNING: No valid hex characters found in the line, skipping");
        // $display("line = %s", a);
        r = "skip";
        return r;
    end

    // Check if the instruction is valid (0, 1, 2, 3, 4, 8, 9)
    case(v.substr(0,0))
        "0","1","2","3","4","8","9": begin
            // Do nothing
        end
        default: begin
            $display("WARNING: Invalid instruction found in the line, skipping");
            $display("Extracted line = %s", v);
            r = "skip";
            return r;
        end
    endcase

    // Check if the string is less than 9 characters (instruction is present)
    if(v.len() < 9) begin
        $display("WARNING: line is %d characters long", v.len());
        $display("v = %s", v);

        // Trailing zeros
        `ifdef TRAILING_ZEROS
            // Add the entire string to the result
            r = v;

            // Calculate the number of missing characters
            missing = 8 - (v.len()-1);

            // Now add the trailing zeros
            for(int i = 0; i < missing; i++) begin
                r = {r,"0"};
            end
        // Leading zeros (on the address only) [default]
        `else
            // Add the instruction (first character) to the string
            r = {r,v.substr(0,0)};

            // Calculate the number of missing characters
            missing = 8 - (v.len()-1);
            // $display("missing = %d", missing);

            // For the remaining 8 characters needed, pad the string with 0s in front of the address
            for(int i = 0; i < missing; i++) begin
                r = {r,"0"};
            end

            // Now add the rest of the string (the address) 
            r = {r,v.substr(1,v.len()-1)};

            // one line version
            //r = {v.substr(0,0), {8-v.len(){'0'}}, v.substr(1,v.len()-1)};
        
        `endif
        
        // Display the result
        $display("WARNING: Padded address = %s", r);
    end
    else begin
        // Take the first 9 characters
        r = v.substr(0,8);
    end

    // $display("Extracted hex characters = %s", r);
	return r;  
	
endfunction   


function automatic void trace_in(ref command_t instructions[TEST_INSTRUCTIONS]);
    string file;
    int fp = 0;
    int status = 0;
    string line;
    command_t hex_value = 36'b0;
    int i = 0;

    // Check if the FILENAME argument is provided
    if (!$value$plusargs("FILENAME=%s", file)) begin
        file = "trace.txt";
        $display("WARNING: Using Default Trace settings.");
    end 

    // Try to open the file
    fp = $fopen(file, "r");

    // Check if the file was opened successfully
    if (!fp) begin
        $display("FILE READ ERROR");
        $stop;
    end

    // Insert a reset instruction at the beginning of the array
    instructions[i++] = {4'd8,32'b0};

    // Read the file line by line
    while (!$feof(fp)) begin
        // Read a line from the file
        $fgets(line, fp);
        // $display("Got line: %s",line);
        
        // Clean the line
        line = find(line);

        // Check if the line is invalid
        if(line == "skip") begin
            continue;
        end

        
        // Convert the clean line to hex_value
        status = $sscanf(line, "%h", hex_value);

        // how many items were successfully read
        // $display("status = %p\n", status);

        // Display hex_value for debugging
        // $display("%p", hex_value);
        // $display("Cleaned line: %s",line);

        // Check if i exceeds the array size
        if (i >= TEST_INSTRUCTIONS) begin
            $display("SEGMENTATION FAULT");
            break; // Exit the loop
        end

        // Store hex_value in instructions array
        instructions[i++] = hex_value;
    end

    $fclose(fp); // Close the file after processing
endfunction



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
end

 
// Clock generation
// Reads occur on the positive edge of the clock
// Writes occur on the negative edge of the clock
always #TIME_DURATION clk = ~clk;


// Set initial values
initial begin
    // Initialize the caches
    clk = 0;    // Start with a low clock (write mode)
    instruction = {4'd8,32'b0,3'b0,2'b0};    // Send a reset instruction
    trace_in(instructions);
    
    // Allow FSM to initialize
    rst = 1;
    #TIME_DURATION;
    rst = 0;

    $stop;
end


// Feed instructions to the processor on the negative edge of the clock
always @(negedge clk) begin
    
    // Send instructions once we leave silent mode)
    if (mode_select > MODE_SILENT) begin
        // Check if there are no more instructions left
        if($isunknown(instructions[instruction_index])) begin
	        $display("");
            $display("Invalid / last instruction reached.");
	        $display("read_sum = %d", read_sum);
            $display("write_sum = %d", write_sum);
            $display("miss_sum = %d", miss_sum);
            $display("hit_sum = %d", hit_sum);
            $display("ratio = %f", ratio);
            $display("");

            
            // Go back to silent mode
            instruction_index = 0;
            mode_select = MODE_SILENT;
            
            // Stop the simulation
            $stop;
        end
        else begin
            // Send the instruction to the processor
            instruction = instructions[instruction_index++];
            //$display("Time = %t : Instruction = %p", $time, instruction);

        end   
    end

    // Silent mode
    else begin
        // Do nothing
    end
end

// Check if we are changing the mode
//force -deposit /top/mode_select 1 0
//run -all
always @(mode_select) begin
    // Reset the instruction index
    instruction_index = 0;
    // Send a reset instruction
    instruction = {4'd8,32'b0,3'b0,2'b0};

    // Check if we are in silent mode
    if(mode_select == MODE_SILENT) begin
        $display("Mode = SILENT");    
    end
    else if(mode_select == MODE_STATS) begin
        $display("Mode = STATS");
    end
    else if(mode_select == MODE_VERBOSE) begin
        $display("Mode = VERBOSE");
    end

end

// Whenever the instruction changes
always @(posedge clk) begin

    // Check if have something to do
    if(mode_select >= MODE_STATS) begin
            
        // Read and write statistics
        case(instruction.n) 

            0,2,4: read_sum += 1;
            1,3:   write_sum += 1;
            
            // Other values do not affect the write/read ratio
            default: begin
                //do nothing
            end
        endcase

        // Hit and miss statistics
        case(instruction.n)
            // Check if there were any hits on the data cache
            0,1,3,4: begin
                if(|processor.data_read_bus)begin
                    // Increment the hit counter and recalculate the ratio
                    hit_sum ++;
                    ratio = hit_sum/(hit_sum + miss_sum);
                end
                else begin
                    // Increment the miss counter and recalculate the ratio
                    miss_sum += 1;
                    ratio = hit_sum/(hit_sum + miss_sum);

                    // Check if we need to print the address
                    if (mode_select == MODE_VERBOSE) begin
                        $display("Read from L2 <%h> (data)", instruction.address);
                    end
                end
            end

            // Check if there were any hits on the instruction cache
            2: begin
                if(|processor.instruction_read_bus) begin
                    // Increment the hit counter and recalculate the ratio
                    hit_sum++;
                    ratio = hit_sum/(hit_sum + miss_sum);
                end
                else begin
                    // Increment the miss counter and recalculate the ratio
                    miss_sum += 1;
                    ratio = hit_sum/(hit_sum + miss_sum);

                    // Check if we need to print the address
                    if (mode_select == MODE_VERBOSE) begin
                        $display("Read from L2 <%h> (instruction)", instruction.address);
                    end
                end
            end

            // Other values do not affect the hit/miss ratio
            default: begin
                // Do nothing
            end
        endcase

        // Check if we need to print the statistics
        case(instruction.n)
            8: begin
                // Reset the statistics
                hit_sum = 0;
                miss_sum = 0;
                read_sum = 0;
                write_sum = 0;
                ratio = 0;
            end

            9: begin
                // Print the statistics
		        $display("time = %0t", $time);
                for(int i = 0; i < I_WAYS; i++) begin
                    $display("Instruction Cache[%h] = %p", instruction.address.set_index, instruction_cache.cache[instruction.address.set_index][i]);
                end

                $display("");

                for(int i = 0; i < D_WAYS; i++) begin
                    $display("Data Cache[%h] = %p", instruction.address.set_index, data_cache.cache[instruction.address.set_index][i]);
                end
                
                // $display("Time = %0t: \t\tInput Cache Line[%h] = %p", $time, instruction.address.set_index, data_cache.cache[instruction.address.set_index][i]);
                // $display("Time = %0t: \t\tInput Cache Line[%h] = %p", $time, instruction.address.set_index, instruction_cache.cache[instruction.address.set_index][i]);
                $display("read_sum =  %0d", read_sum);
                $display("write_sum = %0d", write_sum);
                $display("miss_sum =  %0d", miss_sum);
                $display("hit_sum =   %0d", hit_sum);
                $display("ratio =     %0f", ratio);
                $display("");
            end

            default: begin
                // If we are in verbose mode, also print the statistics every instruction
                if (mode_select >= MODE_VERBOSE) begin
                    $display("Verbose mode: time = %0t", $time);
                    $display("read_sum = %d", read_sum);
                    $display("write_sum = %d", write_sum);
                    $display("miss_sum = %d", miss_sum);
                    $display("hit_sum = %d", hit_sum);
                    $display("ratio = %f", ratio);
                    $display("");
                end
            end
        endcase

        // Now check if we need to print the transition
        if (mode_select >= MODE_VERBOSE) begin
            $display("Transitioning from %p to %p : time = %0t", fsm.internal_line.MESI_bits, fsm.nextstate,$time);
            
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
                
                E: begin
		        end

                S: begin
                end

                I: begin
                    case(fsm.nextstate)
                        M: begin
                            $display("Read for Ownership from L2 <%h>", instruction.address);	
                        end 	
                        
                        E: begin
                            $display("Read from L2 <%h>", instruction.address);
                        end
                    endcase
                end 

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
    case(instruction.n)
        // Ignore on Reset/Initialize
        'x, 8: begin
            // Do nothing
        end

        // Otherwise, check the LRU values
        default: begin

            // Check if the caches are safe
            i_safe = 1; // Assume the instruction cache is safe
            d_safe = 1; // Assume the data cache is safe

            // Check that the instruction cache is not in an invalid state
            for(int i = 0; i < I_WAYS; i++) begin
                if (|cache_output_i[i] === 'x) begin
                    // $display("WARNING (top): at time %0t Instruction cache is in an invalid state.", $time);
                    i_safe = 0; // The instruction cache is not safe
                end
            end

            // Check that the data cache is not in an invalid state
            for(int i = 0; i < D_WAYS; i++) begin
                if (|cache_output_d[i] === 'x) begin
                    // $display("WARNING (top): at time %0t Data cache is in an invalid state.", $time);
                    d_safe = 0; // The data cache is not safe
                end
            end


            // Check if the instruction cache has duplicate LRU bits (and isn't in an invalid state)
            if ((sum_i != 6) && (i_safe == 1)) begin
                $display("WARNING (top): at time %0t Duplicate LRU bits found in instruction cache.", $time);
                // Nice formatting
                if((sum_d == 28) || (d_safe == 0)) begin
                    $display("");   // Add a new line since this is the last warning
                end
            end

            // Check if the data cache has duplicate LRU bits (and isn't in an invalid state)
            if ((sum_d != 28) && (d_safe == 1)) begin
                $display("WARNING (top): at time %0t Duplicate LRU bits found in data cache.\n", $time);
            end
        end
    endcase

end

// Check for special flags
always_ff @(posedge clk) begin
    // Check the data cache for new evicts
    if (processor.evict_d > num_evicts_d) begin
        
        $display("WARNING (top): at time %0t Data cache is evicting a line.", $time);
        $display("\tEvicted line = %p", processor.internal_d[processor.d_select]);
        
        // The first 8 lines are writethrough, the rest are writeback
        if(++num_evicts_d <= D_WAYS) begin
            num_writethroughs_d++;
            // Display what line was written to L2
            $display("Writethrough[%0d]d to L2 <%h>", num_writethroughs_d, processor.internal_d[processor.d_select].tag);
        end
        else begin
            num_writebacks_d++;
            // Display what line was written to L2
            $display("Writeback[%0d]d to L2 <%h>", num_writebacks_d, processor.internal_d[processor.d_select].tag);
        end
    end

    // Check the instruction cache for evicts (first 4 are writethrough)
    if(processor.evict_i > num_evicts_i) begin

        $display("WARNING (top): at time %0t Instruction cache is evicting a line.", $time);
        $display("\tEvicted line = %p", processor.internal_i[processor.i_select]);

        // The first 4 lines are writethrough, the rest are writeback
        if(++num_evicts_i <= I_WAYS) begin
            num_writethroughs_i++;
            // Display what line was written to L2
            $display("Writethrough[%0d]i to L2 <%h>", num_writethroughs_i, processor.internal_i[processor.i_select].tag);
        end
        else begin
            num_writebacks_i++;
            // Display what line was written to L2
            $display("Writeback[%0d]i to L2 <%h>", num_writebacks_i, processor.internal_i[processor.i_select].tag);

        end
    end

end


endmodule

