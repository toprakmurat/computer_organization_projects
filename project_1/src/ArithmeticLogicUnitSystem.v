`timescale 1ns / 1ps

/*
    Module Authors: Murat Toprak & Vedat Enis Gül
    Implementation of the final Arithmetic Logic Unit System
    
    MUX modules select one of many input signals and forward
    the selected input to a single output
    
    Maximum line length is 63 characters
*/

module MUX_AB(
    input wire          Clock,
    input wire [1:0]    MuxSel,
    input wire [31:0]   ALUOut,
    input wire [15:0]   ARFOutC,
    input wire [31:0]   DROut,
    input wire [7:0]    IROut,
    output reg [31:0]   Out
);
    /* Combinatorial Select Logic */
    always @(*)
    begin
        case(MuxSel)
            2'b00:      Out = ALUOut;
            2'b01:      Out = {{16{ARFOutC[15]}}, ARFOutC};
            2'b10:      Out = DROut;
            2'b11:      Out = {{24{IROut[7]}}, IROut};
            
            default:    Out = Out;
        endcase
    end
endmodule

module MUX_C(
    input wire          Clock,
    input wire [1:0]    MuxSel,
    input wire [7:0]    ALUOut1,
    input wire [7:0]    ALUOut2,
    input wire [7:0]    ALUOut3,
    input wire [7:0]    ALUOut4,
    output reg [7:0]    Out
);
    /* Combinatorial Select Logic */
    always @(*)
    begin
        case(MuxSel)
            2'b00:      Out = ALUOut1;
            2'b01:      Out = ALUOut2;
            2'b10:      Out = ALUOut3;
            2'b11:      Out = ALUOut4;
            
            default:    Out = Out;
        endcase
    end

endmodule

module MUX_D(
    input wire          Clock,
    input wire          MuxSel,
    input wire [31:0]   RFOutA,
    input wire [15:0]   ARFOutC,
    output reg [31:0]   Out
);
    /* Combinatorial Select Logic */
    always @(*)
        Out = (MuxSel) ? {{16{ARFOutC[15]}}, ARFOutC} : RFOutA;
    
endmodule

module ArithmeticLogicUnitSystem (
    input wire [2:0] RF_OutASel,
    input wire [2:0] RF_OutBSel,
    input wire [2:0] RF_FunSel,
    input wire [3:0] RF_RegSel,
    input wire [3:0] RF_ScrSel,
    
    input wire [4:0] ALU_FunSel,
    input wire       ALU_WF,
    
    input wire [1:0] ARF_OutCSel,
    input wire [1:0] ARF_OutDSel,
    input wire [1:0] ARF_FunSel,
    input wire [2:0] ARF_RegSel,
    
    input wire       IR_LH,
    input wire       IR_Write,
    input wire       Mem_WR,
    input wire       Mem_CS,
    
    input wire [1:0] MuxASel,
    input wire [1:0] MuxBSel,
    input wire [1:0] MuxCSel,
    input wire       Clock,
    input wire [1:0] DR_FunSel,
    input wire       DR_E,
    input wire       MuxDSel
);
  
	wire [31:0] OutA, OutB, ALUOut, DROut;
    wire [31:0] MuxAOut, MuxBOut, MuxDOut;
    wire [15:0] IROut, OutC, Address;
    wire [7:0]  MuxCOut, MemOut;
    wire [3:0]  FlagsOut;
    
    RegisterFile RF (
        .I(MuxAOut),
        .OutASel(RF_OutASel),
        .OutBSel(RF_OutBSel),
        .FunSel(RF_FunSel),
        .RegSel(RF_RegSel),
        .ScrSel(RF_ScrSel),
        .Clock(Clock),
        .OutA(OutA),
        .OutB(OutB)
    );
    
    MUX_D muxD (
        .Clock(Clock),
        .MuxSel(MuxDSel),
        .RFOutA(OutA),
        .ARFOutC(OutC),
        .Out(MuxDOut)
    );
    
    ArithmeticLogicUnit ALU (
        .A(MuxDOut),
        .B(OutB),
        .FunSel(ALU_FunSel),
        .WF(ALU_WF),
        .Clock(Clock),
        .ALUOut(ALUOut),
        .FlagsOut(FlagsOut)
    );
    
    MUX_C muxC (
        .Clock(Clock),
        .MuxSel(MuxCSel),
        .ALUOut1(ALUOut[7:0]),
        .ALUOut2(ALUOut[15:8]),
        .ALUOut3(ALUOut[23:15]),
        .ALUOut4(ALUOut[31:24]),
        .Out(MuxCOut)
    );
    
    Memory MEM (
        .Address(Address),
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
    
    AddressRegisterFile ARF (
        .I(MuxBOut),
        .OutCSel(ARF_OutCSel),
        .OutDSel(ARF_OutDSel),
        .FunSel(ARF_FunSel),
        .RegSel(ARF_RegSel),
        .Clock(Clock),
        .OutC(OutC),
        .OutD(Address)
    );
    
    MUX_AB muxA (
        .Clock(Clock),
        .MuxSel(MuxASel),
        .ALUOut(ALUOut),
        .ARFOutC(OutC),
        .DROut(DROut),
        .IROut(IROut[7:0]),
        .Out(MuxAOut)
    );
    
    MUX_AB muxB (
        .Clock(Clock),
        .MuxSel(MuxBSel),
        .ALUOut(ALUOut),
        .ARFOutC(OutC),
        .DROut(DROut),
        .IROut(IROut[7:0]),
        .Out(MuxBOut)
    );

endmodule
