module alu_system(clock, RegSel, ScrSel, FunSel3, OutASel, OutBSel, MuxDSel, FunSel5, MuxCSel, LH, write, IROut, E, FunSel2_dr, MuxASel, MuxBSel, FunSel2_arf, RegSel, OutDSel, OutCSel);
    input wire clock;

    input wire [3:0] RegSel_rf;
    input wire [3:0] ScrSel;
    input wire [2:0] FunSel3;
    input wire [2:0] OutASel;
    input wire [2:0] OutBSel;

    input wire MuxDSel;

    input wire [4:0] FunSel5;

    input wire [1:0] MuxCSel;

    input wire LH;
    input wire write;
    output wire [15:0] IROut;

    input wire E;
    input wire [1:0] FunSel2_dr;

    input wire [1:0] MuxASel;

    input wire [1:0] MuxBSel;

    input wire [1:0] FunSel2_arf;
    input wire [2:0] RegSel_arf;
    input wire [1:0] OutDSel;
    input wire [1:0] OutCSel;

    wire [31:0] w1, w2, w3, w5, w6, w12, w13;
    wire [15:0] w4, w14;
    wire [7:0] w7, w9, w10, w11;
    wire w8;

    register_file rf_1 (
        .clock(clock),
        .i(w1),
        .RegSel(RegSel_rf),
        .ScrSel(ScrSel),
        .FunSel(FunSel3),
        .OutASel(OutASel),
        .OutBSel(OutBSel),
        .OutA(w2),
        .OutB(w3)
    );

    mux_1_2 mux_D (
        .clock(clock),
        .select(MuxDSel),
        .i0(w2),
        .i1(w4),
        .o(w5)
    );

    alu alu_1 (
        .clock(clock),
        .input_a(w5),
        .input_b(w3),
        .cin(w8),
        .FunSel(FunSel5),
        .ALUOut(w6),  
        .flags(w7)  // buna bak
    );

    flag_register flag_register_1 (
        .clock(clock),
        .Z(),
        .C(),
        .N(),  /// buraya bak tam nasıl yapılacak
        .O(),
        .flag_reg(w7),
        .carry(w8)
    );

    mux_2_4_2 mux_C (
        .clock(clock),
        .select(MuxCSel),
        .i0(w6[7:0]),
        .i1(w6[15:8]),
        .i2(w6[23:16]),
        .i3(w6[31:24]),
        .o(w9)
    );

    memory memory_1 (
        .Address(w14),
        .Data(),
        .WR(),
        .CS(), // burayada bak
        .Clock(clock),
        .MemOut(w10)
    );

    instruction_register instruction_register_1 (
        .clock(clock),
        .i(w10),
        .o({w11, IROut}),  // buna bak
        .LH(LH),
        .write(write)
    );

    data_register data_register_1 (
        .clock(clock),
        .enable(E),
        .FunSel(FunSel2_dr),
        .i(w10),
        .o(w12),
    );

    address_register address_register_1 (
        clock(clock),
        i(w13),
        RegSel(RegSel_arf),
        FunSel(FunSel2_arf),
        OutCSel(OutCSel),
        OutDSel(OutDSel),
        OutC(w4),
        OutD(w14)
    );

    mux_2_4 mux_A (
        clock(clock),
        select(MuxASel),
        i0(w6),
        i1(w4),
        i2(w12),
        i3(w11),
        o(w1)
    );

    mux_2_4 mux_B (
        clock(clock),
        select(MuxBSel),
        i0(w6),
        i1(w4),
        i2(w12),
        i3(w11),
        o(w13)
    );

endmodule