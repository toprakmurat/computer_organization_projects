module ArithmeticLogicUnit(A, B, FunSel, WF, Clock, ALUOut, FlagsOut);

    input wire Clock;
    input wire [31:0] A;
    input wire [31:0] B;
    input wire [4:0] FunSel;
    input wire WF;

    output reg [31:0] ALUOut;
    output reg [3:0] FlagsOut; // Z|C|N|V

    wire [31:0] b_complement_32_bit;
    assign b_complement_32_bit = ~B + 1;

    wire [16:0] b_complement_16_bit;
    assign b_complement_16_bit = ~B[15:0] + 1;

    reg Z; // Zero
    reg C; // Carry
    reg N; // Negative
    reg O; // Overflow

    `define SIGN_EXTEND(value) {{16{value[15]}}, value} // 16-bit to 32-bit sign extension

    always @(posedge Clock)
    begin
        Z <= 1'b0;
        C <= WF;
        N <= 1'b0;
        O <= 1'b0;

        case (FunSel)
        //16-bit operations, using the last 16 bits of A and B
        // Directly assign A or B
        5'b00000: ALUOut <= `SIGN_EXTEND(A[15:0]); 
        5'b00001: ALUOut <= `SIGN_EXTEND(B[15:0]);
        // not A or not B
        5'b00010: ALUOut <= `SIGN_EXTEND(~A[15:0]); 
        5'b00011: ALUOut <= `SIGN_EXTEND(~B[15:0]); 
        // A + B , A + B + carry, A - B
        5'b00100: ALUOut <= `SIGN_EXTEND(A[15:0] + B[15:0]);
        5'b00101: ALUOut <= `SIGN_EXTEND(A[15:0] + B[15:0] + C); 
        5'b00110: ALUOut <= `SIGN_EXTEND(A[15:0] + b_complement_16_bit); 
        // A & B, A | B, A ^ B, ~(A & B)
        5'b00111: ALUOut <= `SIGN_EXTEND(A[15:0] & B[15:0]);
        5'b01000: ALUOut <= `SIGN_EXTEND(A[15:0] | B[15:0]);
        5'b01001: ALUOut <= `SIGN_EXTEND(A[15:0] ^ B[15:0]);
        5'b01010: ALUOut <= `SIGN_EXTEND(~(A[15:0] & B[15:0])); 
        // LSL A, LSR A, ASR A, CSL A, CSR A
        5'b01011: ALUOut <= `SIGN_EXTEND(A[15:0] << 1);
        5'b01100: ALUOut <= `SIGN_EXTEND(A[15:0] >> 1);
        5'b01101: ALUOut <= `SIGN_EXTEND($signed(A[15:0]) >>> 1); 
        5'b01110: ALUOut <= `SIGN_EXTEND({A[14:0],C}); 
        5'b01111: ALUOut <= `SIGN_EXTEND({C, A[15:1]});
        // 32-bit operations
        // Directly assign A or B
        5'b10000: ALUOut <= A;
        5'b10001: ALUOut <= B;
        // not A or not B
        5'b10010: ALUOut <= ~A;
        5'b10011: ALUOut <= ~B;
        // A + B , A + B + carry, A - B
        5'b10100: ALUOut <= A + B;
        5'b10101: ALUOut <= A + B + C;
        5'b10110: ALUOut <= A + b_complement_32_bit;
        // A & B, A | B, A ^ B, ~(A & B)
        5'b10111: ALUOut <= A & B;
        5'b11000: ALUOut <= A | B;
        5'b11001: ALUOut <= A ^ B;
        5'b11010: ALUOut <= ~(A & B);
        // LSL A, LSR A, ASR A, CSL A, CSR A
        5'b11011: ALUOut <= A << 1;
        5'b11100: ALUOut <= A >> 1;
        5'b11101: ALUOut <= $signed(A) >>> 1; 
        5'b11110: ALUOut <= {A[30:0], C};
        5'b11111: ALUOut <= {C, A[31:1]};
        default: ALUOut <= 32'b0;
        endcase

        // Zero
        Z <= (ALUOut == 32'b0);// For both 16-bit and 32-bit operations

        // Carry
        if (FunSel[4] == 0) // For 16-bit operations
            begin
            if(FunSel[3:0] == 4'b0100 || FunSel[3:0] == 4'b0101) // A + B or A + B + Carry
            C <= (ALUOut[15:0] < A[15:0] || ALUOut[15:0] < B[15:0]);
            else if(FunSel[3:0] == 4'b0110) // A - B
            C <= (A[15:0] > B[15:0]);
            else if(FunSel[3:0] == 4'b1011 || FunSel[3:0] == 4'b1110) // LSL A or CSL A
            C <= (A[15] == 1);
            else if(FunSel[3:0] == 4'b1100 || FunSel[3:0] == 4'b1111) // LSR A or CSR A
            C <= (A[0] == 1);
            end
        else  // For 32-bit operations
            begin
            if(FunSel[3:0] == 4'b0100 || FunSel[3:0] == 4'b0101) // A + B or A + B + Carry
            C <= (ALUOut < A || ALUOut < B);
            else if(FunSel[3:0] == 4'b0110) // A - B
            C <= (A > B);
            else if(FunSel[3:0] == 4'b1011 || FunSel[3:0] == 4'b1110) // LSL A or CSL A
            C <= (A[31] == 1);
            else if(FunSel[3:0] == 4'b1100 || FunSel[3:0] == 4'b1111) // LSR A or CSR A
            C <= (A[0] == 1);
            end

        // Negative
        N <= (ALUOut[31] == 1);// For both 16-bit and 32-bit operations

        // Overflow
        if(FunSel == 5'b00100 || FunSel == 5'b00101 || FunSel == 5'b00110)
        begin
        O <= (A[15] & B[15] & ~ALUOut[15]) || (~A[15] & ~B[15] & ALUOut[15]);// For 16-bit operations
        end
        else if(FunSel == 5'b10100 || FunSel == 5'b10101 || FunSel == 5'b10110)
        begin
        O <= (A[31] & B[31] & ~ALUOut[31]) || (~A[31] & ~B[31] & ALUOut[31]);// For 32-bit operations
        end
        else 
        O <= 1'b0;

        // Update flags
        FlagsOut <= {Z, C, N, O};
    end

endmodule