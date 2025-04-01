`timescale 1ns / 1ps

`define ZERO_FLAG       3
`define CARRY_FLAG      2
`define NEGATIVE_FLAG   1
`define OVERFLOW_FLAG   0

module alu(
    input wire clock,
    input wire Cin,
    input wire [4:0] FunSel,
    input wire [31:0] InA,
    input wire [31:0] InB,
    output reg [3:0] flags,
    output reg [31:0] Out
);
    wire [15:0] B_comp_16;
    wire [31:0] B_comp_32;
    assign B_comp_16 = ~InB[15:0] + 1;
    assign B_comp_32 = ~InB + 1;
     
    reg [32:0] temp_result; // Extra bit for carry detection
    
    always @(posedge clock)
    begin
        case(FunSel)
            /* ---- 16-BIT OPERATIONS ---- */
            
            /* Choose A, B, ANOT, BNOT */
            5'b00000:   Out <= {16'b0, InA[15:0]};
            5'b00001:   Out <= {16'b0, InB[15:0]};
            5'b00010:   Out <= {16'b0, ~InA[15:0]};
            5'b00011:   Out <= {16'b0, ~InB[15:0]};
            
            /* Arithmetic operations */
            5'b00100: begin  // A + B
                temp_result <= {1'b0, InA[15:0]} + {1'b0, InB[15:0]};
                Out <= {16'b0, temp_result[15:0]};
                flags[`CARRY_FLAG] <= temp_result[16];
                
                // Overflow occurs if both operands are same sign and result is opposite
                flags[`OVERFLOW_FLAG] <= (~(InA[15] ^ InB[15])) & (InA[15] ^ Out[15]);
            end            
            5'b00101: begin // A + B + Cin
                temp_result <= {1'b0, InA[15:0]} + {1'b0, InB[15:0]} + Cin;
                Out <= {16'b0, temp_result[15:0]};
                flags[`CARRY_FLAG] <= temp_result[16];
                
                // Overflow occurs if both operands are same sign and result is opposite
                flags[`OVERFLOW_FLAG] <= (~(InA[15] ^ InB[15])) & (InA[15] ^ Out[15]);
            end
            5'b00110: begin // A - B
                temp_result <= {1'b0, InA[15:0]} + {1'b0, B_comp_16};
                Out <= {16'b0, temp_result[15:0]};
                flags[`CARRY_FLAG] <= temp_result[16];
                
                // Overflow condition:
                // A and B have different signs
                // A and result also have different signs
                // neg - pos => pos or pos - neg => pos
                flags[`OVERFLOW_FLAG] <= (InA[15] ^ InB[15]) & (InA[15] ^ Out[15]);
            end
            
            /* Logic Operations */
            5'b00111:   Out <= {16'b0, InA[15:0] & InB[15:0]};
            5'b01000:   Out <= {16'b0, InA[15:0] | InB[15:0]};
            5'b01001:   Out <= {16'b0, InA[15:0] ^ InB[15:0]};
            5'b01010:   Out <= {16'b0, ~(InA[15:0] & InB[15:0])};
            
            /* Shift Operations*/
            5'b01011: begin // Logical Shift Left A
                temp_result <= {1'b0, InA[15:0]} << 1;
                Out <= temp_result[15:0];
                flags[`CARRY_FLAG] <= temp_result[16];
            end
            5'b01100: begin // Logical Shift Right A
                temp_result <= {InA[15:0], 1'b0} >> 1;
                Out <= {16'b0, temp_result[16:1]};
                flags[`CARRY_FLAG] <= temp_result[0];
            end
            5'b01101: Out <= {16'b0, $signed(InA[15:0]) >>> 1}; // Arithmetic Shift Right A
            5'b01110: begin // Circular Shift Left A
                Out <= {16'b0, InA[14:0], Cin};
                flags[`CARRY_FLAG] <= InA[15];
            end
            5'b01111: begin // Circular Shift Right A
                Out <= {16'b0, Cin, InA[15:1]};
                flags[`CARRY_FLAG] <= InA[0];
            end
            
            /* ---- 32-BIT OPERATIONS ---- */
            
            /* Choose A, B, ANOT, BNOT */
            5'b10000:   Out <= InA;
            5'b10001:   Out <= InB;
            5'b10010:   Out <= ~InA;
            5'b10011:   Out <= ~InB;
            
            /* Arithmetic Operations */
            5'b10100: begin // A + B
                temp_result <= {1'b0, InA} + {1'b0, InB};
                Out <= {temp_result[31:0]};
                flags[`CARRY_FLAG] <= temp_result[32];
                
                // Overflow occurs if both operands are same sign and result is opposite
                flags[`OVERFLOW_FLAG] <= (~(InA[31] ^ InB[31])) & (InA[31] ^ Out[31]);
            end
            5'b10101: begin // A + B + Cin
                temp_result <= {1'b0, InA} + {1'b0, InB} + Cin;
                Out <= {temp_result[31:0]};
                flags[`CARRY_FLAG] <= temp_result[32];
                
                // Overflow occurs if both operands are same sign and result is opposite
                flags[`OVERFLOW_FLAG] <= (~(InA[31] ^ InB[31])) & (InA[31] ^ Out[31]);
            end
            5'b10110: begin // A - B
                temp_result <= {1'b0, InA} - {1'b0, InB};
                Out <= temp_result[31:0];
                flags[`CARRY_FLAG] <= temp_result[32];
                
                // Overflow condition:
                // A and B have different signs
                // A and result also have different signs
                // neg - pos => pos or pos - neg => pos
                flags[`OVERFLOW_FLAG] <= (InA[31] ^ InB[31]) & (InA[31] ^ Out[31]);
            end
            
            /* Logic Operations */
            5'b10111:   Out <= InA & InB;
            5'b11000:   Out <= InA | InB;
            5'b11001:   Out <= InA ^ InB;
            5'b11010:   Out <= ~(InA & InB);
            
            /* Shift Operations */
            5'b11011: begin // Logical Shift Left A
                temp_result <= {1'b0, InA} << 1;
                Out <= temp_result[31:0];
                flags[`CARRY_FLAG] = temp_result[32]; // Carry flag
            end    
            5'b11100: begin // Logical Shift Right A
                temp_result <= {InA, 1'b0} >> 1;
                Out <= temp_result[32:1];
                flags[`CARRY_FLAG] <= temp_result[0];
            end
            5'b11101: Out <= $signed(InA) >>> 1; // Arithmetic Shift Right A
            5'b11110: begin // Circular Shift Left A
                Out <= {InA[30:0], Cin};
                flags[`CARRY_FLAG] <= InA[31];
            end
            5'b11111: begin // Circular Shift Right A
                Out <= {Cin, InA[31:1]};
                flags[`CARRY_FLAG] <= InA[0];
            end
            
            default: begin
                Out <= Out;
                flags <= flags;
            end
        endcase
                
        flags[`ZERO_FLAG] <= (Out == 32'b0);
        
        if (FunSel[4] == 0) 
            flags[`NEGATIVE_FLAG] <= (Out[15] == 1);
        else
            flags[`NEGATIVE_FLAG] <= (Out[31] == 1);
    end
endmodule
