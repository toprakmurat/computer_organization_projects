`timescale 1ns / 1ps

// register_16bit.v
module register_16bit (clock, E, FunSel, In, Out);
    input wire clock;
    input wire E;
    
    input wire [1:0]    FunSel;
    input wire [15:0]   In;
    output reg [15:0]   Out;
    
    always @(posedge clock)
    begin
        if (E)
        begin
            case (FunSel)
                2'b00:  Out <= Out - 1;
                2'b01:  Out <= Out + 1;
                2'b10:  Out <= In;
                2'b11:  Out <= 16'b0;
                
                default: Out <= Out;
            endcase
        end
        /* E=0 => retain current value in the Out */
    end
endmodule
