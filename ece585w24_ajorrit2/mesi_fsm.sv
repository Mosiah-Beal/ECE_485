module mesi_fsm(
    input logic clk,
    input logic rst,
    input  my_struct_package::command_t instruction,
    input my_struct_package::cache_line_t internal_line[1][1],  
    input logic hit, 
    input logic hitM, 
    output my_struct_package::cache_line_t return_line[1][1]
);


    // Import the struct package
    import my_struct_package::*;


    // Declare state variables
    states_t state, nextstate;
	

      // Sequential logic block for state transition
    always_ff@(posedge clk) begin: Sequential_Logic
        if (rst)
	    internal_line[0][0].MESI_bits <= E;
        else
            internal_line[0][0].MESI_bits <= nextstate;
    end

    // Combinational logic block for determining the next state based on the current state and input
 always_comb begin: Next_State_Logic
$display("internal_line[0][0].tag = %h : internal_line[0][0].LRU = %h : internal_line[0][0].MESI_bits = %c : internal_line[0][0].data = %h", internal_line[0][0].tag,internal_line[0][0].LRU,internal_line[0][0].MESI_bits,internal_line[0][0].data); 
$display("return_line[0][0].tag   = %h : return_line.LRU[0][0]   = %h : return_line[0][0].MESI_bits   = %c : return_line[0][0].data   = %h", return_line[0][0].tag,return_line[0][0].LRU,return_line[0][0].MESI_bits,return_line[0][0].data);
    case (internal_line[0][0].MESI_bits)
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
        return_line[0][0] = internal_line[0][0];

        // Update mesi_bits based on nextstate
        return_line[0][0].MESI_bits = nextstate;
	return_line[0][0].LRU = 0;
    
end

endmodule 
