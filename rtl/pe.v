module pe(input clk,
input reset,
input [7:0]a_in,
input [7:0]b_in,
output reg[7:0] a_out,
output reg[7:0]b_out,
output reg[31:0] result);
always @(posedge clk ) //synchronous
begin
    if(reset) begin
    a_out<= 8'b0;
    b_out<= 8'b0;
    result<= 32'b0;
    end
    else
    begin
    a_out<= a_in;
    b_out<= b_in;
    result<=result + a_in*b_in;
    end
end
endmodule


