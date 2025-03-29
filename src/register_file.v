module register_file(clock, i, RegSel, ScrSel, FunSel, OutASel, OutBSel, OutA, OutB);

    input wire clock;
    input wire [31:0] i;
    input wire [3:0] RegSel;
    input wire [3:0] ScrSel;
    input wire [2:0] FunSel;
    input wire [2:0] OutASel;
    input wire [2:0] OutBSel;

    output reg [31:0] OutA;
    output reg [31:0] OutB;

    wire [31:0] R1, R2, R3, R4, S1, S2, S3, S4;

    32_bit_register R1_reg (
        .clock(clock),
        .enable(RegSel[0]),  
        .funSel(funSel),
        .i(i),
        .o(R1)
    );

    32_bit_register R2_reg (
        .clock(clock),
        .enable(RegSel[1]),
        .funSel(funSel),
        .i(i),
        .o(R2)
    );

    32_bit_register R3_reg (
        .clock(clock),
        .enable(RegSel[2]),
        .funSel(funSel),
        .i(i),
        .o(R3)
    );

    32_bit_register R4_reg (
        .clock(clock),
        .enable(RegSel[3]),
        .funSel(funSel),
        .i(i),
        .o(R4)
    );

    32_bit_register S1_reg (
        .clock(clock),
        .enable(ScrSel[0]),
        .funSel(funSel),
        .i(i),
        .o(S1)
    );

    32_bit_register S2_reg (
        .clock(clock),
        .enable(ScrSel[1]),
        .funSel(funSel),
        .i(i),
        .o(S2)
    );

    32_bit_register S3_reg (
        .clock(clock),
        .enable(ScrSel[2]),
        .funSel(funSel),
        .i(i),
        .o(S3)
    );

    32_bit_register S4_reg (
        .clock(clock),
        .enable(ScrSel[3]),
        .funSel(funSel),
        .i(i),
        .o(S4)
    );

    always @(posedge clock) begin
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