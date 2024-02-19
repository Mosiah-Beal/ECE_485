/* ARs
* Select way
* Select processor
* Mesi implementation
* 
* Highlight way to select data
* How to send to data to MESI
* For loop to go through every bank and compare address tag to cacheline tag and output 8 hit/no hit
* Determine hitm based on if (hit exists AND write instruction)
*/


/**********
* Structs *
***********/

// Address struct, unpacks 32-bit address into tag, set index, and byte offset
typedef struct packed {
	reg [11:0] tag;         // 12 bits for tag
	reg [13:0] set_index;   // 14 bits for set index
	reg [5:0]  byte_offset; // 6 bits for byte offset
} address_t;

// Processor instruction struct, contains instruction, address, and processor ID
typedef struct packed {
    reg[3:0] n;             // instruction
    address_t address;      // 32-bit address
    reg[2:0] PID;           // processor id
    logic[1:0] cache_num;   // which instruction cache
} command_t;

// Cache line struct, contains tag, LRU, MESI bits, and data
typedef struct packed {
	reg [11:0] tag;         // 12 bits for tag
	reg [2:0] LRU;          // 3 bits for LRU
	reg [1:0] MESI_bits;    // 2 bits for MESI states
	reg [511:0] data        // 512 bits for data
} cache_line_t;


/************
* Instances *
*************/
/*
    // simulate processor0
    address_t p0addresses [7];
    p0addresses[0] = 32'h984DE132;
    p0addresses[1] = 32'h116DE12F;
    p0addresses[2] = 32'h100DE130;
    p0addresses[3] = 32'h999DE12E;
    p0addresses[4] = 32'h645DE10A;
    p0addresses[5] = 32'h846DE107;
    p0addresses[6] = 32'h211DE128;
    p0addresses[7] = 32'h777DE133;

    // simulate processor1
    address_t p1addresses[7];
    p1addresses[0] = 32'h984DE132;
    p1addresses[1] = 32'h116DE12F;
    p1addresses[2] = 32'h100DE130;
    p1addresses[3] = 32'h999DE12E;
    p1addresses[4] = 32'h645DE10A;
    p1addresses[5] = 32'h846DE107;
    p1addresses[6] = 32'h211DE128;
    p1addresses[7] = 32'h777DE133;

    // simulate processor2 
    address_t p2addresses[7];
    p2addresses[0] = 32'h984DE132;
    p2addresses[1] = 32'h116DE12F;
    p2addresses[2] = 32'h100DE130;
    p2addresses[3] = 32'h999DE12E;
    p2addresses[4] = 32'h645DE10A;
    p2addresses[5] = 32'h846DE107;
    p2addresses[6] = 32'h211DE128;
    p2addresses[7] = 32'h777DE133;
*/

// simulate processor0
address_t p0addresses[8] = '{
    32'h984DE132,
    32'h116DE12F,
    32'h100DE130,
    32'h999DE12E,
    32'h645DE10A,
    32'h846DE107,
    32'h211DE128,
    32'h777DE133
};

// simulate processor1
address_t p1addresses[8] = '{
    32'h984DE132,
    32'h116DE12F,
    32'h100DE130,
    32'h999DE12E,
    32'h645DE10A,
    32'h846DE107,
    32'h211DE128,
    32'h777DE133
};

// simulate processor2
address_t p2addresses[8] = '{
    32'h984DE132,
    32'h116DE12F,
    32'h100DE130,
    32'h999DE12E,
    32'h645DE10A,
    32'h846DE107,
    32'h211DE128,
    32'h777DE133
};



/**********
* Modules *
***********/

// Example of potential module structure
module top;
    // Declare signals
    wire [31:0] signal_from_p0_to_p1;
    wire [31:0] signal_from_p1_to_p0;

    // Instantiate processor 0
    processor p0 (
        .output_signal(signal_from_p0_to_p1),
        .input_signal(signal_from_p1_to_p0)
    );

    // Instantiate processor 1
    processor p1 (
        .output_signal(signal_from_p1_to_p0),
        .input_signal(signal_from_p0_to_p1)
    );
endmodule

module mesi_controller( input (hit_bus_out) input command_t input cache_line_t

);


module project(
    
    input logic [34:0] command,


);     // top level module

    // Declare global signals
    // hit buses for instruction and data caches
    logic [1:0] instruction_read_bus;   // 4-way instruction caches
    logic [2:0] data_read_bus;          // 8-way data caches

    // Other signals


    mesi controller MESI_controller(.instruction_read_bus(instruction_read_bus), .data_read_bus(data_read_bus);
    // Instantiate the processors, each has their own 4-way instruction and 8-way data cache
    processor processor0(.instruction_read_bus(instruction_read_bus), .data_read_bus(data_read_bus));
    processor processor1;
    processor processor2;

    
    /** 
        mesi controller instance will include call to mem ops functions. 
        necessary struct info needs to be ported
        MESI_controller(.n(n), .mesi_now(cache_bus_in));
    */


    // Declare the MESI controller module
    // MESI_controller MESI_controller();

    // Feed the processor instructions to the MESI controller
    /** 
        MESI_controller.processor_instruction = processor0.test_instruction;
        MESI_controller.processor_instruction = processor1.test_instruction;
        MESI_controller.processor_instruction = processor2.test_instruction;
    */
endmodule

module processor(input hit_bus_in,
 output hit_bus_out );   
    // Instantiate an array of data caches
    cache #(.sets(16384), .ways(8)) data_cache;

    // Instantiate an array of instruction caches
    cache #(.sets(16384), .ways(4)) instruction_cache;
endmodule


module cache #(parameter sets = 16384, parameter ways = 8); // cache module
    /** Initialize data cache as a 2D array of cache lines
    *  cache_line contains tag, LRU, MESI bits, and data
    **/

    // Declare the cache as an array of cache lines
    cache_line_t cache[sets-1:0][ways-1:0];   // L1 cache

    // Initialize the cache
    initial begin
        // Initialize each set
        for(int i = 0; i < sets; i++) begin
            // Initialize each way
            for(int j = 0; j < ways; j++) begin
                cache[i][j].LRU = j;           // LRU = way of the cache line (0, 1, 2, 3, 4, 5, 6, 7)
                cache[i][j].MESI_bits = 2'b00; // Initialize MESI bits to Invalid
                cache[i][j].tag = 6'b0;        // Initialize tag to 0
                cache[i][j].data = 512'b0;     // Initialize mem to 0
            end
        end
    end
endmodule


/************ 
* Functions *
*************
* The following sections provide functions which execute cache operation given the structure defined above
* LRU is not implemented but available for implementation
*/ 

/** find_hits
* Determines which coloumn(s) of the cache produced a hit (if any)
* Set the read_bus using the four states of the operator to specify 
* hit(1), hitM(z), no hit(0), dont care(x)
**/
function automatic logic find_hits (command_t test_instruction
hit_bus_in,
hit bus_ out) 

    address_t desired_address = test_instruction.address;   // get the address we are looking for
    logic [1:0] instruction_read_bus;   // 4-way instruction caches
    logic [2:0] data_read_bus;          // 8-way data caches
    // integer instruction = test_instruction.n;

    //! higher level repeat for all caches !!! not done!!!!
    //NEEDS TO MAKE OWNER CACHE AN X OUTPUT
	for (int i = 0; i < ways; i++) begin
        
        data_read_bus[i] = 0;    // Assume this cache has no hit

        // check if there is a match in the way, using the set index passed in (updates read_bus)
        if(desired_address.tag == data_cache[desired_address.set_index][i])  {

            case(test_intruction.n)  // which instruction is this?

                0:  // data read
                    data_read_bus[i] = 1;   // if read instruction -> hit;

                1:  // data write
                    data_read_bus[i] = z;   // if write instruction -> hitM;


                2:  // instruction fetch
                    data_read_bus[i] = 1;

                3:  // L2 invalidate
                    data_read_bus[i] = z;   // if hit found on other caches

                default:  
                    data_read_bus[i] = x;   // dont care
            
            endcase
        }

    end
endfunction

function automatic logic update_mesi ([2:0] n, [1:0] mesi_now);

    MESI_controller(.n(n), .mesi_now(cache_bus_in));
endfunction



function automatic logic mem_op(input [2:0] n, input [1:0] mesi_now, input cache_line_t cache, input address_t owner_address, input cache_line_t shared_cache_in, input data_mem_in, input hit,hitM,busRd,busRdX, output [7:0] data);

    // Check if the cache is invalid
    if (mesi_now == 2'b00) begin
        // Call the invalid memory operation function
        invalid_mem_op(n, mesi_now, cache, owner_address, shared_cache_in, data_mem_in, hit, hitM, busRd, busRdX, data);
    end
    else begin
        // Call the valid memory operation function
        valid_mem_op(n, mesi_now, cache, owner_address, shared_cache_in, data_mem_in, hit, hitM, busRd, busRdX, data);
    end
endfunction



function automatic logic owner_invalid_mem_op( 
    input command_t test_instruction       
    input cache_line_t cache,
    input address_t owner_address,          //killed (in test_instruction)
    input cache_line_t shared_cache_in,
    input data_mem_in,
    input hit,hitM,busRd,busRdX             // 4-state bus?    
    output [7:0] data
    );   
    logic [7:0] data_register;	// 
    // implement processor masking i.e decide which processor the instruction came from

    
        case (n)
        0: begin	// read instruction
            // Check if hit is 0
            if (hit == 0) begin
                // Write data_mem_in to data memory
                cache[set_index][ways-1].data = data_mem_in;
            end
            else begin
                // Write data_mem_in to data memory from shared_cache_in
                cache[set_index][ways-1].data = shared_cache_in.data;
            end
            
        
        // Write tag bits to tag memory
            cache[set_index][ways-1].tag = owner_address.tag; 
            // Deliver tag data to CPU
            data_out = cache[set_index][ways-1].data[byte_offset +: 8];
            // Reset hit flag
            hit = 0;
        end

        1: begin	// Write instruction
            // Check if hit is 0
            if (hit == 0) begin
                // Write data_mem_in to data memory
                cache[set_index][ways-1].data = data_mem_in;
            end
            else begin
                // Write data_mem_in to data memory from shared_cache_in
                cache[set_index][ways-1].data = shared_cache_in.data;
            end


            // Write tag bits to tag memory
            cache[set_index][ways-1].tag = owner_address.tag; 
            // Deliver tag data to CPU
            data_out = cache[set_index][ways-1].data[byte_offset +: 8];
            // Reset hit flag
            hit = 0;
        end
        
        // Check if n is 3 or 4
        3, 4: begin
            // Display message indicating busRdX signal is ignored because it's already invalid
            $display("busRdX signal ignored already invalid");
            // Write tag bits to tag memory
            cache[set_index][ways-1].tag = owner_address.tag;
            // Reset hit flag
            hit = 0;
        end

        default: begin
            // Display debugging information
            $display("000");
            $display("tag = %h tag_mem0[set_index] = %h tag_mem0[set_index][2:11] = %h time = %t", tag, cache[n].tag_mem[set_index], cache[n].tag_mem[set_index][2:11], $time);
        end
    endcase
endfunction

function automatic logic invalid_state([0:1] cache_bus_in, [2:0] n, hit, hitM, busRd, BusRdX)

	update_mesi( n, cache_bus_in);

	owner_mem_op(n, cache_bus_in, owner); //not complete!!
	
	snoop_mem_op(n, 	
endfunction

