module alu(clock, input_a, input_b, cin, FunSel, ALUOut, flags);

    input wire clock;
    input wire [31:0] input_a;
    input wire [31:0] input_b;
    input wire [4:0] FunSel;
    input wire cin;

    output reg [31:0] ALUOut;
    output reg [3:0] flags; // Z|C|N|V

    wire [31:0] b_complement_32_bit;
    assign b_complement_32_bit = ~input_b + 1;

    wire [16:0] b_complement_16_bit;
    assign b_complement_16_bit = ~input_b[15:0] + 1;

    reg Z; // Zero
    reg C; // Carry
    reg N; // Negative
    reg O; // Overflow

    `define SIGN_EXTEND(value) {{16{value[15]}}, value} // 16 biti 32 bit yapıyor sign extension ile


    always @(posedge clock)
    begin
        Z <= 1'b0;
        C <= cin;
        N <= 1'b0;
        O <= 1'b0;

        case (FunSel)
        //16 bitlik kısım, A ve B nin son 16bitiyle işlem yapılıyor
        // A ya da B yi direkt eşitle
        5'b00000: ALUOut <= `SIGN_EXTEND(input_a[15:0]); 
        5'b00001: ALUOut <= `SIGN_EXTEND(input_b[15:0]);
        // not A ya da not B
        5'b00010: ALUOut <= `SIGN_EXTEND(~input_a[15:0]); 
        5'b00011: ALUOut <= `SIGN_EXTEND(~input_b[15:0]); 
        // A + B , A + B + carry, A - B
        5'b00100: ALUOut <= `SIGN_EXTEND(input_a[15:0] + input_b[15:0]);
        5'b00101: ALUOut <= `SIGN_EXTEND(input_a[15:0] + input_b[15:0] + C); 
        5'b00110: ALUOut <= `SIGN_EXTEND(input_a[15:0] + b_complement_16_bit); 
        // A & B, A | B, A ^ B, ~(A & B)
        5'b00111: ALUOut <= `SIGN_EXTEND(input_a[15:0] & input_b[15:0]);
        5'b01000: ALUOut <= `SIGN_EXTEND(input_a[15:0] | input_b[15:0]);
        5'b01001: ALUOut <= `SIGN_EXTEND(input_a[15:0] ^ input_b[15:0]);
        5'b01010: ALUOut <= `SIGN_EXTEND(~(input_a[15:0] & input_b[15:0])); 
        // LSL A, LSR A, ASR A, CSL A, CSR A
        5'b01011: ALUOut <= `SIGN_EXTEND(input_a[15:0] << 1);
        5'b01100: ALUOut <= `SIGN_EXTEND(input_a[15:0] >> 1);
        5'b01101: ALUOut <= `SIGN_EXTEND($signed(input_a[15:0]) >>> 1); 
        5'b01110: ALUOut <= `SIGN_EXTEND({input_a[14:0],C}); 
        5'b01111: ALUOut <= `SIGN_EXTEND({C, input_a[15:1]});
        // 32 bitlik kısım
        // A ya da B yi direkt eşitle
        5'b10000: ALUOut <= input_a;
        5'b10001: ALUOut <= input_b;
        // not A ya da not B
        5'b10010: ALUOut <= ~input_a;
        5'b10011: ALUOut <= ~input_b;
        // A + B , A + B + carry, A - B
        5'b10100: ALUOut <= input_a + input_b;
        5'b10101: ALUOut <= input_a + input_b + flags[2];
        5'b10110: ALUOut <= input_a + b_complement_32_bit;
        // A & B, A | B, A ^ B, ~(A & B)
        5'b10111: ALUOut <= input_a & input_b;
        5'b11000: ALUOut <= input_a | input_b;
        5'b11001: ALUOut <= input_a ^ input_b;
        5'b11010: ALUOut <= ~input_a & input_b;
        // LSL A, LSR A, ASR A, CSL A, CSR A
        5'b11011: ALUOut <= input_a << 1;
        5'b11100: ALUOut <= input_a >> 1;
        5'b11101: ALUOut <= $signed(input_a) >>> 1; 
        5'b11110: ALUOut <= {input_a[30:0], C};
        5'b11111: ALUOut <= {C, input_a[31:1]};
        default: ALUOut <= 32'b0;
        endcase

        // Zero
        if (FunSel[4] == 0)  
            Z <= (ALUOut[15:0] == 16'b0); // 16-bit işlemler için
        else  
            Z <= (ALUOut == 32'b0);// 32-bit işlemler için

        // Carry
        if (FunSel[4] == 0) // 16-bit işlemler için
            begin
            if(FunSel[3:0] == 4'b0100 || FunSel[3:0] == 4'b0101) // A + B veya A + B + Carry
            C <= (ALUOut[15:0] < input_a[15:0] || ALUOut[15:0] < input_b[15:0]);
            else if(FunSel[3:0] == 4'b0110) // A - B
            C <= (input_a[15:0] > input_b[15:0]);
            else if(FunSel[3:0] == 4'b1011 || FunSel[3:0] == 4'b1110) // LSL A veya CSL A
            C <= (input_a[15] == 1);
            else if(FunSel[3:0] == 4'b1100 || FunSel[3:0] == 4'b1111) // LSR A veya CSR A
            C <= (input_a[0] == 1);
            end
        else  // 32-bit işlemler için
            begin
            if(FunSel[3:0] == 4'b0100 || FunSel[3:0] == 4'b0101) // A + B veya A + B + Carry
            C <= (ALUOut < input_a || ALUOut < input_b);
            else if(FunSel[3:0] == 4'b0110) // A - B
            C <= (input_a > input_b);
            else if(FunSel[3:0] == 4'b1011 || FunSel[3:0] == 4'b1110) // LSL A veya CSL A
            C <= (input_a[31] == 1);
            else if(FunSel[3:0] == 4'b1100 || FunSel[3:0] == 4'b1111) // LSR A veya CSR A
            C <= (input_a[0] == 1);
            end
        // Negative
        if (FunSel[4] == 0)  
            N <= (ALUOut[15] == 1); // 16-bit işlemler için
        else  
            N <= (ALUOut[31] == 1);// 32-bit işlemler için

        // Overflow
        if(FunSel == 5'b00100 || FunSel == 5'b00101 || FunSel == 5'b00110)
        begin
        O <= (input_a[15] & input_b[15] & ~ALUOut[15]) || (~input_a[15] & ~input_b[15] & ALUOut[15]);// 16-bit işlemler için
        end
        else if(FunSel == 5'b10100 || FunSel == 5'b10101 || FunSel == 5'b10110)
        begin
        O <= (input_a[31] & input_b[31] & ~ALUOut[31]) || (~input_a[31] & ~input_b[31] & ALUOut[31]);// 32-bit işlemler için
        end
        else 
        O <= 1'b0;


        //update
        flags <= {Z, C, N, O};
    end


endmodule