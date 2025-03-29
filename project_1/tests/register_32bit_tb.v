`timescale 1ns / 1ps

module register_32bit_tb;
    reg clk;
    reg E;
    reg [2:0] FunSel;
    reg [31:0] In;
    wire [31:0] Out;
    
    // Instantiate the register_32bit module
    register_32bit uut (
        .clock(clk),
        .E(E),
        .FunSel(FunSel),
        .In(In),
        .Out(Out)
    );
    
    // Clock generation
    always begin
        #5 clk = ~clk;  // Clock period of 10 units
    end
    
    initial begin
        // Initialize signals
        clk = 0;
        E = 0;
        FunSel = 3'b000;
        In = 32'hA5A5A5A5;
        
        // Test 1: Apply reset (E = 0) and check retention of value
        #10 E = 1; // Enable the register
        FunSel = 3'b010;  // Load In into Out
        #10;
        
        // Test 2: Increment Out (FunSel = 3'b001)
        FunSel = 3'b001;
        #10;
        
        // Test 3: Decrement Out (FunSel = 3'b000)
        FunSel = 3'b000;
        #10;
        
        // Test 4: Clear Out (FunSel = 3'b011)
        FunSel = 3'b011;
        #10;
        
        // Test 5: Lower 8 bits of In to Out (FunSel = 3'b100)
        In = 32'hF0F0F0F0;
        FunSel = 3'b100;
        #10;
        
        // Test 6: Lower 16 bits of In to Out (FunSel = 3'b101)
        FunSel = 3'b101;
        #10;
        
        // Test 7: Shift Out and insert lower 8 bits of In (FunSel = 3'b110)
        FunSel = 3'b110;
        #10;
        
        // Test 8: Sign extend lower 16 bits of In (FunSel = 3'b111)
        In = 32'hFF0000FF;
        FunSel = 3'b111;
        #10;
        
        // Test 9: Test invalid FunSel (default case)
        FunSel = 3'bxxx;  // Invalid FunSel (should retain value of Out)
        #10;
        
        $finish;  // End simulation
    end
    
    initial begin
        $monitor("Time = %0t, FunSel = %b, In = %h, Out = %h", $time, FunSel, In, Out);
    end
endmodule
