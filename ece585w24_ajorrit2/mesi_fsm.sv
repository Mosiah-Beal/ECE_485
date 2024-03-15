
import my_struct_package::*;

module mesi_fsm(
    /* Signal ports
    * top: clk, rst, instruction, hit, hitM
    * cache: return_line, internal_line
    */

    input  logic clk,
    input  logic rst,
    input  command_t instruction,
    input  cache_line_t internal_line,  
    output cache_line_t return_line
    );

    // Declare state variables
    states_t state, nextstate;

    // Sequential logic block for state transition
    always_ff @(posedge clk) begin
        if (rst)
            state <= I;
        else
            state <= nextstate;
    end

    // Combinational logic block for determining the next state based on the current state and input
    always_comb begin
        case (internal_line.MESI_bits)
            M: begin
                case (instruction.n)
                    3, 8: nextstate = I;
                    4: nextstate = I;
                    default: nextstate = M;
                endcase
            end

            E: begin
                case (instruction.n)
                    0, 4: nextstate = S;
                    1: nextstate = M;
                    3, 8: nextstate = I;
                    default: nextstate = E;
                endcase
            end

            S: begin
                case (instruction.n)
                    1: nextstate = M;
                    3, 8: nextstate = I;
                    default: nextstate = S;
                endcase
            end

            I: begin
                case (instruction.n)
		            0,2: nextstate = E;
                    1: nextstate = M;
                    default: nextstate = I;
                endcase
            end

            default: nextstate = I;
        endcase
    end

    // Combinational logic block for determining outputs based on the current state and input
    always_comb begin
        return_line = internal_line;
        return_line.MESI_bits = state;
    end
endmodule
