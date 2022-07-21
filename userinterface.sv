module userinterface (	input Clk, Win, Lose,
				input [9:0] DrawX, DrawY,
				input [6:0] Score,
				output [2:0] Color_UI
);
	
	logic [6:0] Highest;
	
	parameter [9:0] SCORE_Y_Pos = 10'd60;
	parameter [9:0] SCORE_S_X_Pos = 10'd20;
	parameter [9:0] SCORE_C_X_Pos = 10'd40;
	parameter [9:0] SCORE_O_X_Pos = 10'd60;
	parameter [9:0] SCORE_R_X_Pos = 10'd80;
	parameter [9:0] SCORE_E_X_Pos = 10'd100;
	

	parameter [9:0] HIGHEST_Y_Pos = 10'd140;
	parameter [9:0] HIGHEST_H1_X_Pos = 10'd20;
	parameter [9:0] HIGHEST_I_X_Pos = 10'd40;
	parameter [9:0] HIGHEST_G_X_Pos = 10'd60;
	parameter [9:0] HIGHEST_H2_X_Pos = 10'd80;
	parameter [9:0] HIGHEST_E_X_Pos = 10'd100;
	parameter [9:0] HIGHEST_S_X_Pos = 10'd120;
	parameter [9:0] HIGHEST_T_X_Pos = 10'd140;
	
	parameter [9:0] Score_Num_Y_Pos = 10'd90;
	parameter [9:0] Highest_Num_Y_Pos = 10'd170;
	parameter [9:0] Score_3_X_Pos = 10'd20;
	parameter [9:0] Score_2_X_Pos = 10'd40;
	parameter [9:0] Score_1_X_Pos = 10'd60;
	parameter [9:0] Score_0_X_Pos = 10'd80;
	
	parameter [9:0] YOU_Y_Pos = 10'd280;
	parameter [9:0] YOU_Y_X_Pos = 10'd25;
	parameter [9:0] YOU_O_X_Pos = 10'd75;
	parameter [9:0] YOU_U_X_Pos = 10'd125;
	
	parameter [9:0] WIN_Y_Pos = 10'd360;
	parameter [9:0] WIN_W_X_Pos = 10'd35;
	parameter [9:0] WIN_I_X_Pos = 10'd85;
	parameter [9:0] WIN_N_X_Pos = 10'd135;
	parameter [9:0] LOSE_L_X_Pos = 10'd10;
	parameter [9:0] LOSE_O_X_Pos = 10'd60;
	parameter [9:0] LOSE_S_X_Pos = 10'd110;
	parameter [9:0] LOSE_E_X_Pos = 10'd160;
	
	parameter [4:0] Text_Height = 5'd16;
	parameter [3:0] Text_Width = 4'd8;
	
	int Scaled_X, Scaled_Y;
	logic [31:0] sprite_adress;
	logic [0:7] sprite_data;
	logic text_on, is_text;
	
	logic [6:0] Score_10_bit, Score_1_bit;
	logic [6:0] Highest_10_bit, Highest_1_bit;
	
	assign Score_1_bit = Score%7'd10;
	assign Score_10_bit = Score/7'd10;
	assign Highest_1_bit = Highest%7'd10;
	assign Highest_10_bit = Highest/7'd10;
	
	always_ff @ (posedge Clk)
	begin
		if (Score >= Highest)
			Highest <= Score;
	end
	
	always_comb
	begin
		// Print "SCORE"
		if ( (DrawX >= SCORE_S_X_Pos) && (DrawX < SCORE_S_X_Pos+Text_Width*2)
			&& (DrawY >= SCORE_Y_Pos) && (DrawY < SCORE_Y_Pos+Text_Height*2) )
		begin    
			text_on = 1'b1;
			Scaled_X = (DrawX-SCORE_S_X_Pos)/2;
			Scaled_Y = (DrawY-SCORE_Y_Pos)/2;
			sprite_adress = Scaled_Y + Text_Height*8'd19;
		end
		else if ( (DrawX >= SCORE_C_X_Pos) && (DrawX < SCORE_C_X_Pos+Text_Width*2)
			&& (DrawY >= SCORE_Y_Pos) && (DrawY < SCORE_Y_Pos+Text_Height*2) )
		begin    
			text_on = 1'b1;
			Scaled_X = (DrawX-SCORE_C_X_Pos)/2;
			Scaled_Y = (DrawY-SCORE_Y_Pos)/2;
			sprite_adress = Scaled_Y + Text_Height*8'd3;
		end
		else if ( (DrawX >= SCORE_O_X_Pos) && (DrawX < SCORE_O_X_Pos+Text_Width*2)
			&& (DrawY >= SCORE_Y_Pos) && (DrawY < SCORE_Y_Pos+Text_Height*2) )
		begin    
			text_on = 1'b1;
			Scaled_X = (DrawX-SCORE_O_X_Pos)/2;
			Scaled_Y = (DrawY-SCORE_Y_Pos)/2;
			sprite_adress = Scaled_Y + Text_Height*8'd15;
		end
		else if ( (DrawX >= SCORE_R_X_Pos) && (DrawX < SCORE_R_X_Pos+Text_Width*2)
			&& (DrawY >= SCORE_Y_Pos) && (DrawY < SCORE_Y_Pos+Text_Height*2) )
		begin    
			text_on = 1'b1;
			Scaled_X = (DrawX-SCORE_R_X_Pos)/2;
			Scaled_Y = (DrawY-SCORE_Y_Pos)/2;
			sprite_adress = Scaled_Y + Text_Height*8'd18;
		end
		else if ( (DrawX >= SCORE_E_X_Pos) && (DrawX < SCORE_E_X_Pos+Text_Width*2)
			&& (DrawY >= SCORE_Y_Pos) && (DrawY < SCORE_Y_Pos+Text_Height*2) )
		begin    
			text_on = 1'b1;
			Scaled_X = (DrawX-SCORE_E_X_Pos)/2;
			Scaled_Y = (DrawY-SCORE_Y_Pos)/2;
			sprite_adress = Scaled_Y + Text_Height*8'd5;
		end
		
		// Print "HIGHEST"
		else if ( (DrawX >= HIGHEST_H1_X_Pos) && (DrawX < HIGHEST_H1_X_Pos+Text_Width*2)
			&& (DrawY >= HIGHEST_Y_Pos) && (DrawY < HIGHEST_Y_Pos+Text_Height*2) )
		begin    
			text_on = 1'b1;
			Scaled_X = (DrawX-HIGHEST_H1_X_Pos)/2;
			Scaled_Y = (DrawY-HIGHEST_Y_Pos)/2;
			sprite_adress = Scaled_Y + Text_Height*8'd8;
		end
		else if ( (DrawX >= HIGHEST_I_X_Pos) && (DrawX < HIGHEST_I_X_Pos+Text_Width*2)
			&& (DrawY >= HIGHEST_Y_Pos) && (DrawY < HIGHEST_Y_Pos+Text_Height*2) )
		begin    
			text_on = 1'b1;
			Scaled_X = (DrawX-HIGHEST_I_X_Pos)/2;
			Scaled_Y = (DrawY-HIGHEST_Y_Pos)/2;
			sprite_adress = Scaled_Y + Text_Height*8'd9;
		end
		else if ( (DrawX >= HIGHEST_G_X_Pos) && (DrawX < HIGHEST_G_X_Pos+Text_Width*2)
			&& (DrawY >= HIGHEST_Y_Pos) && (DrawY < HIGHEST_Y_Pos+Text_Height*2) )
		begin    
			text_on = 1'b1;
			Scaled_X = (DrawX-HIGHEST_G_X_Pos)/2;
			Scaled_Y = (DrawY-HIGHEST_Y_Pos)/2;
			sprite_adress = Scaled_Y + Text_Height*8'd7;
		end
		else if ( (DrawX >= HIGHEST_H2_X_Pos) && (DrawX < HIGHEST_H2_X_Pos+Text_Width*2)
			&& (DrawY >= HIGHEST_Y_Pos) && (DrawY < HIGHEST_Y_Pos+Text_Height*2) )
		begin    
			text_on = 1'b1;
			Scaled_X = (DrawX-HIGHEST_H2_X_Pos)/2;
			Scaled_Y = (DrawY-HIGHEST_Y_Pos)/2;
			sprite_adress = Scaled_Y + Text_Height*8'd8;
		end
		else if ( (DrawX >= HIGHEST_E_X_Pos) && (DrawX < HIGHEST_E_X_Pos+Text_Width*2)
			&& (DrawY >= HIGHEST_Y_Pos) && (DrawY < HIGHEST_Y_Pos+Text_Height*2) )
		begin    
			text_on = 1'b1;
			Scaled_X = (DrawX-HIGHEST_E_X_Pos)/2;
			Scaled_Y = (DrawY-HIGHEST_Y_Pos)/2;
			sprite_adress = Scaled_Y + Text_Height*8'd5;
		end
		else if ( (DrawX >= HIGHEST_S_X_Pos) && (DrawX < HIGHEST_S_X_Pos+Text_Width*2)
			&& (DrawY >= HIGHEST_Y_Pos) && (DrawY < HIGHEST_Y_Pos+Text_Height*2) )
		begin    
			text_on = 1'b1;
			Scaled_X = (DrawX-HIGHEST_S_X_Pos)/2;
			Scaled_Y = (DrawY-HIGHEST_Y_Pos)/2;
			sprite_adress = Scaled_Y + Text_Height*8'd19;
		end
		else if ( (DrawX >= HIGHEST_T_X_Pos) && (DrawX < HIGHEST_T_X_Pos+Text_Width*2)
			&& (DrawY >= HIGHEST_Y_Pos) && (DrawY < HIGHEST_Y_Pos+Text_Height*2) )
		begin    
			text_on = 1'b1;
			Scaled_X = (DrawX-HIGHEST_T_X_Pos)/2;
			Scaled_Y = (DrawY-HIGHEST_Y_Pos)/2;
			sprite_adress = Scaled_Y + Text_Height*8'd20;
		end

		else if ( (DrawX >= Score_3_X_Pos) && (DrawX < Score_3_X_Pos+Text_Width*2)
			&& (DrawY >= Score_Num_Y_Pos) && (DrawY < Score_Num_Y_Pos+Text_Height*2) )
		begin    
			text_on = 1'b1;
			Scaled_X = (DrawX-Score_3_X_Pos)/2;
			Scaled_Y = (DrawY-Score_Num_Y_Pos)/2;
			sprite_adress = Scaled_Y + Text_Height*(8'd27+Score_10_bit);
		end
		else if ( (DrawX >= Score_2_X_Pos) && (DrawX < Score_2_X_Pos+Text_Width*2)
			&& (DrawY >= Score_Num_Y_Pos) && (DrawY < Score_Num_Y_Pos+Text_Height*2) )
		begin    
			text_on = 1'b1;
			Scaled_X = (DrawX-Score_2_X_Pos)/2;
			Scaled_Y = (DrawY-Score_Num_Y_Pos)/2;
			sprite_adress = Scaled_Y + Text_Height*(8'd27+Score_1_bit);
		end
		else if ( (DrawX >= Score_1_X_Pos) && (DrawX < Score_1_X_Pos+Text_Width*2)
			&& (DrawY >= Score_Num_Y_Pos) && (DrawY < Score_Num_Y_Pos+Text_Height*2) )
		begin    
			text_on = 1'b1;
			Scaled_X = (DrawX-Score_1_X_Pos)/2;
			Scaled_Y = (DrawY-Score_Num_Y_Pos)/2;
			sprite_adress = Scaled_Y + Text_Height*8'd27;
		end
		else if ( (DrawX >= Score_0_X_Pos) && (DrawX < Score_0_X_Pos+Text_Width*2)
			&& (DrawY >= Score_Num_Y_Pos) && (DrawY < Score_Num_Y_Pos+Text_Height*2) )
		begin    
			text_on = 1'b1;
			Scaled_X = (DrawX-Score_0_X_Pos)/2;
			Scaled_Y = (DrawY-Score_Num_Y_Pos)/2;
			sprite_adress = Scaled_Y + Text_Height*8'd27;
		end
		

		else if ( (DrawX >= Score_3_X_Pos) && (DrawX < Score_3_X_Pos+Text_Width*2)
			&& (DrawY >= Highest_Num_Y_Pos) && (DrawY < Highest_Num_Y_Pos+Text_Height*2) )
		begin    
			text_on = 1'b1;
			Scaled_X = (DrawX-Score_3_X_Pos)/2;
			Scaled_Y = (DrawY-Highest_Num_Y_Pos)/2;
			sprite_adress = Scaled_Y + Text_Height*(8'd27+Highest_10_bit);
		end
		else if ( (DrawX >= Score_2_X_Pos) && (DrawX < Score_2_X_Pos+Text_Width*2)
			&& (DrawY >= Highest_Num_Y_Pos) && (DrawY < Highest_Num_Y_Pos+Text_Height*2) )
		begin    
			text_on = 1'b1;
			Scaled_X = (DrawX-Score_2_X_Pos)/2;
			Scaled_Y = (DrawY-Highest_Num_Y_Pos)/2;
			sprite_adress = Scaled_Y + Text_Height*(8'd27+Highest_1_bit);
		end
		else if ( (DrawX >= Score_1_X_Pos) && (DrawX < Score_1_X_Pos+Text_Width*2)
			&& (DrawY >= Highest_Num_Y_Pos) && (DrawY < Highest_Num_Y_Pos+Text_Height*2) )
		begin    
			text_on = 1'b1;
			Scaled_X = (DrawX-Score_1_X_Pos)/2;
			Scaled_Y = (DrawY-Highest_Num_Y_Pos)/2;
			sprite_adress = Scaled_Y + Text_Height*8'd27;
		end
		else if ( (DrawX >= Score_0_X_Pos) && (DrawX < Score_0_X_Pos+Text_Width*2)
			&& (DrawY >= Highest_Num_Y_Pos) && (DrawY < Highest_Num_Y_Pos+Text_Height*2) )
		begin    
			text_on = 1'b1;
			Scaled_X = (DrawX-Score_0_X_Pos)/2;
			Scaled_Y = (DrawY-Highest_Num_Y_Pos)/2;
			sprite_adress = Scaled_Y + Text_Height*8'd27;
		end
		
		else if (Lose)
		begin
			if ( (DrawX >= YOU_Y_X_Pos) && (DrawX < YOU_Y_X_Pos+Text_Width*5)
			&& (DrawY >= YOU_Y_Pos) && (DrawY < YOU_Y_Pos+Text_Height*5) )
			begin    
				text_on = 1'b1;
				Scaled_X = (DrawX-YOU_Y_X_Pos)/5;
				Scaled_Y = (DrawY-YOU_Y_Pos)/5;
				sprite_adress = Scaled_Y + Text_Height*8'd25;
			end
			else if ( (DrawX >= YOU_O_X_Pos) && (DrawX < YOU_O_X_Pos+Text_Width*5)
			&& (DrawY >= YOU_Y_Pos) && (DrawY < YOU_Y_Pos+Text_Height*5) )
			begin
				text_on = 1'b1;
				Scaled_X = (DrawX-YOU_O_X_Pos)/5;
				Scaled_Y = (DrawY-YOU_Y_Pos)/5;
				sprite_adress = Scaled_Y + Text_Height*8'd15;
			end
			else if ( (DrawX >= YOU_U_X_Pos) && (DrawX < YOU_U_X_Pos+Text_Width*5)
			&& (DrawY >= YOU_Y_Pos) && (DrawY < YOU_Y_Pos+Text_Height*5) )
			begin    
				text_on = 1'b1;
				Scaled_X = (DrawX-YOU_U_X_Pos)/5;
				Scaled_Y = (DrawY-YOU_Y_Pos)/5;
				sprite_adress = Scaled_Y + Text_Height*8'd21;
			end
			else if ( (DrawX >= LOSE_L_X_Pos) && (DrawX < LOSE_L_X_Pos+Text_Width*5)
			&& (DrawY >= WIN_Y_Pos) && (DrawY < WIN_Y_Pos+Text_Height*5) )
			begin    
				text_on = 1'b1;
				Scaled_X = (DrawX-LOSE_L_X_Pos)/5;
				Scaled_Y = (DrawY-WIN_Y_Pos)/5;
				sprite_adress = Scaled_Y + Text_Height*8'd12;
			end
			else if ( (DrawX >= LOSE_O_X_Pos) && (DrawX < LOSE_O_X_Pos+Text_Width*5)
			&& (DrawY >= WIN_Y_Pos) && (DrawY < WIN_Y_Pos+Text_Height*5) )
			begin    
				text_on = 1'b1;
				Scaled_X = (DrawX-LOSE_O_X_Pos)/5;
				Scaled_Y = (DrawY-WIN_Y_Pos)/5;
				sprite_adress = Scaled_Y + Text_Height*8'd15;
			end
			else if ( (DrawX >= LOSE_S_X_Pos) && (DrawX < LOSE_S_X_Pos+Text_Width*5)
			&& (DrawY >= WIN_Y_Pos) && (DrawY < WIN_Y_Pos+Text_Height*5) )
			begin    
				text_on = 1'b1;
				Scaled_X = (DrawX-LOSE_S_X_Pos)/5;
				Scaled_Y = (DrawY-WIN_Y_Pos)/5;
				sprite_adress = Scaled_Y + Text_Height*8'd19;
			end
			else if ( (DrawX >= LOSE_E_X_Pos) && (DrawX < LOSE_E_X_Pos+Text_Width*5)
			&& (DrawY >= WIN_Y_Pos) && (DrawY < WIN_Y_Pos+Text_Height*5) )
			begin    
				text_on = 1'b1;
				Scaled_X = (DrawX-LOSE_E_X_Pos)/5;
				Scaled_Y = (DrawY-WIN_Y_Pos)/5;
				sprite_adress = Scaled_Y + Text_Height*8'd5;
			end
			else
			begin
				text_on = 1'b0;
				Scaled_X = 0;
				Scaled_Y = 0;
				sprite_adress = 10'b0;
			end
			
			
		end
		
		else if (Win)
		begin
			if ( (DrawX >= YOU_Y_X_Pos) && (DrawX < YOU_Y_X_Pos+Text_Width*5)
			&& (DrawY >= YOU_Y_Pos) && (DrawY < YOU_Y_Pos+Text_Height*5) )
			begin    
				text_on = 1'b1;
				Scaled_X = (DrawX-YOU_Y_X_Pos)/5;
				Scaled_Y = (DrawY-YOU_Y_Pos)/5;
				sprite_adress = Scaled_Y + Text_Height*8'd25;
			end
			else if ( (DrawX >= YOU_O_X_Pos) && (DrawX < YOU_O_X_Pos+Text_Width*5)
			&& (DrawY >= YOU_Y_Pos) && (DrawY < YOU_Y_Pos+Text_Height*5) )
			begin
				text_on = 1'b1;
				Scaled_X = (DrawX-YOU_O_X_Pos)/5;
				Scaled_Y = (DrawY-YOU_Y_Pos)/5;
				sprite_adress = Scaled_Y + Text_Height*8'd15;
			end
			else if ( (DrawX >= YOU_U_X_Pos) && (DrawX < YOU_U_X_Pos+Text_Width*5)
			&& (DrawY >= YOU_Y_Pos) && (DrawY < YOU_Y_Pos+Text_Height*5) )
			begin    
				text_on = 1'b1;
				Scaled_X = (DrawX-YOU_U_X_Pos)/5;
				Scaled_Y = (DrawY-YOU_Y_Pos)/5;
				sprite_adress = Scaled_Y + Text_Height*8'd21;
			end
			else if ( (DrawX >= WIN_W_X_Pos) && (DrawX < WIN_W_X_Pos+Text_Width*5)
			&& (DrawY >= WIN_Y_Pos) && (DrawY < WIN_Y_Pos+Text_Height*5) )
			begin    
				text_on = 1'b1;
				Scaled_X = (DrawX-WIN_W_X_Pos)/5;
				Scaled_Y = (DrawY-WIN_Y_Pos)/5;
				sprite_adress = Scaled_Y + Text_Height*8'd23;
			end
			else if ( (DrawX >= WIN_I_X_Pos) && (DrawX < WIN_I_X_Pos+Text_Width*5)
			&& (DrawY >= WIN_Y_Pos) && (DrawY < WIN_Y_Pos+Text_Height*5) )
			begin    
				text_on = 1'b1;
				Scaled_X = (DrawX-WIN_I_X_Pos)/5;
				Scaled_Y = (DrawY-WIN_Y_Pos)/5;
				sprite_adress = Scaled_Y + Text_Height*8'd9;
			end
			else if ( (DrawX >= WIN_N_X_Pos) && (DrawX < WIN_N_X_Pos+Text_Width*5)
			&& (DrawY >= WIN_Y_Pos) && (DrawY < WIN_Y_Pos+Text_Height*5) )
			begin    
				text_on = 1'b1;
				Scaled_X = (DrawX-WIN_N_X_Pos)/5;
				Scaled_Y = (DrawY-WIN_Y_Pos)/5;
				sprite_adress = Scaled_Y + Text_Height*8'd14;
			end
			else
			begin
				text_on = 1'b0;
				Scaled_X = 0;
				Scaled_Y = 0;
				sprite_adress = 10'b0;
			end
		end
			
		else
		begin
			text_on = 1'b0;
			Scaled_X = 0;
			Scaled_Y = 0;
			sprite_adress = 10'b0;
		end
		
		if (text_on==1'b1 && sprite_data[Scaled_X]== 1'b1)
			is_text = 1'b1;
		else
			is_text = 1'b0;
	
		if (DrawX<=10'd214 && DrawX>=10'd210 && DrawY<=10'd451 && DrawY>=10'd30)
			Color_UI = 3'd111;
		else if (DrawX<=10'd554 && DrawX>=10'd550 && DrawY<=10'd451 && DrawY>=10'd30)
			Color_UI = 3'd111;
		else if (DrawX<=10'd554 && DrawX>=10'd210 && DrawY<=10'd455 && DrawY>=10'd451)
			Color_UI = 3'd111;
		else if (is_text)
			Color_UI = 3'b111;
		else
			Color_UI = 3'd000;
	end
	
	alphabet_rom game_select(.addr(sprite_adress), .data(sprite_data));
	
endmodule
			