module mx2_64bits(d0, d1, s, y);
	input [63:0] d0, d1;
	input s;
	output [63:0] y;
	
	assign y = (s != 1'b1) ? d0 : d1; // made mux using conditional operator
endmodule
