`timescale 1ns/100ps
module tb_FactoCore; // testbench for factocore
	reg tb_clk, tb_reset_n, tb_s_sel, tb_s_wr;
	reg [15:0] tb_s_addr;
	reg [63:0] tb_s_din;
	wire [63:0] tb_s_dout;
	wire tb_interrupt;
	// instance
	FactoCore U0_FactoCore(.clk(tb_clk), .reset_n(tb_reset_n), .s_sel(tb_s_sel), .s_wr(tb_s_wr),
		.s_addr(tb_s_addr), .s_din(tb_s_din), .s_dout(tb_s_dout), .interrupt(tb_interrupt));
		
	always begin
		#5 tb_clk = ~tb_clk;
	end
	
	always @(tb_interrupt) begin
		if (tb_interrupt == 1'b1) begin
			#5; tb_s_wr <= 1'b0; #100; tb_s_wr <= 1'b1;
		end
		else tb_s_wr <= 1'b1;
	end // when interrupt rising, read result_l, result_h
	
	initial begin
		tb_clk = 1'b1; tb_reset_n = 1'b0; tb_s_sel = 1'b1;
		tb_s_addr = 16'h70ff; tb_s_din = 64'b1; #5; // write to wrong address
		tb_reset_n = 1'b1; #10;
		tb_s_addr = 16'h7020; tb_s_din = 64'd5; #10; // operand = 5
		tb_s_addr = 16'h7018; tb_s_din = 64'b1; #10; // intrEn = 1
		tb_s_addr = 16'h7000; tb_s_din = 64'b1; #10; // opstart = 1 -> start
		tb_s_addr = 16'h7030; #800; // read result_l
		tb_s_addr = 16'h7028; #100; // read result_h
		tb_s_addr = 16'h7008; tb_s_din = 64'b1; #10; // opclear
		tb_s_addr = 16'h7008; tb_s_din = 64'b0; #10;
		tb_s_addr = 16'h7020; tb_s_din = 64'd10; #10; // operand = 10
		tb_s_addr = 16'h7000; tb_s_din = 64'b1; #10; // start
		tb_s_addr = 16'h7030; #1720;
		tb_s_addr = 16'h7028; #100;
		tb_s_addr = 16'h7008; tb_s_din = 64'b1; #10; // opclear
		tb_s_addr = 16'h7008; tb_s_din = 64'b0; #10;
		tb_s_addr = 16'h7020; tb_s_din = 64'd68; #10; // operand = 68 -> this has large result
		tb_s_addr = 16'h7000; tb_s_din = 64'b1; #10;
		tb_s_addr = 16'h7030; #12740;
		tb_s_addr = 16'h7028; #100;
		tb_s_addr = 16'h7008; tb_s_din = 64'b1; #10;
		tb_s_addr = 16'h7008; tb_s_din = 64'b0; #10;
		tb_s_addr = 16'h7020; tb_s_din = 64'b0; #10; // operand = 0 -> finish in one cycle
		tb_s_addr = 16'h7000; tb_s_din = 64'b1; #10;
		tb_s_addr = 16'h7030; #20;
		tb_s_addr = 16'h7028; #100;
		tb_s_addr = 16'h7008; tb_s_din = 64'b1; #10;
		tb_s_addr = 16'h7008; tb_s_din = 64'b0; #10;
		tb_s_addr = 16'h7020; tb_s_din = 64'b1; #10; // operand = 0 -> finish in one cycle
		tb_s_addr = 16'h7000; tb_s_din = 64'b1; #10;
		tb_s_addr = 16'h7030; #20;
		tb_s_addr = 16'h7028; #100;
		$stop;
	end
endmodule
