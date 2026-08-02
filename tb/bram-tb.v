`timescale 1ns / 1ps

module bram_tb;
    reg clk;
    reg we_a;
    reg [3:0] addr_a;
    reg [7:0] din_a;
    wire [7:0] dout_a;
    reg we_b;
    reg [3:0] addr_b;
    reg [7:0] din_b;
    wire [7:0] dout_b;
    integer i;
    integer errors;
    
    bram #(.DATA_WIDTH(8), .ADDR_WIDTH(4)) u_bram (
        .clk(clk),
        .we_a(we_a),
        .addr_a(addr_a),
        .din_a(din_a),
        .dout_a(dout_a),
        .we_b(we_b),
        .addr_b(addr_b),
        .din_b(din_b),
        .dout_b(dout_b)
    );
    
    always #5 clk = ~clk;
    
    initial begin
        #5000;
        $display("=== TIMEOUT ===");
        $finish;
    end
    
    initial begin
        clk = 0;
        we_a = 0;
        we_b = 0;
        addr_a = 0;
        addr_b = 0;
        din_a = 0;
        din_b = 0;
        errors = 0;
        
        #20;
        
        $display("");
        $display("=== TEST 1: Writing 16 values via Port A ===");
        for (i = 0; i < 16; i = i + 1) begin
            @(posedge clk); #1;
            we_a = 1;
            addr_a = i;
            din_a = i * 10;
        end
        
        // Clean up after TEST 1
        @(posedge clk); #1;
        we_a = 0;
        addr_a = 0;
        din_a = 0;
        
        $display("");
        $display("=== TEST 2: Reading via Port B ===");
        for (i = 0; i < 16; i = i + 1) begin
            addr_b = i;
            @(posedge clk); #1;
            if (dout_b !== (i * 10)) begin//cause dout wont be updated in the same cycle
                $display("  FAIL: mem[%0d] = %0d, expected %0d", i, dout_b, i * 10);
                errors = errors + 1;
            end else begin
                $display("  PASS: mem[%0d] = %0d", i, dout_b);
            end
        end
        
        $display("");
        if (errors == 0)
            $display("=== ALL TESTS PASSED ===");
        else
            $display("=== %0d ERRORS ===", errors);
        
        #50;
        $finish;
    end
endmodule