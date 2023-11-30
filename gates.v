module _inv(a, y); // NOT gate
	input a;
	output y;
	
	assign y = ~a;
endmodule

module _nand2(a, b, y); // NAND gate(2 input)
	input a, b;
	output y;
	
	assign y = ~(a&b);
endmodule

module _and2(a, b, y); // AND gate(2 input)
	input a, b;
	output y;
	
	assign y = a&b;
endmodule

module _or2(a, b, y); // OR gate(2 input)
	input a, b;
	output y;
	
	assign y = a|b;
endmodule

module _xor2(a, b, y); // XOR gate(2 input)
	input a, b; // y = a * ~b + ~a * b
	output y; // use NOT, AND, OR gate
	
	_inv iv0(.a(a), .y(na));
	_inv iv1(.a(b), .y(nb)); // use two instances of NOT gate
	_and2 nd20(.a(a), .b(nb), .y(w0));
	_and2 nd21(.a(na), .b(b), .y(w1)); // use two instances of AND gate
	_or2 nd22(.a(w0), .b(w1), .y(y)); // use a instance of OR gate
endmodule

module _and3(a, b, c, y);
	input a, b, c;
	output y;
	
	assign y = a & b & c;
endmodule

module _and4(a, b, c, d, y);
	input a, b, c, d;
	output y;
	
	assign y = a & b & c & d;
endmodule

module _and5(a, b, c, d, e, y);
	input a, b, c, d, e;
	output y;
	
	assign y = a & b & c & d & e;
endmodule

module _or3(a, b, c, y);
	input a, b, c;
	output y;
	
	assign y = a | b | c;
endmodule

module _or4(a, b, c, d, y);
	input a, b, c, d;
	output y;
	
	assign y = a | b | c | d;
endmodule

module _or5(a, b, c, d, e, y);
	input a, b, c, d, e;
	output y;
	
	assign y = a | b | c | d | e;
endmodule
