// Import the struct package
import my_struct_package::*;

module processor_block (
    input   logic clk,
    input   command_t instruction,
    input   cache_line_t p0return_line_i[1][4],
    input   cache_line_t p0return_line_d[1][8],
    input   cache_line_t p1return_line_i[1][4],
    input   cache_line_t p1return_line_d[1][8],
    input   cache_line_t p2return_line_i[1][4],
    input   cache_line_t p2return_line_d[1][8],
    output  cache_line_t p0current_line_i[1][4],
    output  cache_line_t p0current_line_d[1][8],
    output  cache_line_t p1current_line_i[1][4],
    output  cache_line_t p1current_line_d[1][8],
    output  cache_line_t p2current_line_i[1][4],
    output  cache_line_t p2current_line_d[1][8],
    output  logic [35:0] hit_bus
);

    // Instance the hit buses for each processor
    logic [11:0] p0_bus;
    logic [11:0] p1_bus;
    logic [11:0] p2_bus;

    // Instantiate three instances of the processor module
    processor p0 (
        .clk(clk),
        .instruction(instruction),
    	.return_line_i(p0return_line_i),
	    .return_line_d(p0return_line_d),
        .current_line_i(p0current_line_i),
        .current_line_d(p0current_line_d),
        .p_bus(p0_bus)
    );

    processor p1 (
        .clk(clk),
        .instruction(instruction),
        .return_line_i(p1return_line_i),
        .return_line_d(p1return_line_d),
        .current_line_i(p1current_line_i),
        .current_line_d(p1current_line_d),
        .p_bus(p1_bus)
    );

    processor p2 (
        .clk(clk),
        .instruction(instruction),
        .return_line_i(p2return_line_i),
        .return_line_d(p2return_line_d),
        .current_line_i(p2current_line_i),
        .current_line_d(p2current_line_d),
        .p_bus(p2_bus)
    );

    // Concatenate the hit buses
    assign hit_bus = {p0_bus, p1_bus, p2_bus};

endmodule