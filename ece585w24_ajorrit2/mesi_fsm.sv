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
    case (internal_line[0][0].MESI_bits)
        M: begin
            case (instruction.n)
                0, 1:   // (0) local read (assumed from same processor due to requirements, no transition to S)
                       // (1) local write
                begin
                    return_line[1][1] = internal_line[1][1];
    		     // Local changes stay in M (may need to send signals)

                end
                2:      // (2) instruction fetch
                begin
                    return_line[1][1] = internal_line[1][1];
    		   
                end
                3, 8:   // (3) Invalidate
                        // (8) clear and reset
                begin
		    return_line[1][1] = internal_line[1][1];
                    return_line[1][1].MESI_bits = I;
                end
                4:      // (4) Writeback (RFO, snoop) (owner -> E, others -> I)
                begin
		    return_line[1][1] = internal_line[1][1];
                    return_line[1][1].MESI_bits = E;  // Multi-step process
                end
                default: // Invalid instruction, stay in M
                begin
                    return_line[1][1] = internal_line[1][1];
                end
            endcase
        end
    
        E: begin
            case (instruction.n)
                0: begin   // (Assumed from different processor due to requirements, transition to S)
                    return_line[1][1] = internal_line[1][1];
		    return_line[1][1].MESI_bits = S;
                end
                1: begin   // local write
                    return_line[1][1] = internal_line[1][1];
		    return_line[1][1].MESI_bits = M;
                end
                2: begin
                    return_line[1][1] = internal_line[1][1];
		    return_line[1][1].MESI_bits = E;
                end
                3, 8: begin   // Invalidate
                     return_line[1][1] = internal_line[1][1];
		    return_line[1][1].MESI_bits = I;
                end
                4: begin
		 return_line[1][1] = internal_line[1][1];
		    return_line[1][1].MESI_bits = S;
                end
                default: begin
                     return_line[1][1] = internal_line[1][1];
                end
            endcase
        end

        S: begin
            case (instruction.n)
                0, 2, 4: begin   // local read or no change in state
		 return_line[1][1] = internal_line[1][1];
		    return_line[1][1].MESI_bits = S;
                end
                1: begin   // local write
                     return_line[1][1] = internal_line[1][1];
		    return_line[1][1].MESI_bits = M;
                end
                3, 8: begin   // Invalidate
                     return_line[1][1] = internal_line[1][1];
		    return_line[1][1].MESI_bits = I;
                end
                default: begin
                     return_line[1][1] = internal_line[1][1];
		 end              
	   endcase
        end

        I: begin
            case (instruction.n)
                0, 2: begin
                    //if (hit || hitM)begin
                   /// return_line[1][1] = internal_line[1][1];
		   // return_line[1][1].MESI_bits = S; // Multiple read or Transition to S or E depending on snoop hardware
		   // end
                    ///else begin
		    return_line[1][1] = internal_line[1][1];
		    return_line[1][1].MESI_bits = E; // Single read
		    //end
                end
                1: begin   // RFO
                    return_line[1][1] = internal_line[1][1];
		    return_line[1][1].MESI_bits = M;
                end
                3, 4, 8: begin   // Invalidate
                    return_line[1][1] = internal_line[1][1];
		    return_line[1][1].MESI_bits = I;
                end
                default: begin
                     return_line[1][1] = internal_line[1][1];
                end
            endcase
        end

        default:    begin return_line[1][1] = internal_line[1][1];
		    return_line[1][1].MESI_bits = I;
		end
    endcase
end

endmodule 
