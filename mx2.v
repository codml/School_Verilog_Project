module mx2(y, d0, d1, s); // 2-to-1 MUX module
	input d0, d1, s;
	output y;
	
	assign y = (s != 1'b1) ? d0 : d1; // made mux using conditional operator
	
endmodule
