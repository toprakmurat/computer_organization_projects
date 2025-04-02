`timescale 1ns / 1ps

/*
    Module Authors: Murat Toprak & Vedat Enis Gül
    Implementation of the Instruction Register
    
    Maximum line length is 73 characters
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
            IROut <= (LH) ? {I[7:0], IROut[7:0]} : {IROut[15:8], I[7:0]};
        else
            IROut <= IROut;
    end
endmodule