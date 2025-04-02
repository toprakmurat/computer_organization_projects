`timescale 1ns / 1ps

/*
    Module Authors: Murat Toprak & Vedat Enis Gül
    Implementation of the Data Register
    
    Maximum line length is 59 characters
*/

module DataRegister(I, E, FunSel, Clock, DROut);
    input wire [7:0]    I;
    input wire          E;
    input wire [1:0]    FunSel;
    input wire          Clock;
    output reg [31:0]   DROut;
    
    always @(posedge Clock)
    begin
        if (E)
        begin
            case (FunSel)
                2'b00:      DROut <= {{24{I[7]}}, I[7:0]};
                2'b01:      DROut <= {24'b0, I[7:0]};
                2'b10:      DROut <= {DROut[23:0], I[7:0]};
                2'b11:      DROut <= {I[7:0], DROut[31:8]};
                
                default:    DROut <= DROut;
            endcase
        end
        /* E=0 => retain current value in the DROut */
    end
endmodule