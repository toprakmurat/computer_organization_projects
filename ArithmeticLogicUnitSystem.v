`timescale 1ns / 1ps

module mux_1_2 (select, i0, i1, o);
    input wire select;
    input wire [31:0] i0;
    input wire [15:0] i1;
    output reg [31:0] o;

    always @(*)
    begin
        if(select)
            o <= {{16{i1[15]}}, i1};
        else
            o <= i0;
    end
endmodule

module mux_2_4 (select, i0, i1, i2, i3, o);
    input wire [1:0] select;
    input wire [31:0] i0;
    input wire [15:0] i1;
    input wire [31:0] i2;
    input wire [7:0] i3;
    output reg [31:0] o;

    always @(*)
    begin
        case (select)
            2'b00: o <= i0;
            2'b01: o <= {{16{i1[15]}}, i1};
            2'b10: o <= i2;
            2'b11: o <= {{24{i3[7]}}, i3};
            default: o <= o;
        endcase
    end


endmodule

module mux_2_4_2 (select, i0, i1, i2, i3, o);
    input wire [1:0] select;
    input wire [7:0] i0;
    input wire [7:0] i1;
    input wire [7:0] i2;
    input wire [7:0] i3;
    output reg [7:0] o;

    always @(*)
    begin
        case (select)
            2'b00: o <= i0;
            2'b01: o <= i1;
            2'b10: o <= i2;
            2'b11: o <= i3;
            default: o <= o;
        endcase
    end


endmodule

module flag_register(clock, flag_reg, carry);
    input wire clock;

    wire Z;  
    wire C;  
    wire N;  
    wire O;  

    output reg [3:0] flag_reg;  

    assign Z = flag_reg[3];
    assign C = flag_reg[2];
    assign N = flag_reg[1];
    assign O = flag_reg[0];

    output reg carry; 

    always @(posedge clock) begin
        carry <= C;
    end

 

endmodule

module ArithmeticLogicUnitSystem(RF_OutASel, RF_OutBSel, RF_FunSel, RF_RegSel, RF_ScrSel, ALU_FunSel, ALU_WF, ARF_OutCSel, ARF_OutDSel, ARF_FunSel, ARF_RegSel, IR_LH, IR_Write, Mem_WR, Mem_CS, MuxASel, MuxBSel, MuxCSel, Clock, DR_FunSel, DR_E, MuxDSel);

    
    
    input wire Clock;

    input wire [3:0] RF_RegSel;
    input wire [3:0] RF_ScrSel;
    input wire [2:0] RF_FunSel;
    input wire [2:0] RF_OutASel;
    input wire [2:0] RF_OutBSel;

    input wire MuxDSel;

    input wire [4:0] ALU_FunSel;
    input wire ALU_WF;

    input wire [1:0] MuxCSel;

    input wire IR_LH;
    input wire IR_Write;

    input wire DR_E;
    input wire [1:0] DR_FunSel;

    input wire [1:0] MuxASel;

    input wire [1:0] MuxBSel;

    input wire [1:0] ARF_FunSel;
    input wire [2:0] ARF_RegSel;
    input wire [1:0] ARF_OutDSel;
    input wire [1:0] ARF_OutCSel;

    input wire Mem_WR;
    input wire Mem_CS;

    wire [31:0] MuxAOut, RFOutA, RFOutB, MuxDOut, ALUOut, DROut, MuxBOut;
    wire [15:0] ARFOutC, ARFOutD;
    wire [7:0]  MuxCOut, MemOut, IROut;
    wire [3:0] FlagsOut;
    wire FlagCarryOut;

    RegisterFile RF(
        .I(MuxAOut),
        .OutASel(RF_OutASel),
        .OutBSel(RF_OutBSel),
        .FunSel(RF_FunSel),
        .RegSel(RF_RegSel),
        .ScrSel(RF_ScrSel),
        .Clock(Clock),
        .OutA(RFOutA),
        .OutB(RFOutB)
    );

    mux_1_2 mux_D (
        .select(MuxDSel),
        .i0(RFOutA),
        .i1(ARFOutC),
        .o(MuxDOut)
    );

    ArithmeticLogicUnit ALU(
        .A(MuxDOut),
        .B(RFOutB),
        .FunSel(ALU_FunSel),
        .WF(ALU_WF),
        .Clock(Clock),
        .ALUOut(ALUOut),
        .FlagsOut(FlagsOut)
    );

    flag_register flag_register_1 (
        .clock(Clock),
        .flag_reg(FlagsOut),
        .carry(FlagCarryOut)
    );

    mux_2_4_2 mux_C (
        .select(MuxCSel),
        .i0(ALUOut[7:0]),
        .i1(ALUOut[15:8]),
        .i2(ALUOut[23:16]),
        .i3(ALUOut[31:24]),
        .o(MuxCOut)
    );

    Memory MEM(
        .Address(ARFOutD),
        .Data(MuxCOut),
        .WR(Mem_WR),
        .CS(Mem_CS), 
        .Clock(Clock),
        .MemOut(MemOut)
    );

    InstructionRegister IR (
        .I(MemOut),
        .Write(IR_Write),
        .LH(IR_LH),
        .Clock(Clock),
        .IROut(IROut)
    );

    DataRegister DR (
        .I(MemOut),
        .E(DR_E),
        .FunSel(DR_FunSel),
        .Clock(Clock),
        .DROut(DROut)
    );

    AddressRegisterFile ARF(
        .I(MuxBOut),
        .OutCSel(ARF_OutCSel),
        .OutDSel(ARF_OutDSel),
        .FunSel(ARF_FunSel),
        .RegSel(ARF_RegSel),
        .Clock(Clock),
        .OutC(ARFOutC),
        .OutD(ARFOutD)
    );
    mux_2_4 mux_A (
        .select(MuxASel),
        .i0(ALUOut),
        .i1(ARFOutC),
        .i2(DROut),
        .i3(IROut[7:0]),
        .o(MuxAOut)
    );

    mux_2_4 mux_B (
        .select(MuxBSel),
        .i0(ALUOut),
        .i1(ARFOutC),
        .i2(DROut),
        .i3(IROut[7:0]),
        .o(MuxBOut)
    );

endmodule
