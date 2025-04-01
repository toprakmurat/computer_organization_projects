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

    wire [31:0] R1, R2, R3, R4, S1, S2, S3, S4;


    Register32bit R1_reg(
        .I(I),
        .E(RegSel[3]),
        .FunSel(FunSel),
        .Clock(Clock),
        .Q(R1)
    );
    Register32bit R2_reg(
        .I(I),
        .E(RegSel[2]),
        .FunSel(FunSel),
        .Clock(Clock),
        .Q(R2)
    );
    Register32bit R3_reg(
        .I(I),
        .E(RegSel[1]),
        .FunSel(FunSel),
        .Clock(Clock),
        .Q(R3)
    );

    Register32bit R4_reg(
        .I(I),
        .E(RegSel[0]),
        .FunSel(FunSel),
        .Clock(Clock),
        .Q(R4)
    );


    Register32bit S1_reg(
        .I(I),
        .E(ScrSel[3]),
        .FunSel(FunSel),
        .Clock(Clock),
        .Q(S1)
    );
    Register32bit S2_reg(
        .I(I),
        .E(ScrSel[2]),
        .FunSel(FunSel),
        .Clock(Clock),
        .Q(S2)
    );
    Register32bit S3_reg(
        .I(I),
        .E(ScrSel[1]),
        .FunSel(FunSel),
        .Clock(Clock),
        .Q(S3)
    );
    Register32bit S4_reg(
        .I(I),
        .E(ScrSel[0]),
        .FunSel(FunSel),
        .Clock(Clock),
        .Q(S4)
    );


    always @(posedge Clock) begin
        case (OutASel)
            3'b000: OutA <= R1;
            3'b001: OutA <= R2;
            3'b010: OutA <= R3;
            3'b011: OutA <= R4;
            3'b100: OutA <= S1;
            3'b101: OutA <= S2;
            3'b110: OutA <= S3;
            3'b111: OutA <= S4;
            default: OutA <= 32'b0;
        endcase

        case (OutBSel)
            3'b000: OutB <= R1;
            3'b001: OutB <= R2;
            3'b010: OutB <= R3;
            3'b011: OutB <= R4;
            3'b100: OutB <= S1;
            3'b101: OutB <= S2;
            3'b110: OutB <= S3;
            3'b111: OutB <= S4;
            default: OutB <= 32'b0;
        endcase
    end

endmodule