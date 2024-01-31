module MESI_controller(
    input logic clk,
    input logic rst,
    input logic [3] n,
    input logic [32] address,
    input logic hit, //same as busRd but input
    input logic hitM, // same as busRdx but input
    input logic [14] cache_bus_in,
    output logic [2] cache_bus_out,
    output logic [2] state_out,
    output logic busRd, 
    output logic busRdX
);

    // Define an enumerated type for states
    typedef enum logic [2] {
        M = 2'b01,
        E = 2'b00,
        S = 2'b10,
        I = 2'b11
    } states_t;

    // Declare state variables
    states_t state, nextstate;

    // Sequential logic block for state transition
    always_ff @(posedge clk) begin: Sequential_Logic
        if (rst)
            state <= I;
	/*else if(flag) 
		state <= [0:1] cache_bus_in; */
        else
            state <= nextstate;
    end

    // Combinational logic block for determining the next state based on the current state and input
    always_comb begin: Next_State_Logic
        case (state)
            M: begin
$display("Modified", $time);
                case (n)
                    0: nextstate = M;
                    1: nextstate = M;
                    2: nextstate = M;
                    3: nextstate = I;
                    4: nextstate = S;
                    8: nextstate = I;
                    default: nextstate = M;
                endcase
            end
            
            E: begin
$display("Exclusive", $time);
                case (n)
                    0: nextstate = E;
                    1: nextstate = M;
                    2: nextstate = E;
                    3: nextstate = I;
                    4: nextstate = S;
                    8: nextstate = I;
                    default: nextstate = E;
                endcase
            end
            
            S: begin
$display("Shared", $time);
                case (n)
                    0: nextstate = S;
                    1: nextstate = M;
                    2: nextstate = S;
                    3: nextstate = I;
                    4: nextstate = S;
                    8: nextstate = I;
                    default: nextstate = S;
                endcase
            end
            
            I: begin
$display("Invalid", $time);
                case (n)
                    0: begin
                        if (hit || hitM)
                            nextstate = S; // Transition to S or E depending on snoop hardware
                        else
                            nextstate = E;
                        end
                    1: nextstate = M; // RFO
                    2: begin
                        if (hit || hitM)
                            nextstate = S; // Transition to S or E depending on snoop hardware
                        else
                            nextstate = E;
                        end
                    3: nextstate = I;
                    4: nextstate = I;
                    8: nextstate = I;
                    default: nextstate = I;
                endcase
            end
            
            default: nextstate <= I;
        endcase
    end

    // Combinational logic block for determining outputs based on the current state and input
    always_comb begin: Output_Logic
	state_out = state;
	case(state)
        M:begin
        cache_bus_out = state;
        busRdX = 0;
        busRd = 0;
        end	

        E:begin
        cache_bus_out = state;
        busRdX = 0;
        busRd = 0;
        end

        S:begin
        cache_bus_out = state;
        busRdX = 0;
        busRd = 0;
            
        end

        I:begin
            cache_bus_out = state;
            case(n)
                0: begin
                cache_bus_out = state;
                busRd = 1;
                busRdX = 0;
                end
                1: begin
                cache_bus_out = state;
                busRdX = 1;
                busRd = 0;
                end
                default: begin
                cache_bus_out = state;
                end
            endcase
        end

        default: begin
        cache_bus_out = state;
        $display("fell through %d", $time);
        
        end

    endcase
    end

endmodule
