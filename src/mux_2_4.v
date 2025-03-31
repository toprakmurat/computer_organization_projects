module mux_2_4 (clock, select, i0, i1, i2, i3, o);
    input wire clock;
    input wire [1:0] select;
    input wire [31:0] i0;
    input wire [15:0] i1;
    input wire [31:0] i2;
    input wire [7:0] i3;
    output reg [31:0] o;

    always @(posedge clock)
    begin
        case (select)
            2'b00: o <= i0;
            2'b01: o <= {{16{i1[15]}}, i1};
            2'b10: o <= i2;
            2'b11: o <= {{24{i3[7]}}, i3};
            default: o <= 32'b0;
        endcase
    end


endmodule