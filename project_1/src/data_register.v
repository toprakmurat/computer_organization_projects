`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2025 12:37:39 PM
// Design Name: 
// Module Name: data_register
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module data_register(clock, E, FunSel, In, Out);
    input wire clock;
    input wire E;
    input wire [1:0] FunSel;
    
    input wire [7:0] In;
    output reg [31:0] Out;
    
    always @(posedge clock)
    begin
        if (E)
        begin
            case (FunSel)
                2'b00:  Out <= {{24{In[7]}}, In[7:0]};
                2'b01:  Out <= {24'b0, In[7:0]};
                2'b10:  Out <= {Out[23:0], In[7:0]};
                2'b11:  Out <= {In[7:0], Out[31:8]};
                
                default: Out <= Out;
            endcase
        end
        /* E=0 => retain current value in the Out */
    end
endmodule

