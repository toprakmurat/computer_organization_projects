module test_16_bit_register;

    reg clock;
    reg enable;
    reg [1:0] funSel;
    reg [15:0] i;
    wire [15:0] o;
    
    16_bit_register uut (
        .clock(clock),
        .enable(enable),
        .funSel(funSel),
        .i(i),
        .o(o)
    );
    
    // Clock üretimi (her 10 birimlik zaman diliminde değişir)
    always begin
        #10 clock = ~clock;  // 10 birimlik periyot ile saat oluştur
    end
    

    initial begin
        // Başlangıç değerlerini ayarla
        clock = 0;
        enable = 0;
        funSel = 2'b00;  // Decrement
        i = 16'b000000000000010;   // Test için rastgele bir değer 

        // Test 1: Enable 0, çıkışın değişmemesi gerektiğini kontrol et
        $display("Test 1: Enable 0, çıkış değişmemeli");
        #20;
        $display("Output (Test 1): %b", o);
        
        // Test 2: Decrement 
        $display("Test 2: Decrement işlemi");
        enable = 1;
        funSel = 2'b00;  // Decrement
        #20;
        $display("Output (Test 2): %b", o);
        
        // Test 3: Increment 
        $display("Test 3: Increment işlemi");
        funSel = 2'b01;  // Increment
        #20;
        $display("Output (Test 3): %b", o);
        
        // Test 4: Load 
        $display("Test 4: Load işlemi");
        i = 16'b0001001000110100;    
        funSel = 2'b10;  // Load
        #20;
        $display("Output (Test 4): %b", o);
        
        // Test 5: Clear 
        $display("Test 5: Clear işlemi");
        funSel = 2'b11;  // Clear
        #20;
        $display("Output (Test 5): %b", o);
        
        // Simülasyonu sonlandır
        #50;
        $finish;
    end
    
endmodule
