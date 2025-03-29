module 32_bit_register(clock, enable, funSel, I, o);
	//inputs
	input wire clock;
	input wire enable;
	input wire [2:0] funSel;
	input wire [31:0] i;
	//outputs, alwaysin içinde sadece reg güncellenebiliyormuş
	reg [31:0] o;

    always @(posedge clock)
    begin

        if(enable)
        begin
            case(funSel)
            //Decrement
            3'b000: begin
            o <= o - 1;
            end
            //Increment
            3'b001: begin
            o <= o + 1;
            end
            //Load
            3'b010: begin
            o <= i;
            end
            //Clear
            3'b011: begin
            o <= 32'b0;
            end
            // son 8 biti inputun son 8 bitiyle değiştir, kalanları sıfırla
            3'b100: begin
            o[31:8] <= 24'b0;
            o[7:0] <= i[7:0];
            end
            // son 16 biti inputun son 16 bitiyle değiştir, kalanları sıfırla
            3'b101: begin
            o[31:16] <= 16'b0;
            o[15:0] <= i[15:0];
            end
            3'b110: begin
            o[31:8] <= o[23:0]; // 8-bit left shift
            o[7:0] <= i[7:0]; 
            end
            3'b111: begin
            o[31:16] <= { {16{i[15]}} }; // sign extend bu şekilde yapılıyor!!!
            o[15:0] <= i[15:0];
            end

            endcase
        end
        
    end



endmodule