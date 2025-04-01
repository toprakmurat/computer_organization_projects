module Register16bit(I, E, FunSel, Clock, Q);
	
	//inputs
	input wire clock; // clocku kafamıza göre mi belirliyoruz  posedge ya da negedge olduğunu bilmiyorum???
	input wire E;
	input wire [1:0] FunSel;
	input wire [15:0] I;
	//outputs, alwaysin içinde sadece reg güncellenebiliyormuş
	reg [15:0] Q;
	
	always @(posedge clock)
	begin

        if(E)
	    begin
		case(FunSel)
		    //Decrement
		    2'b00: Q <= Q - 1;
            //Increment
            2'b01: Q <= Q + 1;
            //Load
            2'b10: Q <= I;
            //Clear
            2'b11: Q <= 16'b0;
            default: Q <= 16'b0;
        endcase
	    end
	
	end

endmodule