`timescale 1ns / 1ps

module matmul_tb;
    reg clk, reset, start;
    reg [7:0] A [3:0][3:0];
    reg [7:0] B [3:0][3:0];
    wire [31:0] C [3:0][3:0];
    wire done;
    integer i;
    integer cycle_num;

    wire [7:0] a_temp [3:0][3:0];
    wire [7:0] b_temp [3:0][3:0];
    wire [31:0] c_temp [3:0][3:0];

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

    // Clock generation
    always #5 clk = ~clk;

    // Timeout watchdog
    initial begin
        #2000;
        $display("");
        $display("=== TIMEOUT ===");
        $finish;
    end

    // Cycle-by-cycle PE(0,0) trace
    initial begin
        cycle_num = 0;
        @(negedge reset);
        $display("");
        $display("=========================================================================");
        $display(" Cycle | start | run | cyc_cnt | a_in(0,0) | b_in(0,0) | PE(0,0).result | c[0][0] | c_temp[0][0] | done");
        $display("=========================================================================");
        forever begin
            @(posedge clk);
            #1;
            $display("  %0d   |   %b   |  %b  |    %0d    |    %0d      |    %0d      |      %0d       |    %0d    |     %0d       |  %b",
                cycle_num,
                start,
                u_dut.so.running,
                u_dut.so.cycle_count,
                u_dut.loopi[0].loopj[0].p.a_in,
                u_dut.loopi[0].loopj[0].p.b_in,
                u_dut.loopi[0].loopj[0].p.result,
                u_dut.c[0][0],
                c_temp[0][0],
                done
            );
            cycle_num = cycle_num + 1;
            if (cycle_num > 25) $finish;
        end
    end

    // Probe what stagger actually receives at its input port
    initial begin
        @(negedge reset);
        @(posedge clk); #1;
        $display("");
        $display("=== Stagger input-port probe ===");
        $display("  Testbench A[0][0] = %0d, stagger sees a_in[0][0] = %0d", A[0][0], u_dut.so.a_in[0][0]);
        $display("  Testbench A[3][3] = %0d, stagger sees a_in[3][3] = %0d", A[3][3], u_dut.so.a_in[3][3]);
        $display("  Testbench A[0][3] = %0d, stagger sees a_in[0][3] = %0d", A[0][3], u_dut.so.a_in[0][3]);
        $display("  Testbench A[3][0] = %0d, stagger sees a_in[3][0] = %0d", A[3][0], u_dut.so.a_in[3][0]);
        $display("================================");
        $display("");
    end

    // Stimulus
    initial begin
        clk = 0;
        reset = 1;
        start = 0;

        // Row 0
        A[0][0]=1; A[0][1]=2; A[0][2]=3; A[0][3]=4;
        // Row 1
        A[1][0]=2; A[1][1]=3; A[1][2]=4; A[1][3]=5;
        // Row 2
        A[2][0]=3; A[2][1]=4; A[2][2]=5; A[2][3]=6;
        // Row 3
        A[3][0]=4; A[3][1]=5; A[3][2]=6; A[3][3]=7;

        // B: each row constant
        B[0][0]=1; B[0][1]=1; B[0][2]=1; B[0][3]=1;
        B[1][0]=2; B[1][1]=2; B[1][2]=2; B[1][3]=2;
        B[2][0]=3; B[2][1]=3; B[2][2]=3; B[2][3]=3;
        B[3][0]=4; B[3][1]=4; B[3][2]=4; B[3][3]=4;

        $display("");
        $display("Matrix A:");
        for (i = 0; i < 4; i = i + 1)
            $display("  [%0d %0d %0d %0d]", A[i][0], A[i][1], A[i][2], A[i][3]);
        $display("");
        $display("Matrix B:");
        for (i = 0; i < 4; i = i + 1)
            $display("  [%0d %0d %0d %0d]", B[i][0], B[i][1], B[i][2], B[i][3]);
        $display("");
        $display("Expected C[0][0] = 1*1 + 2*2 + 3*3 + 4*4 = 30");
        $display("Expected C[3][3] = 4*1 + 5*2 + 6*3 + 7*4 = 60");
        $display("");

        #30 reset = 0;
        @(posedge clk); #1 start = 1;
        @(posedge clk); #1 start = 0;

        wait(done == 1'b1);
        repeat(10) @(posedge clk);

        $display("");
        $display("Final C matrix:");
        for (i = 0; i < 4; i = i + 1)
            $display("  [%0d %0d %0d %0d]", C[i][0], C[i][1], C[i][2], C[i][3]);

        $finish;
    end
endmodule