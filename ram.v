module ram(clk, cen, wen, s_addr, s_din, s_dout); // top module
	input clk, cen, wen;
	input [7:0] s_addr;
	input [63:0] s_din;
	
	output reg [63:0] s_dout;
	
	reg [63:0] mem [0:255]; // memory declaration
	reg [31:0] i; // == integer i

	parameter READ = 2'b10;
	parameter WRITE = 2'b11; // state
	
	initial begin
		for (i = 0; i < 256; i = i + 1) mem[i] = 64'b0; // memory initialization
	end

	always @(posedge clk) begin // sync read, write
		casex({cen, wen})
		{1'b0, 1'bx}: s_dout <= 64'b0; // chip unable
		READ: s_dout <= mem[s_addr]; // read
		WRITE: begin
			mem[s_addr] <= s_din; // write, dout will be 32'b0
			s_dout <= 64'b0;
		end
		default: s_dout <= 64'bx; // for debugging
		endcase
	end
	
endmodule
