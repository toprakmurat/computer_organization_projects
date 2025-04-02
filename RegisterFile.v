`timescale 1ns / 1ps
module RegisterFile(I, OutASel, OutBSel, FunSel, RegSel, ScrSel, Clock, OutA, OutB);

    input wire Clock;
    input wire [31:0] I;
    input wire [3:0] RegSel;
    input wire [3:0] ScrSel;
    input wire [2:0] FunSel;
    input wire [2:0] OutASel;
    input wire [2:0] OutBSel;

    output reg [31:0] OutA;
    output reg [31:0] OutB;

    wire [31:0] R1_reg, R2_reg, R3_reg, R4_reg, S1_reg, S2_reg, S3_reg, S4_reg;


    Register32bit R1(
        .I(I),
        .E(RegSel[3]),
        .FunSel(FunSel),
        .Clock(Clock),
        .Q(R1_reg)
    );
    Register32bit R2(
        .I(I),
        .E(RegSel[2]),
        .FunSel(FunSel),
        .Clock(Clock),
        .Q(R2_reg)
    );
    Register32bit R3(
        .I(I),
        .E(RegSel[1]),
        .FunSel(FunSel),
        .Clock(Clock),
        .Q(R3_reg)
    );

    Register32bit R4(
        .I(I),
        .E(RegSel[0]),
        .FunSel(FunSel),
        .Clock(Clock),
        .Q(R4_reg)
    );


    Register32bit S1(
        .I(I),
        .E(ScrSel[3]),
        .FunSel(FunSel),
        .Clock(Clock),
        .Q(S1_reg)
    );
    Register32bit S2(
        .I(I),
        .E(ScrSel[2]),
        .FunSel(FunSel),
        .Clock(Clock),
        .Q(S2_reg)
    );
    Register32bit S3(
        .I(I),
        .E(ScrSel[1]),
        .FunSel(FunSel),
        .Clock(Clock),
        .Q(S3_reg)
    );
    Register32bit S4(
        .I(I),
        .E(ScrSel[0]),
        .FunSel(FunSel),
        .Clock(Clock),
        .Q(S4_reg)
    );


    always @(*) begin
        case (OutASel)
            3'b000: OutA <= R1_reg;
            3'b001: OutA <= R2_reg;
            3'b010: OutA <= R3_reg;
            3'b011: OutA <= R4_reg;
            3'b100: OutA <= S1_reg;
            3'b101: OutA <= S2_reg;
            3'b110: OutA <= S3_reg;
            3'b111: OutA <= S4_reg;
            default: OutA <= 32'b0;
        endcase

        case (OutBSel)
            3'b000: OutB <= R1_reg;
            3'b001: OutB <= R2_reg;
            3'b010: OutB <= R3_reg;
            3'b011: OutB <= R4_reg;
            3'b100: OutB <= S1_reg;
            3'b101: OutB <= S2_reg;
            3'b110: OutB <= S3_reg;
            3'b111: OutB <= S4_reg;
            default: OutB <= 32'b0;
        endcase
    end

endmodule
