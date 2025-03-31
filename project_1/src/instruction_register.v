`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2025 12:35:06 PM
// Design Name: 
// Module Name: instruction_register
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


module instruction_register(clock, W, HighSel, In, Out);
    input wire clock;
    input wire W;
    input wire HighSel;
    
    input wire [7:0] In;
    output reg [15:0] Out;
    
    always @(posedge clock)
    begin
        if (W)
            Out <= (HighSel) ? {In[7:0], Out[7:0]} : {Out[15:8], In[7:0]};
        else
			Out <= Out;
    end
endmodule

