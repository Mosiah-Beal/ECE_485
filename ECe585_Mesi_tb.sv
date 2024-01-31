module MESI_controller_tb;

    // Define parameters
    localparam CLK_PERIOD = 10; // Clock period in time units

    // Declare signals
    logic clk;
    logic rst;
    logic [2:0] n;
    logic [32] address;
    logic hit;
    logic hitM;
    logic [14] cache_bus_in;
    logic [2] cache_bus_out;
    logic busRd;
    logic busRdX;
    logic [2] state_in;

    // Instantiate MESI_controller module
    MESI_controller uut (
        .clk(clk),
        .rst(rst),
        .n(n),
        .address(address),
        .hit(hit),
        .hitM(hitM),
        .cache_bus_in(cache_bus_in),
        .cache_bus_out(cache_bus_out),
        .busRd(busRd),
        .busRdX(busRdX),
	.state_out(state_in)
    );

    // Clock generation
    always #((CLK_PERIOD / 2)) clk = ~clk;

    // Initial values
    initial begin
        clk = 0;
        rst = 1;
        n = 0;
        address = 32'b0;
        hit = 0;
        hitM = 0;
        cache_bus_in = 15'b0;

        // Reset
        #60 rst = 0;

        // Test case 1: Transition from state M to state S
        #20 n = 4;
        #10 n = 0;
	$display("test 1 at %d", $time);
        // Test case 2: Transition from state E to state M
        #20 n = 1;
        #10 n = 0;
	$display("test 2 at %d", $time);
        // Test case 3: Transition from state S to state I
        #20 n = 3;
        #10 n = 0;
	$display("test 3 at %d", $time);
        // Test case 4: Transition from state I to state E (hit)
        #20 hit = 1;
        #10 n = 0;
	$display("test 4 at %d", $time);
        // Test case 5: Transition from state I to state S (no hit)
        #20 hit = 0;
        #10 n = 0;
	$display("test 5 at %d", $time);
        // Test case 6: Transition from state I to state M (busRdX)
        #20 n = 1;
        #10 n = 0;
	$display("test 6 at %d", $time);
        // Test case 7: Transition from state I to state S (busRd)
        #20 n = 0;
        #10 n = 0;
	$display("test 7 at %d", $time);
        // Add more test cases as needed...

        // End simulation
        #100 $stop;
    end

endmodule 



