

module mesi_fsm_tb;

    // Parameters
    parameter CLK_PERIOD = 10; // Clock period in nanoseconds

    // Signals
    logic clk;
    logic rst;
    logic hit;
    logic hitM;
    logic [31:0] address;
    logic [2:0] n;
    my_struct_package::command_t instruction;
    my_struct_package::cache_line_t internal_line [1][1];
    my_struct_package::cache_line_t return_line [1][1];

    import my_struct_package::*;

    // Instantiate the mesi_fsm module
    mesi_fsm uut (
        .clk(clk),
        .rst(rst),
        .hit(hit),
        .hitM(hitM),
        .instruction(instruction),
        .internal_line(internal_line),
        .return_line(return_line)
    );

    // Clock generation
    always #((CLK_PERIOD) / 2) clk = ~clk;
    assign internal_line[0][0].tag = instruction.address.tag;
    assign instruction = {n,address,3'b0,2'b0};// Initializations
    initial begin
        // Initialize inputs
        clk = 0;
        rst = 1;
        hit = 0;
        hitM = 0;
        n = 0;
	address = 32'h0000_0000;
       // Initialize to zero
        
	/*0 984DE132
	0 116DE12F
	0 100DE130
	0 999DE12E
	0 645DE10A
	0 846DE107
	0 211DE128
	0 777DE133*/

        // Reset for a few cycles
        #10;
        rst = 0;
        #10;
	
	n= 0; address = 32'h984DE132;

#10;
	n = 0; address = 32'h116DE12F;

#10;
	n = 0; address = 32'h100DE130;
#10;
	n = 0; address = 32'h999DE12E;

#10;
	n = 0; address = 32'h645DE10A;

#10;
n = 0; address = 32'h846DE107;

#10;
n = 0; address = 32'h211DE128;

#10;
n = 0; address = 32'h777DE133;

#10;


       

        // End simulation
        #1000;
        $finish;
    end

endmodule
