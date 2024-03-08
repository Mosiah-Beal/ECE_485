
import my_struct_package::*;

module processor_tb;

    // Parameters
    localparam CLK_PERIOD = 10; // Clock period in time units
   
    // Declare signals
    logic clk = 0;
    logic [31:0] instr_address = 0;
    logic [3:0] n;
    command_t instruction;
    cache_line_t current_line_i[4];
    cache_line_t current_line_d[8];
    cache_line_t return_line_i[4];
    cache_line_t return_line_d[8];
    logic [11:0] p_bus;

    // Instantiate the processor module
    processor dut (
        .clk(clk),
        .instruction(instruction),
        .return_line_i(return_line_i),
        .return_line_d(return_line_d),
        .current_line_i(current_line_i),
        .current_line_d(current_line_d),
        .p_bus(p_bus)
    );

    // Clock generation
    always #((CLK_PERIOD)/2) clk = ~clk;
    
    // Assign instructions
    assign instruction = {n, instr_address, 3'b0, 2'b0};

    // Initialize signals
    initial begin
        
	// Apply some dummy instructions
        
	//write operation
	n  = 1;
	instr_address = 32'hABCD_EF01;
	return_line_d[0].tag        = instruction.address.tag;
	return_line_d[0].LRU        = 3'b0;
	return_line_d[0].MESI_bits  = M;
	return_line_d[0].data       = 32'hABCD_EF01;
#10;	 
        //read operation
	n  = 0;
	instr_address = 32'hABCD_EF01;
	return_line_d[0].tag        = instruction.address.tag;
	return_line_d[0].LRU        = 3'b0;
	return_line_d[0].MESI_bits  = M;
	return_line_d[0].data       = 32'hABCD_EF01; 
#10;
	// Write operation
	n  = 1;
	instr_address = 32'h1234_5678;
	return_line_d[1].tag        = instruction.address.tag;
	return_line_d[1].LRU        = 3'b0;
	return_line_d[1].MESI_bits  = M;
	return_line_d[1].data = 32'h1234_5678;
#10;
	// Read operation	
	n  = 0;
	instr_address = 32'h1234_5678;
	return_line_d[1].tag        = instruction.address.tag;
	return_line_d[1].LRU        = 3'b0;
	return_line_d[1].MESI_bits  = M;
	return_line_d[1].data = 32'h1234_5678;
#10;
	// Write operation
	n  = 1;
	instr_address = 32'h8765_4321;
	return_line_d[2].tag        = instruction.address.tag;
	return_line_d[2].LRU        = 3'b0;
	return_line_d[2].MESI_bits  = M;
	return_line_d[2].data = 32'h8765_4321;
#10;
	// Read operation
	n  = 0;
	instr_address = 32'h8765_4321;
	return_line_d[2].tag        = instruction.address.tag;
	return_line_d[2].LRU        = 3'b0;
	return_line_d[2].MESI_bits  = M;
	return_line_d[2].data = 32'h8765_4321;
#10;
	// Write operation
	n  = 1;
	instr_address = 32'h2468_ACE0;
	return_line_d[3].tag        = instruction.address.tag;
	return_line_d[3].LRU        = 3'b0;
	return_line_d[3].MESI_bits  = M;
	return_line_d[3].data = 32'h2468_ACE0;
#10;
	// Read operation
	n  = 0;
	instr_address = 32'h2468_ACE0;
	return_line_d[3].tag        = instruction.address.tag;
	return_line_d[3].LRU        = 3'b0;
	return_line_d[3].MESI_bits  = M;
	return_line_d[3].data = 32'h2468_ACE0;
#10;
	// Write operation
	n  = 1;
	instr_address = 32'hABC0_9876;
	return_line_d[4].tag        = instruction.address.tag;
	return_line_d[4].LRU        = 3'b0;
	return_line_d[4].MESI_bits  = M;
	return_line_d[4].data = 32'hABC0_9876;
#10;
	// Read operation
	n  = 0;
	instr_address = 32'hABC0_9876;
	return_line_d[4].tag        = instruction.address.tag;
	return_line_d[4].LRU        = 3'b0;
	return_line_d[4].MESI_bits  = M;
	return_line_d[4].data = 32'hABC0_9876;

#10;
       
	// Write operation
	n  = 1;
	instr_address = 32'hABCD_EF01;
	return_line_d[0].tag        = instruction.address.tag;
	return_line_d[0].LRU        = 3'b0;
	return_line_d[0].MESI_bits  = M;
	return_line_d[0].data = 32'hABC0_9876;

#10;
	//read operation
	n  = 0;
	instr_address = 32'hABCD_EF01;
	return_line_d[0].tag        = instruction.address.tag;
	return_line_d[0].LRU        = 3'b0;
	return_line_d[0].MESI_bits  = M;
	return_line_d[0].data = 32'hABCD_EF01; 

#10;
	// Write operation
	n  = 1;
	instr_address = 32'h1234_5678;
	return_line_d[1].tag        = instruction.address.tag;
	return_line_d[1].LRU        = 3'b0;
	return_line_d[1].MESI_bits  = M;
	return_line_d[1].data = 32'h1234_5678;

#10;
	// Read operation	
	n  = 0;
	instr_address = 32'h1234_5678;
	return_line_d[1].tag        = instruction.address.tag;
	return_line_d[1].LRU        = 3'b0;
	return_line_d[1].MESI_bits  = M;
	return_line_d[1].data = 32'h1234_5678;

#10;
	// Write operation
	n  = 1;
	instr_address = 32'h8765_4321;
	return_line_d[2].tag        = instruction.address.tag;
	return_line_d[2].LRU        = 3'b0;
	return_line_d[2].MESI_bits  = M;
	return_line_d[2].data = 32'h8765_4321;

#10;
	// Read operation
	n  = 0;
	instr_address = 32'h8765_4321;
	return_line_d[2].tag        = instruction.address.tag;
	return_line_d[2].LRU        = 3'b0;
	return_line_d[2].MESI_bits  = M;
	return_line_d[2].data = 32'h8765_4321;

#10;
	// Write operation
	n  = 1;
	instr_address = 32'h2468_ACE0;
	return_line_d[3].tag        = instruction.address.tag;
	return_line_d[3].LRU        = 3'b0;
	return_line_d[3].MESI_bits  = M;
	return_line_d[3].data = 32'h2468_ACE0;

#10;
	// Read operation
	n  = 0;
	instr_address = 32'h2468_ACE0;
	return_line_d[3].tag        = instruction.address.tag;
	return_line_d[3].LRU        = 3'b0;
	return_line_d[3].MESI_bits  = M;
	return_line_d[3].data = 32'h2468_ACE0;

#10;
	// Write operation
	n  = 1;
	instr_address = 32'hABC0_9876;
	return_line_d[4].tag        = instruction.address.tag;
	return_line_d[4].LRU        = 3'b0;
	return_line_d[4].MESI_bits  = M;
	return_line_d[4].data = 32'hABC0_9876;

#10;
	// Read operation
	n  = 0;
	instr_address = 32'hABC0_9876;
	return_line_d[4].tag        = instruction.address.tag;
	return_line_d[4].LRU        = 3'b0;
	return_line_d[4].MESI_bits  = M;
	return_line_d[4].data = 32'hABC0_9876;
	 

	// Monitor p_bus
	$monitor("Time = %0t: p_bus = %b data cache = %p instr cache = %p",
			$time, p_bus, current_line_d, current_line_i);

	// Run simulation for a certain period
	#1000;
	$stop;
	
	// Add more simulation time as needed
    end

endmodule