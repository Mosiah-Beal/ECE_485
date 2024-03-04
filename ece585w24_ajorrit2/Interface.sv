// Define the interface for the cache module
interface cache_if #(parameter WAYS = 8);
    logic clk;
    command_t instruction;
    cache_line_t cache_in[WAYS-1:0];    // input from processor
    cache_line_t cache_out[WAYS-1:0];   // output to processor
    logic write_enable;
    logic read_enable;

    modport cache_mp (input clk, input instruction, input cache_in, output cache_out, input write_enable, input read_enable);
endinterface

// Define the interface for the processor module
interface processor_if;
    logic clk;                      // input from top
    command_t instruction;          // input from top
    cache_line_t current_line_i;    // input from top to i_cache
    cache_line_t current_line_d;    // input from top to d_cache
    cache_line_t return_line_i;     // output to top from i_cache
    cache_line_t return_line_d;     // output to top from d_cache
    cache_line_t block_in;          // input to cache from fsm 
    cache_line_t block_out;         // output to top
    logic [2:0] count;              // input from count

    modport processor_mp (input clk, input instruction, input current_line_i, input current_line_d, output return_line_i, output return_line_d, input block_in, output block_out, input count);
endinterface

// Define the interface for the mesi_fsm module
interface mesi_fsm_if;
    logic clk;
    logic rst;
    command_t instruction;
    cache_line_t internal_line;
    cache_line_t return_line;
    logic hit;
    logic hitM;

    modport fsm_mp (input clk, input rst, input instruction, input internal_line, output return_line, input hit, input hitM);
endinterface

// Define the interface for the count module
interface count_if;
    logic start;
    logic rst;
    logic [2:0] sum;

    modport count_mp (input start, input rst, output sum);
endinterface

// Define the top-level interface that includes all the sub-interfaces
interface top_if;
    cache_if #(WAYS = 8) data_cache_if;
    cache_if #(WAYS = 4) instruction_cache_if;
    processor_if processor_if;
    mesi_fsm_if mesi_fsm_if;
    count_if count_if;

    modport top_mp (cache_if.cache_mp data_cache_if, cache_if.cache_mp instruction_cache_if, processor_if.processor_mp processor_if, mesi_fsm_if.fsm_mp mesi_fsm_if, count_if.count_mp count_if);
endinterface