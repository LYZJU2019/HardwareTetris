module audio ( input logic Clk, Reset,      // The Reset signal is passed in from toplevel, which is Reset_ah
				  input logic INIT_FINISH,  // output from .vhd file
				  input logic data_over,    // output from .vhd file
				  output logic INIT,        // input to .vhd file
				  output [16:0] Addr         // input to music.sv
);

logic [15:0] counter;
logic [15:0] next_counter;

// WAIT: waiting for .vhd to initialize the audio state
// RUN: playing the music
enum logic {WAIT,RUN} current_state, next_state;
logic [16:0] next_Addr;


always_ff @ (posedge Clk)
	begin
		if (Reset)
		begin
			current_state <= WAIT;
			// # of CLK cycles for each note (controls the speed)
			counter <= 16'd0;
			// Address pointer (we have 54831 notes in total, 17 bits will be enough)
			Addr <= 17'd0;
		end
		else
		begin
			// next state value by default
			current_state <= next_state;
			counter <= next_counter;
			Addr <= next_Addr;
		end
	end
		
always_comb
	begin
		unique case(current_state)
			WAIT:
				begin
					// wait until .vhd file finishes initializing ...
					if (INIT_FINISH == 4'd01)
						begin
							next_state = RUN;
						end
					else
						begin
							next_state = WAIT;		
						end
					// Set default values here ...
					INIT = 4'd01;	
					next_counter = 16'd0;
					next_Addr = 17'd0;
				end

				
			
			RUN:
			begin 
				next_state = RUN;
				INIT = 4'd01;

				// controls the speed of music (each note persists for 91 clock cycles)
				if (counter<16'd91 )
					next_counter = counter+16'd1;
				else
					next_counter = 16'd0;
				
				// next_Addr points at the next note when current note finished
				if (counter==16'd90 && Addr<=17'd54831 && data_over!=0)
					next_Addr = Addr+17'd1;
			    // points at current note if current note is playing
				else if (Addr < 17'd54831)
					next_Addr = Addr;
				// points at the beginning when music finishes
				else
					next_Addr = 17'd0;
			end	
		
		default: ;
		endcase	
	end

endmodule

