module AddressRegisterFile(clock, i, RegSel, FunSel, OutCSel, OutDSel, OutC, OutD);

    input wire clock;
    input wire [31:0] i;
    input wire [2:0] RegSel;
    input wire [1:0] FunSel;
    input wire [1:0] OutCSel;
    input wire [1:0] OutDSel;

    output reg [15:0] OutC;
    output reg [15:0] OutD;

    wire [15:0] PC, SP, AR;


    Register16bit PC_reg(
        .I(i[15:0]),
        .E(RegSel[2]),
        .FunSel(FunSel),
        .Clock(clock),
        .Q(PC)
    )

    Register16bit SP_reg(
        .I(i[15:0]),
        .E(RegSel[1]),
        .FunSel(FunSel),
        .Clock(clock),
        .Q(SP)
    )

    Register16bit AR_reg(
        .I(i[15:0]),
        .E(RegSel[0]),
        .FunSel(FunSel),
        .Clock(clock),
        .Q(AR)
    );


    always @(posedge clock)
    begin
        case (OutCSel)
            2'b00: OutC <= PC;
            2'b01: OutC <= SP;
            2'b10: OutC <= AR;
            2'b11: OutC <= AR;
            default: OutC <= 16'b0;
        endcase

        case (OutDSel)
            2'b00: OutD <= PC;
            2'b01: OutD <= SP;
            2'b10: OutD <= AR;
            2'b11: OutD <= AR;
            default: OutD <= 16'b0;
        endcase
    end

endmodule