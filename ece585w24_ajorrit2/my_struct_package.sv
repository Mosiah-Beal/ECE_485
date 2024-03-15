
package my_struct_package;

// Define parameters
parameter D_WAYS = 8; 			// 8 ways for data cache
parameter I_WAYS = 4; 			// 4 ways for instruction cache
parameter SETS = 16384; 		// 16K sets
parameter LINE_SIZE = 64; 		// 64 bytes per line
parameter ADDRESS_BITS = 32; 	// 32-bit address
parameter DATA_BITS = 32; 		// 32-bit data

// Calculate other parameters
parameter LARGER_WAYS = (D_WAYS > I_WAYS) ? D_WAYS : I_WAYS;
parameter LRU_BITS = $clog2(LARGER_WAYS);
parameter SET_BITS = $clog2(SETS);
parameter BYTE_OFFSET_BITS = $clog2(LINE_SIZE);
parameter TAG_BITS = ADDRESS_BITS - SET_BITS - BYTE_OFFSET_BITS;

// Define MESI states
typedef enum logic [1:0] {
	I = 2'b00, // Invalid
	S = 2'b01, // Shared
	E = 2'b10, // Exclusive
	M = 2'b11  // Modified
} states_t;

// Address struct, unpacks 32-bit address into tag, set index, and byte offset
typedef struct packed {
	logic [TAG_BITS-1:0] tag;         // TAG_BITS for tag
	logic [SET_BITS-1:0] set_index;   // SET_BITS for set index
	logic [BYTE_OFFSET_BITS-1:0]  byte_offset; // BYTE_OFFSET_BITS for byte offset
} address_t;

// Processor instruction struct, contains instruction, address, and processor ID
typedef struct packed {
	logic [3:0] n;             // 4 bits for instruction
	address_t address;      // 32-bit address
} command_t;

// Cache line struct, contains tag, LRU, MESI bits, and data
typedef struct packed {
	logic [TAG_BITS-1:0] tag;         	// TAG_BITS for tag
	logic [LRU_BITS-1:0] LRU;           // LRU_BITS for LRU
	states_t MESI_bits;    				// 2 bits for MESI states
	logic [DATA_BITS-1:0] data;         // DATA_BITS for data
} cache_line_t;

endpackage
