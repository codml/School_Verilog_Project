module clb4(a, b, ci, c1, c2, c3, co);
	input [3:0] a, b;
	input ci;
	output c1, c2, c3, co; // reason for c1 ~ c3 : ppt 12 page
	wire [3:0] g, p;
	wire [5:0] pg;
	
	_and2 ad20(.a(a[0]), .b(b[0]), .y(g[0]));
	_and2 ad21(.a(a[1]), .b(b[1]), .y(g[1]));
	_and2 ad22(.a(a[2]), .b(b[2]), .y(g[2]));
	_and2 ad23(.a(a[3]), .b(b[3]), .y(g[3])); // make generation
	_or2 or20(.a(a[0]), .b(b[0]), .y(p[0]));
	_or2 or21(.a(a[1]), .b(b[1]), .y(p[1]));
	_or2 or22(.a(a[2]), .b(b[2]), .y(p[2]));
	_or2 or23(.a(a[3]), .b(b[3]), .y(p[3])); // make propagation
	_and2 ad24(.a(g[0]), .b(p[1]), .y(pg[0]));
	_or2 or24(.a(pg[0]), .b(g[1]), .y(pg[1]));
	_and2 ad25(.a(pg[1]), .b(p[2]), .y(pg[2]));
	_or2 or25(.a(pg[2]), .b(g[2]), .y(pg[3]));
	_and2 ad26(.a(pg[3]), .b(p[3]), .y(pg[4]));
	_or2 or26(.a(pg[4]), .b(g[3]), .y(pg[5])); // calculate pg_block
	_and2 ad27(.a(p[0]), .b(ci), .y(w0));
	_or2 or27(.a(g[0]), .b(w0), .y(c1)); // calculate c1
	_and3 ad30(.a(p[0]), .b(p[1]), .c(ci), .y(w1));
	_or2 or28(.a(pg[1]), .b(w1), .y(c2)); // calculate c2
	_and4 ad40(.a(p[0]), .b(p[1]), .c(p[2]), .d(ci), .y(w2));
	_or2 or29(.a(pg[3]), .b(w2), .y(c3)); // calculate c3
	_and5 ad50(.a(p[0]), .b(p[1]), .c(p[2]), .d(p[3]), .e(ci), .y(w3));
	_or2 or210(.a(pg[5]), .b(w3), .y(co)); // calculate co
endmodule
	