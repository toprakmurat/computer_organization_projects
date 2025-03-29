`timescale 1ns / 1ps

module register_32bit (clock, E, FunSel, In, Out);
    input wire clock;
    input wire E;
    input wire [2:0] FunSel;
    input wire [31:0] In;
    output reg [31:0] Out;
    
    always @(posedge clock)
    begin
        if (E)
        begin
            case(FunSel)
                3'b000:     Out <= Out - 1;
                3'b001:     Out <= Out + 1;
                3'b010:     Out <= In;
                3'b011:     Out <= 32'b0;
                3'b100:     Out <= {24'b0, In[7:0]};
                3'b101:     Out <= {16'b0, In[15:0]};
                3'b110:     Out <= {Out[23:0], In[7:0]};
                3'b111:     Out <= {{16{In[15]}}, In[15:0]};
                
                default:    Out <= Out;
            endcase
        end
        /* E=0 => retain current value in the Out */
    end
endmodule
