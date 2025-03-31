module flag_register(clock, flag_reg, carry);
    input wire clock;

    wire Z;  
    wire C;  
    wire N;  
    wire O;  

    output reg [3:0] flag_reg;  

    assign Z = flag_reg[3];
    assign C = flag_reg[2];
    assign N = flag_reg[1];
    assign O = flag_reg[0];

    output reg carry; 

    always @(posedge clock) begin
        carry <= C;
    end

 

endmodule
