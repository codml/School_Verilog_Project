`timescale 1ns/100ps
module tb_BUS;
   reg tb_clk, tb_reset_n, tb_m_req, tb_m_wr;
	reg [15:0] tb_m_addr;
	reg [63:0] tb_m_dout, tb_s0_dout, tb_s1_dout;
	wire tb_m_grant;
	wire [63:0] tb_m_din;
	wire tb_s0_sel, tb_s1_sel, tb_s_wr;
	wire [15:0] tb_s_addr;
	wire [63:0] tb_s_din;
	
	BUS U0_BUS(.clk(tb_clk), .reset_n(tb_reset_n), .m_req(tb_m_req), .m_wr(tb_m_wr), .m_addr(tb_m_addr),
		.m_dout(tb_m_dout), .s0_dout(tb_s0_dout), .s1_dout(tb_s1_dout), .m_grant(tb_m_grant),
		.m_din(tb_m_din), .s0_sel(tb_s0_sel), .s1_sel(tb_s1_sel), .s_addr(tb_s_addr), .s_wr(tb_s_wr), .s_din(tb_s_din));
		
	always begin
		#5; tb_clk = ~tb_clk;
	end
	
	initial begin
	tb_clk = 1'b1; tb_reset_n = 1'b0; tb_m_wr = 1'b0; tb_m_addr = 16'h0000;
	tb_m_dout = 64'hffff; tb_s0_dout = 64'h0f0f; tb_s1_dout = 64'hf0f0; #5;
	tb_reset_n = 1'b1; #10;
	tb_m_req = 1'b1; #10;
	tb_m_wr = 1'b0; tb_m_addr = 16'h70ff; #10;
	tb_m_addr = 16'h6060; #10;
	tb_m_wr = 1'b1; tb_m_addr = 16'h07ff; #10;
	tb_m_wr = 1'b0; tb_m_addr = 16'h7000; #10;
	tb_m_req = 1'b0; #10;
	$stop;
	end
endmodule
