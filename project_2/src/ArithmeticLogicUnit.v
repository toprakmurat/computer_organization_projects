`timescale 1ns / 1ps

/*
    Module Authors: Murat Toprak & Vedat Enis Gül

    Implementation of the Arithmetic Logic Unit

    A 4-bit flag register is used to save additional information
    for every operation. However, some flags are not checked for some operations.
    Flag Register (MSB to LSB): ZERO, CARRY, NEGATIVE, OVERFLOW.    
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
        case(FunSel)
            /* ---- 16-BIT OPERATIONS ---- */
			
			/*
			 * Depending on the function applied, `temp_result` buffer 
			 * is used to update the flag register later.
			 *
			 * All operations extend the 16 bits (MSB) of ALUOut with 0, 
			 * as we are dealing with only 16-bit inputs
			 */
			 
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
			
			/*
			 * Depending on the function applied, `temp_result` buffer 
			 * is used to update the flag register later.
			 */

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
                temp_result = {1'b0, A} + {1'b0, B_comp_32};
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

    /* Sequential Flag Register Logic */
    always @(posedge Clock) 
    begin
        if (!WF)
            FlagsOut <= FlagsOut;
        else
        begin
		
		/* 
		 * - ZERO_FLAG: Set to 1 if all bits of ALUOut is zero; otherwise, set to 0.
		 * - NEGATIVE_FLAG: Set to 1 if the most significant bit (MSB) of ALUOut is 1 
		 *   - For 16-bit operations, the MSB is ALUOut[15].
		 *   - For 32-bit operations, the MSB is ALUOut[31].
		 * - CARRY_FLAG: Updated based on the operation specified by FunSel.
		 * - OVERFLOW_FLAG: Updated for addition and subtraction to indicate overflow.
		 * 
		 * The `temp_result` buffer is used for carry and overflow calculations.
		 * The flags do not change if WF is low.
		 */
		 
		/*
         * Carry Detection Logic
		 * 
		 * Arithmetic Operations:
		 * - For addition, a carry is detected if there is an overflow
		 * from the most significant bit (MSB) of the result.
		 *   - For 16-bit operations: `temp_result[16]` indicates a carry.
		 *   - For 32-bit operations: `temp_result[32]` indicates a carry.
		 *
		 * - For subtraction, a carry is detected when borrowing occurs, 
		 * which is represented using the two's complement addition logic.
		 * 
		 * Shift Operations:
		 * - For logical and circular shift left, carry flag gets the MSB of input.
		 * - For logical and circular shift right, carry flag gets the LSB of input.
		 * - For arithmetic shifts, carry flag updates are not necessary.
		 */
		 
		/*
         * Overflow Detection Logic (For 32-bit inputs)
		 * Note: The one and only difference for 16-bit inputs is,
		 * `ALUOut` indexes become 15 instead of 31.
		 *
		 * Case 5'b10100 (A + B) and 5'b10101 (A + B + Cin) overflow detection:
		 * - Overflow occurs if the sign bits of A and B are the same (A[31] == B[31]),
		 *   but the sign bit of the result (ALUOut[31]) differs from A and B.
		 * - The condition is expressed as:
		 *   (~(A[31] ^ B[31])) & (A[31] ^ ALUOut[31])
		 *   - `~(A[31] ^ B[31])`: A and B have the same sign.
		 *   - `(A[31] ^ ALUOut[31])`: the result has a different sign.
		 *
		 * Case 5'b10110 (A - B) overflow detection:
		 * - Overflow occurs if the sign bits of A and B differ (A[31] != B[31]),
		 *   but the sign bit of the result (ALUOut[31]) differs from A.
		 * - The condition is expressed as:
		 *   (A[31] ^ B[31]) & (A[31] ^ ALUOut[31])
		 *   - `(A[31] ^ B[31])`: A and B have different signs.
		 *   - `(A[31] ^ ALUOut[31])`: the result has a different sign from A.
         */
		
        /* Update ZERO and NEGATIVE flags in every clock cycle */
        FlagsOut[`ZERO_FLAG] <= (ALUOut == 32'b0);
        if (FunSel[4] == 0) 
            FlagsOut[`NEGATIVE_FLAG] <= (ALUOut[15] == 1);
        else
            FlagsOut[`NEGATIVE_FLAG] <= (ALUOut[31] == 1);
 
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
    end
endmodule
