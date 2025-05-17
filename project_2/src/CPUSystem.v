`timescale 1ns / 1ps

module CPUSystem(
    input wire Clock,
    input wire Reset,
    output reg [11:0] T
);
    // =============================================
    // State Encoding (One-Hot for T0-T11)
    // =============================================
    localparam T0  = 12'b000000000001;
    localparam T1  = 12'b000000000010;
    localparam T2  = 12'b000000000100;
    localparam T3  = 12'b000000001000;
    localparam T4  = 12'b000000010000;
    localparam T5  = 12'b000000100000;
    localparam T6  = 12'b000001000000;
    localparam T7  = 12'b000010000000;
    localparam T8  = 12'b000100000000;
    localparam T9  = 12'b001000000000;
    localparam T10 = 12'b010000000000;
    localparam T11 = 12'b100000000000;
    
    // =============================================
    // Instruction Code Encoding
    // =============================================
    localparam BRA      = 6'h00;
    localparam BNE      = 6'h01;
    localparam BEQ      = 6'h02;
    localparam POPL     = 6'h03;
    localparam PSHL     = 6'h04;
    localparam POPH     = 6'h05;
    localparam PSHH     = 6'h06;
    localparam CALL     = 6'h07;
    localparam RET      = 6'h08;
    localparam INC      = 6'h09;
    localparam DEC      = 6'h0A;
    localparam LSL      = 6'h0B;
    localparam LSR      = 6'h0C;
    localparam ASR      = 6'h0D;
    localparam CSL      = 6'h0E;
    localparam CSR      = 6'h0F;
    localparam NOT      = 6'h10;
    localparam AND      = 6'h11;
    localparam ORR      = 6'h12;
    localparam XOR      = 6'h13;
    localparam NAND     = 6'h14;
    localparam ADD      = 6'h15;
    localparam ADC      = 6'h16;
    localparam SUB      = 6'h17;
    localparam MOV      = 6'h18;
    localparam MOVL     = 6'h19;
    localparam MOVSH    = 6'h1A;   
    localparam LDARL    = 6'h1B; 
    localparam LDARH    = 6'h1C; 
    localparam STAR     = 6'h1D;
    localparam LDAL     = 6'h1E;
    localparam LDAH     = 6'h1F;
    localparam STA      = 6'h20; 
    localparam LDDRL    = 6'h21; 
    localparam LDDRH    = 6'h22; 
    localparam STDR     = 6'h23;
    localparam STRIM    = 6'h24; 
    
    // =============================================
    // Control Signals
    // =============================================
    reg [5:0] Opcode;
    reg [1:0] RegSel;
    reg [7:0] Address;
    reg [2:0] DestReg, SrcReg1, SrcReg2;

    reg [3:0] RF_RegSel, RF_ScrSel;
    reg [2:0] RF_OutASel, RF_OutBSel, RF_FunSel;
    reg [4:0] ALU_FunSel;
    reg       ALU_WF;
    reg [1:0] ARF_OutCSel, ARF_OutDSel, ARF_FunSel;
    reg [2:0] ARF_RegSel;
    reg       IR_LH, IR_Write, Mem_WR, Mem_CS;
    reg [1:0] MuxASel, MuxBSel, MuxCSel;
    reg [1:0] DR_FunSel;
    reg       DR_E, MuxDSel;
    reg       T_Reset;

    // =============================================
    // ALU System Instance
    // =============================================
    ArithmeticLogicUnitSystem ALUSys (
        .RF_OutASel(RF_OutASel),
        .RF_OutBSel(RF_OutBSel),
        .RF_FunSel(RF_FunSel),
        .RF_RegSel(RF_RegSel),
        .RF_ScrSel(RF_ScrSel),
        .ALU_FunSel(ALU_FunSel),
        .ALU_WF(ALU_WF),
        .ARF_OutCSel(ARF_OutCSel),
        .ARF_OutDSel(ARF_OutDSel),
        .ARF_FunSel(ARF_FunSel),
        .ARF_RegSel(ARF_RegSel),
        .IR_LH(IR_LH),
        .IR_Write(IR_Write),
        .Mem_WR(Mem_WR),
        .Mem_CS(Mem_CS),
        .MuxASel(MuxASel),
        .MuxBSel(MuxBSel),
        .MuxCSel(MuxCSel),
        .Clock(Clock),
        .DR_FunSel(DR_FunSel),
        .DR_E(DR_E),
        .MuxDSel(MuxDSel)
    );
    // =============================================
    // State Machine (Sequential Logic)
    // =============================================
    always @(posedge Clock or posedge Reset) begin
        if (Reset)
            T <= T0;
        else if (T_Reset) begin
			T_Reset <= 0;
			T <= T0;
        end
        else
            T <= {T[10:0], T[11]};
    
        // === Instruction Decode at T2 ===
        if (T == T2) begin
            Opcode   <= ALUSys.IR.IROut[15:10];
            RegSel   <= ALUSys.IR.IROut[9:8];
            Address  <= ALUSys.IR.IROut[7:0];
            DestReg  <= ALUSys.IR.IROut[9:7];
            SrcReg1  <= ALUSys.IR.IROut[6:4];
            SrcReg2  <= ALUSys.IR.IROut[3:1];
        end
    end

    // =============================================
    // Control Signal Generation (Combinational Logic)
    // =============================================
    always @(*) begin
        // Default values (reset everything)
        RF_RegSel = 0;
        RF_ScrSel = 0;
        RF_OutASel = 0;
        RF_OutBSel = 0;
        RF_FunSel = 0;
    
        ALU_FunSel = 0;
        ALU_WF = 0;
    
        ARF_OutCSel = 0;
        ARF_OutDSel = 0;
        ARF_FunSel = 0;
        ARF_RegSel = 0;
    
        IR_LH = 0;
        IR_Write = 0;
        Mem_WR = 0;
        Mem_CS = 1; // Disabled when CS is 1
    
        MuxASel = 0;
        MuxBSel = 0;
        MuxCSel = 0;
        DR_FunSel = 0;
        DR_E = 0;
        MuxDSel = 0;
        T_Reset = 0;
        
        case (T)
            // ========================
            // FETCH Phase
            // ========================
            T0: begin
                /* Fetch 1 (Load LSB to IR) */
                ARF_OutDSel = 2'b00; // Enable PC
                Mem_CS = 0; // Enabled when CS is 0
                Mem_WR = 0;
                IR_LH = 0;
                IR_Write = 1;
                ARF_RegSel = 3'b000; // PC
                ARF_FunSel = 2'b01; // Increment PC for the next fetch
            end
            
            T1: begin
                /* Fetch 2 (Load MSB to IR) */
                Mem_CS = 0;
                Mem_WR = 0;
                ARF_OutDSel = 2'b00;
                IR_LH = 1;
                IR_Write = 1;
            end
            
            // ========================
            // DECODE Phase
            // ========================
            T2: begin
                // Instruction decoded, PC incremented
                ARF_RegSel = 3'b000; // PC
                ARF_FunSel = 2'b01; // Increment PC, next instruction address
            end
            
            // ========================
            // EXECUTE Phase
            // ========================
            T3: begin
				case(Opcode)
                    BRA:begin
                        MuxBSel = 2'b11; // Send IR(7-0) to ARF

                        ARF_RegSel = 3'b100; // enable PC
                        ARF_FunSel = 2'b10; // load PC

                        T_Reset = 1; // reset T
                    end

                    BNE:begin
                        if(ALUSys.FlagsOut[3] == 0) begin // check if Z flag is 0
                            MuxBSel = 2'b11; // Send IR(7-0) to ARF

                            ARF_RegSel = 3'b100; // enable PC
                            ARF_FunSel = 2'b10; // load PC
                        end

                        T_Reset = 1; // reset T
                    end

                    BEQ:begin
                        if(ALUSys.FlagsOut[3])begin // check if Z flag is 1
                            MuxBSel = 2'b11; // Send IR(7-0) to ARF

                            ARF_RegSel = 3'b100; // enable PC
                            ARF_FunSel = 2'b10; // load PC
                        end

                        T_Reset = 1; // reset T
                    end

                    POPL:begin
                        ARF_OutDSel = 2'b01; // send SP to Memory as an Address

                        Mem_CS = 0; // Enable Memory
                        Mem_WR = 0; // Read from Memory

                        DR_E = 1; // Enable Data Register
                        DR_FunSel = 2'b01; // Load DR (0x000000II)

                        // SP <- SP + 1
                        ARF_RegSel = 3'b010; // Enable SP
                        ARF_FunSel = 2'b01; // Increment SP
                    end

                    PSHL: begin
                        ARF_OutDSel = 2'b01; // send SP to Memory as an Address

                        Mem_CS = 0; // Enable Memory
                        Mem_WR = 0; // Read from Memory

                        // Send selected Rx to ALU
                        RF_OutBSel = {1'b0, RegSel}; // select Rx

                        // Send ALU input to ALU output without any change
                        ALU_FunSel = 5'b00001; // B -> B (16bit)
                        
                        MuxCSel = 2'b00; // ALUOut (7-0) -> Memory

                        // SP <- SP + 1
                        ARF_RegSel = 3'b010; // Enable SP
                        ARF_FunSel = 2'b01; // Increment SP

                    end

                    POPH:begin
                        ARF_OutDSel = 2'b01; // send SP to Memory as an Address

                        Mem_CS = 0; // Enable Memory
                        Mem_WR = 0; // Read from Memory

                        DR_E = 1; // Enable Data Register
                        DR_FunSel = 2'b01; // Load DR (0x000000II)

                        // SP <- SP + 1
                        ARF_RegSel = 3'b010; // Enable SP
                        ARF_FunSel = 2'b01; // Increment SP
                    end

                    PSHH:begin
                        ARF_OutDSel = 2'b01; // send SP to Memory as an Address

                        Mem_CS = 0; // Enable Memory
                        Mem_WR = 1; // Write to Memory

                        // Send selected Rx to ALU
                        RF_OutBSel = {1'b0, RegSel}; // select Rx

                        // Send ALU input to ALU output without any change
                        ALU_FunSel = 5'b10001; // B -> B (32bit)
                        
                        MuxCSel = 2'b00; // ALUOut (7-0) -> Memory

                        // SP <- SP + 1
                        ARF_RegSel = 3'b010; // Enable SP
                        ARF_FunSel = 2'b01; // Increment SP
                    end
                    MOVL: begin
                        /* Select the appropriate register based on the RegSel input*/
                        RF_RegSel =  (RegSel == 2'b00) ? (4'b1000) :
                                     (RegSel == 2'b01) ? (4'b0100) :
                                     (RegSel == 2'b10) ? (4'b0010) :
                                     (RegSel == 2'b11) ? (4'b0001) :
                                     4'b0000;
                        
                        MuxASel = 2'b11; // Select IROut[7:0] (IMMEDIATE)
                        RF_FunSel = 3'b100; // Load only LSB 8 bits, clear upper bits
                        
                        T_Reset = 1; // end MOVL
                    end
                    
                    MOVSH: begin
                        /* Select the appropriate register based on the RegSel input*/
                        RF_RegSel =  (RegSel == 2'b00) ? (4'b1000) :
                                     (RegSel == 2'b01) ? (4'b0100) :
                                     (RegSel == 2'b10) ? (4'b0010) :
                                     (RegSel == 2'b11) ? (4'b0001) :
                                     4'b0000;
                        
                        MuxASel = 2'b11; // Select IROut[7:0] (IMMEDIATE)
                        RF_FunSel = 3'b110; // Load and left shift
                        
                        T_Reset = 1; // end MOVSH
                    end
                    
                    LDARL: begin
                        /* Enable memory for reading */
                        ARF_OutDSel = 2'b10;
                        Mem_CS = 0;
                        Mem_WR = 0;
                        
                        /* Enable DR and load */
                        DR_E = 1;
                        DR_FunSel = 2'b01;
                        
                        /* Increment AR */
                        ARF_RegSel = 3'b001;
                        ARF_FunSel = 2'b01;
                    end
                    
                    LDARH: begin
                        /* Enable memory for reading */
                        ARF_OutDSel = 2'b10;
                        Mem_CS = 0;
                        Mem_WR = 0;
                        
                        /* Enable DR and load */
                        DR_E = 1;
                        DR_FunSel = 2'b01;
                        
                        /* Increment AR */
                        ARF_RegSel = 3'b001;
                        ARF_FunSel = 2'b01;
                    end
                    
                    STAR: begin
                        if (SrcReg1[2] == 0) begin
                            // Selected ARF register is loaded to S1 
                            ARF_OutCSel = SrcReg1[1:0];
                            MuxASel = 2'b01;
                            RF_ScrSel = 4'b1000; // Enable only S1
                            RF_FunSel = 3'b010; // Load to S1
                        end
                    end
                    
                    LDAL: begin
                        /* Load from Memory to DR, then from DR to Rx */
                        
                        /* Load AR from IROut[7:0] */
                        MuxBSel = 2'b11; // Select IROut[7:0]
                        ARF_FunSel = 2'b10;
                        ARF_RegSel = 3'b001; // only to AR
                    end
                    
                    LDAH: begin
                        /* Load from Memory to DR, then from DR to Rx */
                        
                        /* Load AR from IROut[7:0] */
                        MuxBSel = 2'b11; // Select IROut[7:0]
                        ARF_FunSel = 2'b10;
                        ARF_RegSel = 3'b001; // only to AR
                    end
                    
                    STA: begin
                        /* Load AR from IROut[7:0] */
                        MuxBSel = 2'b11; // Select IROut[7:0]
                        ARF_FunSel = 2'b10;
                        ARF_RegSel = 3'b001; // only to AR
                    end
                    
                    LDDRL: begin
                        /* Enable memory for read operation */
                        ARF_OutDSel = 2'10; // Address = AR
                        Mem_CS = 0;
                        Mem_WR = 0;
                        
                        /* Load to DR */
                        DR_E = 1;
                        DR_FunSel = 2'b01; // DR = 0x000000II
                        
                        /* Increment Address for the next byte read */
                        ARF_RegSel = 3'b001; // Only enable AR
                        ARF_FunSel = 2'b01; // Increment
                    end
                    
                    LDDRH: begin
                        /* Enable memory for read operation */
                        ARF_OutDSel = 2'10; // Address = AR
                        Mem_CS = 0;
                        Mem_WR = 0;
                        
                        /* Load to DR */
                        DR_E = 1;
                        DR_FunSel = 2'b01; // DR = 0x000000II
                        
                        /* Increment Address for the next byte read */
                        ARF_RegSel = 3'b001; // Only enable AR
                        ARF_FunSel = 2'b01; // Increment
                    end
                    
                    STDR: begin
                        /* Select the appropriate register based on the DestReg input*/
                        ARF_RegSel = (DestReg == 3'b000) ? (3'b100) :
                                     (DestReg == 3'b001) ? (3'b010) :
                                     (DestReg == 3'b010) ? (3'b001) :
                                     (DestReg == 3'b011) ? (3'b001) :
                                     3'b000;
                        RF_RegSel =  (DestReg == 3'b100) ? (4'b1000) :
                                     (DestReg == 3'b101) ? (4'b0100) :
                                     (DestReg == 3'b110) ? (4'b0010) :
                                     (DestReg == 3'b111) ? (4'b0001) :
                                     4'b0000;
                        
                        /* DROut is connected to RF via MuxA */
                        MuxASel = 2'b10; // Select DROut
                        RF_FunSel = 3'b010; // Load to DestReg
                        
                        /* DROut is connected to ARF via MuxB */
                        MuxBSel = 2'b10; // Select DROut
                        ARF_FunSel = 3'b10; // Load to DestReg
                        
                        T_Reset = 1; // end STDR
                    end
                    
                    STRIM: begin
                        /* Store OFFSET in a scratch register */
                        MuxASel = 2'b11;     // Select IROut[7:0]
                        RF_FunSel = 3'b010;  // Select Load
                        RF_ScrSel = 4'b1000; // Write it to S1 
                    end
				endcase
            end
            
            T4: begin
				case(Opcode)
                    POPL:begin
                        ARF_OutDSel = 2'b01; // send SP to Memory as an Address

                        Mem_CS = 0; // Enable Memory
                        Mem_WR = 0; // Read from Memory

                        DR_E = 1; // Enable Data Register
                        DR_FunSel = 2'b10; // Left shift DR and load it (0x0000IIYY) (Y = new inputs)
                    end

                    PSHL: begin
                        ARF_OutDSel = 2'b01; // send SP to Memory as an Address

                        Mem_CS = 0; // Enable Memory
                        Mem_WR = 1; // Write to Memory

                        // Send selected Rx to ALU
                        RF_OutBSel = {1'b0, RegSel}; // select Rx

                        // Send ALU input to ALU output without any change
                        ALU_FunSel = 5'b00001; // B -> B (16bit)
                        
                        MuxCSel = 2'b01; // ALUOut (15-8) -> Memory

                        // SP <- SP - 1
                        ARF_RegSel = 3'b010; // Enable SP
                        ARF_FunSel = 2'b00; // Decrement SP
                    end

                    POPH:begin
                        ARF_OutDSel = 2'b01; // send SP to Memory as an Address

                        Mem_CS = 0; // Enable Memory
                        Mem_WR = 0; // Read from Memory

                        DR_E = 1; // Enable Data Register
                        DR_FunSel = 2'b10; //Left shift DR and load it (0x0000IIYY) (Y = new inputs)

                        // SP <- SP + 1
                        ARF_RegSel = 3'b010; // Enable SP
                        ARF_FunSel = 2'b01; // Increment SP
                    end

                    PSHH:begin
                        ARF_OutDSel = 2'b01; // send SP to Memory as an Address

                        Mem_CS = 0; // Enable Memory
                        Mem_WR = 1; // Write to Memory

                        // Send selected Rx to ALU
                        RF_OutBSel = {1'b0, RegSel}; // select Rx

                        // Send ALU input to ALU output without any change
                        ALU_FunSel = 5'b10001; // B -> B (32bit)
                        
                        MuxCSel = 2'b01; // ALUOut (15-8) -> Memory
                        
                        // SP <- SP + 1
                        ARF_RegSel = 3'b010; // Enable SP
                        ARF_FunSel = 2'b01; // Increment SP
                    end

                    LDARL: begin
                        DR_FunSel = 2'b10; // DR is fully loaded
                        
                        /* Disable memory and AR */
                        ARF_RegSel = 3'b000;
                        Mem_CS = 1;  
                    end
                    
                    LDARH: begin
                        /* Left shift and load to DR */
                        DR_FunSel = 2'b10;
                        
                        /* Increment AR */
                        ARF_RegSel = 3'b001;
                        ARF_FunSel = 2'b01;
                    end
                    
                    STAR: begin
                        // Disable S1 for writing, AR will be incremented
                        RF_ScrSel = 4'b0000;
                    
                        if (SrcReg1[2] == 0) begin
                            RF_OutBSel = 3'b100;
                        end else begin
                            RF_OutBSel = {0, SrcReg1[1:0]};
                        end
                        
                        // Enable memory for writing
                        ARF_OutDSel = 2'b10;
                        Mem_CS = 0;
                        Mem_WR = 1;
                        
                        // Load from ALU
                        ALU_FunSel = 5'b00001;
                        MuxCSel = 2'b00;
                        
                        // Increment AR
                        ARF_RegSel = 3'b001;
                        ARF_FunSel = 2'01;
                    end
                    
                    LDAL: begin
                        /* Load from Memory to DR, then from DR to Rx */
                        
                        /* Enable memory for read operation */
                        ARF_OutDSel = 2'10; // Address = AR
                        Mem_CS = 0;
                        Mem_WR = 0;
                        
                        /* Load to DR */
                        DR_E = 1;
                        DR_FunSel = 2'b01; // DR = 0x000000II
                        
                        /* Increment Address for the next byte read */
                        ARF_RegSel = 3'b001; // Only enable AR
                        ARF_FunSel = 2'b01; // Increment
                    end
                    
                    LDAH: begin
                        /* Load from Memory to DR, then from DR to Rx */
                        
                        /* Enable memory for read operation */
                        ARF_OutDSel = 2'10; // Address = AR
                        Mem_CS = 0;
                        Mem_WR = 0;
                        
                        /* Load to DR */
                        DR_E = 1;
                        DR_FunSel = 2'b01; // DR = 0x000000II
                        
                        /* Increment Address for the next byte read */
                        ARF_RegSel = 3'b001; // Only enable AR
                        ARF_FunSel = 2'b01; // Increment
                    end
                    
                    STA: begin
                        /* Enable memory for write operation */
                        ARF_OutDSel = 2'b10; // Address = AR
                        Mem_CS = 0;
                        Mem_WR = 1;
                        
                        RF_OutBSel = {1'b0, RegSel}; // Select Rx
                        ALU_FunSel = 5'b00001; // ALUOut = B(Rx)
                        MuxCSel = 2'b00; // Load ALUOut[7:0]
                                                
                        ARF_RegSel = 2'b001; // Select AR
                        ARF_FunSel = 2'b01; // Increment
                    end
                    
                    LDDRL: begin
                        /* Enable memory for read operation */
                        ARF_OutDSel = 2'10; // Address = AR
                        Mem_CS = 0;
                        Mem_WR = 0;
                        
                        /* Load to DR(left-shifted) */
                        DR_E = 1;
                        DR_FunSel = 2'b10; // DR = 0x0000xxII
                        
                        T_Reset = 1; // end LDDRL
                    end
                    
                    LDDRH: begin
                        /* Enable memory for read operation */
                        ARF_OutDSel = 2'10; // Address = AR
                        Mem_CS = 0;
                        Mem_WR = 0;
                        
                        /* Load to DR */
                        DR_E = 1;
                        DR_FunSel = 2'b10; // DR = 0x0000xxII
                        
                        /* Increment Address for the next byte read */
                        ARF_RegSel = 3'b001; // Only enable AR
                        ARF_FunSel = 2'b01; // Increment
                    end
                    
                    STRIM: begin
                        /* Perform addition operation (AR + OFFSET) */
                        ARF_OutCSel = 2'b10; // Select AR
                        MuxDSel = 1;         // Send AR to A input of ALU
                        RF_OutBSel = 3'b100; // Send OFFSET to B input of ALU
                        
                        ALU_FunSel = 5'b00100; // Add
                        ALU_WF = 1;
                        
                        /* Store the result(effective address) in AR */
                        ARF_RegSel = 3'b001;
                        ARF_FunSel = 2'b10;
                    end
				endcase
            end
            
            T5: begin
				case(Opcode)
                    POPL:begin
                        MuxASel = 2'b11; // send DR to RF

                        RF_RegSel = (RegSel == 2'b00) ? (4'b1000) : // enable R1
                                    (RegSel == 2'b01) ? (4'b0100) : // enable R2
                                    (RegSel == 2'b10) ? (4'b0010) : // enable R3
                                    (RegSel == 2'b11) ? (4'b0001); // enable R4
                        RF_FunSel = 3'b010; // load to RF

                        T_Reset = 1; // reset T
                    end

                    PSHL:begin
                        // SP <- SP - 1
                        ARF_RegSel = 3'b010; // Enable SP
                        ARF_FunSel = 2'b00; // Decrement SP

                        T_Reset = 1; // reset T
                    end

                    POPH:begin
                        ARF_OutDSel = 2'b01; // send SP to Memory as an Address

                        Mem_CS = 0; // Enable Memory
                        Mem_WR = 0; // Read from Memory

                        DR_E = 1; // Enable Data Register
                        DR_FunSel = 2'b10; //Left shift DR and load it (0x00IIYYXX) (X = new inputs)
                        
                        // SP <- SP + 1
                        ARF_RegSel = 3'b010; // Enable SP
                        ARF_FunSel = 2'b01; // Increment SP
                    end

                    PSHH:begin
                        ARF_OutDSel = 2'b01; // send SP to Memory as an Address

                        Mem_CS = 0; // Enable Memory
                        Mem_WR = 1; // Write to Memory

                        // Send selected Rx to ALU
                        RF_OutBSel = {1'b0, RegSel}; // select Rx

                        // Send ALU input to ALU output without any change
                        ALU_FunSel = 5'b10001; // B -> B (32bit)
                        
                        MuxCSel = 2'b10; // ALUOut (23-16) -> Memory
                        
                        // SP <- SP + 1
                        ARF_RegSel = 3'b010; // Enable SP
                        ARF_FunSel = 2'b01; // Increment SP
                    end
                    LDARL: begin
                        /* Select the appropriate register based on the DestReg input*/
                        ARF_RegSel = (DestReg == 3'b000) ? (3'b100) :
                                     (DestReg == 3'b001) ? (3'b010) :
                                     (DestReg == 3'b010) ? (3'b001) :
                                     (DestReg == 3'b011) ? (3'b001) :
                                     3'b000;
                        RF_RegSel =  (DestReg == 3'b100) ? (4'b1000) :
                                     (DestReg == 3'b101) ? (4'b0100) :
                                     (DestReg == 3'b110) ? (4'b0010) :
                                     (DestReg == 3'b111) ? (4'b0001) :
                                     4'b0000;

                        /* Select DROut for both multiplexers */
                        MuxASel = 2'b10;
                        MuxBSel = 2'b10;
                        
                        /* 
                          Enable load operations
                          
                          if ARF_RegSel or RF_RegSel is 0, 
                          Selected funciton will not be applied
                        */
                        ARF_FunSel = 2'b10;
                        RF_FunSel = 2'b10;
                        
                        T_Reset = 1; // end LDARL
                    end
                    
                    LDARH: begin
                        /* Left shift and load to DR */
                        DR_FunSel = 2'b10;
                        
                        /* Increment AR */
                        ARF_RegSel = 3'b001;
                        ARF_FunSel = 2'b01;
                    end
                    
                    STAR: begin
                        // Load from ALU
                        ALU_FunSel = 5'b00001;
                        MuxCSel = 2'b01;
                        
                        // Increment AR
                        ARF_RegSel = 3'b001;
                        ARF_FunSel = 2'01;
                    end
                    
                    LDAL: begin
                        /* Load from Memory to DR, then from DR to Rx */
                        
                        /* Enable memory for read operation */
                        ARF_OutDSel = 2'10; // Address = AR
                        Mem_CS = 0;
                        Mem_WR = 0;
                        
                        /* Load to DR */
                        DR_E = 1;
                        DR_FunSel = 2'b10; // DR = 0x0000xxII
                    end
                    
                    LDAH: begin
                        /* Load from Memory to DR, then from DR to Rx */
                        
                        /* Enable memory for read operation */
                        ARF_OutDSel = 2'10; // Address = AR
                        Mem_CS = 0;
                        Mem_WR = 0;
                        
                        /* Load to DR */
                        DR_E = 1;
                        DR_FunSel = 2'b10; // DR = 0x0000xxII
                        
                        /* Increment Address for the next byte read */
                        ARF_RegSel = 3'b001; // Only enable AR
                        ARF_FunSel = 2'b01; // Increment
                    end
                    
                    STA: begin
                        /* Enable memory for write operation */
                        ARF_OutDSel = 2'b10; // Address = AR
                        Mem_CS = 0;
                        Mem_WR = 1;
                        
                        RF_OutBSel = {1'b0, RegSel}; // Select Rx
                        ALU_FunSel = 5'b00001; // ALUOut = B(Rx)
                        MuxCSel = 2'b01; // Load ALUOut[15:8]
                                                
                        ARF_RegSel = 2'b001; // Select AR
                        ARF_FunSel = 2'b01; // Increment
                    end
                    
                    LDDRH: begin
                        /* Enable memory for read operation */
                        ARF_OutDSel = 2'10; // Address = AR
                        Mem_CS = 0;
                        Mem_WR = 0;
                        
                        /* Load to DR */
                        DR_E = 1;
                        DR_FunSel = 2'b10; // DR = 0x00xxxxII
                        
                        /* Increment Address for the next byte read */
                        ARF_RegSel = 3'b001; // Only enable AR
                        ARF_FunSel = 2'b01; // Increment
                    end
                    
                    STRIM: begin
                        Mem_CS = 0;
                        Mem_WR = 1;
                        ARF_OutDSel = 2'b10; // Memory Address
                        
                        RF_OutBSel = {1'b0, RegSel}; // Select Rx
                        ALU_FunSel = 5'b00001; // ALUOut = B(Rx)
                        MuxCSel = 2'b00; // Load ALUOut[7:0]
                        
                        ARF_RegSel = 2'b001; // Select AR
                        ARF_FunSel = 2'b01; // Increment
                    end
				endcase
            end
            
            T6: begin
				case(Opcode)
                    POPH:begin
                        ARF_OutDSel = 2'b01; // send SP to Memory as an Address

                        Mem_CS = 0; // Enable Memory
                        Mem_WR = 0; // Read from Memory

                        DR_E = 1; // Enable Data Register
                        DR_FunSel = 2'b10; //Left shift DR and load it (0xIIYYXXZZ) (Z = new inputs)

                        // SP <- SP - 1
                        ARF_RegSel = 3'b010; // Enable SP
                        ARF_FunSel = 2'b01; // Decrement SP
                    end

                    PSHH:begin
                        ARF_OutDSel = 2'b01; // send SP to Memory as an Address

                        Mem_CS = 0; // Enable Memory
                        Mem_WR = 1; // Write to Memory

                        // Send selected Rx to ALU
                        RF_OutBSel = {1'b0, RegSel}; // select Rx

                        // Send ALU input to ALU output without any change
                        ALU_FunSel = 5'b10001; // B -> B (32bit)
                        
                        MuxCSel = 2'b11; // ALUOut (31-24) -> Memory
                        
                        // SP <- SP - 1
                        ARF_RegSel = 3'b010; // Enable SP
                        ARF_FunSel = 2'b00; // Decrement SP
                    end

                    LDARH: begin
                        DR_FunSel = 2'b10; // DR is fully loaded
                        
                        /* Disable memory and AR */
                        ARF_RegSel = 3'b000;
                        Mem_CS = 1;        
                    end
                    
                    STAR: begin
                        // Load from ALU
                        ALU_FunSel = 5'b00001;
                        MuxCSel = 2'b10;
                        
                        // Increment AR
                        ARF_RegSel = 3'b001;
                        ARF_FunSel = 2'01;
                    end
                    
                    LDAL: begin
                        /* Load from Memory to DR, then from DR to Rx */

                        /* Load to Rx */
                        DR_E = 0;
                        MuxASel = 2'b10; // Select DROut
                        RF_RegSel = (RegSel == 2'b00) ? (4'b1000) :
                                    (RegSel == 2'b01) ? (4'b0100) :
                                    (RegSel == 2'b10) ? (4'b0010) :
                                    (RegSel == 2'b11) ? (4'b0001) :
                                    4'b0000;
                        RF_FunSel = 3'b010; // Load
                        
                        T_Reset = 1; // end LDAL
                    end
                    
                    LDAH: begin
                        /* Load from Memory to DR, then from DR to Rx */
                        
                        /* Enable memory for read operation */
                        ARF_OutDSel = 2'10; // Address = AR
                        Mem_CS = 0;
                        Mem_WR = 0;
                        
                        /* Load to DR */
                        DR_E = 1;
                        DR_FunSel = 2'b10; // DR = 0x00xxxxII
                        
                        /* Increment Address for the next byte read */
                        ARF_RegSel = 3'b001; // Only enable AR
                        ARF_FunSel = 2'b01; // Increment
                    end
                    
                    STA: begin
                        /* Enable memory for write operation */
                        ARF_OutDSel = 2'b10; // Address = AR
                        Mem_CS = 0;
                        Mem_WR = 1;
                        
                        RF_OutBSel = {1'b0, RegSel}; // Select Rx
                        ALU_FunSel = 5'b00001; // ALUOut = B(Rx)
                        MuxCSel = 2'b10; // Load ALUOut[23:15]
                                                
                        ARF_RegSel = 2'b001; // Select AR
                        ARF_FunSel = 2'b01; // Increment
                    end
                    
                    LDDRH: begin
                        /* Enable memory for read operation */
                        ARF_OutDSel = 2'10; // Address = AR
                        Mem_CS = 0;
                        Mem_WR = 0;
                        
                        /* Load to DR */
                        DR_E = 1;
                        DR_FunSel = 2'b10; // DR = 0x-xxxxxxII
                        
                        T_Reset = 1; // end LDDRH
                    end
                    
                    STRIM: begin
                        Mem_CS = 0;
                        Mem_WR = 1;
                        ARF_OutDSel = 2'b10; // Memory Address
                        
                        RF_OutBSel = {1'b0, RegSel}; // Select Rx
                        ALU_FunSel = 5'b00001; // ALUOut = B(Rx)
                        MuxCSel = 2'b01; // Load ALUOut[15:8]
                                                
                        ARF_RegSel = 2'b001; // Select AR
                        ARF_FunSel = 2'b01; // Increment
                    end
				endcase
            end
            
            T7: begin
				case(Opcode)
                    POPH:begin
                        MuxASel = 2'b11; // send DR to RF

                        RF_RegSel = (RegSel == 2'b00) ? (4'b1000) : // enable R1
                                    (RegSel == 2'b01) ? (4'b0100) : // enable R2
                                    (RegSel == 2'b10) ? (4'b0010) : // enable R3
                                    (RegSel == 2'b11) ? (4'b0001); // enable R4
                        RF_FunSel = 3'b010; // load to RF

                        // SP <- SP - 1
                        ARF_RegSel = 3'b010; // Enable SP
                        ARF_FunSel = 2'b01; // Decrement SP

                        T_Reset = 1; // reset T
                    end

                    PSHH:begin
                        // SP <- SP - 1
                        ARF_RegSel = 3'b010; // Enable SP
                        ARF_FunSel = 2'b00; // Decrement SP
                    end
                    LDARH: begin
                        /* Select the appropriate register based on the DestReg input*/
                        ARF_RegSel = (DestReg == 3'b000) ? (3'b100) :
                                     (DestReg == 3'b001) ? (3'b010) :
                                     (DestReg == 3'b010) ? (3'b001) :
                                     (DestReg == 3'b011) ? (3'b001) :
                                     3'b000;
                        RF_RegSel =  (DestReg == 3'b100) ? (4'b1000) :
                                     (DestReg == 3'b101) ? (4'b0100) :
                                     (DestReg == 3'b110) ? (4'b0010) :
                                     (DestReg == 3'b111) ? (4'b0001) :
                                     4'b0000;

                        /* Select DROut for both multiplexers */
                        MuxASel = 2'b10;
                        MuxBSel = 2'b10;
                        
                        /* 
                          Enable load operations
                          
                          if ARF_RegSel or RF_RegSel is 0, 
                          Selected funciton will not be applied
                        */
                        ARF_FunSel = 2'b10;
                        RF_FunSel = 2'b10;
                        
                        T_Reset = 1; // end LDARH
                    end
                    
                    STAR: begin
                        // Load from ALU
                        ALU_FunSel = 5'b00001;
                        MuxCSel = 2'b11;
                        
                        T_Reset = 1; // end STAR
                    end
                    
                    LDAH: begin
                        /* Load from Memory to DR, then from DR to Rx */
                        
                        /* Enable memory for read operation */
                        ARF_OutDSel = 2'10; // Address = AR
                        Mem_CS = 0;
                        Mem_WR = 0;
                        
                        /* Load to DR */
                        DR_E = 1;
                        DR_FunSel = 2'b10; // DR = 0x-xxxxxxII
                    end
                    
                    STA: begin
                        /* Enable memory for write operation */
                        ARF_OutDSel = 2'b10; // Address = AR
                        Mem_CS = 0;
                        Mem_WR = 1;
                        
                        RF_OutBSel = {1'b0, RegSel}; // Select Rx
                        ALU_FunSel = 5'b00001; // ALUOut = B(Rx)
                        MuxCSel = 2'b11; // Load ALUOut[31:24]
                                                
                        T_Reset = 1; // end STA
                    end
                    
                    STRIM: begin
                        Mem_CS = 0;
                        Mem_WR = 1;
                        ARF_OutDSel = 2'b10; // Memory Address
                        
                        RF_OutBSel = {1'b0, RegSel}; // Select Rx
                        ALU_FunSel = 5'b00001; // ALUOut = B(Rx)
                        MuxCSel = 2'b10; // Load ALUOut[23:16]
                                                
                        ARF_RegSel = 2'b001; // Select AR
                        ARF_FunSel = 2'b01; // Increment
                    end
				endcase
            end
            
            T8: begin
				case(Opcode)
                    PSHH:begin
                        // SP <- SP - 1
                        ARF_RegSel = 3'b010; // Enable SP
                        ARF_FunSel = 2'b00; // Decrement SP
                    end

                    LDAH: begin
                        /* Load from Memory to DR, then from DR to Rx */

                        /* Load to Rx */
                        DR_E = 0;
                        MuxASel = 2'b10; // Select DROut
                        RF_RegSel = (RegSel == 2'b00) ? (4'b1000) :
                                    (RegSel == 2'b01) ? (4'b0100) :
                                    (RegSel == 2'b10) ? (4'b0010) :
                                    (RegSel == 2'b11) ? (4'b0001) :
                                    4'b0000;
                        RF_FunSel = 3'b010; // Load
                        
                        T_Reset = 1; // end LDAH
                    end
                    
                    STRIM: begin
                        Mem_CS = 0;
                        Mem_WR = 1;
                        ARF_OutDSel = 2'b10; // Memory Address
                        
                        RF_OutBSel = {1'b0, RegSel}; // Select Rx
                        ALU_FunSel = 5'b00001; // ALUOut = B(Rx)
                        MuxCSel = 2'b11; // Load ALUOut[31:24]
                        
                        T_Reset = 1; // end STRIM
                    end
				endcase
            end
            
            T9: begin
                case(Opcode)
                PSHH:begin
                        // SP <- SP - 1
                        ARF_RegSel = 3'b010; // Enable SP
                        ARF_FunSel = 2'b00; // Decrement SP

                        T_Reset = 1; // reset T
                    end
                endcase
            end
            
            T10: begin
            end
            
            T11: begin
            end
            
        endcase
    end
endmodule
