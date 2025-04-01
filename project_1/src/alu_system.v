`timescale 1ns / 1ps

module alu_system(
    input wire clock,
    
    input wire [1:0] MuxASel,
    input wire [1:0] MuxBSel,
    input wire [1:0] MuxCSel,
    input wire       MuxDSel,
    
    input wire [3:0] RFRegSel,
    input wire [3:0] RFScrSel,
    input wire [2:0] RFFunSel,
    input wire [2:0] RFOutASel,
    input wire [2:0] RFOutBSel,
    
    input wire [4:0] ALUFunSel,
    
    input wire [2:0] ARFRegSel,
    input wire [1:0] ARFFunSel,
    input wire [1:0] ARFOutBSel,
    input wire [1:0] ARFOutASel,
    
    input wire       DREnable,
    input wire [1:0] DRFunSel,
    
    input wire       MemCS,
    input wire       MemWR,
    
    input wire       IRHighSel,
    input wire       IRWrite,
    output reg [7:0] IROutMSB
);
    
    wire [31:0] RFOutA, RFOutB, ALUOut, DROut;
    wire [31:0] MuxAOut, MuxBOut, MuxDOut;
    wire [15:0] IROut, ARFOutC, ARFOutD;
    wire [7:0]  MuxCOut, MemOut;
    wire [3:0]  FlagOut;
    wire        FRCarryOut;
    
    register_file rf (
        .clock(clock),
        .RegSel(RFRegSel),
        .ScrSel(RFScrSel),
        .FunSel(RFFunSel),
        .OutASel(RFOutASel),
        .OutBSel(RFOutBSel),
        .In(MuxAOut),
        .OutA(RFOutA),
        .OutB(RFOutB)
    );
    
    MUX_D muxD (
        .clock(clock),
        .MuxSel(MuxDSel),
        .RFOutA(RFOutA),
        .ARFOutC(ARFOutC),
        .Out(MuxDOut)
    );
    
    alu single_alu (
        .clock(clock),
        .Cin(FRCarryOut),
        .FunSel(ALUFunSel),
        .InA(MuxDOut),
        .InB(RFOutB),
        .flags(FlagOut),
        .Out(ALUOut)
    );
    
    flag_register fr (
        .clock(clock),
        .flag_reg(FlagOut),
        .carry(FRCarryOut)
    );
    
    MUX_C muxC (
        .clock(clock),
        .MuxSel(MuxCSel),
        .ALUOut1(ALUOut[7:0]),
        .ALUOut2(ALUOut[15:8]),
        .ALUOut3(ALUOut[23:15]),
        .ALUOut4(ALUOut[31:24]),
        .Out(MuxCOut)
    );
    
    Memory ram(
        .Address(ARFOutD),
        .Data(MuxCOut),
        .WR(MemWR),
        .CS(MemCS),
        .Clock(clock),
        .MemOut(MemOut)
    );
    
    instruction_register ir(
        .clock(clock),
        .W(IRWrite),
        .HighSel(IRHighSel),
        .In(MemOut),
        .Out(IROut)
    );
    
    data_register dr (
        .clock(clock),
        .E(DREnable),
        .FunSel(DRFunSel),
        .In(MemOut),
        .Out(DROut)
    );
    
    address_register_file arf (
        .clock(clock),
        .RegSel(ARFRegSel),
        .FunSel(ARFFunSel),
        .OutCSel(ARFOutCSel),
        .OutDSel(ARFOutDSel),
        .In(MuxBOut)
        .OutC(ARFOutC),
        .OutD(ARFOutD)
    );
    
    MUX_AB muxA (
        .clock(clock),
        .MuxSel(MuxASel),
        .ALUOut(ALUOut),
        .ARFOutC(ARFOutC),
        .DROut(DROut),
        .IROut(IROut[7:0]),
        .Out(MuxAOut),
    );
    
    MUX_AB muxB (
        .clock(clock),
        .MuxSel(MuxBSel),
        .ALUOut(ALUOut),
        .ARFOutC(ARFOutC),
        .DROut(DROut),
        .IROut(IROut[7:0]),
        .Out(MuxBOut),
    );
    
    always @(posedge clock)
		IROutMSB <= IROut[15:8];

endmodule
