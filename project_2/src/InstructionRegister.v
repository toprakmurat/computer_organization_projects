`timescale 1ns / 1ps

/*
    Module Authors: Murat Toprak & Vedat Enis G�l

    Implementation of the Instruction Register
*/

module InstructionRegister(I, Write, LH, Clock, IROut);
    input wire [7:0]    I;
    input wire          Write;
    input wire          LH;
    input wire          Clock;
    output reg [15:0]   IROut;

    always @(posedge Clock)
    begin
        if (Write)
            IROut <= (LH) ? {I, IROut[7:0]} : {IROut[15:8], I};
        else
            IROut <= IROut;
    end
endmodule
