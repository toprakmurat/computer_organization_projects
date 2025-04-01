module DataRegister(I, OutCSel, OutDSel, FunSel, RegSel, Clock, OutC, OutD);

    input wire Clock;
    input wire [7:0] I;
    input wire [1:0] FunSel;
    input wire RegSel;
    input wire OutCSel;
    input wire OutDSel;

    output reg [31:0] OutC;
    output reg [31:0] OutD;

    always @(posedge Clock)
    begin
        if(RegSel)
        begin
            case (FunSel)
                2'b00: begin
                    OutC[31:8] <= {24{I[7]}};
                    OutC[7:0] <= I[7:0];
                end
                2'b01: begin
                    OutC[31:8] <= 24'b0;
                    OutC[7:0] <= I[7:0];
                end
                2'b10: begin
                    OutC[31:8] <= OutC[23:0];
                    OutC[7:0] <= I[7:0];
                end
                2'b11: begin
                    OutC[23:0] <= OutC[31:8];
                    OutC[31:24] <= I[7:0];
                end
                default: OutC <= 32'b0;
            endcase
        end
    end

endmodule