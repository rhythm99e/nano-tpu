`timescale 1ns / 1ps
module bram #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
) (
    input  logic                     clk,
    input  logic                     we_a,
    input  logic [ADDR_WIDTH-1:0]    addr_a,
    input  logic [DATA_WIDTH-1:0]    din_a,
    output logic [DATA_WIDTH-1:0]    dout_a,
    
    input  logic                     we_b,
    input  logic [ADDR_WIDTH-1:0]    addr_b,
    input  logic [DATA_WIDTH-1:0]    din_b,
    output logic [DATA_WIDTH-1:0]    dout_b
);

 logic [DATA_WIDTH-1:0] mem [(2**ADDR_WIDTH)-1:0];
    always_ff @(posedge clk) begin
        if (we_a)
            mem[addr_a] <= din_a;
        dout_a <= mem[addr_a];
    end

    always_ff @(posedge clk) begin
        if (we_b)
            mem[addr_b] <= din_b;
        dout_b <= mem[addr_b];
    end

endmodule