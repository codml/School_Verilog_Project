`timescale 1ns/100ps
module tb_Top; // testbench for top module
	reg tb_clk, tb_reset_n, tb_m_req, tb_m_wr;
	reg [15:0] tb_m_addr;
	reg [63:0] tb_m_dout;
	wire tb_m_grant, tb_interrupt;
	wire [63:0] tb_m_din;
	
	Top U0_Top(.clk(tb_clk), .reset_n(tb_reset_n), .m_req(tb_m_req), .m_wr(tb_m_wr), .m_addr(tb_m_addr),
		.m_dout(tb_m_dout), .m_grant(tb_m_grant), .interrupt(tb_interrupt), .m_din(tb_m_din));
	// instance
	always begin
		#5; tb_clk = ~tb_clk;
	end

	always @(posedge tb_m_grant) begin // when grant rising, start
		#5; // for setup time constraint
		tb_m_wr = 1'b1;
		tb_m_addr = 16'h7020; tb_m_dout = 64'd5; #10; // operand = 5
		tb_m_addr = 16'h7018; tb_m_dout = 64'b1; #10; // interrupt = enable
		tb_m_addr = 16'h7000; tb_m_dout = 64'b1; #800; // start
		
		tb_m_wr = 1'b0;
		tb_m_addr = 16'h7030; #100; // read result_l
		tb_m_addr = 16'h7028; #100; // read result_h
		
		tb_m_wr = 1'b1;
		tb_m_addr = 16'h7008; #10; // opclear
		tb_m_dout = 64'b0; #10;
		
		tb_m_addr = 16'h0070; tb_m_dout = 64'd120; #10; // write 120 to 0x0070
		tb_m_wr = 1'b0;
		tb_m_addr = 16'h0071; #10; // read from 0x0071 -> 120
		
		tb_m_wr = 1'b1;
		tb_m_addr = 16'h7020; tb_m_dout = 64'd80; #10; // operand = 80
		tb_m_addr = 16'h7018; tb_m_dout = 64'b0; #10; // interrupt = disable
		tb_m_addr = 16'h7000; tb_m_dout = 64'b1; #10; // start
		
		tb_m_wr = 1'b0;
		tb_m_addr = 16'h7010; #15030; // read opdone
		tb_m_addr = 16'h7030; #100; // read result_l
		tb_m_addr = 16'h7028; #100;
		
		tb_m_wr = 1'b1;
		tb_m_addr = 16'h7008; #10; // opclear
		tb_m_dout = 64'b0; #10;
		
		tb_m_addr = 16'h00ff; tb_m_dout = 64'd360; #10; // write 360 to 0x00ff
		tb_m_wr = 1'b0;
		tb_m_addr = 16'h00f8; #10; // read from 0x00f8 -> 360
		
		tb_m_addr = 16'h6060; #10; // wrong address
	end
	
	initial begin
	tb_clk = 1'b1; tb_reset_n = 1'b0; tb_m_req = 1'b0; #5; // no request
	tb_reset_n = 1'b1; #10;
	tb_m_req = 1'b1; #18000; // grant = 1
	tb_m_req = 1'b0; #10; // grant = 0
	$stop;
	end
endmodule
