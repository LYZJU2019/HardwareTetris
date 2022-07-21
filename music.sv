 module music (input logic  Clk,
 				  input logic  [16:0]Addr,
 				  output logic [16:0]music_note);
				  
 	logic [16:0] music_mem [0:54831];
 	initial 
 	begin 
 		$readmemh("final_proj.txt",music_mem);
 	end
	
 	always_ff @ (posedge Clk)
 		begin
 			music_note <= music_mem[Addr];
 		end
 endmodule