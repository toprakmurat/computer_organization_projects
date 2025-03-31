`timescale 1ns / 1ps

module flag_register(
    input wire clock,
    input wire [3:0] flag_reg,
    output reg carry
);

    always @(posedge clock)
        carry <= flag_reg[2];
    
endmodule
