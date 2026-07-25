`timescale 1ns / 1ps

module matmul_tb;
    reg clk, reset, start;
    reg [7:0] A [0:3][0:3];
    reg [7:0] B [0:3][0:3];
    wire [31:0] C [0:3][0:3];
    wire done;
    integer i, j;
    
    wire [7:0] a_temp [0:3][0:3];
    wire [7:0] b_temp [0:3][0:3];
    wire [31:0] c_temp [0:3][0:3];
    
    genvar gi, gj;
    generate
        for (gi = 0; gi < 4; gi = gi + 1) begin : row_gen
            for (gj = 0; gj < 4; gj = gj + 1) begin : col_gen
                assign a_temp[gi][gj] = A[gi][gj];
                assign b_temp[gi][gj] = B[gi][gj];
                assign C[gi][gj] = c_temp[gi][gj];
            end
        end
    endgenerate

    systolic u_dut(
        .clk(clk),
        .reset(reset),
        .a_in(a_temp),
        .b_in(b_temp),
        .c(c_temp),
        .start(start),
        .done(done)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        start = 0;
        
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                A[i][j] = (i == j) ? 8'd1 : 8'd0;
                B[i][j] = (i == j) ? 8'd2 : 8'd0;
            end
        end

        #10 reset = 0;
        #10 start = 1;
        #10 start = 0;

        wait(done);
        #10;

        $display("=== Result ===");
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                $display("C[%d][%d] = %d", i, j, C[i][j]);
            end
        end

        $finish;
    end
endmodule