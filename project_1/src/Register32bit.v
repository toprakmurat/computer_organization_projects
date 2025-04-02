`timescale 1ns / 1ps

/*
    Module Authors: Murat Toprak & Vedat Enis Gül
    Implementation of a 32-bit Register
    
    Maximum line length is 56 characters
*/

module Register32bit (I, E, FunSel, Clock, Q);
    input wire [31:0]   I;
    input wire          E;
    input wire [2:0]    FunSel;
    input wire          Clock;
    output reg [31:0]   Q;
    
    always @(posedge Clock)
    begin
        if (E)
        begin
            case(FunSel)
                3'b000:     Q <= Q - 1;
                3'b001:     Q <= Q + 1;
                3'b010:     Q <= I;
                3'b011:     Q <= 32'b0;
                3'b100:     Q <= {24'b0, I[7:0]};
                3'b101:     Q <= {16'b0, I[15:0]};
                3'b110:     Q <= {Q[23:0], I[7:0]};
                3'b111:     Q <= {{16{I[15]}}, I[15:0]};
                
                default:    Q <= Q;
            endcase
        end
        /* E=0 => retain current value in the Q */
    end
endmodule