/*description
* currently the associative cache is split into 4 banks with 4 seperate memory banks
*
*
*
*
*/

/**
* @file 4_way_cache.sv
* @brief 4-way associative cache
* @details This file contains the implementation of a 4-way associative cache
* @date 2021-04-20
*/

/**
Inputs are
n address
Where n is (1 of 7 instructions)
0 read data request to L1 data cache 
1 write data request to L1 data cache 
2 instruction fetch (a read request to L1 instruction cache) 
3 invalidate command from L2 
4 data request from L2 (in response to snoop) 
8 clear the cache and reset all state (and statistics) 
9 print contents and state of the cache (allow subsequent trace activity) 
*/






module four_way_cache(
input logic clk,
input logic rst,
input [4] n,
input logic [32] address,
input logic [512] data_mem_in,
input logic [512] shared_cache_in,
input logic cpu_read_req,
input logic hit_bus_in,
input logic cache_bus_in,
output logic hit0, hit1, hit2, hit3,
output logic hit,
output logic miss,
output logic [8] data_cache_out,
output logic [4] encode,
output logic [2] select,
output logic [14] tag_mem_bus,
output logic [6] byte_index,
output logic [14] set_index,
output logic [12] tag,
output logic [512] data_mem_out); // not used will be implemented soon

// following Blocks are cache stucture
// much of the structure included in port list for debug purposes.

/////////////////////////////////////
//address part breakdown into internal varibles 
/*
logic [1:0] byte_offset;	// which byte in the word		(2^2 = 4 bytes) bit[30:31] of address?
logic [5:0] byte_index;		// which word in the block  	(2^6 = 64 words) bit[0:5] of address {upper 6 bits of address}
logic [13:0] set_index;		// which set in the cache		(2^14 = 16384 sets) bit[6:19] of address
logic [10:0] tag;			// which block in the memory	(2^11 = 2048 ) bit[20:xx] of address?
*/
/////////////////////////////////////


/////////////////////////////////////
// Declaration of 2D array of memory for 4 banks
bit [16383:0][3:0][13:0] tag_mem;  // 16384 indexes, 4 columns, 14 bits each
bit [16383:0][3:0][511:0] data_mem;  // 16384 indexes, 4 columns, 512 bits each

// Initialization
for (int i = 0; i < 16384; i++) {
	for (int j = 0; j < 4; j++) {
		tag_mem[i][j] = 0;
		data_mem[i][j] = 0;
	}
}

/*
// Accessing an element
bit [13:0] tag = tag_mem[index][bank];
bit [511:0] data = data_mem[index][bank];

// Modifying an element
tag_mem[index][bank] = new_tag;
data_mem[index][bank] = new_data;

// Iterating over the array
for (int i = 0; i < 16384; i++) {
	for (int j = 0; j < 4; j++) {
		// Do something with tag_mem[i][j] and data_mem[i][j]
	}
}
*/
////////////////////////////////////

/////////////////////////////////////
//concatenation of address into part select elements

//assign {byte_offset, byte_index, set_index, tag} = address;   

///////////////////////////////////////////
//compare tag bus with address tag and valid bit
/*
always_comb begin
	if((tag_mem0[set_index][0] == 1) && (tag == tag_mem0[set_index][0:10])) 
		hit0 = 1;
	else if (tag_mem_bus1[13] && (tag == tag_mem_bus1[10:0])) 
		hit1 = 1;
	else if (tag_mem_bus2[13] && (tag == tag_mem_bus2[10:0])) 
		hit2 = 1;
	else if (tag_mem_bus3[13] && (tag == tag_mem_bus3[10:0])) 
		hit3 = 1;
	else begin
		$display("fell through 3");
		hit0 = 0;
		hit1 = 0;
		hit2 = 0;
		hit3 = 0;
	end
end
*/
//////////////////////////////////////////
// encode decode to select correct bank
// declare internal encode and select wires 
// concatenate hit bits for case statement in encoder

//logic [3:0] 

assign encode = {hit0, hit1, hit2, hit3};

//logic [1:0] select;

//////////////////////////////////////////
// encoder logic

always_comb begin
case(encode) 

	4'b1000: select = 2'b00;	// select bank 0
	4'b0100: select = 2'b01;	// select bank 1
	4'b0010: select = 2'b10;	// select bank 2
	4'b0001: select = 2'b11;	// select bank 3

	default: select = 2'bzz;	// miss

endcase
end

//////////////////////////////////////////////
// mux logic

always_comb begin
case(select)

0: data_cache_out = data_mem[set_index][0];
1: data_cache_out = data_mem[set_index][1];
2: data_cache_out = data_mem[set_index][2];
3: data_cache_out = data_mem[set_index][3];

default: data_cache_out = 128'bX;

endcase
end

//////////////////////////////////////////////
//OR hits

assign hit = (|encode); 



//Following blocks are cache behavior
//////////////////////////////////////////////
//Read behavior


always_comb begin

/////////////////////////////////////
//same set index used for all four banks

//write as case?
$display("begin");
{byte_index, set_index, tag} = address;

$display("byte_index = %h set_index = %h  tag = %h time = %t", byte_index,set_index,tag, $time);
$display("byte_index = %d", byte_index);

 
////////////////////////////////////////////////////////
// BANK 0


/*
TODO:
- implement update MESI protocol task (replaces update_cache_Invalid and update_cache_Exclusive)
- depricate update_bank task (incomplete code)
- add other 2 MESI tasks
- for loop with case statement for all 4 banks (with break statement for early exit)

- Check if all 4 are full/invalid before writing to memory
- Implement LRU functionality
- Make sure each n case in task does appropriate action (n==2 && busRdX == 1) for example is incorrect


*/


task instructions(n)
	case(n)
		1: $display("00");	// run task for n=1
		2: $display("01");	// run task for n=2
		3: $display("10");	// run task for n=3
		4: $display("11");	// run task for n=4
endtask

task MESI_State(address)
	case(address)	// pass in which instruction to run on case chosen
		M: $display("00");	// run task for Modified
		E: $display("01");	// run task for Exclusive
		S: $display("10");	// run task for Shared
		I: $display("11");	// run task for Invalid
endtask

/* Rough plan for main logic
	// get instruction from CPU
	// task instructions(n); // figure out what to do
	// search for tag in banks
	// task MESI_State(address); // figure out what to do
	// update cache (LRU?)
*/
////////////////////////////////////////////////////////



//BANK 0
case(tag_mem0[set_index][0:1]) 
	2'b11: begin
		update_cache_Invalid(n, hit, data_mem_in, shared_cache_in, cache_bus_in, tag, data_mem0[set_index], tag_mem0[set_index], tag_mem_bus0, data_mem_bus0, hit0);
		$display("000");
		$display("tag = %h tag_mem0[set_index] = %h tag_mem0[set_index][2:11] = %h time = %t",
			tag,tag_mem0[set_index],tag_mem0[set_index][2:11], $time);
	end

	2'b00: begin
		update_cache_Exclusive(n, cache_bus_in, tag, shared_cache_in, busRd, busRdX, data_mem0[set_index], tag_mem0[set_index], tag_mem_bus0, data_mem_bus0, hit0);	
	end
endcase

////////////////////////////////////////////////////////
// BANKS 1, 2, 3


// BANKS
for (integer i = 1; i < 4; i++) begin
	update_bank(i, data_mem_in, tag, tag_mem[i][set_index], data_mem[i][set_index], tag_mem[i][set_index], tag_mem_bus[i], data_mem_bus[i], hit[i], valid[i], dirty[i]);
end
////////////////////////////////////////////////////////

$display("end");
end
endmodule



/********
* Tasks *
********/

/**	Tasks to update cache based on MESI protocol
*   Inputs:
*	@param n - instruction from CPU [0,1,2,3,4,8,9]
*	@param address - address of data
*
*	Outputs:
*	@output bank - bank to update (index for various signals) [0:3]
*	@output data_mem - data from memory
*	@output tag_mem - tag bits
*	@output tag_mem_bus - tag bits for bus
*	@output data_mem_bus - data from memory for bus
*	@output hit - hit signal
*
*
*	@description
*   Each task handles a different state of the MESI protocol, and updates the cache accordingly
*   They have case statements to handle the different instructions from the CPU
*   They may chain to other tasks to handle the actual update of the cache
*
*	- update_cache_Invalid: update cache when cache line is invalid
*	- update_cache_Exclusive: update cache when cache line is exclusive
*	- update_cache_Modified: update cache when cache line is modified
*   - update_cache_Shared: update cache when cache line is shared
*
*	@notes
*	- need to implement LRU functionality
*	- need to implement for loop with case statement for all 4 banks (with break statement for early exit)
*	- need to check if all 4 are full/invalid before writing to memory
*	- need to implement full functionality for the different n instructions
*/

task automatic probe_banks();
	for (int i = 0; i < 4; i++) begin
		$display("probe bank %d", i);
		// probe bank


		// if hit, return bank and update LRU
		if (hit) begin
			$display("hit in bank %d", i);
			// update LRU
			break;
		end

		else begin
			$display("miss in bank %d", i);
		end


	end
endtask


task automatic update_cache(input n, input [31:0] cache_bus_in, input [31:0] tag, input [31:0] shared_cache_in, input busRd, input busRdX, output reg [31:0] data_mem0, output reg [31:0] tag_mem0, output reg [31:0] tag_mem_bus0, output reg [31:0] data_mem_bus0, output reg hit0);
	case(n)
		0: begin
			$display("0: read data request to L1 data cache\n");
		end
		1: begin
			$display("1: write data request to L1 data cache\n");
		end
		2: begin
			$display("2: instruction fetch (a read request to L1 instruction cache)\n");
		end
		3: begin
			$display("3: invalidate command from L2\n");
		end
		4: begin
			$display("4: data request from L2 (in response to snoop)\n");
		end
		8: begin
			$display("8: clear the cache and reset all state (and statistics)\n");
		end
		9: begin
			$display("9: print contents and state of the cache (allow subsequent trace activity)\n");
		end
endtask

//////////////////////////////////////////////
/* These tasks assume that MESI_bits is a 2-bit register where 
   2'b00 represents Invalid
   2'b01 represents Shared
   2'b10 represents Exclusive
   2'b11 represents Modified.
*/

task automatic Modified_update(input n, output reg [1:0] MESI_bits);
	case(n)
		0: begin // read data request to L1 data cache
			MESI_bits = 2'b11; // Remain in Modified state
		end
		1: begin // write data request to L1 data cache
			MESI_bits = 2'b11; // Remain in Modified state
		end
		2: begin // instruction fetch (a read request to L1 instruction cache)
			MESI_bits = 2'b11; // Remain in Modified state
		end
		3: begin // invalidate command from L2
			MESI_bits = 2'b00; // Transition to Invalid state
		end
		4: begin // data request from L2 (in response to snoop)
			MESI_bits = 2'b01; // Transition to Shared state if data is in the cache
							   // Transition to Invalid state if data is not in the cache
		end
		8: begin // clear the cache and reset all state (and statistics)
			MESI_bits = 2'b00; // Transition to Invalid state
		end
		9: begin // print contents and state of the cache (allow subsequent trace activity)
			$display("Current MESI state: %b", MESI_bits);
		end
	endcase
endtask

task automatic Exclusive_update(input n, output reg [1:0] MESI_bits);
	case(n)
		0: begin // read data request to L1 data cache
			MESI_bits = 2'b10; // Remain in Exclusive state
		end
		1: begin // write data request to L1 data cache
			MESI_bits = 2'b11; // Transition to Modified state
		end
		2: begin // instruction fetch (a read request to L1 instruction cache)
			MESI_bits = 2'b10; // Remain in Exclusive state
		end
		3: begin // invalidate command from L2
			MESI_bits = 2'b00; // Transition to Invalid state
		end
		4: begin // data request from L2 (in response to snoop)
			MESI_bits = 2'b01; // Transition to Shared state
		end
		8: begin // clear the cache and reset all state (and statistics)
			MESI_bits = 2'b00; // Transition to Invalid state
		end
		9: begin // print contents and state of the cache (allow subsequent trace activity)
			$display("Current MESI state: %b", MESI_bits);
		end
	endcase
endtask

task automatic Shared_update(input n, output reg [1:0] MESI_bits);
	case(n)
		0: begin // read data request to L1 data cache
			MESI_bits = 2'b01; // Remain in Shared state
		end
		1: begin // write data request to L1 data cache
			MESI_bits = 2'b11; // Transition to Modified state
		end
		2: begin // instruction fetch (a read request to L1 instruction cache)
			MESI_bits = 2'b01; // Remain in Shared state
		end
		3: begin // invalidate command from L2
			MESI_bits = 2'b00; // Transition to Invalid state
		end
		4: begin // data request from L2 (in response to snoop)
			MESI_bits = 2'b01; // Remain in Shared state
		end
		8: begin // clear the cache and reset all state (and statistics)
			MESI_bits = 2'b00; // Transition to Invalid state
		end
		9: begin // print contents and state of the cache (allow subsequent trace activity)
			$display("Current MESI state: %b", MESI_bits);
		end
	endcase
endtask

task automatic Invalid_update(input n, output reg [1:0] MESI_bits);
	case(n)
		0: begin // read data request to L1 data cache
			MESI_bits = 2'b10; // Transition to Exclusive state
		end
		1: begin // write data request to L1 data cache
			MESI_bits = 2'b10; // Transition to Exclusive state
		end
		2: begin // instruction fetch (a read request to L1 instruction cache)
			MESI_bits = 2'b00; // Remain in Invalid state
		end
		3: begin // invalidate command from L2
			MESI_bits = 2'b00; // Remain in Invalid state
		end
		4: begin // data request from L2 (in response to snoop)
			MESI_bits = 2'b00; // Remain in Invalid state
		end
		8: begin // clear the cache and reset all state (and statistics)
			MESI_bits = 2'b00; // Remain in Invalid state
		end
		9: begin // print contents and state of the cache (allow subsequent trace activity)
			$display("Current MESI state: %b", MESI_bits);
		end
	endcase
endtask


//////////////////////////////////////////////
// MESI State tasks
//////////////////////////////////////////////

typedef enum logic [1:0] {Invalid, Shared, Exclusive, Modified} MESI_state;

MESI_state current_state, next_state;

always_ff @(posedge clk or negedge reset_n) begin
	if (!reset_n) begin
		current_state <= Invalid;
	end else begin
		current_state <= next_state;
	end
end

// MESI state transition logic
// Inputs: n - instruction from CPU [0,1,2,3,4,8,9]
// what processor made the request
// Outputs: next_state - next state of MESI protocol

always_comb
begin
	case(current_state)
		Invalid: begin
			case(n)
			  0: begin
				if (hit || hitM)
					nextstate = S; // Transition to S or E depending on snoop hardware
				else
					nextstate = E;
				end
			1: nextstate = M; // RFO
			2: begin
				if (hit || hitM)
					nextstate = S; // Transition to S or E depending on snoop hardware
				else
					nextstate = E;
				end
			3: nextstate = I;
			4: nextstate = I;
			8: nextstate = I;
			default: nextstate = I;
			endcase
		end
				// Autocomplete suggestions
				// 0: next_state = Shared; // read data request to L1 data cache
				// 1: next_state = Modified; // write data request to L1 data cache
				// 2: next_state = Shared; // instruction fetch (a read request to L1 instruction cache)
				// 3: next_state = Invalid; // invalidate command from L2
				// 4: next_state = Shared; // data request from L2 (in response to snoop)
				// 8: next_state = Invalid; // clear the cache and reset all state (and statistics)
				// 9: next_state = Invalid; // print contents and state of the cache (allow subsequent trace activity)
		
		Shared: begin
			case(n)
				0: next_state = Shared; // read data request to L1 data cache
				1: next_state = Modified; // write data request to L1 data cache
				2: next_state = Shared; // instruction fetch (a read request to L1 instruction cache)
				3: next_state = Invalid; // invalidate command from L2
				4: next_state = Shared; // data request from L2 (in response to snoop)
				8: next_state = Invalid; // clear the cache and reset all state (and statistics)
				default: next_state = Shared; // (9) print contents and state of the cache (allow subsequent trace activity)
			endcase
		end
		Exclusive: begin
			case(n)
				0: next_state = Exclusive; // read data request to L1 data cache
				1: next_state = Modified; // write data request to L1 data cache
				2: next_state = Exclusive; // instruction fetch (a read request to L1 instruction cache)
				3: next_state = Invalid; // invalidate command from L2
				4: next_state = Shared; // data request from L2 (in response to snoop)
				8: next_state = Invalid; // clear the cache and reset all state (and statistics)
				default: next_state = Exclusive; // (9) print contents and state of the cache (allow subsequent trace activity)
			endcase
		end
		Modified: begin
			case(n)
				0: next_state = Modified; // read data request to L1 data cache
				1: next_state = Modified; // write data request to L1 data cache
				2: next_state = Modified; // instruction fetch (a read request to L1 instruction cache)
				3: next_state = Invalid; // invalidate command from L2
				4: next_state = Shared; // data request from L2 (in response to snoop)
				8: next_state = Invalid; // clear the cache and reset all state (and statistics)
				default: next_state = Modified; // (9) print contents and state of the cache (allow subsequent trace activity)
			endcase
		end
	endcase
end





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

typedef struct packed {
	reg [11:0] tag;         // 12 bits for tag
	reg [13:0] set_index;   // 14 bits for set index
	reg [5:0]  byte_offset; // 6 bits for byte offset
} address_t;

// Now you can declare an address like this and assign a value to it:
address_t my_address = 32'h984DE132;

// The packed struct will automatically unpack the 32-bit address into the 3 fields
$display("tag = %h, set_index = %h, byte_offset = %h", my_address.tag, my_address.set_index, my_address.byte_offset);

// Make an array of addresses to test LRU
address_t addresses[7];
addresses[0] = 32'h984DE132;
addresses[1] = 32'h116DE12F;
addresses[2] = 32'h100DE130;
addresses[3] = 32'h999DE12E;
addresses[4] = 32'h645DE10A;
addresses[5] = 32'h846DE107;
addresses[6] = 32'h211DE128;
addresses[7] = 32'h777DE133;


// Define the cache line structure
typedef struct packed {
	reg [5:0] tag;         // 6 bits for tag
	reg [2:0] LRU;         // 3 bits for LRU
	reg [1:0] MESI_bits;   // 2 bits for MESI states
} cache_line_t;

// Define the number of ways
parameter ways = 8;

// Declare the cache as an array of cache lines
cache_line_t cache[ways-1:0];


// Initialize the cache
initial begin
	for (int i = 0; i < ways; i++) begin
		cache[i].LRU = i;	// LRU initially ordered according to index number of the cache lines (0, 1, 2, 3, 4, 5, 6, 7)
		cache[i].MESI_bits = 2'b00; // Initialize MESI bits to Invalid
		cache[i].tag = 6'b0; // Initialize tag to 0
	end
end


// Now test the LRU functionality with the array of addresses
for (int i = 0; i < 7; i++) begin	// Loop through the array of addresses

	// Decrement the LRU for all ways and let it underflow
	for (int j = 0; j < ways; j++) begin	
		cache[j].LRU -= 1;	
	end

	// Find the way with the least recently used cache line
	int LRU_way = 0;	// Start by assuming the first way is the least recently used
	for (int j = 1; j < ways; j++) begin	// Loop through the other ways
		if (cache[j].LRU == 3'b111) begin	// The LRU way would have underflowed to 3'b111
			LRU_way = j;	// If the current way is least recently used, update the LRU way
			$display("Least recently used way: %d", LRU_way);	// Print the least recently used way (debug if multiple ways have LRU = 111)
			break;
		end
	end

	// Write the new address to the least recently used way (already set to 3b'111 due to underflow)
	cache[LRU_way].tag = addresses[i].tag;	// Update the tag
end

// Display the cache
for (int i = 0; i < ways; i++) begin
	$display("Way %d: tag = %h, LRU = %b, MESI_bits = %b", i, cache[i].tag, cache[i].LRU, cache[i].MESI_bits);
end
/////////////////////////////////////
