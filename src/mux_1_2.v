module mux_1_2 (clock, select, i0, i1, o);
    input wire clock;
    input wire select;
    input wire [31:0] i0;
    input wire [15:0] i1;
    output reg [31:0] o;

    always @(posedge clock)
    begin
        if(select)
            o <= i1;
        else
            o <= i0;
    end