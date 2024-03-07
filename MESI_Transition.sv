always_comb begin: Next_State_Logic
    case (state)
        M: begin
            $display("Modified", $time);
            case (n)
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
            case (n)
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
            case (n)
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
            case (n)
                0, 2: begin
                    if (hit || hitM)
                        nextstate = S; // Multiple read or Transition to S or E depending on snoop hardware
                    else
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

        default: nextstate <= I;
    endcase
end