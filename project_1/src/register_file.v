`timescale 1ns / 1ps

module register_file(
	input wire clock, 
	input wire [3:0] RegSel, 
	input wire [3:0] ScrSel,
	input wire [2:0] FunSel,
	input wire [2:0] OutASel, 
	input wire [2:0] OutBSel, 
	input wire [31:0] In, 
	output reg [31:0] OutA, 
	output reg [31:0] OutB
);
	reg [31:0] R1, R2, R3, R4, S1, S2, S3, S4;
	
	register_32bit reg_R1 (
		.clock(clock),
		.E(RegSel[3]),
		.FunSel(FunSel),
		.In(In),
		.Out(R1)
	);
	
	register_32bit reg_R2 (
		.clock(clock),
		.E(RegSel[2]),
		.FunSel(FunSel),
		.In(In),
		.Out(R2)
	);
	
	register_32bit reg_R3 (
		.clock(clock),
		.E(RegSel[1]),
		.FunSel(FunSel),
		.In(In),
		.Out(R3)
	);
	
	register_32bit reg_R4 (
		.clock(clock),
		.E(RegSel[0]),
		.FunSel(FunSel),
		.In(In),
		.Out(R4)
	);
	
	register_32bit reg_S1 (
		.clock(clock),
		.E(ScrSel[3]),
		.FunSel(FunSel),
		.In(In),
		.Out(S1)
	);
	
	register_32bit reg_S2 (
		.clock(clock),
		.E(ScrSel[2]),
		.FunSel(FunSel),
		.In(In),
		.Out(S2)
	);
	
	register_32bit reg_S3 (
		.clock(clock),
		.E(ScrSel[1]),
		.FunSel(FunSel),
		.In(In),
		.Out(S3)
	);
	
	register_32bit reg_S4 (
		.clock(clock),
		.E(ScrSel[0]),
		.FunSel(FunSel),
		.In(In),
		.Out(S4)
	);
	
	always @(posedge clock)
	begin
        case (OutASel)
            3'b000: OutA <= R1;
            3'b001: OutA <= R2;
            3'b010: OutA <= R3;
            3'b011: OutA <= R4;
            3'b100: OutA <= S1;
            3'b101: OutA <= S2;
            3'b110: OutA <= S3;
            3'b111: OutA <= S4;
            default: OutA <= 32'b0;
        endcase

        case (OutBSel)
            3'b000: OutB <= R1;
            3'b001: OutB <= R2;
            3'b010: OutB <= R3;
            3'b011: OutB <= R4;
            3'b100: OutB <= S1;
            3'b101: OutB <= S2;
            3'b110: OutB <= S3;
            3'b111: OutB <= S4;
            default: OutB <= 32'b0;
        endcase	
	end
	
endmodule
