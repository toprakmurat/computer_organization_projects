module data_register(clock, enable, Funsel, i, o);

    input wire clock;
    input wire enable;
    input wire [1:0] Funsel;
    input wire [7:0] i;

    output reg [31:0] o;

    always @(posedge clock)
    begin
        if(enable)
        begin
            case (Funsel)
                2'b00: begin
                    o[31:8] <= {24{i[7]}};
                    o[7:0] <= i[7:0];
                end
                2'b01: begin
                    o[31:8] <= 24'b0;
                    o[7:0] <= i[7:0];
                end
                2'b10: begin
                    o[31:8] <= o[23:0];
                    o[7:0] <= i[7:0];
                end
                2'b11: begin
                    o[23:0] <= o[31:8];
                    o[31:24] <= i[7:0];
                end
                default: o <= 32'b0;
            endcase
        end
    end

endmodule