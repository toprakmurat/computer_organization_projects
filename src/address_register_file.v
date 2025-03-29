module address_register(clock, i, RegSel, FunSel, OutASel, OutBSel, OutC, OutD);

    input wire clock;
    input wire [31:0] i;
    input wire [2:0] RegSel;
    input wire [1:0] FunSel;
    input wire [1:0] OutASel;
    input wire [1:0] OutBSel;

    output reg [15:0] OutC;
    output reg [15:0] OutD;

    wire [15:0] PC, SP, AR;

    16_bit_register PC_reg (
        .clock(clock),
        .enable(RegSel[0]),
        .funSel(FunSel),
        .i(i),
        .o(PC)
    );

    16_bit_register SP_reg (
        .clock(clock),
        .enable(RegSel[1]),
        .funSel(FunSel),
        .i(i),
        .o(SP)
    );

    16_bit_register AR_reg (
        .clock(clock),
        .enable(RegSel[2]),
        .funSel(FunSel),
        .i(i),
        .o(AR)
    );

    always @(posedge clock)
    begin
        case (OutASel)
            2'b00: OutC <= PC;
            2'b01: OutC <= SP;
            2'b10: OutC <= AR;
            2'b11: OutC <= AR;
            default: OutC <= 16'b0;
        endcase

        case (OutBSel)
            2'b00: OutD <= PC;
            2'b01: OutD <= SP;
            2'b10: OutD <= AR;
            2'b11: OutD <= AR;
            default: OutD <= 16'b0;
        endcase
    end

endmodule