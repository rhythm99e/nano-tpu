module systolic(input logic clk,
input logic reset,
input logic [7:0] a_in[3:0][3:0],
input logic [7:0] b_in[3:0][3:0],
output logic [31:0] c[3:0][3:0],
input logic start,
output logic done
);

logic [7:0] a[3:0][4:0];
logic [7:0] b[4:0][3:0];
logic [7:0] a_initial[3:0];
logic [7:0] b_initial[3:0];
stagger so(
    .clk(clk),
    .reset(reset),
    .start(start),
    .a_in(a_in),
    .b_in(b_in),
    .a_out(a_initial),
    .b_out(b_initial),
    .done(done)
);

genvar i,j;
generate
for (i=0;i<4;i=i+1)begin: loop
    assign a[i][0]=a_initial[i];
    assign b[0][i]=b_initial[i];
end
endgenerate
generate
for (i=0;i<4;i=i+1)begin: loopi
    for (j=0;j<4;j=j+1)begin: loopj
     pe p(
        .clk(clk),
        .reset(reset),
        .a_in(a[i][j]),
        .b_in(b[i][j]),
        .result(c[i][j]),
        .a_out(a[i][j+1]),
        .b_out(b[i+1][j])
     );
    end
end
endgenerate
endmodule