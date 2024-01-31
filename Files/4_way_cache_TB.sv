module four_way_cache_TB;

logic clk;
logic rst;
logic [32] address;
logic [512] data_mem_in;
logic hit;
logic [8] data_cache_out;
logic cpu_read_req;
logic miss;
logic hit0,hit1,hit2,hit3;
logic valid0,valid1,valid2,valid3;
logic dirty0,dirty1,dirty2,dirty3;
logic [4] encode;
logic [2] select;
logic [14] tag_mem_bus0;
logic [6] byte_index;
logic [14] set_index;
logic [12] tag;
logic [512] data_mem_out; 

four_way_cache dut(.*); 



initial begin 
clk = 0;
rst = 0;
address = 0;
data_mem_in = 0;
hit = 0;
data_cache_out = 0;
cpu_read_req = 0;
miss = 0;
hit0 = 0;
valid0 = 0;
valid1 = 0;
valid2 = 0;
valid3 = 0;
dirty0 = 0;
dirty1 = 0;
dirty2 = 0;
dirty3 = 0; 
hit0 = 0;
hit1 = 0;
hit2 = 0;
hit3 = 0;
#20; 

clk = 0;
rst = 0;
address = 269484032;
data_mem_in = 0;
hit = 0;
data_cache_out = 0;
cpu_read_req = 0;
miss = 0;
hit0 = 0;
valid0 = 0;
valid1 = 0;
valid2 = 0;
valid3 = 0;
dirty0 = 0;
dirty1 = 0;
dirty2 = 0;
dirty3 = 0; 
hit0 = 0;
hit1 = 0;
hit2 = 0;
hit3 = 0;
#20; 

clk = 0;
rst = 0;
address = 538968064;
data_mem_in = 0;
hit = 0;
data_cache_out = 0;
cpu_read_req = 0;
miss = 0;
hit0 = 0;
valid0 = 0;
valid1 = 0;
valid2 = 0;
valid3 = 0;
dirty0 = 0;
dirty1 = 0;
dirty2 = 0;
dirty3 = 0; 
hit0 = 0;
hit1 = 0;
hit2 = 0;
hit3 = 0;

#20; 

clk = 0;
rst = 0;
address = 809500672;
data_mem_in = 0;
hit = 0;
data_cache_out = 0;
cpu_read_req = 0;
miss = 0;
hit0 = 0;
valid0 = 0;
valid1 = 0;
valid2 = 0;
valid3 = 0;
dirty0 = 0;
dirty1 = 0;
dirty2 = 0;
dirty3 = 0; 
hit0 = 0;
hit1 = 0;
hit2 = 0;
hit3 = 0;
#20;


address = 32'h2408ed4; data_mem_in = 128'hFF;#100;

address = 32'h2402438; data_mem_in = 128'hAA;#100;

address = 32'h2408ed4; #100;

#100;
 
end 

endmodule 