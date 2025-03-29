module test_32_bit_register;

    reg clock;
    reg enable;
    reg [2:0] funSel;
    reg [31:0] i;
    wire [31:0] o;
    
    32_bit_register uut (
        .clock(clock),
        .enable(enable),
        .funSel(funSel),
        .i(i),
        .o(o)
    );
    
    always begin
        #10 clock = ~clock;
    end
    
    initial begin
        clock = 0;
        enable = 0;
        funSel = 3'b000;  
        i = 32'b10101010101010101010101010101010;

        // Test 1: Enable 0, çıkışın değişmemesi gerektiğini kontrol et
        $display("Test 1: Enable 0, çıkış değişmemeli");
        #20;
        $display("Output (Test 1): %b", o);
        
        // Test 2: Decrement
        $display("Test 2: Decrement işlemi");
        enable = 1;
        funSel = 3'b000;  
        #20;
        $display("Output (Test 2): %b", o);
        
        // Test 3: Increment
        $display("Test 3: Increment işlemi");
        funSel = 3'b001;  
        #20;
        $display("Output (Test 3): %b", o); 
        
        // Test 4: Load
        $display("Test 4: Load işlemi");
        i = 32'b00010010001101000000000000000000;    
        funSel = 3'b010;  
        #20;
        $display("Output (Test 4): %b", o);
        
        // Test 5: Clear
        $display("Test 5: Clear işlemi");
        funSel = 3'b011;  
        #20;
        $display("Output (Test 5): %b", o);
        
        // Test 6: Son 8 biti değiştir
        $display("Test 6: Son 8 biti değiştir");
        i = 32'b00000000000000000000000011110000;  
        funSel = 3'b100;  
        #20;
        $display("Output (Test 6): %b", o);
        
        // Test 7: Son 16 biti değiştir
        $display("Test 7: Son 16 biti değiştir");
        i = 32'b00000000000000000000000000001111;  
        funSel = 3'b101;  
        #20;
        $display("Output (Test 7): %b", o);
        
        // Test 8: 8-bit left shift
        $display("Test 8: 8-bit left shift");
        i = 32'b11111111000000001111111111111111;  
        funSel = 3'b110;  
        #20;
        $display("Output (Test 8): %b", o);
        
        // Test 9: Sign extend
        $display("Test 9: Sign extend");
        i = 32'b10000000000000000000000000001111;  
        funSel = 3'b111;  
        #20;
        $display("Output (Test 9): %b", o);

        $finish;
    end
    
endmodule
