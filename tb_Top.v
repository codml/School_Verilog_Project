`timescale 1ns/100ps
module tb_Top;
	reg tb_clk, tb_reset_n, tb_m_req, tb_m_wr;
	reg [15:0] tb_m_addr;
	reg [63:0] tb_m_dout;
	wire tb_m_grant, tb_interrupt;
	wire [63:0] tb_m_din;
	
	Top U0_Top(.clk(tb_clk), .reset_n(tb_reset_n), .m_req(tb_m_req), .m_wr(tb_m_wr), .m_addr(tb_m_addr),
		.m_dout(tb_m_dout), .m_grant(tb_m_grant), .interrupt(tb_interrupt), .m_din(tb_m_din));
		
	always begin
		#5; tb_clk = ~tb_clk;
	end

	always @(posedge tb_m_grant) begin
		#5;
		tb_m_wr = 1'b1;
		tb_m_addr = 16'h7020; tb_m_dout = 64'd5; #10;
		tb_m_addr = 16'h7018; tb_m_dout = 64'b1; #10;
		tb_m_addr = 16'h7000; tb_m_dout = 64'b1; #700;
		
		tb_m_wr = 1'b0;
		tb_m_addr = 16'h7030; #100;
		
		tb_m_wr = 1'b1;
		tb_m_addr = 16'h7008; #10;
		
		tb_m_addr = 16'h0070; tb_m_dout = 64'd120; #10;
		tb_m_wr = 1'b0;
		tb_m_addr = 16'h0071; #10;
		
		tb_m_wr = 1'b1;
		tb_m_addr = 16'h7020; tb_m_dout = 64'd10; #10;
		tb_m_addr = 16'h7000; tb_m_dout = 64'b1; #10;
		
		tb_m_wr = 1'b0;
		tb_m_addr = 16'h7010; #1600;
		tb_m_addr = 16'h7030; #100;
		
		tb_m_wr = 1'b1;
		tb_m_addr = 16'h7008; #10;
		
		tb_m_addr = 16'h00ff; tb_m_dout = 64'd3628800; #10;
		tb_m_wr = 1'b0;
		tb_m_addr = 16'h00f8; #10;
		
		tb_m_addr = 16'h6060; #10;
	end
	
	initial begin
	tb_clk = 1'b1; tb_reset_n = 1'b0; tb_m_req = 1'b0; #5;
	tb_reset_n = 1'b1; #10;
	tb_m_req = 1'b1; #3000;
	tb_m_req = 1'b0; #10;
	$stop;
	end
endmodule
