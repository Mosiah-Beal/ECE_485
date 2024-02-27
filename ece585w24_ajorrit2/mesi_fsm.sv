// Import the struct package
import my_struct_package::*;

module mesi_fsm(
    input logic clk,
    input logic rst,
    input command_t instruction,
    input cache_line_t internal_line,  
    input logic hit, 
    input logic hitM, 
    output cache_line_t return_line
);

    // Declare state variables
    states_t state, nextstate;
	

    // Sequential logic block for state transition
    always_ff@(posedge clk) begin: Sequential_Logic
        if (rst)
	    internal_line.MESI_bits <= E;
        else
            internal_line.MESI_bits <= nextstate;
    end

    // Combinational logic block for determining the next state based on the current state and input
    always_comb begin: Next_State_Logic
        $display(" internal_line[0][0].tag = %h     : internal_line[0][0].LRU = %h \n internal_line[0][0].MESI_bits = %h : internal_line[0][0].data = %h", internal_line.tag, internal_line.LRU, internal_line.MESI_bits, internal_line.data); 
        $display(" return_line[0][0].tag   = %h     : return_line.LRU[0][0]   = %h \n return_line[0][0].MESI_bits   = %h : return_line[0][0].data   = %h", return_line.tag,return_line.LRU,return_line.MESI_bits,return_line.data);
        case (internal_line.MESI_bits)
            M: begin
                $display("Modified", $time);
                case (instruction.n)
                    0, 1:   // (0) local read (assumed from same processor due to requirements, no transition to S)
                            // (1) local write
                    begin
                        nextstate = M;  // Local changes stay in M (may need to send signals)
                    end
                    2:      // (2) instruction fetch
                    begin
                        nextstate = M;  
                    end
                    3, 8:   // (3) Invalidate
                            // (8) clear and reset
                    begin
                        nextstate = I;
                    end
                    4:      // (4) Writeback (RFO, snoop) (owner -> E, others -> I)
                    begin
                        nextstate = S;  // Multi-step process
                    end
                    default: // Invalid instruction, stay in M
                    begin
                        nextstate = M;
                    end
                endcase
            end
        
            E: begin
                $display("Exclusive", $time);
                case (instruction.n)
                    0: begin   // (Assumed from different processor due to requirements, transition to S)
                        nextstate = S;
                    end
                    1: begin   // local write
                        nextstate = M;
                    end
                    2: begin
                        nextstate = E;
                    end
                    3, 8: begin   // Invalidate
                        nextstate = I;
                    end
                    4: begin
                        nextstate = S;
                    end
                    default: begin
                        nextstate = E;
                    end
                endcase
            end

            S: begin
                $display("Shared", $time);
                case (instruction.n)
                    0, 2, 4: begin   // local read or no change in state
                        nextstate = S;
                    end
                    1: begin   // local write
                        nextstate = M;
                    end
                    3, 8: begin   // Invalidate
                        nextstate = I;
                    end
                    default: begin
                        nextstate = S;
                    end
                endcase
            end

            I: begin
                $display("Invalid", $time);
                case (instruction.n)
                    0, 2: begin
                    //  if (hit || hitM)
                        //  nextstate = S; // Multiple read or Transition to S or E depending on snoop hardware
                    // else
                            nextstate = E;  // Single read
                    end
                    1: begin   // RFO
                        nextstate = M;
                    end
                    3, 4, 8: begin   // Invalidate
                        nextstate = I;
                    end
                    default: begin
                        nextstate = I;
                    end
                endcase
            end

            default: nextstate <= E;
        endcase
    end

    // Combinational logic block for determining outputs based on the current state and input
    always_comb begin: Output_Logic
        // Copy internal_line to return_line
        return_line.tag = internal_line.tag;
        
        // Update mesi_bits based on nextstate
        return_line.MESI_bits = nextstate;
	return_line.LRU = 0;
        
    end

endmodule 