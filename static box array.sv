module static_box_array ( input Reset,     // reset_h
								Clk,
								frame_clk, 
								Active,

						  // output of block.sv
						  input En_New_Static,                
						  input [3:0][4:0] New_Static_Row,    
						  input [3:0][3:0] New_Static_col,
						  input [2:0] New_Static_Color,
						  input [9:0] DrawX, DrawY,
						  output [2:0] Color_Static,           // inside box, color array; outside box, black
						  output [23:0][15:0] Static_arr,    // 
						  output [6:0] Fall_Count,
						  output [5:0] Line_Count, 
						  output [6:0] Score,
						  output Win, Lose
);

	logic [23:0][15:0][2:0]	color_arr;

	logic [15:0][9:0]	Box_X_C;
	logic [23:0][9:0]	Box_Y_C;
	logic [23:0][5:0] Line_Counter;
	logic [5:0] Line_count_prev;
	
	assign Box_X_C[0] = 10'd225;
	assign Box_X_C[1] = 10'd246;
	assign Box_X_C[2] = 10'd267;
	assign Box_X_C[3] = 10'd288;
	assign Box_X_C[4] = 10'd309;
	assign Box_X_C[5] = 10'd330;
	assign Box_X_C[6] = 10'd351;
	assign Box_X_C[7] = 10'd372;
	assign Box_X_C[8] = 10'd393;
	assign Box_X_C[9] = 10'd414;
	assign Box_X_C[10] = 10'd435;
	assign Box_X_C[11] = 10'd456;
	assign Box_X_C[12] = 10'd477;
	assign Box_X_C[13] = 10'd498;
	assign Box_X_C[14] = 10'd519;
	assign Box_X_C[15] = 10'd540;
	
	
	assign Box_Y_C[4] = 10'd41;
	assign Box_Y_C[5] = 10'd62;
	assign Box_Y_C[6] = 10'd83;
	assign Box_Y_C[7] = 10'd104;
	assign Box_Y_C[8] = 10'd125;
	assign Box_Y_C[9] = 10'd146;
	assign Box_Y_C[10] = 10'd167;
	assign Box_Y_C[11] = 10'd188;
	assign Box_Y_C[12] = 10'd209;
	assign Box_Y_C[13] = 10'd230;
	assign Box_Y_C[14] = 10'd251;
	assign Box_Y_C[15] = 10'd272;
	assign Box_Y_C[16] = 10'd293;
	assign Box_Y_C[17] = 10'd314;
	assign Box_Y_C[18] = 10'd335;
	assign Box_Y_C[19] = 10'd356;
	assign Box_Y_C[20] = 10'd377;
	assign Box_Y_C[21] = 10'd398;
	assign Box_Y_C[22] = 10'd419;
	assign Box_Y_C[23] = 10'd440;
	
	// 24 lines in total, add them together to get the total line count
	assign Line_Count = Line_Counter[0]+Line_Counter[1]+Line_Counter[2]+Line_Counter[3]+Line_Counter[4]+Line_Counter[5]+Line_Counter[6]+Line_Counter[7]+Line_Counter[8]+Line_Counter[9]+Line_Counter[10]+Line_Counter[11]+Line_Counter[12]+Line_Counter[13]+Line_Counter[14]+Line_Counter[15]+Line_Counter[16]+Line_Counter[17]+Line_Counter[18]+Line_Counter[19]+Line_Counter[20]+Line_Counter[21]+Line_Counter[22]+Line_Counter[23];
	
	logic frame_clk_prev, frame_clk_rising_edge;
	always_ff @ (posedge Clk)
	begin
		frame_clk_prev <= frame_clk;
		frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_prev == 1'b0);
	end
	
	always_ff @ (posedge Clk)
	begin
		// clear
		if (Reset)
		begin
			for (int i=0; i<24; i++)
			begin
				color_arr[i][15] <= 3'b000;
				color_arr[i][14] <= 3'b000;
				color_arr[i][13] <= 3'b000;
				color_arr[i][12] <= 3'b000;
				color_arr[i][11] <= 3'b000;
				color_arr[i][10] <= 3'b000;
				color_arr[i][9] <= 3'b000;
				color_arr[i][8] <= 3'b000;
				color_arr[i][7] <= 3'b000;
				color_arr[i][6] <= 3'b000;
				color_arr[i][5] <= 3'b000;
				color_arr[i][4] <= 3'b000;
				color_arr[i][3] <= 3'b000;
				color_arr[i][2] <= 3'b000;
				color_arr[i][1] <= 3'b000;
				color_arr[i][0] <= 3'b000;
				Static_arr[i] <= 16'b0;
				Line_Counter[i] <= 6'd0;
			end
			Fall_Count <= 7'd0;
			Score <= 7'd0;
		end

		// if static signal (touch) is set high, read the contents of New_Static_Row and New_Static_col, set color array and static array
		else if (En_New_Static == 1'b1)
		begin
			color_arr[New_Static_Row[0]][New_Static_col[0]] <= New_Static_Color;
			color_arr[New_Static_Row[1]][New_Static_col[1]] <= New_Static_Color;
			color_arr[New_Static_Row[2]][New_Static_col[2]] <= New_Static_Color;
			color_arr[New_Static_Row[3]][New_Static_col[3]] <= New_Static_Color;
			Static_arr[New_Static_Row[0]][New_Static_col[0]] <= 1'b1;
			Static_arr[New_Static_Row[1]][New_Static_col[1]] <= 1'b1;
			Static_arr[New_Static_Row[2]][New_Static_col[2]] <= 1'b1;
			Static_arr[New_Static_Row[3]][New_Static_col[3]] <= 1'b1;
			Fall_Count <= Fall_Count+7'd1;
		end

		// double check this loop...

		for (int k=23; k>0; k--)
		begin
			if ((Static_arr[k]==16'b0) && (Static_arr[k-1]!=16'b0))
			begin
				Static_arr[k] <= Static_arr[k-1];
				Static_arr[k-1] <= 16'b0;
				color_arr[k][15] <= color_arr[k-1][15];
				color_arr[k][14] <= color_arr[k-1][14];
				color_arr[k][13] <= color_arr[k-1][13];
				color_arr[k][12] <= color_arr[k-1][12];
				color_arr[k][11] <= color_arr[k-1][11];
				color_arr[k][10] <= color_arr[k-1][10];
				color_arr[k][9] <= color_arr[k-1][9];
				color_arr[k][8] <= color_arr[k-1][8];
				color_arr[k][7] <= color_arr[k-1][7];
				color_arr[k][6] <= color_arr[k-1][6];
				color_arr[k][5] <= color_arr[k-1][5];
				color_arr[k][4] <= color_arr[k-1][4];
				color_arr[k][3] <= color_arr[k-1][3];
				color_arr[k][2] <= color_arr[k-1][2];
				color_arr[k][1] <= color_arr[k-1][1];
				color_arr[k][0] <= color_arr[k-1][0];
				color_arr[k-1][15] <= 3'b000;
				color_arr[k-1][14] <= 3'b000;
				color_arr[k-1][13] <= 3'b000;
				color_arr[k-1][12] <= 3'b000;
				color_arr[k-1][11] <= 3'b000;
				color_arr[k-1][10] <= 3'b000;
				color_arr[k-1][9] <= 3'b000;
				color_arr[k-1][8] <= 3'b000;
				color_arr[k-1][7] <= 3'b000;
				color_arr[k-1][6] <= 3'b000;
				color_arr[k-1][5] <= 3'b000;
				color_arr[k-1][4] <= 3'b000;
				color_arr[k-1][3] <= 3'b000;
				color_arr[k-1][2] <= 3'b000;
				color_arr[k-1][1] <= 3'b000;
				color_arr[k-1][0] <= 3'b000;
			end
		end
		
		// compute the score according to the number of lines eliminated (no-linear reward)
		if (frame_clk_rising_edge)
		begin
			Line_count_prev <= Line_Count;
			if (Line_Count == Line_count_prev+6'd1)
				Score <= Score+7'd1;
			else if (Line_Count == Line_count_prev+6'd2)
				Score <= Score+7'd3;
			else if (Line_Count == Line_count_prev+6'd3)
				Score <= Score+7'd6;
			else if (Line_Count == Line_count_prev+6'd4)
				Score <= Score+7'd10;
				
			for (int i=23; i>3; i--)
			begin
				if ((Static_arr[i]==16'b0) && (color_arr[i][0]==3'b111))
				begin
					Static_arr[i] <= 16'b0;
					color_arr[i][15] <= 3'b0;
					color_arr[i][14] <= 3'b0;
					color_arr[i][13] <= 3'b0;
					color_arr[i][12] <= 3'b0;
					color_arr[i][11] <= 3'b0;
					color_arr[i][10] <= 3'b0;
					color_arr[i][9] <= 3'b0;
					color_arr[i][8] <= 3'b0;
					color_arr[i][7] <= 3'b0;
					color_arr[i][6] <= 3'b0;
					color_arr[i][5] <= 3'b0;
					color_arr[i][4] <= 3'b0;
					color_arr[i][3] <= 3'b0;
					color_arr[i][2] <= 3'b0;
					color_arr[i][1] <= 3'b0;
					color_arr[i][0] <= 3'b0;
				end
			
				else if (color_arr[i][0] == 3'b111 && Static_arr[i]==16'b1111111111111111)
				begin
					Static_arr[i] <= 16'b0;
					Line_Counter[i] <= Line_Counter[i]+6'd1;
				end
				
				else if (Static_arr[i]==16'b1111111111111111)
				begin
					color_arr[i][15] <= 3'b111;
					color_arr[i][14] <= 3'b111;
					color_arr[i][13] <= 3'b111;
					color_arr[i][12] <= 3'b111;
					color_arr[i][11] <= 3'b111;
					color_arr[i][10] <= 3'b111;
					color_arr[i][9] <= 3'b111;
					color_arr[i][8] <= 3'b111;
					color_arr[i][7] <= 3'b111;
					color_arr[i][6] <= 3'b111;
					color_arr[i][5] <= 3'b111;
					color_arr[i][4] <= 3'b111;
					color_arr[i][3] <= 3'b111;
					color_arr[i][2] <= 3'b111;
					color_arr[i][1] <= 3'b111;
					color_arr[i][0] <= 3'b111;
				end
			end
		end
	end

	int Row,Column;
	assign Row = (DrawY-10'd31)/10'd21+10'd4;
	assign Column = (DrawX-10'd215)/10'd21;
	
   int DistX, DistY, Size;
   assign DistX = DrawX - Box_X_C[Column];
   assign DistY = DrawY - Box_Y_C[Row];
   assign Size = 10'd9;
   always_comb
	begin
       if ( (DistX*DistX<=Size*Size) && (DistY*DistY<=Size*Size) )
           Color_Static = color_arr[Row][Column];
		 
       else
           Color_Static = 3'b000;
			 
		if (Static_arr[3] != 16'b0)
		begin
			Win = 1'b0;
			Lose = 1'b1;
		end
		else if (Line_Count >= 6'd36)
		begin
			Win = 1'b1;
			Lose = 1'b0;
		end
		else
		begin
			Win = 1'b0;
			Lose = 1'b0;
		end
   end
endmodule

module total_dynamic (	        input [2:0] Color_O_Block,     // output of block.color_dynamic
						        input	En_O_block,                  // output of block.En_New_Static
						        input [2:0] State_O_block,           // output of block.State_onehot (one hot encoding)
						        input [3:0][4:0] New_Static_Row_O,     // output of block.New_Static_Row
								input [3:0][3:0] New_Static_col_O,  // output of block.New_Static_col
								
								input [2:0] Color_T_Block,
								input	En_T_block, 
								input [2:0] State_T_block,
								input [3:0][4:0] New_Static_Row_T,
								input [3:0][3:0] New_Static_col_T,
								
								
								input [2:0] Color_I_Block,
								input	En_I_block,
								input [2:0] State_I_block,
								input [3:0][4:0] New_Static_Row_I,
								input [3:0][3:0] New_Static_col_I,

								
								input [2:0] Color_RF_Block,
								input	En_RF_block,
								input [2:0] State_RF_block,
								input [3:0][4:0] New_Static_Row_RF,
								input [3:0][3:0] New_Static_col_RF,

																
								input [2:0] Color_RL_Block,
								input	En_RL_block,
								input [2:0] State_RL_block,
								input [3:0][4:0] New_Static_Row_RL,
								input [3:0][3:0] New_Static_col_RL,

								
								input [2:0] Color_LF_Block,
								input	En_LF_block,
								input [2:0] State_LF_block,
								input [3:0][4:0] New_Static_Row_LF,
								input [3:0][3:0] New_Static_col_LF,
								
								
								input [2:0] Color_LL_Block,
								input	En_LL_block,
								input [2:0] State_LL_block,
								input [3:0][4:0] New_Static_Row_LL,
								input [3:0][3:0] New_Static_col_LL,
								
								output En_New_Static,         // tells the static_box_array whether an update is necessary
								output [2:0] Game_State,      // determines the next activate signal
								output [2:0] Color_Dynamic,   // combines the above six color_dynamic input and determines the output according to En signals (a mux)
								output [3:0][4:0] New_Static_Row,  // combines the above six New_static_row (also like a mux)
								output [3:0][3:0] New_Static_col,  // combines the above six New_Static_col (also mux ...)
								output [2:0] New_Static_Color  // write if one of En cur_State is high, black otherwise
	);
	
	
	assign En_New_Static = En_O_block | En_T_block | En_I_block | En_RF_block | En_RL_block | En_LF_block | En_LL_block;
	
	// generate next activate signal IFF the previous block is in Halt cur_State
	assign Game_State[2] = State_O_block[2] | State_T_block[2] | State_RL_block[2] | State_RF_block[2] | State_LL_block[2] | State_LF_block[2] | State_I_block[2];  // 1 if one (or more) blocks touch
	assign Game_State[1] = State_O_block[1] | State_T_block[1] | State_RL_block[1] | State_RF_block[1] | State_LL_block[1] | State_LF_block[1] | State_I_block[1];  // 1 if one (or more) blocks FALL
	assign Game_State[0] = (~Game_State[2]) && (~Game_State[1]);    // this bit is necessary to determine the next activated block (see kbinput.sv)
	
	// code is lengthy but it just combines all cases together ...
	always_comb
	begin
		if (En_O_block)
		begin 
			Color_Dynamic = Color_O_Block;
			New_Static_Color = 3'b111;
			New_Static_Row[0] = New_Static_Row_O[0];
			New_Static_Row[1] = New_Static_Row_O[1];
			New_Static_Row[2] = New_Static_Row_O[2];
			New_Static_Row[3] = New_Static_Row_O[3];
			New_Static_col[0] = New_Static_col_O[0];
			New_Static_col[1] = New_Static_col_O[1];
			New_Static_col[2] = New_Static_col_O[2];
			New_Static_col[3] = New_Static_col_O[3];
		end
		
		else if (En_T_block)
		begin
			Color_Dynamic = Color_T_Block;
			New_Static_Color = 3'b111;
			New_Static_Row[0] = New_Static_Row_T[0];
			New_Static_Row[1] = New_Static_Row_T[1];
			New_Static_Row[2] = New_Static_Row_T[2];
			New_Static_Row[3] = New_Static_Row_T[3];
			New_Static_col[0] = New_Static_col_T[0];
			New_Static_col[1] = New_Static_col_T[1];
			New_Static_col[2] = New_Static_col_T[2];
			New_Static_col[3] = New_Static_col_T[3];
		end
		
		else if (En_I_block)
		begin
			Color_Dynamic = Color_I_Block;
			New_Static_Color = 3'b111;
			New_Static_Row[0] = New_Static_Row_I[0];
			New_Static_Row[1] = New_Static_Row_I[1];
			New_Static_Row[2] = New_Static_Row_I[2];
			New_Static_Row[3] = New_Static_Row_I[3];
			New_Static_col[0] = New_Static_col_I[0];
			New_Static_col[1] = New_Static_col_I[1];
			New_Static_col[2] = New_Static_col_I[2];
			New_Static_col[3] = New_Static_col_I[3];
		end
		
		else if (En_LL_block)
		begin
			Color_Dynamic = Color_LL_Block;
			New_Static_Color = 3'b111;
			New_Static_Row[0] = New_Static_Row_LL[0];
			New_Static_Row[1] = New_Static_Row_LL[1];
			New_Static_Row[2] = New_Static_Row_LL[2];
			New_Static_Row[3] = New_Static_Row_LL[3];
			New_Static_col[0] = New_Static_col_LL[0];
			New_Static_col[1] = New_Static_col_LL[1];
			New_Static_col[2] = New_Static_col_LL[2];
			New_Static_col[3] = New_Static_col_LL[3];
		end
		
		else if (En_RL_block)
		begin
			Color_Dynamic = Color_T_Block;
			New_Static_Color = 3'b111;
			New_Static_Row[0] = New_Static_Row_RL[0];
			New_Static_Row[1] = New_Static_Row_RL[1];
			New_Static_Row[2] = New_Static_Row_RL[2];
			New_Static_Row[3] = New_Static_Row_RL[3];
			New_Static_col[0] = New_Static_col_RL[0];
			New_Static_col[1] = New_Static_col_RL[1];
			New_Static_col[2] = New_Static_col_RL[2];
			New_Static_col[3] = New_Static_col_RL[3];
		end
		
		else if (En_LF_block)
		begin
			Color_Dynamic = Color_T_Block;
			New_Static_Color = 3'b111;
			New_Static_Row[0] = New_Static_Row_LF[0];
			New_Static_Row[1] = New_Static_Row_LF[1];
			New_Static_Row[2] = New_Static_Row_LF[2];
			New_Static_Row[3] = New_Static_Row_LF[3];
			New_Static_col[0] = New_Static_col_LF[0];
			New_Static_col[1] = New_Static_col_LF[1];
			New_Static_col[2] = New_Static_col_LF[2];
			New_Static_col[3] = New_Static_col_LF[3];
		end
		
		else if (En_RF_block)
		begin
			Color_Dynamic = Color_T_Block;
			New_Static_Color = 3'b111;
			New_Static_Row[0] = New_Static_Row_RF[0];
			New_Static_Row[1] = New_Static_Row_RF[1];
			New_Static_Row[2] = New_Static_Row_RF[2];
			New_Static_Row[3] = New_Static_Row_RF[3];
			New_Static_col[0] = New_Static_col_RF[0];
			New_Static_col[1] = New_Static_col_RF[1];
			New_Static_col[2] = New_Static_col_RF[2];
			New_Static_col[3] = New_Static_col_RF[3];
		end
		
		else
		begin
			// None of the signal is high ...
			Color_Dynamic = Color_O_Block+Color_T_Block+Color_I_Block+Color_LL_Block+Color_RL_Block+Color_LF_Block+Color_RF_Block;
			New_Static_Color = 3'b000;   // outputs black
			// no static
			New_Static_Row[0] = 5'd0;
			New_Static_Row[1] = 5'd0;
			New_Static_Row[2] = 5'd0;
			New_Static_Row[3] = 5'd0;
			New_Static_col[0] = 4'd0;
			New_Static_col[1] = 4'd0;
			New_Static_col[2] = 4'd0;
			New_Static_col[3] = 4'd0;
		end
	end
	
endmodule
