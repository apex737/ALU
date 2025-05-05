module LOD10(
	input [9:0] frac,
	output [3:0] idx_o
);
wire [3:0] p2 = frac[9:6];
wire [3:0] p1 = frac[5:2];
wire [3:0] p0 = {frac[1:0],2'b00};
wire [2:0] g = {|p2, |p1, |p0}; // 몇번째 블럭?
wire valid = |g;
reg [1:0] pos;
always@* begin
	casex(g)
		3'b1xx: pos = 2;
		3'b01x: pos = 1;
		3'b001: pos = 0;
		default: pos = 0; // Invalid 
	endcase
end

reg [1:0] idx; // 블럭의 어느위치?
wire [3:0] p = (pos == 2) ? p2 : (pos == 1) ? p1 : p0; // Leading-1 block
always@* begin
	casex(p)
		4'b1xxx: idx = 3;
		4'b01xx: idx = 2;
		4'b001x: idx = 1;
		4'b0001: idx = 0;
		default: idx = 0;
	endcase
end

assign idx_o = valid ? (4*pos + idx) : 0;
endmodule
