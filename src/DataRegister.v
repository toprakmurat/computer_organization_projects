module DataRegister(I, E, FunSel, Clock, DROut);

    input wire Clock;
    input wire [7:0] I;
    input wire [1:0] FunSel;
    input wire E;

    output reg [31:0] DROut;

    always @(posedge Clock)
    begin
        if(E)
        begin
            case (FunSel)
                2'b00: begin
                    DROut[31:8] <= {24{I[7]}};
                    DROut[7:0] <= I[7:0];
                end
                2'b01: begin
                    DROut[31:8] <= 24'b0;
                    DROut[7:0] <= I[7:0];
                end
                2'b10: begin
                    DROut[31:8] <= DROut[23:0];
                    DROut[7:0] <= I[7:0];
                end
                2'b11: begin
                    DROut[23:0] <= DROut[31:8];
                    DROut[31:24] <= I[7:0];
                end
                default: DROut <= 32'b0;
            endcase
        end
    end

endmodule