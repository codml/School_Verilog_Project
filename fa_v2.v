module fa_v2(a, b, ci, s);
	input a, b, ci;
	output s;
	
	_xor2 xr20(.a(a), .b(b), .y(w0));
	_xor2 xr21(.a(w0), .b(ci), .y(s)); // no cout
endmodule
