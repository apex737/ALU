module FPADD(
	input [15:0] opA_i, opB_i, 
	output reg [15:0] ADD_o
);

// Decode
wire aSign = opA_i[15];
wire bSign = opB_i[15];
wire [4:0] aE = opA_i[14:10];
wire [4:0] bE = opB_i[14:10];
wire [9:0] aF = opA_i[9:0];
wire [9:0] bF = opB_i[9:0];
reg Sign, isDiff;

// Sign 결정 
always@* begin
	if(aSign == bSign) begin // 부호 같은 경우 : 부호 유지 
		Sign = aSign; 
		isDiff = 1'b0; 
	end
	else begin // 부호 다른 경우 : exp/frac이 더 큰 것을 따라감 
		isDiff = 1'b1;	 
		if(aE == bE) Sign = (aF > bF) ? aSign : bSign; 
		else Sign = (aE > bE) ? aSign : bSign; 
	end
end

// Exp, Frac 결정
reg signed [5:0] rs_bigExp, rs_smallExp;
reg [11:0] r_bigF, r_smallF;
wire [5:0] shamt = rs_bigExp - rs_smallExp;

always@* begin
	if(aE == 0 && bE == 0) begin  // DN+DN
		rs_bigExp = -5'sd14; rs_smallExp = rs_bigExp;
		r_bigF = {2'b00, aF}; r_smallF = {2'b00, bF};
	end 
	else if (aE != 0 && bE == 0) begin // N+DN
		rs_bigExp = $signed(aE) - 5'sd15; rs_smallExp = -5'sd14; 
		r_bigF = {2'b01, aF}; r_smallF = {2'b00, bF};
	end
	else if (aE == 0 && bE != 0) begin // DN+N
		rs_bigExp = $signed(bE) - 5'sd15; rs_smallExp = -5'sd14; 
		r_bigF = {2'b01, bF}; r_smallF = {2'b00, aF};
	end
	else begin // N+N
		rs_bigExp = (aE >= bE) ? $signed(aE) - 5'sd15 : $signed(bE) - 5'sd15;
		rs_smallExp = (aE <= bE) ? $signed(aE) - 5'sd15 : $signed(bE) - 5'sd15;
		r_bigF = (aF >= bF) ? {2'b01, aF} : {2'b01, bF};
		r_smallF = (aF <= bF) ? {2'b01, aF} : {2'b01, bF};
	end
end

// Instanciation : Leading-One-Detection 
wire [11:0] F_add = r_bigF + (r_smallF >> shamt);
wire [11:0] F_sub = r_bigF - (r_smallF >> shamt);
wire [3:0] idxAdd, idxSub; // 11 ~ 2 , 0 (invalid)
wire [3:0] sh_Add = 4'd12-idxAdd; // 1 ~ 10
wire [3:0] sh_Sub = 4'd12-idxSub; // 1 ~ 10
LOD10 lodA (.frac(F_add[9:0]), .idx_o(idxAdd));
LOD10 lodB (.frac(F_sub[9:0]), .idx_o(idxSub));

// 정규화 
reg signed [6:0] rs_Exp;
reg [11:0] r_F;
always@* begin
	if(~isDiff) begin // 부호 같음 (덧셈)
		if(F_add[11]) begin // M >= 2
			r_F = F_add << 1;
			rs_Exp = rs_bigExp + 1;
		end
		else if(F_add[11:10] == 2'b00) begin // M < 1
			rs_Exp = rs_bigExp - sh_Add;
			r_F = F_add << sh_Add;
		end
		else begin 
			rs_Exp = rs_bigExp;
			r_F = F_add;
		end
	end
	else begin // 부호 다름 (unsigned 뺄셈) 
		if(F_sub[11]) begin // M >= 2
			r_F = F_sub << 1;
			rs_Exp = rs_bigExp + 1;
		end
		else if(F_sub[11:10] == 2'b00) begin // M < 1
			rs_Exp = rs_bigExp - sh_Sub;
			r_F = F_sub << sh_Sub;
		end
		else begin 
			rs_Exp = rs_bigExp;
			r_F = F_sub;
		end
	end
end

// Output Encoding
reg [4:0] DNshamt;
reg [11:0] shifted;
reg [9:0] FTarget;
always@* begin
	if(Exp > 7'sd15) ADD_o = {16{1'b1}}; // ovf
	else if(Exp < -7'sd24) ADD_o = 0; // udf 또는 0 
	else if(Exp <= 7'sd15 && Exp >= -7'sd14) begin // encode: Norm
		ADD_o = {Sign, Exp + 7'sd15, F[9:0]};
	end
	else begin // encode: Denorm (-24 <= exp < -14)
		DNshamt = -(Exp+7'sd14);
		shifted = F >> DNshamt;
		FTarget = shifted[9:0];
		ADD_o = {Sign, 5'b0, FTarget};
	end
end
endmodule