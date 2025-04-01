module Register32bit(I, E, FunSel, Clock, Q);
	//Inputs
	Input wire Clock;
	Input wire E;
	Input wire [2:0] FunSel;
	Input wire [31:0] I;
	//Qutputs, alwaysin içinde sadece reg güncellenebiliyormuş
	reg [31:0] Q;

    always @(posedge Clock)
    begin

        If(E)
        begin
            case(FunSel)
            //Decrement
            3'b000: begin
            Q <= Q - 1;
            end
            //Increment
            3'b001: begin
            Q <= Q + 1;
            end
            //Load
            3'b010: begin
            Q <= I;
            end
            //Clear
            3'b011: begin
            Q <= 32'b0;
            end
            // son 8 biti Inputun son 8 bitiyle değiştir, kalanları sıfırla
            3'b100: begin
            Q[31:8] <= 24'b0;
            Q[7:0] <= I[7:0];
            end
            // son 16 biti Inputun son 16 bitiyle değiştir, kalanları sıfırla
            3'b101: begin
            Q[31:16] <= 16'b0;
            Q[15:0] <= I[15:0];
            end
            3'b110: begin
            Q[31:8] <= Q[23:0]; // 8-bit left shift
            Q[7:0] <= I[7:0]; 
            end
            3'b111: begin
            Q[31:16] <= { {16{I[15]}} }; // sign extend bu şekilde yapılıyor!!!
            Q[15:0] <= I[15:0];
            end

            endcase
        end
        
    end



endmodule