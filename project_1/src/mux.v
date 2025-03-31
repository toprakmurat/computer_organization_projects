`timescale 1ns / 1ps

module MUX_AB(
    input wire clock,
    input wire [1:0]  MuxSel,
    input wire [31:0] ALUOut,
    input wire [15:0] ARFOutC,
    input wire [31:0] DROut,
    input wire [7:0]  IROut,
    output reg [31:0] Out
);

    always @(posedge clock)
    begin
        case(MuxSel)
            2'b00:  Out <= ALUOut;
            2'b01:  Out <= {{16{ARFOutC[15]}}, ARFOutC};
            2'b10:  Out <= DROut;
            2'b11:  Out <= {{24{IROut[7]}}, IROut};
            
            default: Out <= Out;
        endcase
    end
endmodule

module MUX_C(
    input wire clock,
    input wire [1:0] MuxSel,
    input wire [7:0] ALUOut1,
    input wire [7:0] ALUOut2,
    input wire [7:0] ALUOut3,
    input wire [7:0] ALUOut4,
    output reg [7:0] Out
);

    always @(posedge clock)
    begin
        case(MuxSel)
            2'b00:  Out <= ALUOut1;
            2'b01:  Out <= ALUOut2;
            2'b10:  Out <= ALUOut3;
            2'b11:  Out <= ALUOut4;
            
            default: Out <= Out;
        endcase
    end

endmodule

module MUX_D(
    input wire clock,
    input wire MuxSel,
    input wire [31:0] RFOutA,
    input wire [15:0] ARFOutC,
    output reg [31:0] Out
);
    
    always @(posedge clock)
        Out <= (MuxSel) ? {{16{ARFOutC[15]}}, ARFOutC} : RFOutA;
    
endmodule
