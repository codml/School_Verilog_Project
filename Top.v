module Top(clk, reset_n, m_req, m_wr, m_addr, m_dout, m_grant, interrupt, m_din); // top module
	input clk, reset_n, m_req, m_wr;
	input [15:0] m_addr;
	input [63:0] m_dout;
	output m_grant, interrupt;
	output [63:0] m_din;
	
	wire [63:0] s0_dout, s1_dout; // s0 = ram, s1 = factocore
	wire s0_sel, s1_sel;
	wire [15:0] s_addr;
	wire s_wr;
	wire [63:0] s_din;
	
	BUS U0_BUS(.clk(clk), .reset_n(reset_n), .m_req(m_req), .m_wr(m_wr), .m_addr(m_addr),
		.m_dout(m_dout), .s0_dout(s0_dout), .s1_dout(s1_dout), .m_grant(m_grant), .m_din(m_din),
		.s0_sel(s0_sel), .s1_sel(s1_sel), .s_addr(s_addr), .s_wr(s_wr), .s_din(s_din)); // bus instance
	ram U1_ram(.clk(clk), .cen(s0_sel), .wen(s_wr), .s_addr(s_addr[10:3]), .s_din(s_din), .s_dout(s0_dout)); // ram
	FactoCore U2_FactoCore(.clk(clk), .reset_n(reset_n), .s_sel(s1_sel), .s_wr(s_wr), .s_addr(s_addr),
		.s_din(s_din), .s_dout(s1_dout), .interrupt(interrupt)); // FactoCore instance
endmodule
