module 16_bit_register(clock, enable, funSel, I, o);
	//inputs
	input wire clock; // clocku kafamıza göre mi belirliyoruz  posedge ya da negedge olduğunu bilmiyorum???
	input wire enable;
	input wire [1:0] funSel;
	input wire [15:0] i;
	//outputs, alwaysin içinde sadece reg güncellenebiliyormuş
	reg [15:0] o;
	
	always @(posedge clock)
	begin

        if(enable)
	    begin
		case(funSel)
		    //Decrement
		    2'b00: o <= o - 1;
            //Increment
            2'b01: o <= o + 1;
            //Load
            2'b10: o <= i;
            //Clear
            2'b11: o <= 16'b0;
            default: o <= 16'b0;
        endcase
	    end
	
	end

endmodule