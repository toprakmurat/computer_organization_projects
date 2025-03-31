module instruction_register(clock, i, o, LH, write);
    input wire clock;
    input wire [7:0] i;
    input wire LH;
    input wire write;

    output reg [15:0] o;

    always @(posedge clock)
    begin
        if(!write)
            o <= o;
        else if(!LH)
            o <= {i, o[7:0]};
        else
            o <= {o[15:8], i};
    end
endmodule
