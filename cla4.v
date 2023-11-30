module cla4(a, b, ci, s, co); //4-bit cla
	input [3:0] a, b;
	input ci;
	output [3:0] s;
	output co;
	
	wire [3:0] c;
	
	
	fa_v2 U0_fa_v2(.a(a[0]), .b(b[0]), .s(s[0]), .ci(ci));
	fa_v2 U1_fa_v2(.a(a[1]), .b(b[1]), .s(s[1]), .ci(c[1]));
	fa_v2 U2_fa_v2(.a(a[2]), .b(b[2]), .s(s[2]), .ci(c[2]));
	fa_v2 U3_fa_v2(.a(a[3]), .b(b[3]), .s(s[3]), .ci(c[3]));
	clb4 U4_clb4(.a(a), .b(b), .ci(ci), .c1(c[1]), .c2(c[2]), .c3(c[3]), .co(co));
endmodule
