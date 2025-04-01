`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ITU Computer Engineering Department
// Engineer: Kadir Ozlem
// Project Name: BLG222E Project 1 Simulation
//////////////////////////////////////////////////////////////////////////////////


module ArithmeticLogicUnitSystemSimulation();
    reg[2:0] RF_OutASel, RF_OutBSel, RF_FunSel;
    reg[3:0] RF_RegSel, RF_ScrSel;
    reg[4:0] ALU_FunSel;
    reg ALU_WF; 
    reg[1:0] ARF_OutCSel, ARF_OutDSel, ARF_FunSel;
    reg[2:0] ARF_RegSel;
    reg IR_LH, IR_Write, Mem_WR, Mem_CS;
    reg[1:0] MuxASel, MuxBSel, MuxCSel;
    reg MuxDSel;
    reg DR_E;
    reg[1:0] DR_FunSel;
    integer test_no;
    wire Z, C, N, O;
    
    CrystalOscillator clk();
    ArithmeticLogicUnitSystem ALUSys(
        .RF_OutASel(RF_OutASel),   .RF_OutBSel(RF_OutBSel), 
        .RF_FunSel(RF_FunSel),     .RF_RegSel(RF_RegSel),
        .RF_ScrSel(RF_ScrSel),     .ALU_FunSel(ALU_FunSel),
        .ALU_WF(ALU_WF),           .ARF_OutCSel(ARF_OutCSel), 
        .ARF_OutDSel(ARF_OutDSel), .ARF_FunSel(ARF_FunSel),
        .ARF_RegSel(ARF_RegSel),   .IR_LH(IR_LH),
        .IR_Write(IR_Write),       .Mem_WR(Mem_WR),
        .Mem_CS(Mem_CS),           .MuxASel(MuxASel),
        .MuxBSel(MuxBSel),         .MuxCSel(MuxCSel),
        .Clock(clk.clock),         .DR_FunSel(DR_FunSel),
        .DR_E(DR_E),               .MuxDSel(MuxDSel) 
    ); 
    FileOperation F();
    
    assign {Z,C,N,O} = ALUSys.ALU.FlagsOut;
    
    task ClearRegisters;
        begin
            ALUSys.RF.R1.Q = 32'h0;
            ALUSys.RF.R2.Q = 32'h0;
            ALUSys.RF.R3.Q = 32'h0;
            ALUSys.RF.R4.Q = 32'h0;
            ALUSys.RF.S1.Q = 32'h0;
            ALUSys.RF.S2.Q = 32'h0;
            ALUSys.RF.S3.Q = 32'h0;
            ALUSys.RF.S4.Q = 32'h0;
            ALUSys.ARF.PC.Q = 16'h0;
            ALUSys.ARF.AR.Q = 16'h0;
            ALUSys.ARF.SP.Q = 16'h0;
            ALUSys.IR.IROut = 16'h0;
            ALUSys.DR.DROut = 32'h0;
        end
        endtask
        
        task SetRegisters16;
            input [15:0] value;
            begin
                ALUSys.ARF.PC.Q = value;
                ALUSys.ARF.AR.Q = value;
                ALUSys.ARF.SP.Q = value;
                ALUSys.IR.IROut = value;
            end
        endtask

        task SetRegisters32;
            input [31:0] value;
            begin
                ALUSys.RF.R1.Q = value;
                ALUSys.RF.R2.Q = value;
                ALUSys.RF.R3.Q = value;
                ALUSys.RF.R4.Q = value;
                ALUSys.RF.S1.Q = value;
                ALUSys.RF.S2.Q = value;
                ALUSys.RF.S3.Q = value;
                ALUSys.RF.S4.Q = value;
                ALUSys.DR.DROut = value;
            end
        endtask
        
        task DisableAll;
            begin
                RF_RegSel = 4'b0000;
                RF_ScrSel = 4'b0000;
                ARF_RegSel = 3'b000;
                IR_Write = 0;
                ALU_WF = 0;
                Mem_CS = 1;
                Mem_WR = 0;
                DR_E = 0;
            end
        endtask
    
    initial begin
        F.SimulationName ="ArithmeticLogicUnitSystem";
        F.InitializeSimulation(0);
        clk.clock = 0;
        
        //Test 1
        test_no = 1;
        DisableAll();
        ClearRegisters();
        ALUSys.RF.R1.Q = 32'h77777777;
        ALUSys.RF.S2.Q = 32'h88888887;
        RF_OutASel = 3'b000;
        RF_OutBSel = 3'b101;
        ALUSys.ALU.FlagsOut = 4'b0000;
        ALU_FunSel =5'b10101;
        ALU_WF =1;
        MuxASel = 2'b00;
        MuxBSel = 2'b00;
        MuxCSel = 2'b00;
        MuxDSel = 0;
        RF_RegSel = 4'b0100;
        RF_ScrSel = 4'b0010;
        RF_FunSel = 3'b010;
        
        ARF_RegSel = 3'b100;
        ARF_FunSel = 2'b10;
        #5;
        F.CheckValues(ALUSys.RF.OutA,32'h77777777, test_no, "OutA");
        F.CheckValues(ALUSys.RF.OutB,32'h88888887, test_no, "OutB");
        F.CheckValues(ALUSys.ALUOut,32'hFFFFFFFE, test_no, "ALUOut");
        F.CheckValues(Z,0, test_no, "Z");
        F.CheckValues(C,0, test_no, "C");
        F.CheckValues(N,0, test_no, "N");
        F.CheckValues(O,0, test_no, "O");
        F.CheckValues(ALUSys.MuxAOut,32'hFFFFFFFE, test_no, "MuxAOut");
        F.CheckValues(ALUSys.MuxBOut,32'hFFFFFFFE, test_no, "MuxBOut");
        F.CheckValues(ALUSys.MuxCOut,8'hFE, test_no, "MuxCOut");
        F.CheckValues(ALUSys.MuxDOut,32'h77777777, test_no, "MuxDOut");
        F.CheckValues(ALUSys.RF.R2.Q,32'h00000000, test_no, "R2");
        F.CheckValues(ALUSys.RF.S3.Q,32'h00000000, test_no, "S3");
        
        clk.Clock();

        //Test 2
        test_no = 2;
        F.CheckValues(ALUSys.RF.OutA,32'h77777777, test_no, "OutA");
        F.CheckValues(ALUSys.RF.OutB,32'h88888887, test_no, "OutB");
        F.CheckValues(ALUSys.ALUOut,32'hFFFFFFFE, test_no, "ALUOut");
        F.CheckValues(Z,0, test_no, "Z");
        F.CheckValues(C,0, test_no, "C");
        F.CheckValues(N,1, test_no, "N");
        F.CheckValues(O,0, test_no, "O");
        F.CheckValues(ALUSys.MuxAOut,32'hFFFFFFFE, test_no, "MuxAOut");
        F.CheckValues(ALUSys.MuxBOut,32'hFFFFFFFE, test_no, "MuxBOut");
        F.CheckValues(ALUSys.MuxCOut,8'hFE, test_no, "MuxCOut");
        F.CheckValues(ALUSys.MuxDOut,32'h77777777, test_no, "MuxDOut");
        F.CheckValues(ALUSys.RF.R2.Q,32'hFFFFFFFE, test_no, "R2");
        F.CheckValues(ALUSys.RF.S3.Q,32'hFFFFFFFE, test_no, "S3");
        F.CheckValues(ALUSys.ARF.PC.Q,16'hFFFE, test_no, "PC");
        
        //Test 3
        test_no = 3;
        DisableAll();
        ClearRegisters();
        ALUSys.MEM.RAM_DATA[16'h23] = 8'h15;
        ALUSys.ARF.AR.Q = 16'h23;
        ALUSys.ARF.PC.Q = 16'h1254;
        ARF_OutCSel = 2'b00;
        ARF_OutDSel = 2'b10;
        Mem_CS = 0;
        Mem_WR = 0;
        IR_LH = 0;
        IR_Write = 1;
        #5;
        F.CheckValues(ALUSys.ARFOutC,16'h1254, test_no, "OutC");
        F.CheckValues(ALUSys.MEM.Address,16'h23, test_no, "Address");
        F.CheckValues(ALUSys.MEM.MemOut,8'h15, test_no, "Memout");
        F.CheckValues(ALUSys.IROut,16'h0000, test_no, "IROut");
        F.CheckValues(ALUSys.DROut,32'h0000, test_no, "DROut");
        
        //Test 4
        test_no = 4;
        clk.Clock();
        F.CheckValues(ALUSys.ARF.OutC,16'h1254, test_no, "OutC");
        F.CheckValues(ALUSys.MEM.Address,16'h23, test_no, "Address");
        F.CheckValues(ALUSys.MEM.MemOut,8'h15, test_no, "Memout");
        F.CheckValues(ALUSys.IROut,16'h0015, test_no, "IROut");

        F.FinishSimulation();
    end
endmodule
