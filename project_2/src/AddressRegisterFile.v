`timescale 1ns / 1ps

/*
    Module Authors: Murat Toprak & Vedat Enis Gül

    Implementation of the Address Register File
*/

module AddressRegisterFile (
	input wire [31:0]  I,
	input wire [1:0]   OutCSel,
	input wire [1:0]   OutDSel,
	input wire [1:0]   FunSel,
	input wire [2:0]   RegSel,
	input wire         Clock,
	output reg [15:0]  OutC,
	output reg [15:0]  OutD
);
	wire [15:0] reg_PC, reg_SP, reg_AR;

	Register16bit AR (
		.I(I[15:0]),
		.E(RegSel[0]),
		.FunSel(FunSel),
		.Clock(Clock),
		.Q(reg_AR)
	);

	Register16bit SP (
		.I(I[15:0]),
		.E(RegSel[1]),
		.FunSel(FunSel),
		.Clock(Clock),
		.Q(reg_SP)
	);

	Register16bit PC (
		.I(I[15:0]),
		.E(RegSel[2]),
		.FunSel(FunSel),
		.Clock(Clock),
		.Q(reg_PC)
	);

	always @(*)
	begin
		case(OutCSel)
			2'b00:       OutC = reg_PC;
			2'b01:       OutC = reg_SP;
			2'b10:       OutC = reg_AR;
			2'b11:       OutC = reg_AR;

			default:     OutC = OutC;
		endcase

		case(OutDSel)
			2'b00:       OutD = reg_PC;
			2'b01:       OutD = reg_SP;
			2'b10:       OutD = reg_AR;
			2'b11:       OutD = reg_AR;

			default:     OutD = OutD;
		endcase
	end
endmodule
