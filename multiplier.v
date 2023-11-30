module multiplier(clk, reset_n, multiplier, multiplicand, op_start, op_clear, op_done, result); // top module
	input clk, reset_n, op_start, op_clear;
	input [63:0] multiplier, multiplicand;
	
	output reg op_done;
	output reg [127:0] result;
	
	reg [1:0] state;
	reg [1:0] next_state;
	
	reg [3:0] idx; // count cycles of multiplication
	reg [63:0] reg_multiplicand; // store the multiplicand when op_start rising
	reg [63:0] reg_multiplier; // store the multiplier when op_start rising
	
	reg [64:0] inside_multiplier; // multiplier that be needed to shift
	reg [3:0] next_idx;
	
	wire [3:0] idx_plus_1; // idx + 1
	wire [127:0] next_result; // result from multiply_one
	
	parameter INIT = 2'b00;
	parameter MULTIPLY = 2'b01;
	parameter DONE = 2'b10;
	
	always @(posedge clk, negedge reset_n) begin // sync clock
		if (reset_n == 1'b0) begin
			state <= INIT;
			idx <= 4'b0;
		end
		else begin
			state <= next_state;
			idx <= next_idx;
		end
	end
	
	always @(state, op_start, op_clear, op_done) begin // for next state
		casex({state, op_start, op_clear, op_done})
		{INIT, 1'b0, 1'bx, 1'bx}: next_state <= INIT;
		{INIT, 1'b1, 1'bx, 1'bx}: next_state <= MULTIPLY;
		{MULTIPLY, 1'bx, 1'b0, 1'b0}: next_state <= MULTIPLY;
		{MULTIPLY, 1'bx, 1'b0, 1'b1}: next_state <= DONE;
		{MULTIPLY, 1'bx, 1'b1, 1'bx}: next_state <= INIT;
		{DONE, 1'bx, 1'b0, 1'b1}: next_state <= DONE;
		{DONE, 1'bx, 1'b1, 1'b1}: next_state <= INIT;
		default: next_state <= 2'bx;
		endcase
	end
	
	always @(op_start, clk, reset_n) begin // when op_start 0 to 1 in INIT state, multiplicand, multiplier will be saved
		if ((clk == 1 && op_clear == 1'b1) || reset_n == 1'b0) begin // op_clear will initiate register
			reg_multiplicand <= 64'b0;
			reg_multiplier <= 64'b0;
		end
		else if (op_start == 1'b1 && state == INIT) begin
			reg_multiplicand <= multiplicand;
			reg_multiplier <= multiplier;
		end
	end
	
	always @(state, idx, reg_multiplier) begin // for output logic
		case(state)
		INIT: begin // INIT state will initiate registers
			next_idx <= 4'b0;
			op_done <= 1'b0;
			result <= 128'b0;
			inside_multiplier <= {reg_multiplier, 1'b0};
		end
		MULTIPLY: begin // MULTIPLY state will continue multiplication
			result <= next_result;
			next_idx <= idx_plus_1;
			inside_multiplier <= inside_multiplier >> 4;
			if (idx == 4'hf) op_done <= 1'b1; // if multiplication is done, op_done == 1
			else op_done <= 1'b0;
		end
		DONE: begin
			op_done <= 1'b1;
			next_idx <= 4'b0;
			inside_multiplier <= inside_multiplier;
			result <= result;
		end
		default: begin // default
			op_done <= 1'bx;
			result <= 128'bx;
			next_idx <= 4'bx;
			inside_multiplier <= 65'bx;
		end
		endcase
	end
	
	cla4 U0_cla4(.a(idx), .b(4'b1), .ci(1'b0), .s(idx_plus_1), .co()); // idx_plus_1 = idx + 1
	multiply_one U0_mul(reg_multiplicand, result, inside_multiplier[4:0], next_result); // instance
	
endmodule