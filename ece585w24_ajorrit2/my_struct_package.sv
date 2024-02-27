package my_struct_package;


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
	reg [31:0] data;        // 512 bits for data
} cache_line_t;

// define MESI states
typedef enum logic [1:0] {
	I = 2'b00, // Invalid
	S = 2'b01, // Shared
	E = 2'b10, // Exclusive
	M = 2'b11  // Modified
} MESI_t;

endpackage

