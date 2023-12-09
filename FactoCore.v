module FactoCore(clk, reset_n, s_sel, s_wr, s_addr, s_din, s_dout, interrupt);
	input clk, reset_n, s_sel, s_wr;
	input [15:0] s_addr;
	input [63:0] s_din;
	output reg [63:0] s_dout;
	output interrupt;
	
	reg [63:0] mem [0:6]; // register
	reg [2:0] state, next_state;
	
	reg [63:0] operand; // to store and sub mem[OPERAND]
	reg booth_op_start;
	reg booth_op_clear;
	reg [63:0] booth_input; // multiplier inputs
	
	wire [63:0] result_h, result_l;
	wire booth_op_done; // multiplier outputs
	
	parameter OP_START = 5'b0;
	parameter OP_CLEAR = 5'b1;
	parameter OP_DONE = 5'd2;
	parameter INTR_EN = 5'd3;
	parameter OPERAND = 5'd4;
	parameter RESULT_H = 5'd5;
	parameter RESULT_L = 5'd6;
	
	parameter INIT = 3'b000;
	parameter OP_CLR = 3'b001;
	parameter SET_1 = 3'b010;
	parameter SET_2 = 3'b011;
	parameter MUL_1 = 3'b100;
	parameter MUL_2 = 3'b101;
	parameter DONE = 3'b110;
	
	always @(posedge clk, negedge reset_n) begin // clock
		if (reset_n == 1'b0) state <= INIT;
		else state <= next_state;
	end
	 // next state logic
	always @(state, mem[OP_START], mem[OP_CLEAR], mem[OP_DONE], booth_op_done) begin
		casex({state, mem[OP_START][0], mem[OP_CLEAR][0], mem[OP_DONE][0], booth_op_done})
		{INIT, 1'bx, 1'b0, 1'bx, 1'bx}: next_state <= SET_1;
		{INIT, 1'bx, 1'b1, 1'bx, 1'bx}: next_state <= OP_CLR;
		{OP_CLR, 1'bx, 1'b0, 1'bx, 1'bx}: next_state <= SET_1;
		{OP_CLR, 1'bx, 1'b1, 1'bx, 1'bx}: next_state <= OP_CLR;
		{SET_1, 1'bx, 1'b1, 1'bx, 1'bx}: next_state <= OP_CLR;
		{SET_1, 1'b0, 1'b0, 1'bx, 1'bx}: next_state <= SET_2;
		{SET_1, 1'b1, 1'b0, 1'bx, 1'bx}: next_state <= MUL_1;
		{SET_2, 1'bx, 1'b1, 1'bx, 1'bx}: next_state <= OP_CLR;
		{SET_2, 1'b0, 1'b0, 1'bx, 1'bx}: next_state <= SET_1;
		{SET_2, 1'b1, 1'b0, 1'bx, 1'bx}: next_state <= MUL_1;
		{MUL_1, 1'bx, 1'b1, 1'bx, 1'bx}: next_state <= OP_CLR;
		{MUL_1, 1'bx, 1'b0, 1'b0, 1'b0}: next_state <= MUL_1;
		{MUL_1, 1'bx, 1'b0, 1'b0, 1'b1}: next_state <= MUL_2;
		{MUL_1, 1'bx, 1'b0, 1'b1, 1'bx}: next_state <= DONE;
		{MUL_2, 1'bx, 1'b1, 1'bx, 1'bx}: next_state <= OP_CLR;
		{MUL_2, 1'bx, 1'b0, 1'b0, 1'b0}: next_state <= MUL_2;
		{MUL_2, 1'bx, 1'b0, 1'b0, 1'b1}: next_state <= MUL_1;
		{MUL_2, 1'bx, 1'b0, 1'b1, 1'bx}: next_state <= DONE;
		{DONE, 1'bx, 1'b0, 1'bx, 1'bx}: next_state <= DONE;
		{DONE, 1'bx, 1'b1, 1'bx, 1'bx}: next_state <= OP_CLR;
		default: next_state <= 3'bx;
		endcase
	end
	
	always @(posedge clk) begin // write logic -> sync
	if (state == INIT || state == OP_CLR) mem[OP_START] <= 64'b0; // opclear init registers except opclear, intrEn, operand
	if (state == INIT) begin
		mem[OP_CLEAR] <= 64'b0;
		mem[INTR_EN] <= 64'b0;
		mem[OPERAND] <= 64'b0;
	end
	case({s_sel, s_wr, s_addr[15:8], s_addr[7:3]}) // ignore wrong address
	{1'b1, 1'b1, 8'h70, OP_START}: mem[OP_START] <= s_din;
	{1'b1, 1'b1, 8'h70, OP_CLEAR}: mem[OP_CLEAR] <= s_din;
	{1'b1, 1'b1, 8'h70, INTR_EN}: mem[INTR_EN] <= s_din;
	{1'b1, 1'b1, 8'h70, OPERAND}: mem[OPERAND] <= s_din;
	endcase
	end

	always @(state, mem[OPERAND], booth_op_done) begin // multiply logic(output logic)
	case(state)
	INIT, OP_CLR: begin // init registers
		mem[OP_DONE] <= 64'b0;
		mem[RESULT_H] <= 64'b0;
		mem[RESULT_L] <= 64'b1;
		operand <= 64'b0;
		booth_op_start <= 1'b0;
		booth_op_clear <= 1'b0;
		booth_input <= 64'b0;
	end
	SET_1, SET_2: begin // write operand
		if (mem[OP_START][0] !== 1'b1) operand <= mem[OPERAND];
	end
	MUL_1, MUL_2: begin // multiply -> write result to regiser -> operand sub
		if (mem[OPERAND] === 64'b0 || mem[OPERAND] === 64'b1) begin
			mem[RESULT_H] <= 64'd0;
			mem[RESULT_L] <= 64'd1;
			mem[OP_DONE][1:0] <= 2'b11;
		end
		else if (booth_op_start == 1'b0) begin
			mem[OP_DONE][1] <= 1'b1;
			if (mem[RESULT_L] === 64'b0) booth_input <= mem[RESULT_H];
			else booth_input <= mem[RESULT_L];
			booth_op_clear <= 1'b0;
			booth_op_start <= 1'b1;
		end
		else if (booth_op_done == 1'b1) begin
			mem[RESULT_H] <= result_h;
			mem[RESULT_L] <= result_l;
			booth_op_start <= 1'b0;
			booth_op_clear <= 1'b1;
			if (operand === 64'd2) mem[OP_DONE][0] <= 1'b1;
			else operand <= operand - 64'b1;
		end
	end
	endcase // do nothing when state is DONE
	end
	
	always @(s_sel, s_wr, s_addr, mem[OP_DONE], mem[RESULT_H], mem[RESULT_L]) begin // read logic
		case({s_sel, s_wr, s_addr[15:8], s_addr[7:3]})
		{1'b1, 1'b0, 8'h70, OP_DONE}: s_dout <= mem[OP_DONE];
		{1'b1, 1'b0, 8'h70, RESULT_H}: s_dout <= mem[RESULT_H];
		{1'b1, 1'b0, 8'h70, RESULT_L}: s_dout <= mem[RESULT_L];
		default: s_dout <= 64'b0;
		endcase
	end
	
	assign interrupt = mem[OP_DONE][0] & mem[INTR_EN][0]; // interrupt signal
	// multiplier instance
	multiplier U0_mul(.clk(clk), .reset_n(reset_n), .multiplier(booth_input), .multiplicand(operand),
		.op_start(booth_op_start), .op_clear(booth_op_clear), .op_done(booth_op_done), .result({result_h, result_l}));
	
endmodule
