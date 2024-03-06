module count(input start, input logic rst, output logic [2:0] sum);


always_ff@(posedge start) begin
if (rst) begin
            // Reset the counter value to zero if the reset signal is asserted
            sum <= 2'b0;
        end 
	else begin
            // Increment the counter value on each clock cycle
            sum <= sum + 1;
        end
end
endmodule