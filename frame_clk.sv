module frame_clk_generator (input frame_clk_in,      // pixel clock
								  Reset,
							input [6:0] Fall_Count,
							output frame_clk_out
);
	
	logic [6:0] counter, counter_in;
	logic counter_total;
	
	always_ff @ (posedge frame_clk_in)
	begin
		if (Reset)
			counter <= 7'd0;
		else
			counter <= counter_in;
	end
	
	always_comb
	begin
		if (counter <= 7'd10)
			frame_clk_out = 1'b1;
		else
			frame_clk_out = 1'b0;
		
		if (Fall_Count <= 7'd70)
		begin
			if (counter+Fall_Count >= 7'd90)
				counter_in = 7'd0;
			else
				counter_in = counter + 7'd1;
		end
		else
		begin
			if (counter >= 7'd20)
				counter_in = 7'd0;
			else
				counter_in = counter + 7'd1;
		end
			
	end
	
endmodule