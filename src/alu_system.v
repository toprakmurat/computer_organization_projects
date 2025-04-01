module alu_system(RF_OutASel, RF_OutBSel, RF_FunSel, RF_RegSel, RF_ScrSel, ALU_FunSel, ALU_WF, ARF_OutCSel, ARF_OutDSel, ARF_FunSel, ARF_RegSel, IR_LH, IR_Write, Mem_WR, Mem_CS, MuxASel, MuxBSel, MuxCSel, Clock, DR_FunSel, DR_E, MuxDSel);

    
    
    input wire Clock;

    input wire [3:0] RF_RegSel;
    input wire [3:0] RF_ScrSel;
    input wire [2:0] RF_FunSel;
    input wire [2:0] RF_OutASel;
    input wire [2:0] RF_OutBSel;

    input wire MuxDSel;

    input wire [4:0] ALU_FunSel;

    input wire [1:0] MuxCSel;

    input wire IR_LH;
    input wire IR_Write;
    output wire [7:0] IROut;

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

    wire [31:0] w1, w2, w3, w5, w6, w12, w13;
    wire [15:0] w4, w14;
    wire [7:0]  w9, w10, w11;
    wire [3:0] w7;
    wire w8;

    RegisterFile rf_1(
        .I(w1),
        .RF_OutASel(RF_OutASel),
        .RF_OutBSel(RF_OutBSel),
        .FunSel(RF_FunSel),
        .RegSel(RF_RegSel),
        .RF_ScrSel(RF_ScrSel),
        .Clock(Clock),
        .OutA(w2),
        .OutB(w3)
    );

    mux_1_2 mux_D (
        .Clock(Clock),
        .select(MuxDSel),
        .i0(w2),
        .i1(w4),
        .o(w5)
    );

    ArithmeticLogicUnit alu_1(
        .A(w5),
        .B(w3),
        .FunSel(ALU_FunSel),
        .WF(w8),
        .Clock(Clock),
        .ALUOut(w6),
        .FlagsOut(w7)
    );

    flag_register flag_register_1 (
        .Clock(Clock),
        .flag_reg(w7),
        .carry(w8)
    );

    mux_2_4_2 mux_C (
        .Clock(Clock),
        .select(MuxCSel),
        .i0(w6[7:0]),
        .i1(w6[15:8]),
        .i2(w6[23:16]),
        .i3(w6[31:24]),
        .o(w9)
    );

    memory memory_1 (
        .Address(w14),
        .Data(w9),
        .WR(Mem_WR),
        .CS(Mem_CS), 
        .Clock(Clock),
        .MemOut(w10)
    );

    InstructionRegister instruction_register_1 (
        .I(w10),
        .IR_Write(IR_Write),
        .IR_LH(IR_LH),
        .Clock(Clock),
        .IROut({IROut, w11})
    );

    DataRegister data_register_1 (
        .I(w10),
        .E(DR_E),
        .FunSel(DR_FunSel),
        .Clock(Clock),
        .DROut(w12)
    );

    AddressRegisterFile address_register_1(
        .I(w13),
        .ARF_OutCSel(ARF_OutCSel),
        .ARF_OutDSel(ARF_OutDSel),
        .FunSel(ARF_FunSel),
        .RegSel(ARF_RegSel),
        .Clock(Clock),
        .OutC(w4),
        .OutD(w14)
    );
    mux_2_4 mux_A (
        .Clock(Clock),
        .select(MuxASel),
        .i0(w6),
        .i1(w4),
        .i2(w12),
        .i3(w11),
        .o(w1)
    );

    mux_2_4 mux_B (
        .Clock(Clock),
        .select(MuxBSel),
        .i0(w6),
        .i1(w4),
        .i2(w12),
        .i3(w11),
        .o(w13)
    );

endmodule