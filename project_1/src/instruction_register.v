`timescale 1ns / 1ps

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

