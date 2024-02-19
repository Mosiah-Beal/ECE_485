// 

// Define the hit bus, which is a 36-bit vector that contains the hits for the ways of the instruction and data caches for each processor.
typedef enum logic [35:0] {
    // Concatenated hit bus of p1:p2:p3
    // Each processor is 12 bits, with 4 bits for instruction and 8 bits for data

    p1d = [7:0],    // processor 1 data
    p1i = [11:8],   // processor 1 instruction
    p2d = [19:12],  // processor 2 data
    p2i = [23:20],  // processor 2 instruction
    p3d = [31:24],  // processor 3 data
    p3i = [35:32],  // processor 3 instruction
    
} hitbus_t; 

// Takes a command, a hit bus, 
module mesi_controller(
    input hitbus_t hit_bus // hit bus from all processors
    
    input command_t instruction    // instruction, address, PID, 

    input cache_line_t cache  // placeholder for registered cache lines to FSM
    )
    

    hitbus_t int_hitbus; // internal hit bus
    cache_line_t current_cache; // register for cache line to FSM
    logic busRd = 0; // bus read
    logic busRdX = 0;  
   
    


    /* Order of operations
        look at hit bus (36 bits)
    
        start owner request  - get cacheline
        output to fsm
        register return from fsm
        operate on current state of fsm
        output to BusRead/ReadX



        Snooping operations (loop through hitbus [excluding owner and misses])
        Has input from BusRead/ReadX
        Get cache line from processors
        Send to FSM
        Register return from FSM
        store new state to cache line 
        

        Finish owner request (owner requested shared data) // redundant if owner doesn't request shared data
        grab cacheline from registered output
    *
    *
    *
    * 1. Look at hit bus
    * 2. Start owner request
    * 3. Snooping operations
    * 4. Finish owner request
    */



    /**********************
     * 1. Look at hit bus *
     **********************/


    logic [2:0] owner = 0;
    logic [2:0] ways = 0;

for(int i = 0; i < 36; i++) begin
    if(int_hitbus[i] == x) begin

    // determine which processor the hit is from
    logic [2:0] owner;   // what cache the hit is from
    // p1d
    if(i < 8) begin
        owner = p1d;
        end
    end
    // p1i
    else if(i < 12) begin
        ways = i-8;
        owner = p1i;
    end
    // p2d
    else if(i < 20) begin
        ways = i-12;
        owner = p2d;
    end
    // p2i
    else if(i < 24) begin
        ways = i-20;
        owner = p2i;
    end
    // p3d
    else if(i < 32) begin
        ways = i-24;
        owner = p3d;
    end
    // p3i
    else if(i < 36) begin
        ways = i-32;
        owner = p3i;
    end
    else begin
        $display("Error: hitbus[%0d] is invalid", i);
    end
    

            // Get cache line from processor
            // Send to FSM
            // Register return from FSM
            // Store new state to cache line
end


    
/**************************
 * 2. Start owner request *
 **************************/

// Initialize FSM
logic [1:0] internal_state = 2'b11; // initial state of FSM 

// Send owner cacheline to FSM
case(owner)
    1: begin 

      internal state = current_cache[instruction.address.set_index][ways].MESI_bits;
        
        // Get cacheline from processor 1 data
        // Send to FSM
        // Register return from FSM
        // Operate on current state of FSM
        // Output to BusRead/ReadX
    end
    2: begin
        internal state = current_cache[instruction.address.set_index][ways].MESI_bits;
        // Get cacheline from processor 1 instruction
        // Send to FSM
        // Register return from FSM
        // Operate on current state of FSM
        // Output to BusRead/ReadX
    end
    3: begin
        internal state = current_cache[instruction.address.set_index][ways].MESI_bits;
        // Get cacheline from processor 2 data
        // Send to FSM
        // Register return from FSM
        // Operate on current state of FSM
        // Output to BusRead/ReadX
    end
    4: begin
        internal state = current_cache[instruction.address.set_index][ways].MESI_bits;
        // Get cacheline from processor 2 instruction
        // Send to FSM
        // Register return from FSM
        // Operate on current state of FSM
        // Output to BusRead/ReadX
    end
    5: begin
        internal state = current_cache[instruction.address.set_index][ways].MESI_bits;
        // Get cacheline from processor 3 data
        // Send to FSM
        // Register return from FSM
        // Operate on current state of FSM
        // Output to BusRead/ReadX
    end
    6: begin
        internal state = current_cache[instruction.address.set_index][ways].MESI_bits;
        // Get cacheline from processor 3 instruction
        // Send to FSM
        // Register return from FSM
        // Operate on current state of FSM
        // Output to BusRead/ReadX
    end
    
    default: begin
        // Do nothing
        $display("No owner found");
    end
endcase
    
    //internal state register for FSM output
    logic [1:0] owner_fsm_return;
    logic [1:0] snoop_fsm_return; 
    
    // Send cacheline to FSM
    MESI_FSM (.clk(clk), .rst(rst) .cache_bus_in(internal_state), .instruction(instruction), .state_out(fsm_return), .hit(hit) .hitM(hitM));   
    
    // register return from FSM
    always_ff @(posedge clk) begin SEQUENTIAL_LOGIC// FIXME: HELP!!! if(!(pipeline_counte++ %=3))    // is this the right way to operate every 3 cycles?
        
        pipeline_counter++;
        
        if(pipeline_counter % 3 == 0) begin
            owner_fsm_return <= fsm_return; // the cache line from the FSM
    
        end
        else begin
            snoop_fsm_return <= fsm_return; // the cache line from the FSM
        end

        current_cache <= cache;   // Next cache line to FSM
        int_hitbus <= hitbus;     // Next hit bus to FSM

    end SEQUENTIAL_LOGIC



function automatic logic owner_mem_op(input logic owner_fsm_return, 
                                      input logic instruction,
                                      input current_cache, 
                                      input hit,
                                      input hitM
                                      output logic busRd, 
                                      output logic busRdX
                                      output cache_line_out);

    
    case(instruction.n)
        0:

        1:
            case(owner_fsm_return)

                2'b00: begin
                    // 
                    busRd_next = 1;
                end
                2'b01: begin
                    
                    busRd = 1;
                end
                2'b10: begin
                    
                    busRd = 1;
                end
                2'b11: begin
                
                    busRd = 1;
                end
                default: begin
                    // Do nothing
                    $display("No owner found");
                end
            endcase
        2:
        3:
        4:
        8:
        9:
        default:
            $display("Error: instruction.n is invalid");
    endcase



    
endfunction    



   

    
    
    always @()
    /**************************
     * 3. Snooping operations *
     **************************/
     
     // Go through hit bus and look for hits
        // If hit, get cache line from processor
        // Send to FSM
        // Register return from FSM
        // Store new state to cache line
    
    logic hit = 0;
    logic hitM = 0;

    for(int i = 0; i < 36; i++) begin
        if(int_hitbus[i] == 1) begin
            //hit registered
            hit = 1; 
            // determine which processor the hit is from
            logic [2:0] L1_cache;   // what cache the hit is from
            // p1d
            if(i < 8) begin
                L1_cache = p1d;
            end
            // p1i
            else if(i < 12) begin
                L1_cache = p1i;
            end
            // p2d
            else if(i < 20) begin
                L1_cache = p2d;
            end
            // p2i
            else if(i < 24) begin
                L1_cache = p2i;
            end
            // p3d
            else if(i < 32) begin
                L1_cache = p3d;
            end
            // p3i
            else if(i < 36) begin
                L1_cache = p3i;
            end
            else begin
                $display("Error: hitbus[%0d] is invalid", i);
            end

            // send L1_cache to FSM
            // stall if else is triggered


            // Get cache line from processor
            // Send to FSM
            // Register return from FSM
            // Store new state to cache line
        end
        elseif(int_hitbus[i] == 0) begin
            // No hit (stall)
            continue;
        end
        elseif(int_hitbus[i] == z) begin
            // RFO
            hitM = 1;
        end
        elseif(int_hitbus[i] == x) begin
            // Owner
            continue;
        end
        else begin
            $display("Error: hitbus[%0d] is invalid", i);
        end
        

        // send L1_cache to FSM
        // stall if else is triggered
    end




    /***************************
     * 4. Finish owner request *
     ***************************/
    
    // return chacheline to owner cache
    case(owner) 
        1: begin
            // Send cacheline to processor 1 data
            // Operate on current state of FSM
        end
        2: begin
            // Send cacheline to processor 1 instruction
            // Operate on current state of FSM
        end
        3: begin
            // Send cacheline to processor 2 data
            // Operate on current state of FSM
        end
        4: begin
            // Send cacheline to processor 2 instruction
            // Operate on current state of FSM
        end
        5: begin
            // Send cacheline to processor 3 data
            // Operate on current state of FSM
        end
        6: begin
            // Send cacheline to processor 3 instruction
            // Operate on current state of FSM
        end
        default: begin
            // Do nothing
            $display("No owner found");
        end
    endcase
    
    
    
    
    function automatic logic snoop_mem_op(input logic owner_fsm_return, 
                                      input logic instruction,
                                      input current_cache, 
                                      input busRd,
                                      input busRdX,
                                      output cache_line_out);

    
    case(instruction.n)
        0:

        1:
            case(owner_fsm_return)

                2'b00: begin
                    // 
                    busRd = 1;
                end
                2'b01: begin
                    
                    busRd = 1;
                end
                2'b10: begin
                    
                    busRd = 1;
                end
                2'b11: begin
                
                    busRd = 1;
                end
                default: begin
                    // Do nothing
                    $display("No owner found");
                end
            endcase
        2:
        3:
        4:
        8:
        9:
        default:
            $display("Error: instruction.n is invalid");
    endcase



    
endfunction


endmodule
