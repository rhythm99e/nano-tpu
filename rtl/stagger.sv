module stagger(input clk,
input reset,
input start,
input logic [7:0] a_in[3:0][3:0],
input logic [7:0] b_in[3:0][3:0],
output logic [7:0] a_out[3:0],
output logic [7:0] b_out[3:0],
output logic done);

localparam int total_cycle=7;
logic [3:0] cycle_count;
logic running;
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        cycle_count <=0;
        running <=0;
        done <=0;
    end
    else if(start && !running)begin
        running <=1;
        cycle_count<=0;
    end
    else if(running)begin
        for (int i=0;i<4;i++)begin
            if(cycle_count>=i&&cycle_count<i+4)begin
                a_out[i]<=a_in[i][cycle_count-i];
            end
            else
                a_out[i]<=0;
            if(cycle_count>=i&&cycle_count<i+4)begin
                b_out[i]<=b_in[cycle_count-i][i];
            end
            else
                b_out[i]<=0;
            if(cycle_count==total_cycle-1)begin
                done<=1;
                running<=0;
            end
            else
                cycle_count<=cycle_count+1;
        end
    end
end
endmodule
