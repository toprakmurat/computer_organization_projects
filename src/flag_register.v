module flag_register(clock, Z, C, N, O, flag_reg, carry);
    input wire clock;
    input wire Z;  
    input wire C;  
    input wire N;  
    input wire O;  

    output reg [3:0] flag_reg;  

    output reg carry; 

    always @(posedge clock) begin
        flag_reg <= {Z, C, N, O}; 
        carry <= flag_reg[2];
    end

 

endmodule
