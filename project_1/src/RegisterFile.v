`timescale 1ns / 1ps

/*
    Module Authors: Murat Toprak & Vedat Enis Gül
    Implementation of the Register File
    
    Maximum line length is 49 characters
*/

module RegisterFile (
	input wire [31:0]  I, 
	input wire [2:0]   OutASel, 
	input wire [2:0]   OutBSel, 
	input wire [2:0]   FunSel,
	input wire [3:0]   RegSel, 
	input wire [3:0]   ScrSel,
	input wire         Clock, 
	output reg [31:0]  OutA, 
	output reg [31:0]  OutB
);
	wire [31:0] reg_R1, reg_R2, reg_R3, reg_R4;
	wire [31:0] reg_S1, reg_S2, reg_S3, reg_S4;
	
	Register32bit R1 (
		.I(I),
		.E(RegSel[3]),
		.FunSel(FunSel),
		.Clock(Clock),
		.Q(reg_R1)
	);
	
	Register32bit R2 (
		.I(I),
		.E(RegSel[2]),
		.FunSel(FunSel),
		.Clock(Clock),
		.Q(reg_R2)
	);
	
	Register32bit R3 (
		.I(I),
		.E(RegSel[1]),
		.FunSel(FunSel),
		.Clock(Clock),
		.Q(reg_R3)
	);
	
	Register32bit R4 (
		.I(I),
		.E(RegSel[0]),
		.FunSel(FunSel),
		.Clock(Clock),
		.Q(reg_R4)
	);
	
	Register32bit S1 (
		.I(I),
		.E(ScrSel[3]),
		.FunSel(FunSel),
		.Clock(Clock),
		.Q(reg_S1)
	);
	
	Register32bit S2 (
		.I(I),
		.E(ScrSel[2]),
		.FunSel(FunSel),
		.Clock(Clock),
		.Q(reg_S2)
	);
	
	Register32bit S3 (
		.I(I),
		.E(ScrSel[1]),
		.FunSel(FunSel),
		.Clock(Clock),
		.Q(reg_S3)
	);
	
	Register32bit S4 (
		.I(I),
		.E(ScrSel[0]),
		.FunSel(FunSel),
		.Clock(Clock),
		.Q(reg_S4)
	);
	
	always @(*)
	begin
        case (OutASel)
            3'b000:     OutA = reg_R1;
            3'b001:     OutA = reg_R2;
            3'b010:     OutA = reg_R3;
            3'b011:     OutA = reg_R4;
            3'b100:     OutA = reg_S1;
            3'b101:     OutA = reg_S2;
            3'b110:     OutA = reg_S3;
            3'b111:     OutA = reg_S4;
            default:    OutA = 32'b0;
        endcase

        case (OutBSel)
            3'b000:     OutB = reg_R1;
            3'b001:     OutB = reg_R2;
            3'b010:     OutB = reg_R3;
            3'b011:     OutB = reg_R4;
            3'b100:     OutB = reg_S1;
            3'b101:     OutB = reg_S2;
            3'b110:     OutB = reg_S3;
            3'b111:     OutB = reg_S4;
            default:    OutB = 32'b0;
        endcase	
	end
	
endmodule