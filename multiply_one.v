module multiply_one(multiplicand, product, part_multiplier, result); // multiply in one cycle
	input [63:0] multiplicand; // reg_multiplicand
	input signed [127:0] product; // before result
	input [4:0] part_multiplier; // multiplier[4:0]
	
	output reg [127:0] result; // calculate partial product
	
	wire signed [127:0] type_1, type_2, type_3, type_4, type_5, type_6, type_7, type_8;
	wire signed [127:0] type_9, type_10, type_11, type_12, type_13, type_14, type_15, type_16;
	wire signed [63:0] complement; // complement = ~product
	
	always @(multiplicand, product, part_multiplier) begin
		case(part_multiplier) // radix-16 multiplier decoding
		5'b00000: result = product >>> 4;
		5'b00001: result = type_1 >>> 4;
		5'b00010: result = type_1 >>> 4;
		5'b00011: result = type_2 >>> 3;
		5'b00100: result = type_2 >>> 3;
		5'b00101: result = type_3 >>> 3;
		5'b00110: result = type_3 >>> 3;
		5'b00111: result = type_4 >>> 2;
		5'b01000: result = type_4 >>> 2;
		5'b01001: result = type_5 >>> 2;
		5'b01010: result = type_5 >>> 2;
		5'b01011: result = type_6 >>> 2;
		5'b01100: result = type_6 >>> 2;
		5'b01101: result = type_7 >>> 1;
		5'b01110: result = type_7 >>> 1;
		5'b01111: result = type_8 >>> 1;
		5'b10000: result = type_9 >>> 1;
		5'b10001: result = type_10 >>> 1;
		5'b10010: result = type_10 >>> 1;
		5'b10011: result = type_11 >>> 1;
		5'b10100: result = type_11 >>> 1;
		5'b10101: result = type_12 >>> 2;
		5'b10110: result = type_12 >>> 2;
		5'b10111: result = type_13 >>> 2;
		5'b11000: result = type_13 >>> 2;
		5'b11001: result = type_14 >>> 2;
		5'b11010: result = type_14 >>> 2;
		5'b11011: result = type_15 >>> 3;
		5'b11100: result = type_15 >>> 3;
		5'b11101: result = type_16 >>> 4;
		5'b11110: result = type_16 >>> 4;
		5'b11111: result = product >>> 4;
		default: result = 128'bx;
		endcase
	end
	
	cla64 U0_cla64(.a(~multiplicand), .b(64'b0), .ci(1'b1), .s(complement), .co()); // ~1
	cla128 U1_cla128(.a(product), .b({multiplicand, 64'b0}), .ci(1'b0), .s(type_1), .co()); // 0001
	cla128 U2_cla128(.a(product >>> 1), .b({multiplicand, 64'b0}), .ci(1'b0), .s(type_2), .co()); // 0010
	cla128 U3_cla128(.a(type_1 >>> 1), .b({multiplicand, 64'b0}), .ci(1'b0), .s(type_3), .co()); // 0011
	cla128 U4_cla128(.a(product >>> 2), .b({multiplicand, 64'b0}), .ci(1'b0), .s(type_4), .co()); // 0100
	cla128 U5_cla128(.a(type_1 >>> 2), .b({multiplicand, 64'b0}), .ci(1'b0), .s(type_5), .co()); // 0101
	cla128 U6_cla128(.a(type_2 >>> 1), .b({multiplicand, 64'b0}), .ci(1'b0), .s(type_6), .co()); // 0110
	cla128 U7_cla128(.a(type_16 >>> 3), .b({multiplicand, 64'b0}), .ci(1'b0), .s(type_7), .co()); // 100~1
	cla128 U8_cla128(.a(product >>> 3), .b({multiplicand, 64'b0}), .ci(1'b0), .s(type_8), .co()); // 1000
	cla128 U9_cla128(.a(product >>> 3), .b({complement, 64'b0}), .ci(1'b0), .s(type_9), .co()); // ~1000
	cla128 U10_cla128(.a(type_1 >>> 3), .b({complement, 64'b0}), .ci(1'b0), .s(type_10), .co()); // ~1001
	cla128 U11_cla128(.a(type_2 >>> 2), .b({complement, 64'b0}), .ci(1'b0), .s(type_11), .co()); // ~1010
	cla128 U12_cla128(.a(type_16 >>> 2), .b({complement, 64'b0}), .ci(1'b0), .s(type_12), .co()); // 0~10~1
	cla128 U13_cla128(.a(product >>> 2), .b({complement, 64'b0}), .ci(1'b0), .s(type_13), .co()); // 0~100
	cla128 U14_cla128(.a(type_1 >>> 2), .b({complement, 64'b0}), .ci(1'b0), .s(type_14), .co()); // 0~101
	cla128 U15_cla128(.a(product >>> 1), .b({complement, 64'b0}), .ci(1'b0), .s(type_15), .co()); // 00~10
	cla128 U16_cla128(.a(product), .b({complement, 64'b0}), .ci(1'b0), .s(type_16), .co()); // 000~1
	
endmodule
