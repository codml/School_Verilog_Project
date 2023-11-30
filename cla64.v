module cla64(a, b, ci, s, co); // 64-bit cla
	input [63:0] a, b;
	input ci;
	output [63:0] s;
	output co;
	
	cla32 U0_cla32(.a(a[31:0]), .b(b[31:0]), .ci(ci), .s(s[31:0]), .co(c));
	cla32 U1_cla32(.a(a[63:32]), .b(b[63:32]), .ci(c), .s(s[63:32]), .co(co)); // 2 32-bit cla instance
endmodule
