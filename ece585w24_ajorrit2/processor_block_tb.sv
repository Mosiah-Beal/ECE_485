import my_struct_package::*;

module processor_block_tb;

    // Parameters
    localparam CLK_PERIOD = 10; // Clock period in time units

    
    // Declare signals
    logic clk = 0;
    logic [31:0] instr_address = 0;
    logic [3:0] n;
    command_t instruction;
    cache_line_t p0return_line_i[1][4];
    cache_line_t p0return_line_d[1][8];
    cache_line_t p1return_line_i[1][4];
    cache_line_t p1return_line_d[1][8];
    cache_line_t p2return_line_i[1][4];
    cache_line_t p2return_line_d[1][8];
    cache_line_t p0current_line_i[1][4];
    cache_line_t p0current_line_d[1][8];
    cache_line_t p1current_line_i[1][4];
    cache_line_t p1current_line_d[1][8];
    cache_line_t p2current_line_i[1][4];
    cache_line_t p2current_line_d[1][8];
    logic [35:0] hit_bus;

    // Instantiate the processor_block module
    processor_block dut (
        .clk(clk),
        .instruction(instruction),
		.p0return_line_i(p0return_line_i),
     	.p0return_line_d(p0return_line_d),
     	.p1return_line_i(p1return_line_i),
    	.p1return_line_d(p1return_line_d),
    	.p2return_line_i(p2return_line_i),
    	.p2return_line_d(p2return_line_d),
        .p0current_line_i(p0current_line_i),
        .p0current_line_d(p0current_line_d),
        .p1current_line_i(p1current_line_i),
        .p1current_line_d(p1current_line_d),
        .p2current_line_i(p2current_line_i),
        .p2current_line_d(p2current_line_d),
        .hit_bus(hit_bus)
    );

    // Clock generation
    always #((CLK_PERIOD)/2) clk = ~clk;

    assign instruction = {n, instr_address, 3'b0, 2'b0};

    // Initialize signals
    initial begin
		// Apply some dummy instructions
	// Write operation
        n  = 1;
		instr_address = 32'hABCD_EF01;
		p0return_line_d[0][0].tag        = instruction.address.tag;
		p0return_line_d[0][0].LRU        = 3'b0;
		p0return_line_d[0][0].MESI_bits  = 2'b11;
       	p0return_line_d[0][0].data       = 32'hABCD_EF01;
		#10;	 
        
	//read operation
		n  = 0;
		instr_address = 32'hABCD_EF01;
       	p0return_line_d[0][0].tag        = instruction.address.tag;
		p0return_line_d[0][0].LRU        = 3'b0;
		p0return_line_d[0][0].MESI_bits  = 2'b11;
       	p0return_line_d[0][0].data       = 32'hABCD_EF01; 
		#10;
	
	// Write operation
		n  = 1;
		instr_address = 32'h1234_5678;
		p1return_line_d[0][1].tag        = instruction.address.tag;
		p1return_line_d[0][1].LRU        = 3'b0;
		p1return_line_d[0][1].MESI_bits  = 2'b11;
		p1return_line_d[0][1].data = 32'h1234_5678;
		#10;
	
	// Read operation	
		n  = 0;
		instr_address = 32'h1234_5678;
		p1return_line_d[0][1].tag        = instruction.address.tag;
		p1return_line_d[0][1].LRU        = 3'b0;
		p1return_line_d[0][1].MESI_bits  = 2'b11;
		p1return_line_d[0][1].data = 32'h1234_5678;
		#10;
	
	// Write operation
		n  = 1;
		instr_address = 32'h8765_4321;
		p2return_line_d[0][2].tag        = instruction.address.tag;
		p2return_line_d[0][2].LRU        = 3'b0;
		p2return_line_d[0][2].MESI_bits  = 2'b11;
		p2return_line_d[0][2].data = 32'h8765_4321;
		#10;
	
	// Read operation
		n  = 0;
		instr_address = 32'h8765_4321;
		p2return_line_d[0][2].tag        = instruction.address.tag;
		p2return_line_d[0][2].LRU        = 3'b0;
		p2return_line_d[0][2].MESI_bits  = 2'b11;
		p2return_line_d[0][2].data = 32'h8765_4321;
		#10;
	
	// Write operation
		n  = 1;
		instr_address = 32'h2468_ACE0;
		p0return_line_d[0][3].tag        = instruction.address.tag;
		p0return_line_d[0][3].LRU        = 3'b0;
		p0return_line_d[0][3].MESI_bits  = 2'b11;
		p0return_line_d[0][3].data = 32'h2468_ACE0;
		#10;
	
	// Read operation
		n  = 0;
		instr_address = 32'h2468_ACE0;
		p0return_line_d[0][3].tag        = instruction.address.tag;
		p0return_line_d[0][3].LRU        = 3'b0;
		p0return_line_d[0][3].MESI_bits  = 2'b11;
		p0return_line_d[0][3].data = 32'h2468_ACE0;
		#10;
	
	// Write operation
		n  = 1;
		instr_address = 32'hABC0_9876;
		p1return_line_d[0][4].tag        = instruction.address.tag;
		p1return_line_d[0][4].LRU        = 3'b0;
		p1return_line_d[0][4].MESI_bits  = 2'b11;
		p1return_line_d[0][4].data = 32'hABC0_9876;
		#10;
	
	// Read operation
		n  = 0;
		instr_address = 32'hABC0_9876;
		p1return_line_d[0][4].tag        = instruction.address.tag;
		p1return_line_d[0][4].LRU        = 3'b0;
		p1return_line_d[0][4].MESI_bits  = 2'b11;
		p1return_line_d[0][4].data = 32'hABC0_9876;
		#10;
       
	// Write operation
		n  = 1;
		instr_address = 32'hABCD_EF01;
		p2return_line_d[0][0].tag        = instruction.address.tag;
		p2return_line_d[0][0].LRU        = 3'b0;
		p2return_line_d[0][0].MESI_bits  = 2'b11;
		p2return_line_d[0][0].data = 32'hABC0_9876;
		#10;

	//read operation
		n  = 0;
		instr_address = 32'hABCD_EF01;
		p2return_line_d[0][0].tag        = instruction.address.tag;
		p2return_line_d[0][0].LRU        = 3'b0;
		p2return_line_d[0][0].MESI_bits  = 2'b11;
		p2return_line_d[0][0].data = 32'hABCD_EF01; 
		#10;
	
	// Write operation
		n  = 1;
		instr_address = 32'h1234_5678;
		p2return_line_d[0][1].tag        = instruction.address.tag;
		p2return_line_d[0][1].LRU        = 3'b0;
		p2return_line_d[0][1].MESI_bits  = 2'b11;
		p2return_line_d[0][1].data = 32'h1234_5678;
		#10;

	// Read operation	
		n  = 0;
		instr_address = 32'h1234_5678;
		p2return_line_d[0][1].tag        = instruction.address.tag;
		p2return_line_d[0][1].LRU        = 3'b0;
		p2return_line_d[0][1].MESI_bits  = 2'b11;
		p2return_line_d[0][1].data = 32'h1234_5678;
		#10;

	// Write operation
		n  = 1;
		instr_address = 32'h8765_4321;
		p2return_line_d[0][2].tag        = instruction.address.tag;
		p2return_line_d[0][2].LRU        = 3'b0;
		p2return_line_d[0][2].MESI_bits  = 2'b11;
		p2return_line_d[0][2].data = 32'h8765_4321;
		#10;

	// Read operation
		n  = 0;
		instr_address = 32'h8765_4321;
		p1return_line_d[0][2].tag        = instruction.address.tag;
		p1return_line_d[0][2].LRU        = 3'b0;
		p1return_line_d[0][2].MESI_bits  = 2'b11;
		p1return_line_d[0][2].data = 32'h8765_4321;
		#10;

	// Write operation
		n  = 1;
		instr_address = 32'h2468_ACE0;
		p0return_line_d[0][3].tag        = instruction.address.tag;
		p0return_line_d[0][3].LRU        = 3'b0;
		p0return_line_d[0][3].MESI_bits  = 2'b11;
		p0return_line_d[0][3].data = 32'h2468_ACE0;
		#10;
		
	// Read operation
		n  = 0;
		instr_address = 32'h2468_ACE0;
		p0return_line_d[0][3].tag        = instruction.address.tag;
		p0return_line_d[0][3].LRU        = 3'b0;
		p0return_line_d[0][3].MESI_bits  = 2'b11;
		p0return_line_d[0][3].data = 32'h2468_ACE0;
		#10;

	// Write operation
		n  = 1;
		instr_address = 32'hABC0_9876;
		p1return_line_d[0][4].tag        = instruction.address.tag;
		p1return_line_d[0][4].LRU        = 3'b0;
		p1return_line_d[0][4].MESI_bits  = 2'b11;
		p1return_line_d[0][4].data = 32'hABC0_9876;
		#10;

	// Read operation
		n  = 0;
		instr_address = 32'hABC0_9876;
		p1return_line_d[0][4].tag        = instruction.address.tag;
		p1return_line_d[0][4].LRU        = 3'b0;
		p1return_line_d[0][4].MESI_bits  = 2'b11;
		p1return_line_d[0][4].data = 32'hABC0_9876;
		#10;		

	// Add more dummy instructions as needed

	// Run simulation for a certain period
 	$monitor("Time = %0t: hit_bus = %h \np0data cache = %p \tp0instr cache = %p, \np1data cache = %p \tp1instr cache = %p, \np2data cache = %p \tp2instr cache = %p\n\n",
         	$time, hit_bus, p0current_line_d, p0current_line_i, p1current_line_d, p1current_line_i, p2current_line_d, p2current_line_i);
        
		#1000;
        // Add more simulation time as needed
    end

endmodule