/*description
* currently the associative cache is split into 4 banks with 4 seperate memory banks
*
*
*
*
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
output logic hit,
output logic [8] data_cache_out,
output logic miss,
output logic hit0,hit1,hit2,hit3,
output logic valid0,valid1,valid2,valid3,
output logic dirty0,dirty1,dirty2,dirty3,
output logic [4] encode,
output logic [2] select,
output logic [14] tag_mem_bus0,
output logic [6] byte_index,
output logic [14] set_index,
output logic [12] tag,
output logic [512] data_mem_out); // not used will be implemented soon

// following Blocks are cache stucture
// much of the structure included in port list for debug purposes.

/////////////////////////////////////
//address part breakdown into internal varibles 
/*
logic [1:0] byte_offset;
logic [5:0] byte_index;
logic [13:0] set_index;
logic [10:0] tag;
*/
/////////////////////////////////////
//declaration of valid + dirty bits + hit bits
/*
logic hit0,hit1,hit2,hit3;
logic valid0,valid1,valid2,valid3;
logic dirty0,dirty1,dirty2,dirty3; 
*/
/////////////////////////////////////
//declaration of tag memory space + data memory space
//for all four banks

bit [16384][14] tag_mem0;
bit [16384][512] data_mem0;
//logic [14] tag_mem_bus0;
logic [512] data_mem_bus0;

bit [16384][14] tag_mem1;
bit [16384][512] data_mem1;
logic [14] tag_mem_bus1;
logic [512] data_mem_bus1;

bit [16384][14] tag_mem2;
bit [16384][512] data_mem2;
logic [14] tag_mem_bus2;
logic [512] data_mem_bus2;

bit [16384][14] tag_mem3;
bit [16384][512] data_mem3;
logic [14] tag_mem_bus3;
logic [512] data_mem_bus3;

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


////////////////////////////////////
//concatenation of address into part select elements

//assign {byte_offset, byte_index, set_index, tag} = address;   

///////////////////////////////////////////
//compare tag bus with address tag and valid bit
/*always_comb begin
if((tag_mem0[set_index][0] == 1) && (tag == tag_mem0[set_index][0:10])) 
hit0 = 1;
else if (tag_mem_bus1[13] && (tag == tag_mem_bus1[10:0])) hit1 = 1;
else if (tag_mem_bus2[13] && (tag == tag_mem_bus2[10:0])) hit2 = 1;
else if (tag_mem_bus3[13] && (tag == tag_mem_bus3[10:0])) hit3 = 1;
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
//encode decode to select correct bank
//declare internal encode and select wires 
//concatenate hit bits for case statement in encoder

//logic [3:0] 

assign encode = {hit0,hit1,hit2,hit3};

//logic [1:0] select;

//////////////////////////////////////////
//encoder logic

always_comb begin
case(encode) 

4'b1000: select = 2'b00;
4'b0100: select = 2'b01;
4'b0010: select = 2'b10;
4'b0001: select = 2'b11;

default: select = 2'bzz;

endcase
end

//////////////////////////////////////////////
//mux logic

always_comb begin
case(select)

0: data_cache_out = data_mem0[set_index];
1: data_cache_out = data_mem1[set_index];
2: data_cache_out = data_mem2[set_index];
3: data_cache_out = data_mem3[set_index];

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

task automatic update_cache_2b11(input [1:0] n, input hit, input [31:0] data_mem_in, input [31:0] shared_cache_in, input [31:0] cache_bus_in, input [31:0] tag, output reg [31:0] data_mem0, output reg [31:0] tag_mem0, output reg [31:0] tag_mem_bus0, output reg [31:0] data_mem_bus0, output reg hit0);
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

task automatic update_cache_2b00(input [1:0] n, input [31:0] cache_bus_in, input [31:0] tag, input [31:0] shared_cache_in, input busRd, input busRdX, output reg [31:0] data_mem0, output reg [31:0] tag_mem0, output reg [31:0] tag_mem_bus0, output reg [31:0] data_mem_bus0, output reg hit0);
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


//BANK 0
case(tag_mem0[set_index][0:1]) 
	2'b11: begin
		update_cache_2b11(n, hit, data_mem_in, shared_cache_in, cache_bus_in, tag, data_mem0[set_index], tag_mem0[set_index], tag_mem_bus0, data_mem_bus0, hit0);
		$display("000");
		$display("tag = %h tag_mem0[set_index] = %h tag_mem0[set_index][2:11] = %h time = %t",
			tag,tag_mem0[set_index],tag_mem0[set_index][2:11], $time);
	end

	2'b00: begin
		update_cache_2b00(n, cache_bus_in, tag, shared_cache_in, busRd, busRdX, data_mem0[set_index], tag_mem0[set_index], tag_mem_bus0, data_mem_bus0, hit0);	
	end
endcase

////////////////////////////////////////////////////////
// BANKS 1, 2, 3
task automatic update_bank(input integer bank_index, input [31:0] data_mem_in, input [31:0] tag, input [31:0] tag_mem_in, output reg [31:0] data_mem_out, output reg [31:0] tag_mem_out, output reg [31:0] tag_mem_bus_out, output reg [31:0] data_mem_bus_out, output reg hit_out, output reg valid_out, output reg dirty_out);
	if(tag_mem_in[0] != 1) begin
		data_mem_out = data_mem_in;               // read cache line from memory
		valid_out = 1;                            // set valid bit
		tag_mem_out = {valid_out,dirty_out,tag};  // write tag bits
		tag_mem_bus_out = tag_mem_out;            // deliver data to CPU
		data_mem_bus_out = data_mem_out;
		hit_out = 0;
	end 
	else if((tag_mem_in[0] == 1) && (tag == tag_mem_in[2:13])) begin
		hit_out = 1;
		tag_mem_bus_out = tag_mem_in;             // deliver data to CPU
		data_mem_bus_out = data_mem_out;
	end 
	else begin
		hit_out = 0;
	end
endtask

// BANKS
for (integer i = 0; i < 3; i++) begin
	update_bank(i, data_mem_in, tag, tag_mem[i][set_index], data_mem[i][set_index], tag_mem[i][set_index], tag_mem_bus[i], data_mem_bus[i], hit[i], valid[i], dirty[i]);
end
////////////////////////////////////////////////////////

$display("end");
end
endmodule





//////////////////////////////////////////////
// Implementation of banks using 2D array
// BANK 1

if(tag_mem[1][set_index][0] != 1) begin
	data_mem[1][set_index] = data_mem_in;             // read cache line from memory
	valid[1] = 1;                                     // set valid bit
	tag_mem[1][set_index] = {valid[1],dirty[1],tag};  // write tag bits
	tag_mem_bus[1] = tag_mem[1][set_index];           // deliver data to CPU
	data_mem_bus[1] = data_mem[1][set_index];
	hit[1] = 0;
	$display("010");
	$display("tag = %b tag_mem[1][set_index] = %b tag_mem[1][set_index][0:10] = %b time = %t",
			  tag, tag_mem[1][set_index], tag_mem[1][set_index][2:11], $time);
end else if((tag_mem[1][set_index][0] == 1) && (tag == tag_mem[1][set_index][2:13])) begin
	hit[1] = 1;
	tag_mem_bus[1] = tag_mem[1][set_index];           // deliver data to CPU
	data_mem_bus[1] = data_mem[1][set_index];
	$display("011");
end else begin
	hit[1] = 0;
	$display("cast out algorithm here 1");
	$display("tag = %b tag_mem[1][set_index] = %b tag_mem[1][set_index][2:13] = %b time = %t",
			  tag, tag_mem[1][set_index], tag_mem[1][set_index][2:11], $time);
end


//////////////////////////////////////////////////////////
// Experimental code for 4 way cache

integer i;

for(i = 0; i < 4; i = i + 1) begin
	if(tag_mem[i][set_index][0] != 1) begin
		data_mem[i][set_index] = data_mem_in;             // read cache line from memory
		valid[i] = 1;                                     // set valid bit
		tag_mem[i][set_index] = {valid[i],dirty[i],tag};  // write tag bits
		tag_mem_bus[i] = tag_mem[i][set_index];           // deliver data to CPU
		data_mem_bus[i] = data_mem[i][set_index];
		hit[i] = 0;
		$display("tag = %b tag_mem[%0d][set_index] = %b tag_mem[%0d][set_index][0:10] = %b time = %t",
				  tag, i, tag_mem[i][set_index], i, tag_mem[i][set_index][2:11], $time);
	end else if((tag_mem[i][set_index][0] == 1) && (tag == tag_mem[i][set_index][2:13])) begin
		hit[i] = 1;
		tag_mem_bus[i] = tag_mem[i][set_index];           // deliver data to CPU
		data_mem_bus[i] = data_mem[i][set_index];
	end else begin
		hit[i] = 0;
		$display("cast out algorithm here %0d", i);
		$display("tag = %b tag_mem[%0d][set_index] = %b tag_mem[%0d][set_index][2:13] = %b time = %t",
				  tag, i, tag_mem[i][set_index], i, tag_mem[i][set_index][2:11], $time);
	end
end
