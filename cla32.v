 module cla32(a, b, ci, s, co); // 32-bit cla
	input [31:0] a, b;
	input ci;
	output [31:0] s;
	output co;
	
	wire [6:0] c;
	
	cla4 cla40(.a(a[3:0]), .b(b[3:0]), .ci(ci), .s(s[3:0]), .co(c[0]));
	cla4 cla41(.a(a[7:4]), .b(b[7:4]), .ci(c[0]), .s(s[7:4]), .co(c[1]));
	cla4 cla42(.a(a[11:8]), .b(b[11:8]), .ci(c[1]), .s(s[11:8]), .co(c[2]));
	cla4 cla43(.a(a[15:12]), .b(b[15:12]), .ci(c[2]), .s(s[15:12]), .co(c[3]));
	cla4 cla44(.a(a[19:16]), .b(b[19:16]), .ci(c[3]), .s(s[19:16]), .co(c[4]));
	cla4 cla45(.a(a[23:20]), .b(b[23:20]), .ci(c[4]), .s(s[23:20]), .co(c[5]));
	cla4 cla46(.a(a[27:24]), .b(b[27:24]), .ci(c[5]), .s(s[27:24]), .co(c[6]));
	cla4 cla47(.a(a[31:28]), .b(b[31:28]), .ci(c[6]), .s(s[31:28]), .co(co));
endmodule
