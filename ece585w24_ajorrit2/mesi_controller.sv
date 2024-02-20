module mesi_ctrl(
    input    logic clk,
    input    logic rst,
    input    my_struct_package::cache_line_t p0current_line_i[1][4],
    input    my_struct_package::cache_line_t p0current_line_d[1][8],
    input    my_struct_package::cache_line_t p1current_line_i[1][4],
    input    my_struct_package::cache_line_t p1current_line_d[1][8],
    input    my_struct_package::cache_line_t p2current_line_i[1][4],
    input    my_struct_package::cache_line_t p2current_line_d[1][8],
    input    logic [35:0] hit_bus, 
    input    my_struct_package::command_t instruction,
    output   my_struct_package::cache_line_t p0return_line_i[1][4],
    output   my_struct_package::cache_line_t p0return_line_d[1][8],
    output   my_struct_package::cache_line_t p1return_line_i[1][4],
    output   my_struct_package::cache_line_t p1return_line_d[1][8],
    output   my_struct_package::cache_line_t p2return_line_i[1][4],
    output   my_struct_package::cache_line_t p2return_line_d[1][8]

);

// Import the struct package
import my_struct_package::*;

logic [1:0] internal_state = 2'b11; // initial state of FSM 
logic [2:0] LRU = 0;
//declare internal ways signals
logic [3:0] p0_i_ways;
logic [7:0] p0_d_ways;
logic [3:0] p1_i_ways;
logic [7:0] p1_d_ways;
logic [3:0] p2_i_ways;
logic [7:0] p2_d_ways;

//declare column select signals
logic [1:0] p0_i_select;
logic [2:0] p0_d_select;
logic [1:0] p1_i_select;
logic [2:0] p1_d_select;
logic [1:0] p2_i_select;
logic [2:0] p2_d_select;

//part select hit bus
assign {p0_i_ways,
	p0_d_ways,
	p1_i_ways,
	p1_d_ways,
	p2_i_ways,
	p2_d_ways} = hit_bus;

//encode to select column of cache
//for p0 instruction cache a hit at msb will correspond
//to way/column 0 
always_comb begin
case(p0_i_ways) 

4'b1000: p0_i_select = 2'b00;
4'b0100: p0_i_select = 2'b01;
4'b0010: p0_i_select = 2'b10;
4'b0001: p0_i_select = 2'b11;
4'bz000: p0_i_select = 2'b00;
4'b0z00: p0_i_select = 2'b01;
4'b00z0: p0_i_select = 2'b10;
4'b000z: p0_i_select = 2'b11;
4'bx000: p0_i_select = 2'b00;
4'b0x00: p0_i_select = 2'b01;
4'b00x0: p0_i_select = 2'b10;
4'b000x: p0_i_select = 2'b11;

default: begin
for(int i = 0; i < 4; i++) begin
	if(p0current_line_i[instruction.address.set_index][i].LRU == 0)begin
		p0_i_select = p0current_line_i[instruction.address.set_index][i];
	break;
	end
end
end


endcase
end

always_comb begin
case(p0_d_ways) 

8'b1000_0000: p0_d_select = 3'b000;
8'b0100_0000: p0_d_select = 3'b001;
8'b0010_0000: p0_d_select = 3'b010;
8'b0001_0000: p0_d_select = 3'b011;
8'b0000_1000: p0_d_select = 3'b100;
8'b0000_0100: p0_d_select = 3'b101;
8'b0000_0010: p0_d_select = 3'b110;
8'b0000_0001: p0_d_select = 3'b111;
8'bz000_0000: p0_d_select = 3'b000;
8'b0z00_0000: p0_d_select = 3'b001;
8'b00z0_0000: p0_d_select = 3'b010;
8'b000z_0000: p0_d_select = 3'b011;
8'b0000_z000: p0_d_select = 3'b100;
8'b0000_0z00: p0_d_select = 3'b101;
8'b0000_00z0: p0_d_select = 3'b110;
8'b0000_000z: p0_d_select = 3'b111;
8'bx000_0000: p0_d_select = 3'b000;
8'b0x00_0000: p0_d_select = 3'b001;
8'b00x0_0000: p0_d_select = 3'b010;
8'b000x_0000: p0_d_select = 3'b011;
8'b0000_x000: p0_d_select = 3'b100;
8'b0000_0x00: p0_d_select = 3'b101;
8'b0000_00x0: p0_d_select = 3'b110;
8'b0000_000x: p0_d_select = 3'b111;

default: begin
for(int i = 0; i < 8; i++) begin
	if(p0current_line_d[instruction.address.set_index][i].LRU == 0)begin
		p0_d_select = p0current_line_d[instruction.address.set_index][i];
	break;
	end
end
end
endcase
end

always_comb begin
case(p1_i_ways) 

4'b1000: p1_i_select = 2'b00;
4'b0100: p1_i_select = 2'b01;
4'b0010: p1_i_select = 2'b10;
4'b0001: p1_i_select = 2'b11;
4'bz000: p1_i_select = 2'b00;
4'b0z00: p1_i_select = 2'b01;
4'b00z0: p1_i_select = 2'b10;
4'b000z: p1_i_select = 2'b11;
4'bx000: p1_i_select = 2'b00;
4'b0x00: p1_i_select = 2'b01;
4'b00x0: p1_i_select = 2'b10;
4'b000x: p1_i_select = 2'b11;

default: begin
for(int i = 0; i < 4; i++) begin
	if(p1current_line_i[instruction.address.set_index][i].LRU == 0)begin
		p1_i_select = p1current_line_i[instruction.address.set_index][i];
	break;
	end
end
end
endcase
end

always_comb begin
    case(p1_d_ways) 
        8'b1000_0000: p1_d_select = 4'b000;
        8'b0100_0000: p1_d_select = 4'b001;
        8'b0010_0000: p1_d_select = 4'b010;
        8'b0001_0000: p1_d_select = 4'b011;
        8'b0000_1000: p1_d_select = 4'b100;
        8'b0000_0100: p1_d_select = 4'b101;
        8'b0000_0010: p1_d_select = 4'b110;
        8'b0000_0001: p1_d_select = 4'b111;
        8'bz000_0000: p1_d_select = 4'b000;
        8'b0z00_0000: p1_d_select = 4'b001;
        8'b00z0_0000: p1_d_select = 4'b010;
        8'b000z_0000: p1_d_select = 4'b011;
        8'b0000_z000: p1_d_select = 4'b100;
        8'b0000_0z00: p1_d_select = 4'b101;
        8'b0000_00z0: p1_d_select = 4'b110;
        8'b0000_000z: p1_d_select = 4'b111;
        8'bx000_0000: p1_d_select = 4'b000;
        8'b0x00_0000: p1_d_select = 4'b001;
        8'b00x0_0000: p1_d_select = 4'b010;
        8'b000x_0000: p1_d_select = 4'b011;
        8'b0000_x000: p1_d_select = 4'b100;
        8'b0000_0x00: p1_d_select = 4'b101;
        8'b0000_00x0: p1_d_select = 4'b110;
        8'b0000_000x: p1_d_select = 4'b111;
        default: begin
	for(int i = 0; i < 8; i++) begin
	if(p1current_line_d[instruction.address.set_index][i].LRU == 0)begin
		p1_d_select = p1current_line_d[instruction.address.set_index][i];
	break;
	end
end
end
    endcase
end

always_comb begin
case(p2_i_ways) 

4'b1000: p2_i_select = 2'b00;
4'b0100: p2_i_select = 2'b01;
4'b0010: p2_i_select = 2'b10;
4'b0001: p2_i_select = 2'b11;
4'bz000: p2_i_select = 2'b00;
4'b0z00: p2_i_select = 2'b01;
4'b00z0: p2_i_select = 2'b10;
4'b000z: p2_i_select = 2'b11;
4'bx000: p2_i_select = 2'b00;
4'b0x00: p2_i_select = 2'b01;
4'b00x0: p2_i_select = 2'b10;
4'b000x: p2_i_select = 2'b11;

default: begin
for(int i = 0; i < 4; i++) begin
	if(p2current_line_i[instruction.address.set_index][i].LRU == 0)begin
		p2_i_select = p2current_line_i[instruction.address.set_index][i];
	break;
	end
end
end
endcase
end

always_comb begin
    case(p2_d_ways) 
        8'b1000_0000: p2_d_select = 4'b000;
        8'b0100_0000: p2_d_select = 4'b001;
        8'b0010_0000: p2_d_select = 4'b010;
        8'b0001_0000: p2_d_select = 4'b011;
        8'b0000_1000: p2_d_select = 4'b100;
        8'b0000_0100: p2_d_select = 4'b101;
        8'b0000_0010: p2_d_select = 4'b110;
        8'b0000_0001: p2_d_select = 4'b111;
        8'bz000_0000: p2_d_select = 4'b000;
        8'b0z00_0000: p2_d_select = 4'b001;
        8'b00z0_0000: p2_d_select = 4'b010;
        8'b000z_0000: p2_d_select = 4'b011;
        8'b0000_z000: p2_d_select = 4'b100;
        8'b0000_0z00: p2_d_select = 4'b101;
        8'b0000_00z0: p2_d_select = 4'b110;
        8'b0000_000z: p2_d_select = 4'b111;
        8'bx000_0000: p2_d_select = 4'b000;
        8'b0x00_0000: p2_d_select = 4'b001;
        8'b00x0_0000: p2_d_select = 4'b010;
        8'b000x_0000: p2_d_select = 4'b011;
        8'b0000_x000: p2_d_select = 4'b100;
        8'b0000_0x00: p2_d_select = 4'b101;
        8'b0000_00x0: p2_d_select = 4'b110;
        8'b0000_000x: p2_d_select = 4'b111;
        default: begin
	for(int i = 0; i < 4; i++) begin
	if(p2current_line_d[instruction.address.set_index][i].LRU == 0)begin
		p2_d_select = p2current_line_d[instruction.address.set_index][i];
	break;
	end
  	end
end
    endcase
end


// Send owner cacheline to FSM
always_comb begin
    case(instruction.PID)
        0: begin 
            case(instruction.n)
                0, 1: begin
                    internal_state = p0current_line_d[instruction.address.set_index][p0_d_select].MESI_bits;
                end
                2: begin
                    internal_state = p0current_line_d[instruction.address.set_index][p0_i_select].MESI_bits;
                end
                3: begin 
                    internal_state = p0current_line_d[instruction.address.set_index][p0_d_select].MESI_bits;
                end
                4: begin
                    internal_state = p0current_line_d[instruction.address.set_index][p0_d_select].MESI_bits;
                end
                8, 9: begin
                    // Do nothing or add specific functionality based on your design
                end
            endcase
        end

        1: begin
            case(instruction.n)
                0, 1: begin
                    internal_state = p1current_line_d[instruction.address.set_index][p1_d_select].MESI_bits;
                end
                2: begin
                    internal_state = p1current_line_d[instruction.address.set_index][p1_i_select].MESI_bits;
                end
                3: begin 
                    internal_state = p1current_line_d[instruction.address.set_index][p1_d_select].MESI_bits;
                end
                4: begin
                    internal_state = p1current_line_d[instruction.address.set_index][p1_d_select].MESI_bits;
                end
                8, 9: begin
                    // Do nothing or add specific functionality 
                end
            endcase
        end

        2: begin
            case(instruction.n)
                0, 1: begin
                    internal_state = p2current_line_d[instruction.address.set_index][p2_d_select].MESI_bits;
                end
                2: begin
                    internal_state = p2current_line_d[instruction.address.set_index][p2_i_select].MESI_bits;
                end
                3: begin 
                    internal_state = p2current_line_d[instruction.address.set_index][p2_d_select].MESI_bits;
                end
                4: begin
                    internal_state = p2current_line_d[instruction.address.set_index][p2_d_select].MESI_bits;
                end
                8, 9: begin
                    // Do nothing or add specific functionality 
                end
            endcase
        end

        default: begin
            // Do nothing
            $display("No owner found");
        end
    endcase
end



endmodule
