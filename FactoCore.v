module FactoCore(clk, reset_n, s_sel, s_wr, s_addr, s_din, s_dout, interrupt);
	input clk, reset_n, s_sel, s_wr;
	input [15:0] s_addr;
	input [63:0] s_din;
	output reg [63:0] s_dout;
	output interrupt;
	
	reg [63:0] mem [0:6];
	reg [2:0] state, next_state;
	
	reg [63:0] operand;
	reg booth_op_start;
	reg booth_op_clear;
	reg [63:0] booth_input;
	
	wire [63:0] result_h, result_l;
	wire booth_op_done;
	
	parameter OP_START = 5'b0;
	parameter OP_CLEAR = 5'b1;
	parameter OP_DONE = 5'd2;
	parameter INTR_EN = 5'd3;
	parameter OPERAND = 5'd4;
	parameter RESULT_H = 5'd5;
	parameter RESULT_L = 5'd6;
	
	parameter INIT = 3'b000;
	parameter SETTING = 3'b001;
	parameter MUL_1 = 3'b010;
	parameter MUL_2 = 3'b011;
	parameter DONE = 3'b100;
	
	always @(posedge clk, negedge reset_n) begin
		if (reset_n == 1'b0) state <= INIT;
		else state <= next_state;
	end
	
	always @(state, mem[OP_START], mem[OP_CLEAR], mem[OP_DONE], booth_op_done) begin
		casex({state, mem[OP_START][0], mem[OP_CLEAR][0], mem[OP_DONE][0], booth_op_done})
		{INIT, 1'b0, 1'bx, 1'bx, 1'bx}: next_state <= SETTING;
		{INIT, 1'b1, 1'bx, 1'bx, 1'bx}: next_state <= MUL_1;
		{SETTING, 1'b0, 1'bx, 1'bx, 1'bx}: next_state <= SETTING;
		{SETTING, 1'b1, 1'bx, 1'bx, 1'bx}: next_state <= MUL_1;
		{MUL_1, 1'bx, 1'b0, 1'b0, 1'b0}: next_state <= MUL_1;
		{MUL_1, 1'bx, 1'b0, 1'b0, 1'b1}: next_state <= MUL_2;
		{MUL_1, 1'bx, 1'b1, 1'bx, 1'bx}: next_state <= INIT;
		{MUL_1, 1'bx, 1'b0, 1'b1, 1'bx}: next_state <= DONE;
		{MUL_2, 1'bx, 1'b0, 1'b0, 1'b0}: next_state <= MUL_2;
		{MUL_2, 1'bx, 1'b0, 1'b0, 1'b1}: next_state <= MUL_1;
		{MUL_2, 1'bx, 1'b1, 1'bx, 1'bx}: next_state <= INIT;
		{MUL_2, 1'bx, 1'b0, 1'b1, 1'bx}: next_state <= DONE;
		{DONE, 1'bx, 1'b0, 1'bx, 1'bx}: next_state <= DONE;
		{DONE, 1'bx, 1'b1, 1'bx, 1'bx}: next_state <= INIT;
		default: next_state <= 3'bx;
		endcase
	end
	
	always @(state, booth_op_done, s_din, s_sel, s_wr, s_addr) begin
	case(state)
	INIT: begin
		mem[OP_DONE] <= 64'b0;
		mem[RESULT_H] <= 64'b0;
		mem[RESULT_L] <= 64'b1;
		casex({s_sel, s_wr, s_addr[7:3]})
		{1'b1, 1'b1, OP_START}: mem[OP_START] <= s_din;
		{1'b1, 1'b1, OP_CLEAR}: mem[OP_CLEAR] <= s_din;
		{1'b1, 1'b1, INTR_EN}: mem[INTR_EN] <= s_din;
		{1'b1, 1'b1, OPERAND}: mem[OPERAND] <= s_din;
		endcase
		if (s_addr[7:3] != OP_START) mem[OP_START] <= 64'b0;
		if (s_addr[7:3] != OP_CLEAR) mem[OP_CLEAR] <= 64'b0;
		if (s_addr[7:3] != INTR_EN) mem[INTR_EN] <= 64'b0;
		if (s_addr[7:3] != OPERAND) mem[OPERAND] <= 64'b0;
		operand <= 64'b0;
		booth_op_start <= 1'b0;
		booth_op_clear <= 1'b0;
		booth_input <= 64'b0;
	end
	SETTING: begin
		casex({s_sel, s_wr, s_addr[7:3]})
		{1'b1, 1'b1, OP_START}: mem[OP_START] <= s_din;
		{1'b1, 1'b1, OP_CLEAR}: mem[OP_CLEAR] <= s_din;
		{1'b1, 1'b1, INTR_EN}: mem[INTR_EN] <= s_din;
		{1'b1, 1'b1, OPERAND}: mem[OPERAND] <= s_din;
		endcase
		operand <= mem[OPERAND];
	end
	MUL_1: begin
		if (mem[OPERAND] == 64'b0 || mem[OPERAND] == 64'b1) mem[OP_DONE][1:0] <= 2'b11;
		else if (operand == 64'b1) mem[OP_DONE][0] <= 1'b1;
		else if (booth_op_start == 1'b0) begin
			mem[OP_DONE][1] <= 1'b1;
			booth_op_clear <= 1'b0;
			booth_op_start <= 1'b1;
			if (mem[RESULT_L] == 64'b0) booth_input <= mem[RESULT_H];
			else booth_input <= mem[RESULT_L];
		end
		else if (booth_op_done == 1'b1) begin
			mem[RESULT_H] <= result_h;
			mem[RESULT_L] <= result_l;
			booth_op_start <= 1'b0;
			booth_op_clear <= 1'b1;
			operand <= operand - 64'b1;
		end
	end
	MUL_2: begin
		if (mem[OPERAND] == 64'b0 || mem[OPERAND] == 64'b1) mem[OP_DONE][1:0] <= 2'b11;
		else if (operand == 64'b1) mem[OP_DONE][0] <= 1'b1;
		else if (booth_op_start == 1'b0) begin
			mem[OP_DONE][1] <= 1'b1;
			booth_op_clear <= 1'b0;
			booth_op_start <= 1'b1;
			if (mem[RESULT_L] == 64'b0) booth_input <= mem[RESULT_H];
			else booth_input <= mem[RESULT_L];
		end
		else if (booth_op_done == 1'b1) begin
			mem[RESULT_H] <= result_h;
			mem[RESULT_L] <= result_l;
			booth_op_start <= 1'b0;
			booth_op_clear <= 1'b1;
			operand <= operand - 64'b1;
		end
	end
	DONE: begin
		casex({s_sel, s_wr, s_addr[7:3]})
		{1'b1, 1'b1, OP_START}: mem[OP_START] <= s_din;
		{1'b1, 1'b1, OP_CLEAR}: mem[OP_CLEAR] <= s_din;
		{1'b1, 1'b1, INTR_EN}: mem[INTR_EN] <= s_din;
		{1'b1, 1'b1, OPERAND}: mem[OPERAND] <= s_din;
		endcase
	end
	endcase
	end
	
	always @(s_sel, s_wr, s_addr, s_din, mem[OP_DONE], mem[RESULT_H], mem[RESULT_L]) begin
		casex({s_sel, s_wr, s_addr[7:3]})
		{1'b1, 1'b0, OP_DONE}: s_dout <= mem[OP_DONE];
		{1'b1, 1'b0, RESULT_H}: s_dout <= mem[RESULT_H];
		{1'b1, 1'b0, RESULT_L}: s_dout <= mem[RESULT_L];
		default: s_dout <= 64'b0;
		endcase
	end
	
	assign interrupt = mem[OP_DONE][0] & mem[INTR_EN][0];
	
	multiplier U0_mul(.clk(clk), .reset_n(reset_n), .multiplier(operand), .multiplicand(booth_input),
		.op_start(booth_op_start), .op_clear(booth_op_clear), .op_done(booth_op_done), .result({result_h, result_l}));
	
endmodule
