module cache;
//////////////////////////////////////////////
// LRU for 8-way set associative cache. Counts down from 7 to 0 depending on the order of access
// Duplicate the structure of the cache lines from the explanation pdf
/*
integer ways = 8;					// 8 way set associative cache
reg [5:0] Tag[ways-1:0];			// 6 bits for tag (index in the example)
reg [2:0] LRU[ways-1:0];			// 3 bits for indexing the 8 ways
reg [1:0] MESI_bits[ways-1:0];		// 2 bits for MESI states (00, 01, 10, 11) (Invalid, Shared, Exclusive, Modified)

// Cache lines structure
// 	[Tag0], [Tag1], [Tag2], [Tag3], [Tag4], [Tag5], [Tag6], [Tag7]
//	[LRU0], [LRU1], [LRU2], [LRU3], [LRU4], [LRU5], [LRU6], [LRU7]	// 000 is least recently used, 111 is most recently used
//	[MESI_bits0], [MESI_bits1], [MESI_bits2], [MESI_bits3], [MESI_bits4], [MESI_bits5], [MESI_bits6], [MESI_bits7]

cache_lines [2:0][ways-1:0] = {Tag, LRU, MESI_bits};

// Accessing an element will update the LRU
// If a write miss occurs, the LRU way is selected for replacement
// if the replaced line is modified, it is written back to memory before the new line is written

// reg [31:0] address = 32'h984DE132;
// reg [11:0] tag = address[31:20]; 		// 12 bits for tag. // 1001 1000 0100b = 0x984h
// reg [13:0] set_index = address[19:6];	// 14 bits for set index. // 1101 1110 0001 00b = 0x3784h
// reg [5:0] byte_offset = address[5:0];	// 6 bits for byte offset. // 11 0010b = 0x32h

*/
 

/** description to line 40
this definition needs to be included in the higher level cpu module

*/

typedef struct packed {
	reg [11:0] tag;         // 12 bits for tag
	reg [13:0] set_index;   // 14 bits for set index
	reg [5:0]  byte_offset; // 6 bits for byte offset
} address_t;

// Now you can declare an address like this and assign a value to it:




address_t my_address = 32'h984DE132;
// The packed struct will automatically unpack the 32-bit address into the 3 fields
$display("tag = %h, set_index = %h, byte_offset = %h", my_address.tag, my_address.set_index, my_address.byte_offset);


// Make an array of addresses to test LRU and simulate processor0

/** description to line 84
this portion of code creates 3 simulated processors
this code needs to be moved to a higher level module which will be ported
to the cache module
*/
//note these will be in a higher level module ported to cache
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
p2address_t p2addresses[7];
p2addresses[0] = 32'h984DE132;
p2addresses[1] = 32'h116DE12F;
p2addresses[2] = 32'h100DE130;
p2addresses[3] = 32'h999DE12E;
p2addresses[4] = 32'h645DE10A;
p2addresses[5] = 32'h846DE107;
p2addresses[6] = 32'h211DE128;
p2addresses[7] = 32'h777DE133;




/** description to line 102 
this portion of the code creates the cache through a 2d array
sets = rows
columns = ways 
*/ 
// Define the cache line structure
typedef struct packed {
	reg [11:0] tag;         // 12 bits for tag
	reg [2:0] LRU;         // 3 bits for LRU
	reg [1:0] MESI_bits;
	reg [511:0] data   // 2 bits for MESI states
} cache_line_t;

// Define the number of ways
parameter ways = 8;
parameter sets = 16384; //16k = 2^15
// Declare the cache as an array of cache lines
cache_line_t cache[sets-1][ways-1:0];   // L1 cache


// Initialize the cache !!! note initialization for each set needs to be added !!!
initial begin
	for (int i = 0; i < ways; i++) begin
		cache[set_index][i].LRU = i;	// LRU initially ordered according to index number of the cache lines (0, 1, 2, 3, 4, 5, 6, 7)
		cache[set_index][i].MESI_bits = 2'b00; // Initialize MESI bits to Invalid
		cache[set_index][i].tag = 6'b0; // Initialize tag to 0
		cache[set_index][i].data = 512'b0 //Initialize mem to 0
	end
end
///////////////////////////////////////////////////////////////////////




/* description to line 122
This portion of the code packages an instruction from the cpu module

*/ 
//ported from higher level cpu module
typedef struct packed {
    reg[3:0] n;         // instruction
    address_t address;  // address
    reg[2:0] PID;       // processor id
    logic[1:0] cache_num; //which cache
} processor_instruction_t *processor;

//                                          write, address, p1
processor test_instruction = {1, p1addresses[0], 1};







/** description to line 164
this portion of the code determines which coloumn of the cache produced a hit if any
Additionally this portion uses the read_bus and the four states of the operator to specify 
hit, hitM, no hit, dont care
**/ 
// cache module struct definition
address_t owner_address;
address_t snoop1;
address_t snoop2;
// Search the ways

function automatic logic find_hits (*processor test_instruction)

    address_t desired_address = test_instruction.address;   // get the address we are looking for
    logic [1:0] instruction_read_bus;   // 4-way instruction caches
    logic [2:0] data_read_bus;          // 8-way data caches
    // integer instruction = test_instruction.n;

    //! higher level repeat for all caches !!! not done!!!!
	for (int i = 0; i < ways; i++) begin
        
        data_read_bus[i] = x;    // Assume this cache has no hit

        // check if there is a match in the way, using the set index passed in (updates read_bus)
        if(desired_address.tag == cache[desired_address.set_index][i])  {

                    case(test_intruction.n)  // which instruction is this?

        0:  // read instruction
            data_read_bus[i] = 1;  // if read instruction -> hit;

        1:  data_read_bus[i] = z;


        2: data_read_bus[i] = 1;

        3:  // L2 invalidate
            data_read_bus[i] = z;

        default:  data_read_bus[i] = x;

	end
endfunction




/** description to line 200
mesi controller instance will include call to mem ops functions. necessary struct info needs to be ported
*/
MESI_controller(.n(n), .mesi_now(cache_bus_in));

/**
end module here
*/




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


/*
decription
not needed since intruction will contain which cache it operates on

///////////////////////////////////////////////////////////////////////
function automatic logic (*processor test_instruction)
	
    logic owner_mask = (test_instruction.PID | 3'b000);
    //logic snoop_mask = (~(test_instruction.PID) & 3'b111);

    for(logic PID = 4'b0000; PID == 4'b1000; PID << 1) {
        // Check if PID is owner    // FIXME: Implement cache selection and make new struct with (do everything)
        (PID & owner_mask) ? mem_op(owner) : //pass;


    }
    
    for(logic PID = 4'b0000; PID == 4'b1000; PID << 1) {
        // Check if PID is owner    // FIXME: Implement cache selection and make new struct with (do everything)
        (PID & owner_mask) ?   : mem_op(snooper);


    }

endfunction
	
*/

/* the above section initialized the cache structure used in the functions
* following sections provide functions which execute cache operation given the structure defined above
*LRU is not implemented but available for implementation
*/ 



function automatic logic update_mesi ([2:0] n, [1:0] mesi_now);

MESI_controller(.n(n), .mesi_now(cache_bus_in));

endfunction

function automatic logic owner_invalid_mem_op( 
input [2:0] n, //Instruction            //killed (in test_instruction)
input [1:0] mesi_now, //M,E,S,I         //killed (in cache)
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
endmodule
	
		
		
	

	