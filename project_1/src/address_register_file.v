`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2025 12:38:37 PM
// Design Name: 
// Module Name: address_register_file
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module address_register_file(
	input wire clock,
	input wire [2:0] RegSel,
	input wire [1:0] FunSel,
	input wire [1:0] OutCSel,
	input wire [1:0] OutDSel,
	input wire [31:0] In,
	output reg [15:0] OutC,
	output reg [15:0] OutD
);
	reg [15:0] PC, SP, AR;
	
	register_16bit reg_AR (
		.clock(clock),
		.E(RegSel[0]),
		.FunSel(FunSel),
		.In(In),
		.Out(AR)
	);

	register_16bit reg_SP (
		.clock(clock),
		.E(RegSel[1]),
		.FunSel(FunSel),
		.In(In),
		.Out(SP)
	);
	
	register_16bit reg_PC (
		.clock(clock),
		.E(RegSel[2]),
		.FunSel(FunSel),
		.In(In),
		.Out(PC)
	);
	
	always @(posedge clock)
	begin
		case(OutCSel)
			2'b00:	OutC <= PC;
			2'b01:	OutC <= SP;
			2'b10:	OutC <= AR;
			2'b11:	OutC <= AR;
			
			default: OutC <= OutC;
		endcase
		
		case(OutDSel)
			2'b00:	OutD <= PC;
			2'b01:	OutD <= SP;
			2'b10:	OutD <= AR;
			2'b11:	OutD <= AR;
			
			default: OutD <= OutD;
		endcase
	end
endmodule
