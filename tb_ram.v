`timescale 1ns/100ps
module tb_ram; // testbench ram
	reg tb_clk, tb_cen, tb_wen;
	reg [7:0] tb_s_addr;
	reg [63:0] tb_s_din;
	
	wire [63:0] tb_s_dout;
	
	ram U0_ram(.clk(tb_clk), .cen(tb_cen), .wen(tb_wen), .s_addr(tb_s_addr), .s_din(tb_s_din), .s_dout(tb_s_dout));
	// instance
	always begin
		#5 tb_clk = ~tb_clk; // clk period: 10ns
	end
	
	initial begin
		tb_clk = 1'b1; tb_cen = 1'b0; tb_wen = 1'b0; tb_s_addr = 8'b0; tb_s_din = 64'h0000ffff; #15; // chip unable
		tb_cen = 1'b1; #10; // read mem[0]
		tb_s_addr = 8'h3f; #10; // read mem[3f]
		tb_s_addr = 8'hff; #10; // read mem[ff]
		tb_wen = 1'b1; tb_s_addr = 8'b0; #10; // write to mem[0]
		tb_s_addr = 8'h3f; tb_s_din = 64'h00ffff00; #10; // write to mem[3f]
		tb_s_addr = 8'hff; tb_s_din = 64'hffff0000; #10; // write to mem[ff]
		tb_wen = 1'b0; tb_s_addr = 8'b0; #10; // read mem[0] -> dout == 0000ffff
		tb_s_addr = 8'h3f; #10; // read mem[0f] -> dout == 00ffff00
		tb_s_addr = 8'hff; #10; // read mem[1f] -> dout == ffff0000
		$stop;
	end
	
endmodule
