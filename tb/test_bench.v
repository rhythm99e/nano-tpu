`timescale 1ns / 1ps

module matmul_tb;
    reg clk, reset, start;
    reg [7:0] A [0:3][0:3];
    reg [7:0] B [0:3][0:3];
    reg [31:0] expected [0:3][0:3];
    wire [31:0] C [0:3][0:3];
    wire done;
    integer i, j;
    integer errors;

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
        #10000;
        $display("TIMEOUT");
        $finish;
    end

    initial begin
        errors = 0;
        clk = 0;
        reset = 1;
        start = 0;

        A[0][0]=0; A[0][1]=2; A[0][2]=3; A[0][3]=4;
        A[1][0]=2; A[1][1]=3; A[1][2]=4; A[1][3]=5;
        A[2][0]=3; A[2][1]=4; A[2][2]=5; A[2][3]=6;
        A[3][0]=4; A[3][1]=5; A[3][2]=6; A[3][3]=7;

        B[0][0]=1; B[0][1]=1; B[0][2]=1; B[0][3]=1;
        B[1][0]=2; B[1][1]=2; B[1][2]=2; B[1][3]=2;
        B[2][0]=3; B[2][1]=3; B[2][2]=3; B[2][3]=3;
        B[3][0]=4; B[3][1]=4; B[3][2]=4; B[3][3]=4;

        expected[0][0]=29; expected[0][1]=29; expected[0][2]=29; expected[0][3]=29;
        expected[1][0]=40; expected[1][1]=40; expected[1][2]=40; expected[1][3]=40;
        expected[2][0]=50; expected[2][1]=50; expected[2][2]=50; expected[2][3]=50;
        expected[3][0]=60; expected[3][1]=60; expected[3][2]=60; expected[3][3]=60;

        $display("");
        $display("Matrix A:");
        for (i = 0; i < 4; i = i + 1)
            $display("  [%3d %3d %3d %3d]", A[i][0], A[i][1], A[i][2], A[i][3]);
        $display("");
        $display("Matrix B:");
        for (i = 0; i < 4; i = i + 1)
            $display("  [%3d %3d %3d %3d]", B[i][0], B[i][1], B[i][2], B[i][3]);
        $display("");
        $display("Expected C = A x B:");
        for (i = 0; i < 4; i = i + 1)
            $display("  [%3d %3d %3d %3d]", expected[i][0], expected[i][1], expected[i][2], expected[i][3]);

        #30 reset = 0;
        @(posedge clk); #1 start = 1;
        @(posedge clk); #1 start = 0;

        wait(done == 1'b1);
        repeat(10) @(posedge clk);

        $display("");
        $display("Actual C:");
        for (i = 0; i < 4; i = i + 1)
            $display("  [%3d %3d %3d %3d]", C[i][0], C[i][1], C[i][2], C[i][3]);

        $display("");
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                if (C[i][j] === expected[i][j])
                    $display("  C[%0d][%0d] = %3d  [PASS]", i, j, C[i][j]);
                else begin
                    $display("  C[%0d][%0d] = %3d  [FAIL expected %0d]", i, j, C[i][j], expected[i][j]);
                    errors = errors + 1;
                end
            end
        end

        $display("");
        if (errors == 0)
            $display("ALL PASS");
        else
            $display("%0d ERRORS", errors);

        $finish;
    end
endmodule