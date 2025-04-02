`timescale 1ns / 1ps
module AddressRegisterFile(I, OutCSel, OutDSel, FunSel, RegSel, Clock, OutC, OutD);

    input wire Clock;
    input wire [31:0] I;
    input wire [2:0] RegSel;
    input wire [1:0] FunSel;
    input wire [1:0] OutCSel;
    input wire [1:0] OutDSel;

    output reg [15:0] OutC;
    output reg [15:0] OutD;

    wire [15:0] PC_reg, SP_reg, AR_reg;

    Register16bit PC(
        .I(I[15:0]),
        .E(RegSel[2]),
        .FunSel(FunSel),
        .Clock(Clock),
        .Q(PC_reg)
    );

    Register16bit SP(
        .I(I[15:0]),
        .E(RegSel[1]),
        .FunSel(FunSel),
        .Clock(Clock),
        .Q(SP_reg)
    );

    Register16bit AR(
        .I(I[15:0]),
        .E(RegSel[0]),
        .FunSel(FunSel),
        .Clock(Clock),
        .Q(AR_reg)
    );

    always @(*)
    begin
        case (OutCSel)
            2'b00: OutC <= PC_reg;
            2'b01: OutC <= SP_reg;
            2'b10: OutC <= AR_reg;
            2'b11: OutC <= AR_reg;
            default: OutC <= OutC;
        endcase

        case (OutDSel)
            2'b00: OutD <= PC_reg;
            2'b01: OutD <= SP_reg;
            2'b10: OutD <= AR_reg;
            2'b11: OutD <= AR_reg;
            default: OutD <= OutD;
        endcase
    end

endmodule
