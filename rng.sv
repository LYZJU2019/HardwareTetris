module randnumbergenerator (input Clk,
				input frame_clk,
				input Reset,
				output [2:0] randnum
	);
	
	logic frame_clk_prev, frame_clk_rising_edge;
	always_ff @ (posedge Clk)
	begin
		frame_clk_prev <= frame_clk;
		frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_prev == 1'b0);
	
		if (Reset)
			randnum <= 3'b111;
		else if (randnum == 3'b000)
			randnum <= 3'b111;
		else if (frame_clk_rising_edge)
		begin
			randnum[2] <= randnum[1];
			randnum[1] <= randnum[0]^randnum[2];
			randnum[0] <= randnum[2];
		end
	end	
	
endmodule
