`timescale 1ns / 1ps

/*
    Module Authors: Murat Toprak & Vedat Enis Gül

    Implementation of a 16-bit Register
*/

module Register16bit (I, E, FunSel, Clock, Q);
    input wire [15:0]   I;
    input wire          E;
    input wire [1:0]    FunSel;
    input wire          Clock;
    output reg [15:0]   Q;

    always @(posedge Clock)
    begin
        if (E)
        begin
            case (FunSel)
                2'b00:      Q <= Q - 1;
                2'b01:      Q <= Q + 1;
                2'b10:      Q <= I;
                2'b11:      Q <= 16'b0;

                default:    Q <= Q;
            endcase
        end
        /* E=0 => retain current value in the Q */
    end
endmodule
