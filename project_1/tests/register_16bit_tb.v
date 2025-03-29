`timescale 1ns / 1ps

module register_16bit_tb;

    reg clk;
    reg E;
    reg [1:0] FunSel;
    reg [15:0] I;
    wire [15:0] Q;

    register_16bit uut (
        .clock(clk),
        .E(E),
        .FunSel(FunSel),
        .In(I),
        .Out(Q)
    );

    always #5 clk = ~clk;  // Generate a 5ns clock

    initial begin
        clk = 0; E = 0; FunSel = 2'b00; I = 16'hAAAA;

        #20 E = 1; FunSel = 2'b10; I = 16'h1234; // Load
        #20 FunSel = 2'b01; // Increment
        #20 FunSel = 2'b00; // Decrement
        #20 FunSel = 2'b11; // Clear
        #20 E = 0; FunSel = 2'b00; // Retain
        #20 $finish;
    end

endmodule
