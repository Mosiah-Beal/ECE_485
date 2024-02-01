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
logic [5:0] byte_index;		// which word in the block  	(2^6 = 64 words) bit[0:5] of address
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


task automatic probe_banks()


task automatic update_cache_Modified(input n, input [31:0] cache_bus_in, input [31:0] tag, input [31:0] shared_cache_in, input busRd, input busRdX, output reg [31:0] data_mem0, output reg [31:0] tag_mem0, output reg [31:0] tag_mem_bus0, output reg [31:0] data_mem_bus0, output reg hit0);
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
			MESI_bits = 2'b01; // Transition to Shared state
		end
		1: begin // write data request to L1 data cache
			MESI_bits = 2'b11; // Transition to Modified state
		end
		2: begin // instruction fetch (a read request to L1 instruction cache)
			MESI_bits = 2'b01; // Transition to Shared state
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
			// No transition, just print the current state
			$display("Current MESI state: %b", MESI_bits);
		end
	endcase
endtask

task automatic Exclusive_update(input n, output reg [1:0] MESI_bits);
	case(n)
		0: begin // read data request to L1 data cache
			MESI_bits = 2'b01; // Transition to Shared state
		end
		1: begin // write data request to L1 data cache
			MESI_bits = 2'b11; // Transition to Modified state
		end
		2: begin // instruction fetch (a read request to L1 instruction cache)
			MESI_bits = 2'b01; // Transition to Shared state
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
			// No transition, just print the current state
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
			// No transition, just print the current state
			$display("Current MESI state: %b", MESI_bits);
		end
	endcase
endtask

task automatic Invalid_update(input n, output reg [1:0] MESI_bits);
	case(n)
		0: begin // read data request to L1 data cache
			MESI_bits = 2'b01; // Transition to Shared state
		end
		1: begin // write data request to L1 data cache
			MESI_bits = 2'b11; // Transition to Modified state
		end
		2: begin // instruction fetch (a read request to L1 instruction cache)
			MESI_bits = 2'b01; // Transition to Shared state
		end
		3: begin // invalidate command from L2
			MESI_bits = 2'b00; // Remain in Invalid state
		end
		4: begin // data request from L2 (in response to snoop)
			MESI_bits = 2'b01; // Transition to Shared state
		end
		8: begin // clear the cache and reset all state (and statistics)
			MESI_bits = 2'b00; // Remain in Invalid state
		end
		9: begin // print contents and state of the cache (allow subsequent trace activity)
			// No transition, just print the current state
			$display("Current MESI state: %b", MESI_bits);
		end
	endcase
endtask

//////////////////////////////////////////////

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
task automatic update_cache_Invalid(input [1:0] n, input hit, input [31:0] data_mem_in, input [31:0] shared_cache_in, input [31:0] cache_bus_in, input [31:0] tag, output reg [31:0] data_mem0, output reg [31:0] tag_mem0, output reg [31:0] tag_mem_bus0, output reg [31:0] data_mem_bus0, output reg hit0);
	if(n < 3) begin
		if(hit == 0) begin
			data_mem0 = data_mem_in; //read cache line from memory
		end
		else begin
			data_mem0 = shared_cache_in; //read cache line from memory
		end
		tag_mem0 = {cache_bus_in,tag}; //write tag bits
		tag_mem_bus0 = tag_mem0; //deliver data to CPU
		data_mem_bus0 = data_mem0;
		hit0 = 0;
	end
	else begin
		$display("busRdX signal ignored already invalid");
		tag_mem0 = {cache_bus_in,tag};
		hit0 = 0;
	end
endtask

task automatic update_cache_Exclusive(input [1:0] n, input [31:0] cache_bus_in, input [31:0] tag, input [31:0] shared_cache_in, input busRd, input busRdX, output reg [31:0] data_mem0, output reg [31:0] tag_mem0, output reg [31:0] tag_mem_bus0, output reg [31:0] data_mem_bus0, output reg hit0);
	if(n < 3) begin
		if(n == 2 && busRdX == 1) begin
			data_mem0 = shared_cache_in; //read cache line from memory
		end
		tag_mem0 = {cache_bus_in,tag}; //write tag bits
		tag_mem_bus0 = tag_mem0; //deliver data to CPU
		data_mem_bus0 = data_mem0;
		hit0 = 1;
	end
	else begin
		$display("busRdX signal ignored already invalid");
		tag_mem0 = {cache_bus_in,tag};
		hit0 = 0;
	end
endtask

task automatic update_cache_Modified(input [1:0] n, input [31:0] cache_bus_in, input [31:0] tag, input [31:0] shared_cache_in, input busRd, input busRdX, output reg [31:0] data_mem0, output reg [31:0] tag_mem0, output reg [31:0] tag_mem_bus0, output reg [31:0] data_mem_bus0, output reg hit0);
	if(n < 3) begin
		if(n == 2 && busRdX == 1) begin
			data_mem0 = shared_cache_in; //read cache line from memory
		end
		tag_mem0 = {cache_bus_in,tag}; //write tag bits
		tag_mem_bus0 = tag_mem0; //deliver data to CPU
		data_mem_bus0 = data_mem0;
		hit0 = 1;
	end
	else begin
		$display("busRdX signal ignored already invalid");
		tag_mem0 = {cache_bus_in,tag};
		hit0 = 0;
	end
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
