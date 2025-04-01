module InstructionRegister(I, Write, LH, Clock, IROut);
    input wire Clock;
    input wire [7:0] I;
    input wire LH;
    input wire Write;

    output reg [15:0] IROut;

    always @(posedge Clock)
    begin
        if(!Write)
            IROut <= IROut;
        else if(!LH)
            IROut <= {I, IROut[7:0]};
        else
            IROut <= {IROut[15:8], I};
    end
endmodule
