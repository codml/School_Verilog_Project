module BUS(clk, reset_n, m_req, m_wr, m_addr, m_dout, s0_dout, s1_dout,
	m_grant, m_din, s0_sel, s1_sel, s_addr, s_wr, s_din);
	// bus
	input clk, reset_n, m_req, m_wr; // 1-bit input
	input [15:0] m_addr; // 16-bit input
	input [63:0] m_dout, s0_dout, s1_dout; // 64-bit input
	
	output reg m_grant, s0_sel, s1_sel; // output
	output s_wr;
	output [15:0] s_addr;
	output [63:0] m_din, s_din;
	
	reg state, next_state; // state for grant
	reg [1:0] addr;
	
	parameter NONE = 1'b0;
	parameter M_GRANT = 1'b1;
	
	always @(posedge clk, negedge reset_n) begin // sync clock
		if (reset_n == 1'b0) begin
			state <= NONE;
			addr <= 2'b0;
		end
		else begin
			state <= next_state;
			addr <= {s0_sel, s1_sel};
		end
	end
	
	always @(m_req, state) begin // arbiter next state
		case({state, m_req})
		{NONE, 1'b0}: next_state <= NONE;
		{NONE, 1'b1}: next_state <= M_GRANT;
		{M_GRANT, 1'b0}: next_state <= NONE;
		{M_GRANT, 1'b1}: next_state <= M_GRANT;
		default: next_state <= 1'bx;
		endcase
	end
	
	always @(state) begin // arbiter output
		case(state)
		NONE: m_grant <= 1'b0;
		M_GRANT: m_grant <= 1'b1;
		default: m_grant <= 1'bx;
		endcase
	end
	
	always @(m_req, s_addr) begin // address decoder
		if (m_req === 1'b1 && s_addr >= 16'b0 && s_addr < 16'h0800) {s0_sel, s1_sel} <= 2'b10;
		else if (m_req === 1'b1 && s_addr >= 16'h7000 && s_addr < 16'h7200) {s0_sel, s1_sel} <= 2'b01;
		else {s0_sel, s1_sel} <= 2'b00;
	end
	
	mx2 U0_mx2(.y(s_wr), .d0(1'bx), .d1(m_wr), .s(m_grant));
	mx2_16bits U1_mx2_16bits(.d0(16'bx), .d1(m_addr), .s(m_grant), .y(s_addr));
	mx2_64bits U2_mx2_64bits(.d0(64'bx), .d1(m_dout), .s(m_grant), .y(s_din));
	
	mx3_64bits U3_mx3_64bits(.d0(64'b0), .d1(s0_dout), .d2(s1_dout), .s(addr), .y(m_din));
	
endmodule
