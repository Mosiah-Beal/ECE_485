import my_struct_package::*;

module top;
    logic clk;
    logic rst;
    command_t instruction;
    cache_line_t cache_input_i[4];
    cache_line_t cache_output_i[4];
    cache_line_t cache_input_d[8];
    cache_line_t cache_output_d[8];
    cache_line_t fsm_input_line;
    cache_line_t fsm_output_line;
    logic hit;
    logic hitM;
    logic [2:0] sum;

// Parameters
parameter sets = 16384;
parameter ways = 8;
parameter TIME_DURATION = 5;


// Define an array of instructions
//4+32+3+2 = 41
reg [40:0] instructions [40];   // n, address, PID, cache_num
initial begin
    instructions[0] = {4'b1000, 32'b0, 3'b0, 2'b0};         // time = 10
    //instructions[0] = {40'b0};                              // time = 10
    instructions[1] = {4'd0,32'h984DE132,3'b0,2'b0};        // time = 20
    instructions[2] = {4'd0,32'h116DE12F,3'b0,2'b0};        // time = 30
    instructions[3] = {4'd0,32'h100DE130,3'b0,2'b0};
    instructions[4] = {4'd0,32'h999DE12E,3'b0,2'b0};
    instructions[5] = {4'd0,32'h645DE10A,3'b0,2'b0};
    instructions[6] = {4'd0,32'h846DE107,3'b0,2'b0};
    instructions[7] = {4'd0,32'h211DE128,3'b0,2'b0};
    instructions[8] = {4'd0,32'h777DE133,3'b0,2'b0};
    instructions[9] = {4'd9,32'h777DE133,3'b0,2'b0}; // time = 100, n=9
    instructions[10] = {4'd0,32'h846DE107,3'b0,2'b0};
    instructions[11] = {4'd0,32'h846DE107,3'b0,2'b0};
    instructions[12] = {4'd0,32'h846DE107,3'b0,2'b0};
    instructions[13] = {4'd9,32'h777DE133,3'b0,2'b0};
    instructions[14] = {4'd2,32'h846DE107,3'b0,2'b0};
    instructions[15] = {4'd2,32'h984DE132,3'b0,2'b0};        // time = 20
    instructions[16] = {4'd2,32'h116DE12F,3'b0,2'b0};        // time = 30
    instructions[17] = {4'd2,32'h100DE130,3'b0,2'b0};
    instructions[18] = {4'd2,32'h999DE12E,3'b0,2'b0};
    instructions[19] = {4'd2,32'h645DE10A,3'b0,2'b0};
    instructions[20] = {4'd2,32'h846DE107,3'b0,2'b0};

    
end

 
// Instantiate the data cache with sets = 16384 and ways = 8
cache #(.sets(16384), .ways(8)) data_cache (
        .clk(clk),
        .instruction(instruction),
	    .cache_in(cache_input_d),
        .cache_out(cache_output_d)
    );

 // Instantiate the instruction cache with sets = 16384 and ways = 4
cache #(.sets(16384), .ways(4)) instruction_cache (
        .clk(clk),
        .instruction(instruction),
	    .cache_in(cache_input_i),
        .cache_out(cache_output_i)
    );
processor processor(
        .clk(clk),
        .instruction(instruction),
        .current_line_i(cache_output_i),
        .current_line_d(cache_output_d),
        .return_line_i(cache_input_i),
        .return_line_d(cache_input_d),
        .block_in(fsm_input_line),
        .block_out(fsm_output_line),
        .count(sum),
        .read_enable(read_enable)
        );
mesi_fsm fsm(
        .clk(clk), 
        .rst(rst), 
        .instruction(instruction),
        .internal_line(fsm_output_line), 
        .return_line(fsm_input_line), 
        .hit(hit),
        .hitM(hitM)
        );
//count LRU(.rst(rst), .sum(sum));


// Clock generation
always #TIME_DURATION clk = ~clk;


// Set initial values
initial begin
    // Initialize inputs
    clk = 0;
    rst = 1;
    instruction = {4'b1000,32'b0,3'b0,2'b0};
    hit = 0;
    hitM = 0;

    // Set initial values for the cache lines
    for (int i = 0; i < 4; i = i + 1) begin
        cache_input_i[i].LRU = i;
        cache_input_i[i].MESI_bits = I;
        cache_input_i[i].tag = 12'b0;
        cache_input_i[i].data = 32'b0;
    end

    for (int i = 0; i < 8; i = i + 1) begin
        cache_input_d[i].LRU = i;
        cache_input_d[i].MESI_bits = I;
        cache_input_d[i].tag = 12'b0;
        cache_input_d[i].data = 32'b0;
    end
 
    // Give a clock pulse to end reset
    #TIME_DURATION;
    rst = 0;
end


// Loop over the instructions
initial begin
    int sum_d;
    int sum_i;

    // wait for reset to end
    #TIME_DURATION;
    for (int i = 0; i < 20; i = i + 1) begin

        // Check if there are no more instructions left
        if($isunknown(instructions[i])) begin
            $display("Invalid / last instruction reached. Exiting simulation.");
            break;
        end

        
        // read
        #TIME_DURATION;

        //$display("Time = %t : Instruction = %p", $time, instruction);
        instruction = instructions[i];    
        
        // write
        #TIME_DURATION;

        // Display output cache line LRU bits
        $display("Time = %t : Cache Line LRU = %p %p %p %p %p %p %p %p", $time, cache_input_d[0].LRU, cache_input_d[1].LRU, cache_input_d[2].LRU, cache_input_d[3].LRU, cache_input_d[4].LRU, cache_input_d[5].LRU, cache_input_d[6].LRU, cache_input_d[7].LRU);
        $display("");

        // Check for duplicate LRU bits by summing them
        sum_d = int'(cache_input_d[0].LRU) + int'(cache_input_d[1].LRU) + int'(cache_input_d[2].LRU) + int'(cache_input_d[3].LRU) + int'(cache_input_d[4].LRU) + int'(cache_input_d[5].LRU) + int'(cache_input_d[6].LRU) + int'(cache_input_d[7].LRU);
        if (sum_d != 28) begin
            $display("Duplicate LRU bits found. sumd = %p Exiting simulation.", sum_d);
        end

        sum_i = int'(cache_input_i[0].LRU) + int'(cache_input_i[1].LRU) + int'(cache_input_i[2].LRU) + int'(cache_input_i[3].LRU);
        if (sum_i != 6) begin
            $display("Duplicate LRU bits found, sumi = %p. Exiting simulation.", sum_i);
        end



        end

    $finish;
end


endmodule