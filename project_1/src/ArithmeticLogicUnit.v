`timescale 1ns / 1ps

/*
    Module Authors: Murat Toprak & Vedat Enis Gül
    Implementation of the Arithmetic Logic Unit
    
    A 4-bit flag register is used to save additional information
    for every operation. However, some flags are not checked for some operations.
    Flag Register (MSB to LSB): ZERO, CARRY, NEGATIVE, OVERFLOW.
    
    Maximum line length is 90 characters
*/

`define ZERO_FLAG       3
`define CARRY_FLAG      2
`define NEGATIVE_FLAG   1
`define OVERFLOW_FLAG   0

module ArithmeticLogicUnit (
    input wire [31:0]   A,
    input wire [31:0]   B,
    input wire [4:0]    FunSel,
    input wire          WF,
    input wire          Clock,
    output reg [31:0]   ALUOut,
    output reg [3:0]    FlagsOut
);
    wire [15:0] B_comp_16;
    wire [31:0] B_comp_32;
    assign B_comp_16 = ~B[15:0] + 1;
    assign B_comp_32 = ~B + 1;
     
    reg [32:0] temp_result; // Extra bit for carry detection
    
    /* Combinatorial ALU Logic */
    always @(*)
    begin
        if (!WF)
            ALUOut = ALUOut;
        else
        begin

        case(FunSel)
            /* ---- 16-BIT OPERATIONS ---- */
        
            /* Choose A, B, ANOT, BNOT */
            5'b00000:   ALUOut = {16'b0, A[15:0]};
            5'b00001:   ALUOut = {16'b0, B[15:0]};
            5'b00010:   ALUOut = {16'b0, ~A[15:0]};
            5'b00011:   ALUOut = {16'b0, ~B[15:0]};
            
            /* Arithmetic operations */
            5'b00100: // A + B 
            begin
                temp_result = {1'b0, A[15:0]} + {1'b0, B[15:0]};
                ALUOut = {16'b0, temp_result[15:0]};
            end            
            5'b00101: // A + B + carry_in
            begin 
                temp_result = {1'b0, A[15:0]} + {1'b0, B[15:0]} + FlagsOut[`CARRY_FLAG];
                ALUOut = {16'b0, temp_result[15:0]};
            end
            5'b00110: // A - B
            begin
                temp_result = {1'b0, A[15:0]} + {1'b0, B_comp_16};
                ALUOut = {16'b0, temp_result[15:0]};
            end
            
            /* Logic Operations */
            5'b00111:   ALUOut = {16'b0, A[15:0] & B[15:0]};
            5'b01000:   ALUOut = {16'b0, A[15:0] | B[15:0]};
            5'b01001:   ALUOut = {16'b0, A[15:0] ^ B[15:0]};
            5'b01010:   ALUOut = {16'b0, ~(A[15:0] & B[15:0])};
            
            /* Shift Operations*/
            5'b01011: // Logical Shift Left A 
            begin
                temp_result = {1'b0, A[15:0]} << 1;
                ALUOut = temp_result[15:0];
            end
            5'b01100: // Logical Shift Right A 
            begin
                temp_result = {A[15:0], 1'b0} >> 1;
                ALUOut = {16'b0, temp_result[16:1]};
            end
            5'b01101: // Arithmetic Shift Right A
                ALUOut = {16'b0, $signed(A[15:0]) >>> 1};
            5'b01110: // Circular Shift Left A
                ALUOut = {16'b0, A[14:0], FlagsOut[`CARRY_FLAG]};
            5'b01111: // Circular Shift Right A
                ALUOut = {16'b0, FlagsOut[`CARRY_FLAG], A[15:1]};
            
            /* ---- 32-BIT OPERATIONS ---- */
            
            /* Choose A, B, ANOT, BNOT */
            5'b10000:   ALUOut = A;
            5'b10001:   ALUOut = B;
            5'b10010:   ALUOut = ~A;
            5'b10011:   ALUOut = ~B;
            
            /* Arithmetic Operations */
            5'b10100: // A + B 
            begin
                temp_result = {1'b0, A} + {1'b0, B};
                ALUOut = {temp_result[31:0]};
            end
            5'b10101: // A + B + carry_in 
            begin
                temp_result = {1'b0, A} + {1'b0, B} + FlagsOut[`CARRY_FLAG];
                ALUOut = {temp_result[31:0]};
            end
            5'b10110: // A - B 
            begin
                temp_result = {1'b0, A} - {1'b0, B};
                ALUOut = temp_result[31:0];
            end
            
            /* Logic Operations */
            5'b10111:   ALUOut = A & B;
            5'b11000:   ALUOut = A | B;
            5'b11001:   ALUOut = A ^ B;
            5'b11010:   ALUOut = ~(A & B);
            
            /* Shift Operations */
            5'b11011: // Logical Shift Left A 
            begin
                temp_result = {1'b0, A} << 1;
                ALUOut = temp_result[31:0];
            end    
            5'b11100: // Logical Shift Right A
            begin
                temp_result = {A, 1'b0} >> 1;
                ALUOut = temp_result[32:1];
            end
            5'b11101: // Arithmetic Shift Right A
                ALUOut = $signed(A) >>> 1;
            5'b11110: // Circular Shift Left A
                ALUOut = {A[30:0], FlagsOut[`CARRY_FLAG]};
            5'b11111: // Circular Shift Right A
                ALUOut = {FlagsOut[`CARRY_FLAG], A[31:1]};

            default:    ALUOut = ALUOut;
        endcase
        end
    end
    
    /* Sequential Flag Register Logic */
    always @(posedge Clock) 
    begin
        /* Update ZERO and NEGATIVE flags in every clock cycle */
        FlagsOut[`ZERO_FLAG] <= (ALUOut == 32'b0);
        if (FunSel[4] == 0) 
            FlagsOut[`NEGATIVE_FLAG] <= (ALUOut[15] == 1);
        else
            FlagsOut[`NEGATIVE_FLAG] <= (ALUOut[31] == 1);
        
        /* CARRY and OVERFLOW flag is updated based on FunSel */
        /* temp_result buffer is utilized for these flag updates */    
        case (FunSel)
            5'b00100, 5'b00101, 5'b00110, 5'b01011:
            begin
                FlagsOut[`CARRY_FLAG] <= temp_result[16];
                if (FunSel == 5'b00100 || FunSel == 5'b00101)
                    FlagsOut[`OVERFLOW_FLAG] <= (~(A[15] ^ B[15])) & (A[15] ^ ALUOut[15]);
                else if (FunSel == 5'b00110)
                    FlagsOut[`OVERFLOW_FLAG] <= (A[15] ^ B[15]) & (A[15] ^ ALUOut[15]);
            end
            5'b01100:
                FlagsOut[`CARRY_FLAG] <= temp_result[0];
            5'b01110:
                FlagsOut[`CARRY_FLAG] <= A[15];
            5'b01111:
                FlagsOut[`CARRY_FLAG] <= A[0];
            
            5'b10100, 5'b10101, 5'b10110, 5'b11011:
            begin
                FlagsOut[`CARRY_FLAG] <= temp_result[32];
                if (FunSel == 5'b10100 || FunSel == 5'b10101)
                    FlagsOut[`OVERFLOW_FLAG] <= (~(A[31] ^ B[31])) & (A[31] ^ ALUOut[31]);
                else if (FunSel == 5'b10110)
                    FlagsOut[`OVERFLOW_FLAG] <= (A[31] ^ B[31]) & (A[31] ^ ALUOut[31]);
            end
                
            5'b11100:
                FlagsOut[`CARRY_FLAG] <= temp_result[0];
            5'b11110:
                FlagsOut[`CARRY_FLAG] <= A[31];
            5'b11111:
                FlagsOut[`CARRY_FLAG] <= A[0];
            
            default: FlagsOut <= FlagsOut;
        endcase
    end
endmodule
