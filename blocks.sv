// The T-shaped Block
module T_block ( input Clk,
					   frame_clk, // refresh when frame_clk is high
					   Reset,     // pass reset_h in
					   Active,    
					   LEFT, RIGHT, UP, DOWN, NULL, // signals from keyboard
				 input [9:0] DrawX, DrawY,
				 input [23:0][15:0] Static_arr,
				 output En_New_Static,                 // signal indicates whether the T block have become parts of the background
				 output [3:0][4:0] New_Static_Row,     // output to the drawing logic
				 output [3:0][3:0] New_Static_col,  // output to the drawing logic
				 output [2:0] Color_Dynamic,           // RGB signal, passed into static_box_array.sv
				 output [2:0] State_onehot                // one-hot encoding of halt, FALL and touch cur_State
	);
	
	logic [3:0][4:0] Box_Center_initRow;     // stores the initial row index of a T block
	logic [3:0][3:0] Box_Center_initCol;  // stores the initial col index of a T block
	logic [3:0][4:0] Box_Center_curRow;     // stores the current row index of a T block
	logic [3:0][3:0] Box_Center_curCol;  // stores the current col index of a T block
	logic [15:0][9:0] Box_X_C;              // define all possible x-axis of a single box
	logic [23:0][9:0] Box_Y_C;              // define all possible y-axis of a single box
	logic touch;                               // flag indicating whether T block touches the bottom / other static blocks
	
	// Initial Position: Need Modify (to set the initial FALL position to the center of screen)
	//         x(0)
	//    x(1) x(2) x(3)

	assign Box_Center_initRow[0] = 5'd0;
	assign Box_Center_initRow[1] = 5'd1;
	assign Box_Center_initRow[2] = 5'd1;
	assign Box_Center_initRow[3] = 5'd1;
	assign Box_Center_initCol[0] = 4'd7;
	assign Box_Center_initCol[1] = 4'd6;
	assign Box_Center_initCol[2] = 4'd7;
	assign Box_Center_initCol[3] = 4'd8;

	// the current position of a block is integrated into the background (static)
	assign New_Static_Row[0] = Box_Center_curRow[0];
	assign New_Static_Row[1] = Box_Center_curRow[1];
	assign New_Static_Row[2] = Box_Center_curRow[2];
	assign New_Static_Row[3] = Box_Center_curRow[3];
	assign New_Static_col[0] = Box_Center_curCol[0];
	assign New_Static_col[1] = Box_Center_curCol[1];
	assign New_Static_col[2] = Box_Center_curCol[2];
	assign New_Static_col[3] = Box_Center_curCol[3];
	
	// starts from 225, increments by 21
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
	
	// starts from 41, increments by 21
	// noted that the first 4 positions are out of screen (we have to press DOWN button several times to see the block)
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
	
	// define three states:
	//      Halt: Next round, set to initial values
	//   FALL: still FALL down on the screen
	// TOUCH: Do nothing (has become part of the background)

	enum logic [2:0] {STOP, FALL, TOUCH}	cur_State, Next_State;

	// rotation states (90-deg, 180-deg, 270-deg)
	logic [1:0]Rot_State;
	
   // Detect rising edge of frame_clk (details refer to lab 8)
	logic frame_clk_prev, frame_clk_rising_edge;
	always_ff @ (posedge Clk)
	begin
		frame_clk_prev <= frame_clk;
		frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_prev == 1'b0);
	end
	
	// 
	always_ff @ (posedge Clk)
	begin
		if (frame_clk_rising_edge)
			case (cur_State)
				STOP:
				begin
					Box_Center_curRow[0] <= Box_Center_initRow[0];
					Box_Center_curRow[1] <= Box_Center_initRow[1];
					Box_Center_curRow[2] <= Box_Center_initRow[2];
					Box_Center_curRow[3] <= Box_Center_initRow[3];
					Box_Center_curCol[0] <= Box_Center_initCol[0];
					Box_Center_curCol[1] <= Box_Center_initCol[1];
					Box_Center_curCol[2] <= Box_Center_initCol[2];
					Box_Center_curCol[3] <= Box_Center_initCol[3];
				end
				
				FALL:
					if (~touch)
					begin
						Box_Center_curRow[0] <= Box_Center_curRow[0]+5'd1;
						Box_Center_curRow[1] <= Box_Center_curRow[1]+5'd1;
						Box_Center_curRow[2] <= Box_Center_curRow[2]+5'd1;
						Box_Center_curRow[3] <= Box_Center_curRow[3]+5'd1;
					end
				
				TOUCH: ;
				default: ;
			endcase
		
		// At first, the block remains the default position (0-deg rotation)
		if (cur_State == STOP)
			Rot_State <= 2'b00;
		
		// Keycodes take effect iff the block is FALL
		else if (cur_State == FALL)
		begin

			// LEFT button
			if (LEFT)
			begin
				if (       (Static_arr[Box_Center_curRow[0]][Box_Center_curCol[0]-4'd1] != 1'b1) // left position has no block
				        && (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]-4'd1] != 1'b1)
						&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]-4'd1] != 1'b1)
						&& (Static_arr[Box_Center_curRow[3]][Box_Center_curCol[3]-4'd1] != 1'b1)

						&& (Box_Center_curCol[0] != 4'd0)   // does not exceeds the left boundary
						&& (Box_Center_curCol[1] != 4'd0)
						&& (Box_Center_curCol[2] != 4'd0)
						&& (Box_Center_curCol[3] != 4'd0)
					)
				begin

					// shift the current block to 1 position left
					Box_Center_curCol[0] <= Box_Center_curCol[0]-4'd1;
					Box_Center_curCol[1] <= Box_Center_curCol[1]-4'd1;
					Box_Center_curCol[2] <= Box_Center_curCol[2]-4'd1;
					Box_Center_curCol[3] <= Box_Center_curCol[3]-4'd1;
				end
			end
			
			// RIGHT button
			else if (RIGHT)
			begin
				if (       (Static_arr[Box_Center_curRow[0]][Box_Center_curCol[0]+4'd1] != 1'b1) // right position has no block
						&& (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]+4'd1] != 1'b1)
						&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]+4'd1] != 1'b1)
						&& (Static_arr[Box_Center_curRow[3]][Box_Center_curCol[3]+4'd1] != 1'b1)

						&& (Box_Center_curCol[0] != 4'd15)   // does not exceeds the right boundary
						&& (Box_Center_curCol[1] != 4'd15)
						&& (Box_Center_curCol[2] != 4'd15)
						&& (Box_Center_curCol[3] != 4'd15)
					)
				begin

					// shift the current block to 1 position right
					Box_Center_curCol[0] <= Box_Center_curCol[0]+4'd1;
					Box_Center_curCol[1] <= Box_Center_curCol[1]+4'd1;
					Box_Center_curCol[2] <= Box_Center_curCol[2]+4'd1;
					Box_Center_curCol[3] <= Box_Center_curCol[3]+4'd1;
				end
			end
			
			else if (DOWN)
			begin
				if (       (Static_arr[Box_Center_curRow[0]+5'd1][Box_Center_curCol[0]] != 1'b1)  // down position has no block
						&& (Static_arr[Box_Center_curRow[1]+5'd1][Box_Center_curCol[1]] != 1'b1)
						&& (Static_arr[Box_Center_curRow[2]+5'd1][Box_Center_curCol[2]] != 1'b1)
						&& (Static_arr[Box_Center_curRow[3]+5'd1][Box_Center_curCol[3]] != 1'b1)

						&& (Box_Center_curRow[0] != 5'd23)   // does not exceeds the bottom boundary
						&& (Box_Center_curRow[1] != 5'd23)
						&& (Box_Center_curRow[2] != 5'd23)
						&& (Box_Center_curRow[3] != 5'd23))
				begin

					// shift the current block to 1 position down
					Box_Center_curRow[0] <= Box_Center_curRow[0]+4'd1;
					Box_Center_curRow[1] <= Box_Center_curRow[1]+4'd1;
					Box_Center_curRow[2] <= Box_Center_curRow[2]+4'd1;
					Box_Center_curRow[3] <= Box_Center_curRow[3]+4'd1;
				end
			end
			
			else if (NULL)
			begin
				if (       (Static_arr[Box_Center_curRow[0]+5'd1][Box_Center_curCol[0]] != 1'b1)   // no keycode pressed, go down by default
						&& (Static_arr[Box_Center_curRow[1]+5'd1][Box_Center_curCol[1]] != 1'b1)
						&& (Static_arr[Box_Center_curRow[2]+5'd1][Box_Center_curCol[2]] != 1'b1)
						&& (Static_arr[Box_Center_curRow[3]+5'd1][Box_Center_curCol[3]] != 1'b1)

						&& (Box_Center_curRow[0] != 5'd23)  // does not exceed the bottom boundary
						&& (Box_Center_curRow[1] != 5'd23)
						&& (Box_Center_curRow[2] != 5'd23)
						&& (Box_Center_curRow[3] != 5'd23))
				begin

					// shift the current block to 1 position down
					Box_Center_curRow[0] <= Box_Center_curRow[0]+5'd1;
					Box_Center_curRow[1] <= Box_Center_curRow[1]+5'd1;
					Box_Center_curRow[2] <= Box_Center_curRow[2]+5'd1;
					Box_Center_curRow[3] <= Box_Center_curRow[3]+5'd1;
				end
			end
			
			else if (UP)   // UP button indicates rotation
			begin

				// current position is 0-deg
				if (Rot_State == 2'b00)
				begin
				
					//         x(0)
	                //    x(1) x(2) x(3)
					//                             x(0)
				    //                     --->    x(2) x(3)
					//                             x(1)

					// as shown above, we only need to check whether 1 position down to the middle block is empty or exceed the boundary
					if (       (Static_arr[Box_Center_curRow[2]+5'd1][Box_Center_curCol[2]] != 1'b1)
					        && (Box_Center_curRow[2] != 5'd23)
					   )
						begin  
							
							// if okay, just modify the position of 1'th block (starting from 0)
							Box_Center_curRow[0] <= Box_Center_curRow[0];
							Box_Center_curRow[1] <= Box_Center_curRow[1]+5'd1;
							Box_Center_curRow[2] <= Box_Center_curRow[2];
							Box_Center_curRow[3] <= Box_Center_curRow[3];

							Box_Center_curCol[0] <= Box_Center_curCol[0];
							Box_Center_curCol[1] <= Box_Center_curCol[1]+4'd1;
							Box_Center_curCol[2] <= Box_Center_curCol[2];
							Box_Center_curCol[3] <= Box_Center_curCol[3];

							// set the cur_State to 1 (has rotated 90-deg)
							Rot_State <= 2'b01;
						end
				end
					
	            // current position is 90-deg
				else if (Rot_State == 2'b01)

				// as the left side is three, consider sliding through the wall
				begin 

					//    x(0)
					//    x(2) x(3)    ---->   x(0) x(2) x(3)
  					//    x(1)                      x(1)

                    // new x(2) aligns to previous x(2), check the left position of previous x(2)
					if  (       (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]-5'd1] != 1'b1)
					         && (Box_Center_curCol[2] >= 1)
					    )

						begin  
							Box_Center_curRow[0] <= Box_Center_curRow[0]+5'd1;
							Box_Center_curRow[1] <= Box_Center_curRow[1];
							Box_Center_curRow[2] <= Box_Center_curRow[2];
							Box_Center_curRow[3] <= Box_Center_curRow[3];
							Box_Center_curCol[0] <= Box_Center_curCol[0]-4'd1;
							Box_Center_curCol[1] <= Box_Center_curCol[1];
							Box_Center_curCol[2] <= Box_Center_curCol[2];
							Box_Center_curCol[3] <= Box_Center_curCol[3];
							Rot_State <= 2'b10;
						end
					
					//    |x(0)
					//    |x(2) x(3)    ---->   |x(0) x(2) x(3)
  					//    |x(1)                       x(1)

					// new x(0) aligns to previous x(2), check the right and down position of previous x(3)
					else if (   (Static_arr[Box_Center_curRow[3]][Box_Center_curCol[3]+5'd1] != 1'b1)
					         && (Static_arr[Box_Center_curRow[3]+5'd1][Box_Center_curCol[3]] != 1'b1)
					         && (Box_Center_curCol[2] < 1)
					        )

						begin
							Box_Center_curRow[0] <= Box_Center_curRow[0]+5'd1;
							Box_Center_curRow[1] <= Box_Center_curRow[1];
							Box_Center_curRow[2] <= Box_Center_curRow[2];
							Box_Center_curRow[3] <= Box_Center_curRow[3];
							Box_Center_curCol[0] <= Box_Center_curCol[0];
							Box_Center_curCol[1] <= Box_Center_curCol[1]+4'd1;
							Box_Center_curCol[2] <= Box_Center_curCol[2]+4'd1;
							Box_Center_curCol[3] <= Box_Center_curCol[3]+4'd1;
							Rot_State <= 2'b10;								
						
						end
					
					//    x(0)
					//    x(2) x(3)|    ---->   x(0) x(2) x(3)|
  					//    x(1)                       x(1)

					// new x(0) aligns to previous x(2), check the right and down position of previous x(3)
					else if (   (Static_arr[Box_Center_curRow[3]][Box_Center_curCol[3]+5'd1] != 1'b1)
					         && (Static_arr[Box_Center_curRow[3]+5'd1][Box_Center_curCol[3]] != 1'b1)
					         && (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]-5'd1] == 1'b1)
					         && (Box_Center_curCol[2] <= 7)
					        )
						begin
							Box_Center_curRow[0] <= Box_Center_curRow[0]+5'd1;
							Box_Center_curRow[1] <= Box_Center_curRow[1];
							Box_Center_curRow[2] <= Box_Center_curRow[2];
							Box_Center_curRow[3] <= Box_Center_curRow[3];
							Box_Center_curCol[0] <= Box_Center_curCol[0];
							Box_Center_curCol[1] <= Box_Center_curCol[1]+4'd1;
							Box_Center_curCol[2] <= Box_Center_curCol[2]+4'd1;
							Box_Center_curCol[3] <= Box_Center_curCol[3]+4'd1;
							Rot_State <= 2'b10;								
						
						end
				end
						
				//       x(0) x(2) x(3)                     x(3)
  				//            x(1)          ----->     x(0) x(2)
				//                                          x(1)

				// new x(2) aligns to previous x(2), check the up position of previous x(2)		
				else if (Rot_State == 2'b10)
				begin
					if ( (Static_arr[Box_Center_curRow[2]-5'd1][Box_Center_curCol[2]] != 1'b1) )
						begin  
							
							Box_Center_curRow[0] <= Box_Center_curRow[0];
							Box_Center_curRow[1] <= Box_Center_curRow[1];
							Box_Center_curRow[2] <= Box_Center_curRow[2];
							Box_Center_curRow[3] <= Box_Center_curRow[3]-5'd1;
							Box_Center_curCol[0] <= Box_Center_curCol[0];
							Box_Center_curCol[1] <= Box_Center_curCol[1];
							Box_Center_curCol[2] <= Box_Center_curCol[2];
							Box_Center_curCol[3] <= Box_Center_curCol[3]-4'd1;
							Rot_State <= 2'b11;
						end
				end
				
				else
				begin 
					//        x(3)
				    //   x(0) x(2)    ---->         x(0)
				    //        x(1)             x(1) x(2) x(3)

					// original x(2) aligns to new x(2), check the right position of x(2)
					if  (    (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]+5'd1] != 1'b1)
					      && (Box_Center_curCol[2]<= 8)
					    )
						begin  
							
							Box_Center_curRow[0] <= Box_Center_curRow[0]-5'd1;
							Box_Center_curRow[1] <= Box_Center_curRow[1]-5'd1;
							Box_Center_curRow[2] <= Box_Center_curRow[2];
							Box_Center_curRow[3] <= Box_Center_curRow[3]+5'd1;
							Box_Center_curCol[0] <= Box_Center_curCol[0]+4'd1;
							Box_Center_curCol[1] <= Box_Center_curCol[1]-4'd1;
							Box_Center_curCol[2] <= Box_Center_curCol[2];
							Box_Center_curCol[3] <= Box_Center_curCol[3]+4'd1;
							Rot_State <= 2'b00;
						end
					
					//        x(3)|
				    //   x(0) x(2)|    ---->         x(0)
				    //        x(1)|             x(1) x(2) x(3)|

					// check the left and up position of x(3)
					else if (   (Static_arr[Box_Center_curRow[3]][Box_Center_curCol[3]-5'd1] != 1'b1)
					         && (Static_arr[Box_Center_curRow[3]-5'd1][Box_Center_curCol[3]] != 1'b1)					
					         && (Box_Center_curCol[2] > 8)
					        )
						begin  
							// first next cur_State, only move 1 to right and down
							Box_Center_curRow[0] <= Box_Center_curRow[0]-5'd1;
							Box_Center_curRow[1] <= Box_Center_curRow[1]-5'd1;
							Box_Center_curRow[2] <= Box_Center_curRow[2];
							Box_Center_curRow[3] <= Box_Center_curRow[3]+5'd1;
							Box_Center_curCol[0] <= Box_Center_curCol[0];
							Box_Center_curCol[1] <= Box_Center_curCol[1]-4'd1-4'd1;
							Box_Center_curCol[2] <= Box_Center_curCol[2]-4'd1;
							Box_Center_curCol[3] <= Box_Center_curCol[3];
							Rot_State <= 2'b00;
						end
					
					else if (    (Static_arr[Box_Center_curRow[3]][Box_Center_curCol[3]-5'd1] != 1'b1)
					          && (Static_arr[Box_Center_curRow[3]-5'd1][Box_Center_curCol[3]] != 1'b1)
					          && (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]+5'd1] == 1'b1)
					          && (Box_Center_curCol[2] >= 2)
					        )
						begin  
							// first next cur_State, only move 1 to right and down
							Box_Center_curRow[0] <= Box_Center_curRow[0]-5'd1;
							Box_Center_curRow[1] <= Box_Center_curRow[1]-5'd1;
							Box_Center_curRow[2] <= Box_Center_curRow[2];
							Box_Center_curRow[3] <= Box_Center_curRow[3]+5'd1;
							Box_Center_curCol[0] <= Box_Center_curCol[0];
							Box_Center_curCol[1] <= Box_Center_curCol[1]-4'd1-4'd1;
							Box_Center_curCol[2] <= Box_Center_curCol[2]-4'd1;
							Box_Center_curCol[3] <= Box_Center_curCol[3];
							Rot_State <= 2'b00;
						end
				end	
			end
		end
		
		// if reset signal passed, set to Halt cur_State (initialize)
		if (Reset)
			cur_State <= STOP;
		else 
			cur_State <= Next_State;			
		
	end

	// compute nextrow, used to determine the torch signal
	logic [3:0][4:0] NextRow;
	assign NextRow[0] = Box_Center_curRow[0]+5'd1;
	assign NextRow[1] = Box_Center_curRow[1]+5'd1;
	assign NextRow[2] = Box_Center_curRow[2]+5'd1;
	assign NextRow[3] = Box_Center_curRow[3]+5'd1;
	
	// calculate each row and column, determine which block to draw in turn
	int Row,Column;

	assign Row = (DrawY-10'd31)/10'd21+10'd4; // since row array starts from 4, we plus 4 here
	assign Column = (DrawX-10'd215)/10'd21;
	
    int DistX, DistY, Size;
    assign Size = 10'd9;
	
	// next cur_State logic
	always_comb
	begin
		unique case (cur_State)
			STOP:
			begin
				// once enter HALT cur_State, wait until Active signal to start FALL
				if (Active)
					Next_State = FALL;
				else
					Next_State = STOP;
			end
			
			FALL:
			begin
				if (touch)
				begin
					// wait until the rising edge of frame clk
					if (frame_clk_rising_edge)
						Next_State = TOUCH;
					else
						Next_State = FALL;
				end
				else
					Next_State = FALL;
			end
			
			TOUCH:
			begin
				Next_State = STOP;
			end
			
			// should never reach here ...
			default:
				Next_State = STOP;
		endcase

		// touch detection
		if (Static_arr[NextRow[0]][Box_Center_curCol[0]] == 1'b1)
			touch = 1'b1;
		else if (Static_arr[NextRow[1]][Box_Center_curCol[1]] == 1'b1)
			touch = 1'b1;
		else if (Static_arr[NextRow[2]][Box_Center_curCol[2]] == 1'b1)
			touch = 1'b1;
		else if (Static_arr[NextRow[3]][Box_Center_curCol[3]] == 1'b1)
			touch = 1'b1;
		else if (Box_Center_curRow[0] == 5'd23)
			touch = 1'b1;
		else if (Box_Center_curRow[1] == 5'd23)
			touch = 1'b1;
		else if (Box_Center_curRow[2] == 5'd23)
			touch = 1'b1;
		else if (Box_Center_curRow[3] == 5'd23)
			touch = 1'b1;
		else
			touch = 1'b0;
		
		// En_New_static signal is passed out to determine whether the block becomes parts of background
		case (cur_State)
			STOP:
			begin
				En_New_Static = 1'b0;
				State_onehot = 3'b001;
			end
			FALL:
			begin
				En_New_Static = 1'b0;
				State_onehot = 3'b010;
			end
			TOUCH:
			begin
				En_New_Static = 1'b1;
				State_onehot = 3'b100;
			end
			default: ;
		endcase

		// DistX and DistY is the distance to the center of block!
		if ((Box_Center_curCol[0]==Column)&&(Box_Center_curRow[0]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else if ((Box_Center_curCol[1]==Column)&&(Box_Center_curRow[1]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else if ((Box_Center_curCol[2]==Column)&&(Box_Center_curRow[2]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else if ((Box_Center_curCol[3]==Column)&&(Box_Center_curRow[3]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else
		begin
			DistX = 20;
			DistY = 20;
		end
	end
	
   always_comb
	begin

	   // area inside the block (blue)
       if ( (DistX*DistX<=Size*Size) && (DistY*DistY<=Size*Size) )
           Color_Dynamic = 3'b011;
       
	   // area outside the block (black)
	   else
           Color_Dynamic = 3'b000;
   end
	
endmodule

// The L-shaped Block Right
module RL_block ( input Clk,
							  frame_clk,
							  Reset,
							  Active,
							  LEFT, RIGHT, UP, DOWN, NULL,
					  input [9:0] DrawX, DrawY,
					  input [23:0][15:0] Static_arr,
					  output En_New_Static,
					  output [3:0][4:0] New_Static_Row,
					  output [3:0][3:0] New_Static_col,
					  output [2:0] Color_Dynamic,
					  output [2:0] State_onehot
	);
	
	logic [3:0][4:0] Box_Center_initRow;
	logic [3:0][3:0] Box_Center_initCol;
	logic [3:0][4:0] Box_Center_curRow;
	logic [3:0][3:0] Box_Center_curCol;
	logic touch;
	logic [15:0][9:0] Box_X_C;
	logic [23:0][9:0] Box_Y_C;
	
	// Initial Position: Need Modify
	//     x
	//     x
	//   x x
	assign Box_Center_initRow[0] = 5'd0;
	assign Box_Center_initRow[1] = 5'd1;
	assign Box_Center_initRow[2] = 5'd2;
	assign Box_Center_initRow[3] = 5'd2;
	assign Box_Center_initCol[0] = 4'd8;
	assign Box_Center_initCol[1] = 4'd8;
	assign Box_Center_initCol[2] = 4'd7;
	assign Box_Center_initCol[3] = 4'd8;
	
	// same as previous module
	assign New_Static_Row[0] = Box_Center_curRow[0];
	assign New_Static_Row[1] = Box_Center_curRow[1];
	assign New_Static_Row[2] = Box_Center_curRow[2];
	assign New_Static_Row[3] = Box_Center_curRow[3];
	assign New_Static_col[0] = Box_Center_curCol[0];
	assign New_Static_col[1] = Box_Center_curCol[1];
	assign New_Static_col[2] = Box_Center_curCol[2];
	assign New_Static_col[3] = Box_Center_curCol[3];
	
	// same as previous module
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
	
	// same as previous module
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
	
	enum logic [2:0] {STOP, FALL, TOUCH}	cur_State, Next_State;
	logic [1:0] Rot_State;
	
   // Detect rising edge of frame_clk
	logic frame_clk_prev, frame_clk_rising_edge;
	always_ff @ (posedge Clk)
	begin
		frame_clk_prev <= frame_clk;
		frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_prev == 1'b0);
	end
	
	always_ff @ (posedge Clk)
	begin
		if (frame_clk_rising_edge)
			case (cur_State)
				STOP:
				begin
					Box_Center_curRow[0] <= Box_Center_initRow[0];
					Box_Center_curRow[1] <= Box_Center_initRow[1];
					Box_Center_curRow[2] <= Box_Center_initRow[2];
					Box_Center_curRow[3] <= Box_Center_initRow[3];
					Box_Center_curCol[0] <= Box_Center_initCol[0];
					Box_Center_curCol[1] <= Box_Center_initCol[1];
					Box_Center_curCol[2] <= Box_Center_initCol[2];
					Box_Center_curCol[3] <= Box_Center_initCol[3];
				end
				
				FALL:
					if (~touch)
					begin
						Box_Center_curRow[0] <= Box_Center_curRow[0]+5'd1;
						Box_Center_curRow[1] <= Box_Center_curRow[1]+5'd1;
						Box_Center_curRow[2] <= Box_Center_curRow[2]+5'd1;
						Box_Center_curRow[3] <= Box_Center_curRow[3]+5'd1;
					end
				
				TOUCH: ;
				default: ;
			endcase

		if (cur_State == STOP)
			Rot_State <= 2'b00;
		else if (cur_State == FALL)
			begin
				if (LEFT)
				begin
					if (       (Static_arr[Box_Center_curRow[0]][Box_Center_curCol[0]-4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]-4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]-4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[3]][Box_Center_curCol[3]-4'd1] != 1'b1)
							&& (Box_Center_curCol[0] != 4'd0)
							&& (Box_Center_curCol[1] != 4'd0)
							&& (Box_Center_curCol[2] != 4'd0)
							&& (Box_Center_curCol[3] != 4'd0))
					begin
						Box_Center_curCol[0] <= Box_Center_curCol[0]-4'd1;
						Box_Center_curCol[1] <= Box_Center_curCol[1]-4'd1;
						Box_Center_curCol[2] <= Box_Center_curCol[2]-4'd1;
						Box_Center_curCol[3] <= Box_Center_curCol[3]-4'd1;
					end
				end
				
				else if (RIGHT)
				begin
					if (       (Static_arr[Box_Center_curRow[0]][Box_Center_curCol[0]+4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]+4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]+4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[3]][Box_Center_curCol[3]+4'd1] != 1'b1)
							&& (Box_Center_curCol[0] != 4'd15)
							&& (Box_Center_curCol[1] != 4'd15)
							&& (Box_Center_curCol[2] != 4'd15)
							&& (Box_Center_curCol[3] != 4'd15))
					begin
						Box_Center_curCol[0] <= Box_Center_curCol[0]+4'd1;
						Box_Center_curCol[1] <= Box_Center_curCol[1]+4'd1;
						Box_Center_curCol[2] <= Box_Center_curCol[2]+4'd1;
						Box_Center_curCol[3] <= Box_Center_curCol[3]+4'd1;
					end
				end
				
				else if (DOWN)
				begin
					if (       (Static_arr[Box_Center_curRow[0]+5'd1][Box_Center_curCol[0]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[1]+5'd1][Box_Center_curCol[1]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]+5'd1][Box_Center_curCol[2]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[3]+5'd1][Box_Center_curCol[3]] != 1'b1)
							&& (Box_Center_curRow[0] != 5'd23)
							&& (Box_Center_curRow[1] != 5'd23)
							&& (Box_Center_curRow[2] != 5'd23)
							&& (Box_Center_curRow[3] != 5'd23))
					begin
						Box_Center_curRow[0] <= Box_Center_curRow[0]+4'd1;
						Box_Center_curRow[1] <= Box_Center_curRow[1]+4'd1;
						Box_Center_curRow[2] <= Box_Center_curRow[2]+4'd1;
						Box_Center_curRow[3] <= Box_Center_curRow[3]+4'd1;
					end
				end
				
				else if (NULL)
				begin
					if (       (Static_arr[Box_Center_curRow[0]+5'd1][Box_Center_curCol[0]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[1]+5'd1][Box_Center_curCol[1]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]+5'd1][Box_Center_curCol[2]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[3]+5'd1][Box_Center_curCol[3]] != 1'b1)
							&& (Box_Center_curRow[0] != 5'd23)
							&& (Box_Center_curRow[1] != 5'd23)
							&& (Box_Center_curRow[2] != 5'd23)
							&& (Box_Center_curRow[3] != 5'd23))
					begin
						Box_Center_curRow[0] <= Box_Center_curRow[0]+5'd1;
						Box_Center_curRow[1] <= Box_Center_curRow[1]+5'd1;
						Box_Center_curRow[2] <= Box_Center_curRow[2]+5'd1;
						Box_Center_curRow[3] <= Box_Center_curRow[3]+5'd1;
					end
				end
				
				else if (UP)
					begin						
						if (Rot_State == 2'b00)
						
						begin
							if  (   (Static_arr[Box_Center_curRow[3]][Box_Center_curCol[3]+5'd1] != 1'b1)
							     && (Static_arr[Box_Center_curRow[2]-5'd1][Box_Center_curCol[2]] != 1'b1)
							     && (Box_Center_curCol[1]<= 8)						
							    )
							
								begin  
									Box_Center_curRow[0] <= Box_Center_curRow[0]+4'd2;
									Box_Center_curRow[1] <= Box_Center_curRow[1]+4'd1;
									Box_Center_curRow[2] <= Box_Center_curRow[2]-4'd1;
									Box_Center_curRow[3] <= Box_Center_curRow[3];
									Box_Center_curCol[0] <= Box_Center_curCol[0]+4'd1;
									Box_Center_curCol[1] <= Box_Center_curCol[1];
									Box_Center_curCol[2] <= Box_Center_curCol[2];
									Box_Center_curCol[3] <= Box_Center_curCol[3]-4'd1;
									Rot_State <= 1'b01;
								end
								
							else if (     (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]-5'd2] != 1'b1)
							           && (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]-5'd1] != 1'b1)
							           && (Box_Center_curCol[1] > 8)
							        )
								begin 
									Box_Center_curRow[0] <= Box_Center_curRow[0]+4'd2;
									Box_Center_curRow[1] <= Box_Center_curRow[1]+4'd1;
									Box_Center_curRow[2] <= Box_Center_curRow[2]-4'd1;
									Box_Center_curRow[3] <= Box_Center_curRow[3];
									Box_Center_curCol[0] <= Box_Center_curCol[0]+4'd1-4'd1;
									Box_Center_curCol[1] <= Box_Center_curCol[1]-4'd1;
									Box_Center_curCol[2] <= Box_Center_curCol[2]-4'd1;
									Box_Center_curCol[3] <= Box_Center_curCol[3]-4'd1-4'd1;
									Rot_State <= 1'b01;
								end

							else if (    (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]-5'd2] != 1'b1)
							          && (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]-5'd1] != 1'b1)
							          && (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]+5'd1] == 1'b1)
							          && (Box_Center_curCol[1] >= 2)
							        )
								begin 
									Box_Center_curRow[0] <= Box_Center_curRow[0]+4'd2;
									Box_Center_curRow[1] <= Box_Center_curRow[1]+4'd1;
									Box_Center_curRow[2] <= Box_Center_curRow[2]-4'd1;
									Box_Center_curRow[3] <= Box_Center_curRow[3];
									Box_Center_curCol[0] <= Box_Center_curCol[0]+4'd1-4'd1;
									Box_Center_curCol[1] <= Box_Center_curCol[1]-4'd1;
									Box_Center_curCol[2] <= Box_Center_curCol[2]-4'd1;
									Box_Center_curCol[3] <= Box_Center_curCol[3]-4'd1-4'd1;
									Rot_State <= 1'b01;
								end	
						end
							
	
						else if (Rot_State == 2'b01)
						
							begin 
								if (     (Static_arr[Box_Center_curRow[1]-5'd1][Box_Center_curCol[1]] != 1'b1)
								     &&  (Static_arr[Box_Center_curRow[1]-5'd2][Box_Center_curCol[1]] != 1'b1)
								     &&  (Static_arr[Box_Center_curRow[1]-5'd2][Box_Center_curCol[1]+5'd1] != 1'b1)
								    )
								begin  
									Box_Center_curRow[0] <= Box_Center_curRow[0];
									Box_Center_curRow[1] <= Box_Center_curRow[1]-4'd1;
									Box_Center_curRow[2] <= Box_Center_curRow[2]-4'd1;
									Box_Center_curRow[3] <= Box_Center_curRow[3]-4'd2;
									Box_Center_curCol[0] <= Box_Center_curCol[0]-4'd1;
									Box_Center_curCol[1] <= Box_Center_curCol[1];
									Box_Center_curCol[2] <= Box_Center_curCol[2]+4'd2;
									Box_Center_curCol[3] <= Box_Center_curCol[3]+4'd1;
									Rot_State <= 2'b10;
								end
							end
								
						else if (Rot_State == 2'b10)
							begin
								if  (   (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]-5'd1] != 1'b1)
									 && (Static_arr[Box_Center_curRow[0]][Box_Center_curCol[0]+5'd1] != 1'b1)
									 && (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]+5'd1] != 1'b1)							
									 && (Box_Center_curCol[1] >= 1)
									)
									begin  
										Box_Center_curRow[0] <= Box_Center_curRow[0]-5'd1;
										Box_Center_curRow[1] <= Box_Center_curRow[1];
										Box_Center_curRow[2] <= Box_Center_curRow[2]+5'd2;
										Box_Center_curRow[3] <= Box_Center_curRow[3]+5'd1;
										Box_Center_curCol[0] <= Box_Center_curCol[0]-4'd1;
										Box_Center_curCol[1] <= Box_Center_curCol[1];
										Box_Center_curCol[2] <= Box_Center_curCol[2];
										Box_Center_curCol[3] <= Box_Center_curCol[3]+4'd1;
										Rot_State <= 2'b11;
									end
								else if (    (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]+5'd1] != 1'b1)
									      && (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]+5'd2] != 1'b1)
									      && (Static_arr[Box_Center_curRow[0]][Box_Center_curCol[0]+5'd2] != 1'b1)
									      && (Box_Center_curCol[1] < 1)
									    )
									begin  
										Box_Center_curRow[0] <= Box_Center_curRow[0]-4'd1;
										Box_Center_curRow[1] <= Box_Center_curRow[1];
										Box_Center_curRow[2] <= Box_Center_curRow[2]+4'd2;
										Box_Center_curRow[3] <= Box_Center_curRow[3]+4'd1;
										Box_Center_curCol[0] <= Box_Center_curCol[0]-4'd1+4'd1;
										Box_Center_curCol[1] <= Box_Center_curCol[1]+4'd1;
										Box_Center_curCol[2] <= Box_Center_curCol[2]+4'd1;
										Box_Center_curCol[3] <= Box_Center_curCol[3]+4'd1+4'd1;
										Rot_State <= 2'b11;
									end
									
								else if (    (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]+5'd1] != 1'b1)
									      && (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]+5'd2] != 1'b1)
									      && (Static_arr[Box_Center_curRow[0]][Box_Center_curCol[0]+5'd2] != 1'b1)									
									      && (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]-5'd1] == 1'b1)
									      && (Box_Center_curCol[1] <=7 )
									)
									begin  
										Box_Center_curRow[0] <= Box_Center_curRow[0]-5'd1;
										Box_Center_curRow[1] <= Box_Center_curRow[1];
										Box_Center_curRow[2] <= Box_Center_curRow[2]+5'd2;
										Box_Center_curRow[3] <= Box_Center_curRow[3]+5'd1;
										Box_Center_curCol[0] <= Box_Center_curCol[0]-4'd1+4'd1;
										Box_Center_curCol[1] <= Box_Center_curCol[1]+4'd1;
										Box_Center_curCol[2] <= Box_Center_curCol[2]+4'd1;
										Box_Center_curCol[3] <= Box_Center_curCol[3]+4'd1+4'd1;
										Rot_State <= 2'b11;
									end
							end
						
						

						else
							begin 
								if (   (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]-5'd1] != 1'b1)
									&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]-5'd2] != 1'b1)
									&& (Static_arr[Box_Center_curRow[1]-5'd1][Box_Center_curCol[1]] != 1'b1)
									)
									begin  
										Box_Center_curRow[0] <= Box_Center_curRow[0]-5'd1;
										Box_Center_curRow[1] <= Box_Center_curRow[1];
										Box_Center_curRow[2] <= Box_Center_curRow[2];
										Box_Center_curRow[3] <= Box_Center_curRow[3]+5'd1;
										Box_Center_curCol[0] <= Box_Center_curCol[0]+4'd1;
										Box_Center_curCol[1] <= Box_Center_curCol[1];
										Box_Center_curCol[2] <= Box_Center_curCol[2]-4'd2;
										Box_Center_curCol[3] <= Box_Center_curCol[3]-4'd1;
										Rot_State <= 2'b00;
									end
							end
					
					end 							
			end
			
		if (Reset) 
			cur_State <= STOP;
		else 
			cur_State <= Next_State;			
		
	end
	
	logic [3:0][4:0] NextRow;
	assign NextRow[0] = Box_Center_curRow[0]+5'd1;
	assign NextRow[1] = Box_Center_curRow[1]+5'd1;
	assign NextRow[2] = Box_Center_curRow[2]+5'd1;
	assign NextRow[3] = Box_Center_curRow[3]+5'd1;
	
	int  Row,Column;
	assign Row = (DrawY-10'd31)/10'd21+10'd4;
	assign Column = (DrawX-10'd215)/10'd21;
	
   int DistX, DistY, Size;
   assign Size = 10'd9;
	
	always_comb
	begin
		unique case (cur_State)
			STOP:
			begin
				if (Active)
					Next_State = FALL;
				else
					Next_State = STOP;
			end
			
			FALL:
			begin
				if (touch)
				begin
					if (frame_clk_rising_edge)
						Next_State = TOUCH;
					else
						Next_State = FALL;
				end
				else
					Next_State = FALL;
			end
			
			TOUCH:
			begin
				Next_State = STOP;
			end
			
			default:
				Next_State = STOP;
		endcase

		
		if (Static_arr[NextRow[0]][Box_Center_curCol[0]] == 1'b1)
			touch = 1'b1;
		else if (Static_arr[NextRow[1]][Box_Center_curCol[1]] == 1'b1)
			touch = 1'b1;
		else if (Static_arr[NextRow[2]][Box_Center_curCol[2]] == 1'b1)
			touch = 1'b1;
		else if (Static_arr[NextRow[3]][Box_Center_curCol[3]] == 1'b1)
			touch = 1'b1;
		else if (Box_Center_curRow[0] == 5'd23)
			touch = 1'b1;
		else if (Box_Center_curRow[1] == 5'd23)
			touch = 1'b1;
		else if (Box_Center_curRow[2] == 5'd23)
			touch = 1'b1;
		else if (Box_Center_curRow[3] == 5'd23)
			touch = 1'b1;
		else
			touch = 1'b0;
			
		case (cur_State)
			STOP:
			begin
				En_New_Static = 1'b0;
				State_onehot = 3'b001;
			end
			FALL:
			begin
				En_New_Static = 1'b0;
				State_onehot = 3'b010;
			end
			TOUCH:
			begin
				En_New_Static = 1'b1;
				State_onehot = 3'b100;
			end
			default: ;
		endcase

		if ((Box_Center_curCol[0]==Column)&&(Box_Center_curRow[0]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else if ((Box_Center_curCol[1]==Column)&&(Box_Center_curRow[1]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else if ((Box_Center_curCol[2]==Column)&&(Box_Center_curRow[2]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else if ((Box_Center_curCol[3]==Column)&&(Box_Center_curRow[3]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else
		begin
			DistX = 20;
			DistY = 20;
		end
	end
	
   always_comb
	begin
       if ( (DistX*DistX<=Size*Size) && (DistY*DistY<=Size*Size) )
           Color_Dynamic = 3'b011;
       else
           Color_Dynamic = 3'b000;
   end
	
endmodule

// The Left-folding Block
module RF_block ( input Clk,
							  frame_clk,
							  Reset,
							  Active,
							  LEFT, RIGHT, UP, DOWN, NULL,
					  input [9:0] DrawX, DrawY,
					  input [23:0][15:0] Static_arr,
					  output En_New_Static,
					  output [3:0][4:0] New_Static_Row,
					  output [3:0][3:0] New_Static_col,
					  output [2:0] Color_Dynamic,
					  output [2:0] State_onehot
	);

	
	logic [3:0][4:0] Box_Center_initRow;
	logic [3:0][3:0] Box_Center_initCol;
	logic [3:0][4:0] Box_Center_curRow;
	logic [3:0][3:0] Box_Center_curCol;
	logic touch;
	logic [15:0][9:0] Box_X_C;
	logic [23:0][9:0] Box_Y_C;
	
	// Initial Position: Need Modify
	//      x x
	//    x x

	assign Box_Center_initRow[0] = 5'd0;
	assign Box_Center_initRow[1] = 5'd0;
	assign Box_Center_initRow[2] = 5'd1;
	assign Box_Center_initRow[3] = 5'd1;
	assign Box_Center_initCol[0] = 4'd7;
	assign Box_Center_initCol[1] = 4'd8;
	assign Box_Center_initCol[2] = 4'd6;
	assign Box_Center_initCol[3] = 4'd7;

	// same as previous module
	assign New_Static_Row[0] = Box_Center_curRow[0];
	assign New_Static_Row[1] = Box_Center_curRow[1];
	assign New_Static_Row[2] = Box_Center_curRow[2];
	assign New_Static_Row[3] = Box_Center_curRow[3];
	assign New_Static_col[0] = Box_Center_curCol[0];
	assign New_Static_col[1] = Box_Center_curCol[1];
	assign New_Static_col[2] = Box_Center_curCol[2];
	assign New_Static_col[3] = Box_Center_curCol[3];
	
	// same as previous module
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
	
	// same as previous module
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
	
	enum logic [2:0] {STOP, FALL, TOUCH}	cur_State, Next_State;
	logic Rot_State;
	
   // Detect rising edge of frame_clk
	logic frame_clk_prev, frame_clk_rising_edge;
	always_ff @ (posedge Clk)
	begin
		frame_clk_prev <= frame_clk;
		frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_prev == 1'b0);
	end
	
	always_ff @ (posedge Clk)
	begin
		if (frame_clk_rising_edge)
			case (cur_State)
				STOP:
				begin
					Box_Center_curRow[0] <= Box_Center_initRow[0];
					Box_Center_curRow[1] <= Box_Center_initRow[1];
					Box_Center_curRow[2] <= Box_Center_initRow[2];
					Box_Center_curRow[3] <= Box_Center_initRow[3];
					Box_Center_curCol[0] <= Box_Center_initCol[0];
					Box_Center_curCol[1] <= Box_Center_initCol[1];
					Box_Center_curCol[2] <= Box_Center_initCol[2];
					Box_Center_curCol[3] <= Box_Center_initCol[3];
				end
				
				FALL:
					if (~touch)
					begin
						Box_Center_curRow[0] <= Box_Center_curRow[0]+5'd1;
						Box_Center_curRow[1] <= Box_Center_curRow[1]+5'd1;
						Box_Center_curRow[2] <= Box_Center_curRow[2]+5'd1;
						Box_Center_curRow[3] <= Box_Center_curRow[3]+5'd1;
					end
				
				TOUCH: ;
				default: ;
			endcase
		
		if (cur_State == STOP)
			Rot_State <= 1'b0;
		else if (cur_State == FALL)
			begin
				if (LEFT)
				begin
					if ((Static_arr[Box_Center_curRow[0]][Box_Center_curCol[0]-4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]-4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]-4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[3]][Box_Center_curCol[3]-4'd1] != 1'b1)
							&& (Box_Center_curCol[0] != 4'd0)
							&& (Box_Center_curCol[1] != 4'd0)
							&& (Box_Center_curCol[2] != 4'd0)
							&& (Box_Center_curCol[3] != 4'd0))
					begin
						Box_Center_curCol[0] <= Box_Center_curCol[0]-4'd1;
						Box_Center_curCol[1] <= Box_Center_curCol[1]-4'd1;
						Box_Center_curCol[2] <= Box_Center_curCol[2]-4'd1;
						Box_Center_curCol[3] <= Box_Center_curCol[3]-4'd1;
					end
				end
				
				else if (RIGHT)
				begin
					if ((Static_arr[Box_Center_curRow[0]][Box_Center_curCol[0]+4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]+4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]+4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[3]][Box_Center_curCol[3]+4'd1] != 1'b1)
							&& (Box_Center_curCol[0] != 4'd15)
							&& (Box_Center_curCol[1] != 4'd15)
							&& (Box_Center_curCol[2] != 4'd15)
							&& (Box_Center_curCol[3] != 4'd15))
					begin
						Box_Center_curCol[0] <= Box_Center_curCol[0]+4'd1;
						Box_Center_curCol[1] <= Box_Center_curCol[1]+4'd1;
						Box_Center_curCol[2] <= Box_Center_curCol[2]+4'd1;
						Box_Center_curCol[3] <= Box_Center_curCol[3]+4'd1;
					end
				end

				else if (DOWN)
				begin
					if ((Static_arr[Box_Center_curRow[0]+5'd1][Box_Center_curCol[0]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[1]+5'd1][Box_Center_curCol[1]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]+5'd1][Box_Center_curCol[2]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[3]+5'd1][Box_Center_curCol[3]] != 1'b1)
							&& (Box_Center_curRow[0] != 5'd23)
							&& (Box_Center_curRow[1] != 5'd23)
							&& (Box_Center_curRow[2] != 5'd23)
							&& (Box_Center_curRow[3] != 5'd23))
					begin
						Box_Center_curRow[0] <= Box_Center_curRow[0]+4'd1;
						Box_Center_curRow[1] <= Box_Center_curRow[1]+4'd1;
						Box_Center_curRow[2] <= Box_Center_curRow[2]+4'd1;
						Box_Center_curRow[3] <= Box_Center_curRow[3]+4'd1;
					end
				end
				
				else if (NULL)
				begin
					if ((Static_arr[Box_Center_curRow[0]+5'd1][Box_Center_curCol[0]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[1]+5'd1][Box_Center_curCol[1]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]+5'd1][Box_Center_curCol[2]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[3]+5'd1][Box_Center_curCol[3]] != 1'b1)
							&& (Box_Center_curRow[0] != 5'd23)
							&& (Box_Center_curRow[1] != 5'd23)
							&& (Box_Center_curRow[2] != 5'd23)
							&& (Box_Center_curRow[3] != 5'd23))
					begin
						Box_Center_curRow[0] <= Box_Center_curRow[0]+5'd1;
						Box_Center_curRow[1] <= Box_Center_curRow[1]+5'd1;
						Box_Center_curRow[2] <= Box_Center_curRow[2]+5'd1;
						Box_Center_curRow[3] <= Box_Center_curRow[3]+5'd1;
					end
				end
				
				else if (UP)
					begin						
						if (Rot_State == 1'b0)						
						begin
							if (    (Static_arr[Box_Center_curRow[2]-5'd1][Box_Center_curCol[2]] != 1'b1)
						         && (Static_arr[Box_Center_curRow[2]-5'd2][Box_Center_curCol[2]] != 1'b1)							
						       )
						
							begin  
								Box_Center_curRow[0] <= Box_Center_curRow[0];
								Box_Center_curRow[1] <= Box_Center_curRow[1]+4'd1;
								Box_Center_curRow[2] <= Box_Center_curRow[2]-4'd2;
								Box_Center_curRow[3] <= Box_Center_curRow[3]-4'd1;
								Box_Center_curCol[0] <= Box_Center_curCol[0];
								Box_Center_curCol[1] <= Box_Center_curCol[1]-4'd1;
								Box_Center_curCol[2] <= Box_Center_curCol[2];
								Box_Center_curCol[3] <= Box_Center_curCol[3]-4'd1;
								Rot_State <= 1'b01;
							end
						end																				
						

						else
						begin 
							if (    (Static_arr[Box_Center_curRow[3]+5'd1][Box_Center_curCol[3]] != 1'b1)
							     && (Static_arr[Box_Center_curRow[0]][Box_Center_curCol[0]+5'd1] != 1'b1)
							     && (Box_Center_curCol[0] <=8 )
							   )
							begin  
								Box_Center_curRow[0] <= Box_Center_curRow[0];
								Box_Center_curRow[1] <= Box_Center_curRow[1]-4'd1;
								Box_Center_curRow[2] <= Box_Center_curRow[2]+4'd2;
								Box_Center_curRow[3] <= Box_Center_curRow[3]+4'd1;
								Box_Center_curCol[0] <= Box_Center_curCol[0];
								Box_Center_curCol[1] <= Box_Center_curCol[1]+4'd1;
								Box_Center_curCol[2] <= Box_Center_curCol[2];
								Box_Center_curCol[3] <= Box_Center_curCol[3]+4'd1;
								Rot_State <= 1'b0;
							end
					
							
							else if (    (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]-5'd2] != 1'b1)
							          && (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]-5'd1] != 1'b1)
							          && (Box_Center_curCol[0] > 8)
							        )
							begin 
								Box_Center_curRow[0] <= Box_Center_curRow[0];
								Box_Center_curRow[1] <= Box_Center_curRow[1]-4'd1;
								Box_Center_curRow[2] <= Box_Center_curRow[2]+4'd2;
								Box_Center_curRow[3] <= Box_Center_curRow[3]+4'd1;
								Box_Center_curCol[0] <= Box_Center_curCol[0]-4'd1;
								Box_Center_curCol[1] <= Box_Center_curCol[1]+4'd1-4'd1;
								Box_Center_curCol[2] <= Box_Center_curCol[2]-4'd1;
								Box_Center_curCol[3] <= Box_Center_curCol[3]+4'd1-4'd1;
								Rot_State <= 1'b0;
							end
							
							else if (    (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]-5'd2] != 1'b1)
							          && (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]-5'd1] != 1'b1)
							          && (Static_arr[Box_Center_curRow[0]][Box_Center_curCol[0]+5'd1] == 1'b1)
							          && (Box_Center_curCol[0] >=2  )
							        )
							begin 
								Box_Center_curRow[0] <= Box_Center_curRow[0];
								Box_Center_curRow[1] <= Box_Center_curRow[1]-4'd1;
								Box_Center_curRow[2] <= Box_Center_curRow[2]+4'd2;
								Box_Center_curRow[3] <= Box_Center_curRow[3]+4'd1;
								Box_Center_curCol[0] <= Box_Center_curCol[0]-4'd1;
								Box_Center_curCol[1] <= Box_Center_curCol[1]+4'd1-4'd1;
								Box_Center_curCol[2] <= Box_Center_curCol[2]-4'd1;
								Box_Center_curCol[3] <= Box_Center_curCol[3]+4'd1-4'd1;
								Rot_State <= 1'b0;
							end 			
						end
										
					end															
		end 
		
		if (Reset) 
			cur_State <= STOP;
		else 
			cur_State <= Next_State;			
		
	end
	
	
	logic [3:0][4:0] NextRow;
	assign NextRow[0] = Box_Center_curRow[0]+5'd1;
	assign NextRow[1] = Box_Center_curRow[1]+5'd1;
	assign NextRow[2] = Box_Center_curRow[2]+5'd1;
	assign NextRow[3] = Box_Center_curRow[3]+5'd1;
	
	int  Row,Column;
	assign Row = (DrawY-10'd31)/10'd21+10'd4;
	assign Column = (DrawX-10'd215)/10'd21;
	
   int DistX, DistY, Size;
   assign Size = 10'd9;
	
	always_comb
	begin
		unique case (cur_State)
			STOP:
			begin
				if (Active)
					Next_State = FALL;
				else
					Next_State = STOP;
			end
			
			FALL:
			begin
				if (touch)
				begin
					if (frame_clk_rising_edge)
						Next_State = TOUCH;
					else
						Next_State = FALL;
				end
				else
					Next_State = FALL;
			end
			
			TOUCH:
			begin
				Next_State = STOP;
			end
			
			default:
				Next_State = STOP;
		endcase

		if (Static_arr[NextRow[0]][Box_Center_curCol[0]] == 1'b1)
			touch = 1'b1;
		else if (Static_arr[NextRow[1]][Box_Center_curCol[1]] == 1'b1)
			touch = 1'b1;
		else if (Static_arr[NextRow[2]][Box_Center_curCol[2]] == 1'b1)
			touch = 1'b1;
		else if (Static_arr[NextRow[3]][Box_Center_curCol[3]] == 1'b1)
			touch = 1'b1;
		else if (Box_Center_curRow[0] == 5'd23)
			touch = 1'b1;
		else if (Box_Center_curRow[1] == 5'd23)
			touch = 1'b1;
		else if (Box_Center_curRow[2] == 5'd23)
			touch = 1'b1;
		else if (Box_Center_curRow[3] == 5'd23)
			touch = 1'b1;
		else
			touch = 1'b0;
			
		case (cur_State)
			STOP:
			begin
				En_New_Static = 1'b0;
				State_onehot = 3'b001;
			end
			FALL:
			begin
				En_New_Static = 1'b0;
				State_onehot = 3'b010;
			end
			TOUCH:
			begin
				En_New_Static = 1'b1;
				State_onehot = 3'b100;
			end
			default: ;
		endcase
			
		if ((Box_Center_curCol[0]==Column)&&(Box_Center_curRow[0]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else if ((Box_Center_curCol[1]==Column)&&(Box_Center_curRow[1]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else if ((Box_Center_curCol[2]==Column)&&(Box_Center_curRow[2]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else if ((Box_Center_curCol[3]==Column)&&(Box_Center_curRow[3]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else
		begin
			DistX = 20;
			DistY = 20;
		end
	end
	
   always_comb
	begin
       if ( (DistX*DistX<=Size*Size) && (DistY*DistY<=Size*Size) )
			  // Need Modify
           Color_Dynamic = 3'b011;
       else
           Color_Dynamic = 3'b000;
   end
	
endmodule

// The L-shaped Block Left
module LL_block ( input Clk,
							  frame_clk,
							  Reset,
							  Active,
							  LEFT, RIGHT, UP, DOWN, NULL,
					  input [9:0] DrawX, DrawY,
					  input [23:0][15:0] Static_arr,
					  output En_New_Static,
					  output [3:0][4:0] New_Static_Row,
					  output [3:0][3:0] New_Static_col,
					  output [2:0] Color_Dynamic,
					  output [2:0] State_onehot
	);
	
	logic [3:0][4:0] Box_Center_initRow;
	logic [3:0][3:0] Box_Center_initCol;
	logic [3:0][4:0] Box_Center_curRow;
	logic [3:0][3:0] Box_Center_curCol;
	logic touch;
	logic [15:0][9:0] Box_X_C;
	logic [23:0][9:0] Box_Y_C;
	
	// Initial Position: Need Modify
	//  x
	//  x
    //  x x

	assign Box_Center_initRow[0] = 5'd0;
	assign Box_Center_initRow[1] = 5'd1;
	assign Box_Center_initRow[2] = 5'd2;
	assign Box_Center_initRow[3] = 5'd2;
	assign Box_Center_initCol[0] = 4'd7;
	assign Box_Center_initCol[1] = 4'd7;
	assign Box_Center_initCol[2] = 4'd7;
	assign Box_Center_initCol[3] = 4'd8;
	assign New_Static_Row[0] = Box_Center_curRow[0];
	assign New_Static_Row[1] = Box_Center_curRow[1];
	assign New_Static_Row[2] = Box_Center_curRow[2];
	assign New_Static_Row[3] = Box_Center_curRow[3];
	assign New_Static_col[0] = Box_Center_curCol[0];
	assign New_Static_col[1] = Box_Center_curCol[1];
	assign New_Static_col[2] = Box_Center_curCol[2];
	assign New_Static_col[3] = Box_Center_curCol[3];
	
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
	
	enum logic [2:0] {STOP, FALL, TOUCH}	cur_State, Next_State;
	logic [1:0] Rot_State;
	
   // Detect rising edge of frame_clk
	logic frame_clk_prev, frame_clk_rising_edge;
	always_ff @ (posedge Clk)
	begin
		frame_clk_prev <= frame_clk;
		frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_prev == 1'b0);
	end
	
	always_ff @ (posedge Clk)
	begin
		if (frame_clk_rising_edge)
			case (cur_State)
				STOP:
				begin
					Box_Center_curRow[0] <= Box_Center_initRow[0];
					Box_Center_curRow[1] <= Box_Center_initRow[1];
					Box_Center_curRow[2] <= Box_Center_initRow[2];
					Box_Center_curRow[3] <= Box_Center_initRow[3];
					Box_Center_curCol[0] <= Box_Center_initCol[0];
					Box_Center_curCol[1] <= Box_Center_initCol[1];
					Box_Center_curCol[2] <= Box_Center_initCol[2];
					Box_Center_curCol[3] <= Box_Center_initCol[3];
				end
				
				FALL:
					if (~touch)
					begin
						Box_Center_curRow[0] <= Box_Center_curRow[0]+5'd1;
						Box_Center_curRow[1] <= Box_Center_curRow[1]+5'd1;
						Box_Center_curRow[2] <= Box_Center_curRow[2]+5'd1;
						Box_Center_curRow[3] <= Box_Center_curRow[3]+5'd1;
					end
				
				TOUCH: ;
				default: ;
			endcase

		if (cur_State == STOP)
			Rot_State = 2'b00;
		else if (cur_State == FALL)
		begin
			if (LEFT)
			begin
				if (       (Static_arr[Box_Center_curRow[0]][Box_Center_curCol[0]-4'd1] != 1'b1)
						&& (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]-4'd1] != 1'b1)
						&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]-4'd1] != 1'b1)
						&& (Static_arr[Box_Center_curRow[3]][Box_Center_curCol[3]-4'd1] != 1'b1)
						&& (Box_Center_curCol[0] != 4'd0)
						&& (Box_Center_curCol[1] != 4'd0)
						&& (Box_Center_curCol[2] != 4'd0)
						&& (Box_Center_curCol[3] != 4'd0))
				begin
					Box_Center_curCol[0] <= Box_Center_curCol[0]-4'd1;
					Box_Center_curCol[1] <= Box_Center_curCol[1]-4'd1;
					Box_Center_curCol[2] <= Box_Center_curCol[2]-4'd1;
					Box_Center_curCol[3] <= Box_Center_curCol[3]-4'd1;
				end
			end
			
			else if (RIGHT)
			begin
				if (       (Static_arr[Box_Center_curRow[0]][Box_Center_curCol[0]+4'd1] != 1'b1)
						&& (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]+4'd1] != 1'b1)
						&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]+4'd1] != 1'b1)
						&& (Static_arr[Box_Center_curRow[3]][Box_Center_curCol[3]+4'd1] != 1'b1)
						&& (Box_Center_curCol[0] != 4'd15)
						&& (Box_Center_curCol[1] != 4'd15)
						&& (Box_Center_curCol[2] != 4'd15)
						&& (Box_Center_curCol[3] != 4'd15))
				begin
					Box_Center_curCol[0] <= Box_Center_curCol[0]+4'd1;
					Box_Center_curCol[1] <= Box_Center_curCol[1]+4'd1;
					Box_Center_curCol[2] <= Box_Center_curCol[2]+4'd1;
					Box_Center_curCol[3] <= Box_Center_curCol[3]+4'd1;
				end
			end
			
			else if (DOWN)
			begin
				if (       (Static_arr[Box_Center_curRow[0]+5'd1][Box_Center_curCol[0]] != 1'b1)
						&& (Static_arr[Box_Center_curRow[1]+5'd1][Box_Center_curCol[1]] != 1'b1)
						&& (Static_arr[Box_Center_curRow[2]+5'd1][Box_Center_curCol[2]] != 1'b1)
						&& (Static_arr[Box_Center_curRow[3]+5'd1][Box_Center_curCol[3]] != 1'b1)
						&& (Box_Center_curRow[0] != 5'd23)
						&& (Box_Center_curRow[1] != 5'd23)
						&& (Box_Center_curRow[2] != 5'd23)
						&& (Box_Center_curRow[3] != 5'd23))
				begin
					Box_Center_curRow[0] <= Box_Center_curRow[0]+4'd1;
					Box_Center_curRow[1] <= Box_Center_curRow[1]+4'd1;
					Box_Center_curRow[2] <= Box_Center_curRow[2]+4'd1;
					Box_Center_curRow[3] <= Box_Center_curRow[3]+4'd1;
				end
			end
			
			else if (NULL)
			begin
				if (       (Static_arr[Box_Center_curRow[0]+5'd1][Box_Center_curCol[0]] != 1'b1)
						&& (Static_arr[Box_Center_curRow[1]+5'd1][Box_Center_curCol[1]] != 1'b1)
						&& (Static_arr[Box_Center_curRow[2]+5'd1][Box_Center_curCol[2]] != 1'b1)
						&& (Static_arr[Box_Center_curRow[3]+5'd1][Box_Center_curCol[3]] != 1'b1)
						&& (Box_Center_curRow[0] != 5'd23)
						&& (Box_Center_curRow[1] != 5'd23)
						&& (Box_Center_curRow[2] != 5'd23)
						&& (Box_Center_curRow[3] != 5'd23))
				begin
					Box_Center_curRow[0] <= Box_Center_curRow[0]+5'd1;
					Box_Center_curRow[1] <= Box_Center_curRow[1]+5'd1;
					Box_Center_curRow[2] <= Box_Center_curRow[2]+5'd1;
					Box_Center_curRow[3] <= Box_Center_curRow[3]+5'd1;
				end
			end
			
			else if (UP)
				begin
					
					if (Rot_State == 2'b00)
					
					// as the right side is three, consider sliding through the wall
					begin
						if (   (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]+5'd1] != 1'b1)
						    && (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]+5'd2] != 1'b1)
						    && (Box_Center_curCol[3] <=5'd8)
						   )
						
							begin  // first next cur_State, only move 1 to right and down
								Box_Center_curRow[0] <= Box_Center_curRow[0]+5'd1;
								Box_Center_curRow[1] <= Box_Center_curRow[1];
								Box_Center_curRow[2] <= Box_Center_curRow[2]-5'd1;
								Box_Center_curRow[3] <= Box_Center_curRow[3];
								Box_Center_curCol[0] <= Box_Center_curCol[0]+4'd2;
								Box_Center_curCol[1] <= Box_Center_curCol[1]+4'd1;
								Box_Center_curCol[2] <= Box_Center_curCol[2];
								Box_Center_curCol[3] <= Box_Center_curCol[3]-4'd1;
								Rot_State <= 1'b01;
							end
						else if (    (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]-5'd1] != 1'b1)
						          && (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]+5'd1] != 1'b1)
						          && (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]] != 1'b1)
						          && (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]-5'd1] != 1'b1)
						          && (Box_Center_curCol[3] > 5'd8)
						        )
							begin 
								Box_Center_curRow[0] <= Box_Center_curRow[0]+5'd1;
								Box_Center_curRow[1] <= Box_Center_curRow[1];
								Box_Center_curRow[2] <= Box_Center_curRow[2]-5'd1;
								Box_Center_curRow[3] <= Box_Center_curRow[3];
								Box_Center_curCol[0] <= Box_Center_curCol[0]+4'd2-4'd1;
								Box_Center_curCol[1] <= Box_Center_curCol[1]+4'd1-4'd1;
								Box_Center_curCol[2] <= Box_Center_curCol[2]-4'd1;
								Box_Center_curCol[3] <= Box_Center_curCol[3]-4'd1-4'd1;
								Rot_State <= 1'b01;
							end
							
						else if (    (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]-5'd1] != 1'b1)
						          && (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]+5'd1] != 1'b1)
						          && (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]-5'd1] != 1'b1)
						          && (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]+5'd2] == 1'b1)
						          && (Box_Center_curCol[3] >= 5'd2)
						        )
							begin 
								Box_Center_curRow[0] <= Box_Center_curRow[0]+5'd1;
								Box_Center_curRow[1] <= Box_Center_curRow[1];
								Box_Center_curRow[2] <= Box_Center_curRow[2]-5'd1;
								Box_Center_curRow[3] <= Box_Center_curRow[3];
								Box_Center_curCol[0] <= Box_Center_curCol[0]+4'd2-4'd1;
								Box_Center_curCol[1] <= Box_Center_curCol[1]+4'd1-4'd1;
								Box_Center_curCol[2] <= Box_Center_curCol[2]-4'd1;
								Box_Center_curCol[3] <= Box_Center_curCol[3]-4'd1-4'd1;
								Rot_State <= 1'b01;
							end	
						
					end
						

					else if (Rot_State == 2'b01)
					
					begin 
						if (    (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]+5'd1] != 1'b1)
						     && (Static_arr[Box_Center_curRow[3]+5'd1][Box_Center_curCol[3]+5'd1] != 1'b1)
						)
							begin  
								Box_Center_curRow[0] <= Box_Center_curRow[0]+5'd2;
								Box_Center_curRow[1] <= Box_Center_curRow[1]+5'd1;
								Box_Center_curRow[2] <= Box_Center_curRow[2];
								Box_Center_curRow[3] <= Box_Center_curRow[3]-5'd1;
								Box_Center_curCol[0] <= Box_Center_curCol[0]-4'd1;
								Box_Center_curCol[1] <= Box_Center_curCol[1];
								Box_Center_curCol[2] <= Box_Center_curCol[2]+4'd1;
								Box_Center_curCol[3] <= Box_Center_curCol[3];
								Rot_State <= 2'b10;
							end
					end
							
					else if (Rot_State == 2'b10)
					begin
						if (    (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]-5'd1] != 1'b1)
						     && (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]+5'd1] != 1'b1)
						     && (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]+5'd1] != 1'b1)
						     && (Box_Center_curCol[1] <= 8)
						)
							begin  
								Box_Center_curRow[0] <= Box_Center_curRow[0]-5'd1;
								Box_Center_curRow[1] <= Box_Center_curRow[1];
								Box_Center_curRow[2] <= Box_Center_curRow[2]+5'd1;
								Box_Center_curRow[3] <= Box_Center_curRow[3];
								Box_Center_curCol[0] <= Box_Center_curCol[0]-4'd1;
								Box_Center_curCol[1] <= Box_Center_curCol[1];
								Box_Center_curCol[2] <= Box_Center_curCol[2]+4'd1;
								Box_Center_curCol[3] <= Box_Center_curCol[3]+4'd2;
								Rot_State <= 2'b11;
							end
							
						else if (    (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]-5'd1] != 1'b1)
						          && (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]-5'd2] != 1'b1)
						          && (Box_Center_curCol[1] >= 9)
						        )
							begin  
								Box_Center_curRow[0] <= Box_Center_curRow[0]-5'd1;
								Box_Center_curRow[1] <= Box_Center_curRow[1];
								Box_Center_curRow[2] <= Box_Center_curRow[2]+5'd1;
								Box_Center_curRow[3] <= Box_Center_curRow[3];
								Box_Center_curCol[0] <= Box_Center_curCol[0]-4'd1-4'd1;
								Box_Center_curCol[1] <= Box_Center_curCol[1]-4'd1;
								Box_Center_curCol[2] <= Box_Center_curCol[2]+4'd1-4'd1;
								Box_Center_curCol[3] <= Box_Center_curCol[3]+4'd2-4'd1;
								Rot_State <= 2'b11;
							end
														
						else if (    (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]-5'd1] != 1'b1)
						          && (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]-5'd2] != 1'b1)
						          && (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]+5'd1] == 1'b1)
						          && (Box_Center_curCol[1] >= 2)
						        )
							begin  
								Box_Center_curRow[0] <= Box_Center_curRow[0]-5'd1;
								Box_Center_curRow[1] <= Box_Center_curRow[1];
								Box_Center_curRow[2] <= Box_Center_curRow[2]+5'd1;
								Box_Center_curRow[3] <= Box_Center_curRow[3];
								Box_Center_curCol[0] <= Box_Center_curCol[0]-4'd1-4'd1;
								Box_Center_curCol[1] <= Box_Center_curCol[1]-4'd1;
								Box_Center_curCol[2] <= Box_Center_curCol[2]+4'd1-4'd1;
								Box_Center_curCol[3] <= Box_Center_curCol[3]+4'd2-'d1;
								Rot_State <= 2'b11;
							end
							
					end
					
					else
					begin 
						if (    (Static_arr[Box_Center_curRow[1]-5'd1][Box_Center_curCol[1]] != 1'b1)
						     && (Static_arr[Box_Center_curRow[1]-5'd2][Box_Center_curCol[1]] != 1'b1)
						)
							begin  
								Box_Center_curRow[0] <= Box_Center_curRow[0]-5'd2;
								Box_Center_curRow[1] <= Box_Center_curRow[1]-5'd1;
								Box_Center_curRow[2] <= Box_Center_curRow[2];
								Box_Center_curRow[3] <= Box_Center_curRow[3]+5'd1;
								Box_Center_curCol[0] <= Box_Center_curCol[0]+4'd1;
								Box_Center_curCol[1] <= Box_Center_curCol[1];
								Box_Center_curCol[2] <= Box_Center_curCol[2]-4'd1;
								Box_Center_curCol[3] <= Box_Center_curCol[3];
								Rot_State <= 2'b00;
							end
					end
				
				end
				
			end
			
		if (Reset) 	
			cur_State <= STOP;
		else 
			cur_State <= Next_State;			
		
	end
	
	logic [3:0][4:0] NextRow;
	assign NextRow[0] = Box_Center_curRow[0]+5'd1;
	assign NextRow[1] = Box_Center_curRow[1]+5'd1;
	assign NextRow[2] = Box_Center_curRow[2]+5'd1;
	assign NextRow[3] = Box_Center_curRow[3]+5'd1;
	
	int  Row,Column;
	assign Row = (DrawY-10'd31)/10'd21+10'd4;
	assign Column = (DrawX-10'd215)/10'd21;
	
    int DistX, DistY, Size;
    assign Size = 10'd9;
	
	always_comb
	begin
		unique case (cur_State)
			STOP:
			begin
				if (Active)
					Next_State = FALL;
				else
					Next_State = STOP;
			end
			
			FALL:
			begin
				if (touch)
				begin
					if (frame_clk_rising_edge)
						Next_State = TOUCH;
					else
						Next_State = FALL;
				end
				else
					Next_State = FALL;
			end
			
			TOUCH:
			begin
				Next_State = STOP;
			end
			
			default:
				Next_State = STOP;
		endcase

		
		if (Static_arr[NextRow[0]][Box_Center_curCol[0]] == 1'b1)
			touch = 1'b1;
		else if (Static_arr[NextRow[1]][Box_Center_curCol[1]] == 1'b1)
			touch = 1'b1;
		else if (Static_arr[NextRow[2]][Box_Center_curCol[2]] == 1'b1)
			touch = 1'b1;
		else if (Static_arr[NextRow[3]][Box_Center_curCol[3]] == 1'b1)
			touch = 1'b1;
		else if (Box_Center_curRow[0] == 5'd23)
			touch = 1'b1;
		else if (Box_Center_curRow[1] == 5'd23)
			touch = 1'b1;
		else if (Box_Center_curRow[2] == 5'd23)
			touch = 1'b1;
		else if (Box_Center_curRow[3] == 5'd23)
			touch = 1'b1;
		else
			touch = 1'b0;
			
		case (cur_State)
			STOP:
			begin
				En_New_Static = 1'b0;
				State_onehot = 3'b001;
			end
			FALL:
			begin
				En_New_Static = 1'b0;
				State_onehot = 3'b010;
			end
			TOUCH:
			begin
				En_New_Static = 1'b1;
				State_onehot = 3'b100;
			end
			default: ;
		endcase

		if ((Box_Center_curCol[0]==Column)&&(Box_Center_curRow[0]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else if ((Box_Center_curCol[1]==Column)&&(Box_Center_curRow[1]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else if ((Box_Center_curCol[2]==Column)&&(Box_Center_curRow[2]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else if ((Box_Center_curCol[3]==Column)&&(Box_Center_curRow[3]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else
		begin
			DistX = 20;
			DistY = 20;
		end
	end
	
   always_comb
	begin
       if ( (DistX*DistX<=Size*Size) && (DistY*DistY<=Size*Size) )
			  // Need Modify
           Color_Dynamic = 3'b011;
       else
           Color_Dynamic = 3'b000;
   end
	
endmodule

// The Left-folding Block

module LF_block ( input Clk,
							  frame_clk,
							  Reset,
							  Active,
							  LEFT, RIGHT, UP, DOWN, NULL,
					  input [9:0] DrawX, DrawY,
					  input [23:0][15:0] Static_arr,
					  output En_New_Static,
					  output [3:0][4:0] New_Static_Row,
					  output [3:0][3:0] New_Static_col,
					  output [2:0] Color_Dynamic,
					  output [2:0] State_onehot
	);

	
	logic [3:0][4:0] Box_Center_initRow;
	logic [3:0][3:0] Box_Center_initCol;
	logic [3:0][4:0] Box_Center_curRow;
	logic [3:0][3:0] Box_Center_curCol;
	logic touch;
	logic [15:0][9:0] Box_X_C;
	logic [23:0][9:0] Box_Y_C;
	
	// Initial Position: Need Modify
	// x x
	//   x x
	
	assign Box_Center_initRow[0] = 5'd0;
	assign Box_Center_initRow[1] = 5'd0;
	assign Box_Center_initRow[2] = 5'd1;
	assign Box_Center_initRow[3] = 5'd1;
	assign Box_Center_initCol[0] = 4'd6;
	assign Box_Center_initCol[1] = 4'd7;
	assign Box_Center_initCol[2] = 4'd7;
	assign Box_Center_initCol[3] = 4'd8;
	assign New_Static_Row[0] = Box_Center_curRow[0];
	assign New_Static_Row[1] = Box_Center_curRow[1];
	assign New_Static_Row[2] = Box_Center_curRow[2];
	assign New_Static_Row[3] = Box_Center_curRow[3];
	assign New_Static_col[0] = Box_Center_curCol[0];
	assign New_Static_col[1] = Box_Center_curCol[1];
	assign New_Static_col[2] = Box_Center_curCol[2];
	assign New_Static_col[3] = Box_Center_curCol[3];
	
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
	
	enum logic [2:0] {STOP, FALL, TOUCH}	cur_State, Next_State;
	logic Rot_State;
	
   // Detect rising edge of frame_clk
	logic frame_clk_prev, frame_clk_rising_edge;
	always_ff @ (posedge Clk)
	begin
		frame_clk_prev <= frame_clk;
		frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_prev == 1'b0);
	end
	
	always_ff @ (posedge Clk)
	begin
		if (frame_clk_rising_edge)
			case (cur_State)
				STOP:
				begin
					Box_Center_curRow[0] <= Box_Center_initRow[0];
					Box_Center_curRow[1] <= Box_Center_initRow[1];
					Box_Center_curRow[2] <= Box_Center_initRow[2];
					Box_Center_curRow[3] <= Box_Center_initRow[3];
					Box_Center_curCol[0] <= Box_Center_initCol[0];
					Box_Center_curCol[1] <= Box_Center_initCol[1];
					Box_Center_curCol[2] <= Box_Center_initCol[2];
					Box_Center_curCol[3] <= Box_Center_initCol[3];
				end
				
				FALL:
					if (~touch)
					begin
						Box_Center_curRow[0] <= Box_Center_curRow[0]+5'd1;
						Box_Center_curRow[1] <= Box_Center_curRow[1]+5'd1;
						Box_Center_curRow[2] <= Box_Center_curRow[2]+5'd1;
						Box_Center_curRow[3] <= Box_Center_curRow[3]+5'd1;
					end
				
				TOUCH: ;
				default: ;
			endcase
		
		if (cur_State == STOP)
			Rot_State <= 1'b0;
		else if (cur_State == FALL)
			begin
				if (LEFT)
				begin
					if (       (Static_arr[Box_Center_curRow[0]][Box_Center_curCol[0]-4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]-4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]-4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[3]][Box_Center_curCol[3]-4'd1] != 1'b1)
							&& (Box_Center_curCol[0] != 4'd0)
							&& (Box_Center_curCol[1] != 4'd0)
							&& (Box_Center_curCol[2] != 4'd0)
							&& (Box_Center_curCol[3] != 4'd0))
					begin
						Box_Center_curCol[0] <= Box_Center_curCol[0]-4'd1;
						Box_Center_curCol[1] <= Box_Center_curCol[1]-4'd1;
						Box_Center_curCol[2] <= Box_Center_curCol[2]-4'd1;
						Box_Center_curCol[3] <= Box_Center_curCol[3]-4'd1;
					end
				end
				
				else if (RIGHT)
				begin
					if (       (Static_arr[Box_Center_curRow[0]][Box_Center_curCol[0]+4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]+4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]+4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[3]][Box_Center_curCol[3]+4'd1] != 1'b1)
							&& (Box_Center_curCol[0] != 4'd15)
							&& (Box_Center_curCol[1] != 4'd15)
							&& (Box_Center_curCol[2] != 4'd15)
							&& (Box_Center_curCol[3] != 4'd15))
					begin
						Box_Center_curCol[0] <= Box_Center_curCol[0]+4'd1;
						Box_Center_curCol[1] <= Box_Center_curCol[1]+4'd1;
						Box_Center_curCol[2] <= Box_Center_curCol[2]+4'd1;
						Box_Center_curCol[3] <= Box_Center_curCol[3]+4'd1;
					end
				end
				
				else if (DOWN)
				begin
					if (       (Static_arr[Box_Center_curRow[0]+5'd1][Box_Center_curCol[0]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[1]+5'd1][Box_Center_curCol[1]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]+5'd1][Box_Center_curCol[2]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[3]+5'd1][Box_Center_curCol[3]] != 1'b1)
							&& (Box_Center_curRow[0] != 5'd23)
							&& (Box_Center_curRow[1] != 5'd23)
							&& (Box_Center_curRow[2] != 5'd23)
							&& (Box_Center_curRow[3] != 5'd23))
					begin
						Box_Center_curRow[0] <= Box_Center_curRow[0]+4'd1;
						Box_Center_curRow[1] <= Box_Center_curRow[1]+4'd1;
						Box_Center_curRow[2] <= Box_Center_curRow[2]+4'd1;
						Box_Center_curRow[3] <= Box_Center_curRow[3]+4'd1;
					end
				end
				
				else if (NULL)
				begin
					if (       (Static_arr[Box_Center_curRow[0]+5'd1][Box_Center_curCol[0]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[1]+5'd1][Box_Center_curCol[1]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]+5'd1][Box_Center_curCol[2]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[3]+5'd1][Box_Center_curCol[3]] != 1'b1)
							&& (Box_Center_curRow[0] != 5'd23)
							&& (Box_Center_curRow[1] != 5'd23)
							&& (Box_Center_curRow[2] != 5'd23)
							&& (Box_Center_curRow[3] != 5'd23))
					begin
						Box_Center_curRow[0] <= Box_Center_curRow[0]+5'd1;
						Box_Center_curRow[1] <= Box_Center_curRow[1]+5'd1;
						Box_Center_curRow[2] <= Box_Center_curRow[2]+5'd1;
						Box_Center_curRow[3] <= Box_Center_curRow[3]+5'd1;
					end
				end
			
				else if (UP)
					begin
						
						if (Rot_State == 1'b0)						
						begin
							if (     (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]+5'd1] != 1'b1)
							      && (Static_arr[Box_Center_curRow[3]-5'd2][Box_Center_curCol[3]] != 1'b1))
								begin                                                                                                                  
									Box_Center_curRow[0] <= Box_Center_curRow[0]-4'd1;
									Box_Center_curRow[1] <= Box_Center_curRow[1];
									Box_Center_curRow[2] <= Box_Center_curRow[2]-4'd1;
									Box_Center_curRow[3] <= Box_Center_curRow[3];
									Box_Center_curCol[0] <= Box_Center_curCol[0]+4'd2;
									Box_Center_curCol[1] <= Box_Center_curCol[1]+4'd1;
									Box_Center_curCol[2] <= Box_Center_curCol[2];
									Box_Center_curCol[3] <= Box_Center_curCol[3]-4'd1;
									Rot_State <= 1'b01;
								end
						end																				
						
						else
						begin 
							if (    (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]-5'd1] != 1'b1)
							     && (Static_arr[Box_Center_curRow[0]+5'd2][Box_Center_curCol[0]] != 1'b1)
							     && (Box_Center_curCol[2] >= 4'd1))
								begin  
									Box_Center_curRow[0] <= Box_Center_curRow[0]+4'd1;
									Box_Center_curRow[1] <= Box_Center_curRow[1];
									Box_Center_curRow[2] <= Box_Center_curRow[2]+4'd1;
									Box_Center_curRow[3] <= Box_Center_curRow[3];
									Box_Center_curCol[0] <= Box_Center_curCol[0]-4'd2;
									Box_Center_curCol[1] <= Box_Center_curCol[1]-4'd1;
									Box_Center_curCol[2] <= Box_Center_curCol[2];
									Box_Center_curCol[3] <= Box_Center_curCol[3]+4'd1;
									Rot_State <= 1'b0;
								end
								
							else if (   (Static_arr[Box_Center_curRow[3]][Box_Center_curCol[3]+5'd2] != 1'b1)
							         && (Static_arr[Box_Center_curRow[1]+5'd1][Box_Center_curCol[0]] != 1'b1)
							         && (Box_Center_curCol[2] < 4'd1 ))
								begin 
									Box_Center_curRow[0] <= Box_Center_curRow[0]+4'd1;
									Box_Center_curRow[1] <= Box_Center_curRow[1];
									Box_Center_curRow[2] <= Box_Center_curRow[2]+4'd1;
									Box_Center_curRow[3] <= Box_Center_curRow[3];
									Box_Center_curCol[0] <= Box_Center_curCol[0]-4'd2+4'd1;
									Box_Center_curCol[1] <= Box_Center_curCol[1]-4'd1+4'd1;
									Box_Center_curCol[2] <= Box_Center_curCol[2]+4'd1;
									Box_Center_curCol[3] <= Box_Center_curCol[3]+4'd1+4'd1;
									Rot_State <= 1'b0;
								end 
							
							else if (    (Static_arr[Box_Center_curRow[3]][Box_Center_curCol[3]+5'd2] != 1'b1)
							          && (Static_arr[Box_Center_curRow[1]+5'd1][Box_Center_curCol[1]] != 1'b1)
							          && (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]-5'd1] == 1'b1)
							          && (Box_Center_curCol[2] <= 4'd7))
								begin 
									Box_Center_curRow[0] <= Box_Center_curRow[0]+4'd1;
									Box_Center_curRow[1] <= Box_Center_curRow[1];
									Box_Center_curRow[2] <= Box_Center_curRow[2]+4'd1;
									Box_Center_curRow[3] <= Box_Center_curRow[3];
									Box_Center_curCol[0] <= Box_Center_curCol[0]-4'd2+4'd1;
									Box_Center_curCol[1] <= Box_Center_curCol[1]-4'd1+4'd1;
									Box_Center_curCol[2] <= Box_Center_curCol[2]+4'd1;
									Box_Center_curCol[3] <= Box_Center_curCol[3]+4'd1+4'd1;
									Rot_State <= 1'b0;
								end 
						end
				    end
		    end
			
		if (Reset)
			cur_State <= STOP;
		else 
			cur_State <= Next_State;			
		
	end
	
	logic [3:0][4:0] NextRow;
	assign NextRow[0] = Box_Center_curRow[0]+5'd1;
	assign NextRow[1] = Box_Center_curRow[1]+5'd1;
	assign NextRow[2] = Box_Center_curRow[2]+5'd1;
	assign NextRow[3] = Box_Center_curRow[3]+5'd1;
	
	int  Row,Column;
	assign Row = (DrawY-10'd31)/10'd21+10'd4;
	assign Column = (DrawX-10'd215)/10'd21;
	
    int DistX, DistY, Size;
    assign Size = 10'd9;
	
	always_comb
	begin
		unique case (cur_State)
			STOP:
			begin
				if (Active)
					Next_State = FALL;
				else
					Next_State = STOP;
			end
			
			FALL:
			begin
				if (touch)
				begin
					if (frame_clk_rising_edge)
						Next_State = TOUCH;
					else
						Next_State = FALL;
				end
				else
					Next_State = FALL;
			end
			
			TOUCH:
			begin
				Next_State = STOP;
			end
			
			default:
				Next_State = STOP;
		endcase

		if (Static_arr[NextRow[0]][Box_Center_curCol[0]] == 1'b1)
			touch = 1'b1;
		else if (Static_arr[NextRow[1]][Box_Center_curCol[1]] == 1'b1)
			touch = 1'b1;
		else if (Static_arr[NextRow[2]][Box_Center_curCol[2]] == 1'b1)
			touch = 1'b1;
		else if (Static_arr[NextRow[3]][Box_Center_curCol[3]] == 1'b1)
			touch = 1'b1;
		else if (Box_Center_curRow[0] == 5'd23)
			touch = 1'b1;
		else if (Box_Center_curRow[1] == 5'd23)
			touch = 1'b1;
		else if (Box_Center_curRow[2] == 5'd23)
			touch = 1'b1;
		else if (Box_Center_curRow[3] == 5'd23)
			touch = 1'b1;
		else
			touch = 1'b0;
			
		case (cur_State)
			STOP:
			begin
				En_New_Static = 1'b0;
				State_onehot = 3'b001;
			end
			FALL:
			begin
				En_New_Static = 1'b0;
				State_onehot = 3'b010;
			end
			TOUCH:
			begin
				En_New_Static = 1'b1;
				State_onehot = 3'b100;
			end
			default: ;
		endcase

			
		if ((Box_Center_curCol[0]==Column)&&(Box_Center_curRow[0]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else if ((Box_Center_curCol[1]==Column)&&(Box_Center_curRow[1]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else if ((Box_Center_curCol[2]==Column)&&(Box_Center_curRow[2]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else if ((Box_Center_curCol[3]==Column)&&(Box_Center_curRow[3]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else
		begin
			DistX = 20;
			DistY = 20;
		end
	end
	
   always_comb
	begin
       if ( (DistX*DistX<=Size*Size) && (DistY*DistY<=Size*Size) )
			// Need Modify
           Color_Dynamic = 3'b011;
       else
           Color_Dynamic = 3'b000;
   end
	
endmodule

// The I-shaped Block
module I_block ( input Clk,
							  frame_clk,
							  Reset,
							  Active,
							  LEFT, RIGHT, UP, DOWN, NULL,
					  input [9:0] DrawX, DrawY,
					  input [23:0][15:0] Static_arr,
					  output En_New_Static,
					  output [3:0][4:0] New_Static_Row,
					  output [3:0][3:0] New_Static_col,
					  output [2:0] Color_Dynamic,
					  output [2:0] State_onehot
	);
	
	logic [3:0][4:0] Box_Center_initRow;
	logic [3:0][3:0] Box_Center_initCol;
	logic [3:0][4:0] Box_Center_curRow;
	logic [3:0][3:0] Box_Center_curCol;
	logic touch;
	logic [15:0][9:0] Box_X_C;
	logic [23:0][9:0] Box_Y_C;
	
	// Initial Position: Need Modify
	// x x x x

	assign Box_Center_initRow[0] = 5'd1;
	assign Box_Center_initRow[1] = 5'd1;
	assign Box_Center_initRow[2] = 5'd1;
	assign Box_Center_initRow[3] = 5'd1;
	assign Box_Center_initCol[0] = 4'd6;
	assign Box_Center_initCol[1] = 4'd7;
	assign Box_Center_initCol[2] = 4'd8;
	assign Box_Center_initCol[3] = 4'd9;

	// same as previous module
	assign New_Static_Row[0] = Box_Center_curRow[0];
	assign New_Static_Row[1] = Box_Center_curRow[1];
	assign New_Static_Row[2] = Box_Center_curRow[2];
	assign New_Static_Row[3] = Box_Center_curRow[3];
	assign New_Static_col[0] = Box_Center_curCol[0];
	assign New_Static_col[1] = Box_Center_curCol[1];
	assign New_Static_col[2] = Box_Center_curCol[2];
	assign New_Static_col[3] = Box_Center_curCol[3];
	
	// same as previous module
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
	
	// same as previous module
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
	
	enum logic [2:0] {STOP, FALL, TOUCH}	cur_State, Next_State;
	logic Rot_State;
	
   // Detect rising edge of frame_clk
	logic frame_clk_prev, frame_clk_rising_edge;
	always_ff @ (posedge Clk)
	begin
		frame_clk_prev <= frame_clk;
		frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_prev == 1'b0);
	end
	
	always_ff @ (posedge Clk)
	begin
		if (frame_clk_rising_edge)
			case (cur_State)
				STOP:
				begin
					Box_Center_curRow[0] <= Box_Center_initRow[0];
					Box_Center_curRow[1] <= Box_Center_initRow[1];
					Box_Center_curRow[2] <= Box_Center_initRow[2];
					Box_Center_curRow[3] <= Box_Center_initRow[3];
					Box_Center_curCol[0] <= Box_Center_initCol[0];
					Box_Center_curCol[1] <= Box_Center_initCol[1];
					Box_Center_curCol[2] <= Box_Center_initCol[2];
					Box_Center_curCol[3] <= Box_Center_initCol[3];
				end
				
				FALL:
					if (~touch)
					begin
						Box_Center_curRow[0] <= Box_Center_curRow[0]+5'd1;
						Box_Center_curRow[1] <= Box_Center_curRow[1]+5'd1;
						Box_Center_curRow[2] <= Box_Center_curRow[2]+5'd1;
						Box_Center_curRow[3] <= Box_Center_curRow[3]+5'd1;
					end
				
				TOUCH: ;
				default: ;
			endcase
		
		if (cur_State == STOP)
			Rot_State <= 1'b0;
		else if (cur_State == FALL)
		begin
			if (LEFT)
			begin
				if (       (Static_arr[Box_Center_curRow[0]][Box_Center_curCol[0]-4'd1] != 1'b1)
						&& (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]-4'd1] != 1'b1)
						&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]-4'd1] != 1'b1)
						&& (Static_arr[Box_Center_curRow[3]][Box_Center_curCol[3]-4'd1] != 1'b1)
						&& (Box_Center_curCol[0] != 4'd0)
						&& (Box_Center_curCol[1] != 4'd0)
						&& (Box_Center_curCol[2] != 4'd0)
						&& (Box_Center_curCol[3] != 4'd0))
				begin
					Box_Center_curCol[0] <= Box_Center_curCol[0]-4'd1;
					Box_Center_curCol[1] <= Box_Center_curCol[1]-4'd1;
					Box_Center_curCol[2] <= Box_Center_curCol[2]-4'd1;
					Box_Center_curCol[3] <= Box_Center_curCol[3]-4'd1;
				end
			end
			
			else if (RIGHT)
			begin
				if (       (Static_arr[Box_Center_curRow[0]][Box_Center_curCol[0]+4'd1] != 1'b1)
						&& (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]+4'd1] != 1'b1)
						&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]+4'd1] != 1'b1)
						&& (Static_arr[Box_Center_curRow[3]][Box_Center_curCol[3]+4'd1] != 1'b1)
						&& (Box_Center_curCol[0] != 4'd15)
						&& (Box_Center_curCol[1] != 4'd15)
						&& (Box_Center_curCol[2] != 4'd15)
						&& (Box_Center_curCol[3] != 4'd15))
				begin
					Box_Center_curCol[0] <= Box_Center_curCol[0]+4'd1;
					Box_Center_curCol[1] <= Box_Center_curCol[1]+4'd1;
					Box_Center_curCol[2] <= Box_Center_curCol[2]+4'd1;
					Box_Center_curCol[3] <= Box_Center_curCol[3]+4'd1;
				end
			end
			
			else if (DOWN)
			begin
				if (       (Static_arr[Box_Center_curRow[0]+5'd1][Box_Center_curCol[0]] != 1'b1)
						&& (Static_arr[Box_Center_curRow[1]+5'd1][Box_Center_curCol[1]] != 1'b1)
						&& (Static_arr[Box_Center_curRow[2]+5'd1][Box_Center_curCol[2]] != 1'b1)
						&& (Static_arr[Box_Center_curRow[3]+5'd1][Box_Center_curCol[3]] != 1'b1)
						&& (Box_Center_curRow[0] != 5'd23)
						&& (Box_Center_curRow[1] != 5'd23)
						&& (Box_Center_curRow[2] != 5'd23)
						&& (Box_Center_curRow[3] != 5'd23))
				begin
					Box_Center_curRow[0] <= Box_Center_curRow[0]+5'd1;
					Box_Center_curRow[1] <= Box_Center_curRow[1]+5'd1;
					Box_Center_curRow[2] <= Box_Center_curRow[2]+5'd1;
					Box_Center_curRow[3] <= Box_Center_curRow[3]+5'd1;
				end
			end
			
			else if (NULL)
			begin
				if (       (Static_arr[Box_Center_curRow[0]+5'd1][Box_Center_curCol[0]] != 1'b1)
						&& (Static_arr[Box_Center_curRow[1]+5'd1][Box_Center_curCol[1]] != 1'b1)
						&& (Static_arr[Box_Center_curRow[2]+5'd1][Box_Center_curCol[2]] != 1'b1)
						&& (Static_arr[Box_Center_curRow[3]+5'd1][Box_Center_curCol[3]] != 1'b1)
						&& (Box_Center_curRow[0] != 5'd23)
						&& (Box_Center_curRow[1] != 5'd23)
						&& (Box_Center_curRow[2] != 5'd23)
						&& (Box_Center_curRow[3] != 5'd23))
				begin
					Box_Center_curRow[0] <= Box_Center_curRow[0]+5'd1;
					Box_Center_curRow[1] <= Box_Center_curRow[1]+5'd1;
					Box_Center_curRow[2] <= Box_Center_curRow[2]+5'd1;
					Box_Center_curRow[3] <= Box_Center_curRow[3]+5'd1;
				end
			end
			
			else if (UP)
			begin
				if (Rot_State == 1'b0)
				begin
					if (       (Static_arr[Box_Center_curRow[0]-5'd2][Box_Center_curCol[1]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[0]-5'd1][Box_Center_curCol[1]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[0]][Box_Center_curCol[1]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[0]+5'd1][Box_Center_curCol[1]] != 1'b1)
							&& (Box_Center_curRow[0]) != 5'd23)
					begin
						Box_Center_curRow[0] <= Box_Center_curRow[0]-5'd2;
						Box_Center_curRow[1] <= Box_Center_curRow[0]-5'd1;
						Box_Center_curRow[2] <= Box_Center_curRow[0];
						Box_Center_curRow[3] <= Box_Center_curRow[0]+5'd1;
						Box_Center_curCol[0] <= Box_Center_curCol[1];
						Box_Center_curCol[1] <= Box_Center_curCol[1];
						Box_Center_curCol[2] <= Box_Center_curCol[1];
						Box_Center_curCol[3] <= Box_Center_curCol[1];
						Rot_State <= 1'b1;
					end
					
					else if (  (Static_arr[Box_Center_curRow[0]-5'd2][Box_Center_curCol[2]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[0]-5'd1][Box_Center_curCol[2]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[0]][Box_Center_curCol[2]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[0]+5'd1][Box_Center_curCol[2]] != 1'b1)
							&& (Box_Center_curRow[0]) != 5'd23)
					begin
						Box_Center_curRow[0] <= Box_Center_curRow[0]-5'd2;
						Box_Center_curRow[1] <= Box_Center_curRow[0]-5'd1;
						Box_Center_curRow[2] <= Box_Center_curRow[0];
						Box_Center_curRow[3] <= Box_Center_curRow[0]+5'd1;
						Box_Center_curCol[0] <= Box_Center_curCol[2];
						Box_Center_curCol[1] <= Box_Center_curCol[2];
						Box_Center_curCol[2] <= Box_Center_curCol[2];
						Box_Center_curCol[3] <= Box_Center_curCol[2];
						Rot_State <= 1'b1;
					end
					
					else if (  (Static_arr[Box_Center_curRow[0]-5'd3][Box_Center_curCol[1]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[0]-5'd2][Box_Center_curCol[1]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[0]-5'd1][Box_Center_curCol[1]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[0]][Box_Center_curCol[1]] != 1'b1))
					begin
						Box_Center_curRow[0] <= Box_Center_curRow[0]-5'd3;
						Box_Center_curRow[1] <= Box_Center_curRow[0]-5'd2;
						Box_Center_curRow[2] <= Box_Center_curRow[0]-5'd1;
						Box_Center_curRow[3] <= Box_Center_curRow[0];
						Box_Center_curCol[0] <= Box_Center_curCol[1];
						Box_Center_curCol[1] <= Box_Center_curCol[1];
						Box_Center_curCol[2] <= Box_Center_curCol[1];
						Box_Center_curCol[3] <= Box_Center_curCol[1];
						Rot_State <= 1'b1;
					end
					
					else if (  (Static_arr[Box_Center_curRow[0]-5'd3][Box_Center_curCol[2]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[0]-5'd2][Box_Center_curCol[2]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[0]-5'd1][Box_Center_curCol[2]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[0]][Box_Center_curCol[2]] != 1'b1))
					begin
						Box_Center_curRow[0] <= Box_Center_curRow[0]-5'd3;
						Box_Center_curRow[1] <= Box_Center_curRow[0]-5'd2;
						Box_Center_curRow[2] <= Box_Center_curRow[0]-5'd1;
						Box_Center_curRow[3] <= Box_Center_curRow[0];
						Box_Center_curCol[0] <= Box_Center_curCol[2];
						Box_Center_curCol[1] <= Box_Center_curCol[2];
						Box_Center_curCol[2] <= Box_Center_curCol[2];
						Box_Center_curCol[3] <= Box_Center_curCol[2];
						Rot_State <= 1'b1;
					end
				end
					
				else
				begin
					if (       (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[0]-4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[0]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[0]+4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[0]+4'd2] != 1'b1)
							&& (Box_Center_curCol[0] >= 4'd1)
							&& (Box_Center_curCol[0] <= 4'd7))
					begin
						Box_Center_curRow[0] <= Box_Center_curRow[2];
						Box_Center_curRow[1] <= Box_Center_curRow[2];
						Box_Center_curRow[2] <= Box_Center_curRow[2];
						Box_Center_curRow[3] <= Box_Center_curRow[2];
						Box_Center_curCol[0] <= Box_Center_curCol[0]-4'd1;
						Box_Center_curCol[1] <= Box_Center_curCol[0];
						Box_Center_curCol[2] <= Box_Center_curCol[0]+4'd1;
						Box_Center_curCol[3] <= Box_Center_curCol[0]+4'd2;
						Rot_State <= 1'b0;
					end
					
					else if (  (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[0]-4'd2] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[0]-4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[0]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[0]+4'd1] != 1'b1)
							&& (Box_Center_curCol[0] >= 4'd2)
							&& (Box_Center_curCol[0] <= 4'd8))
					begin
						Box_Center_curRow[0] <= Box_Center_curRow[2];
						Box_Center_curRow[1] <= Box_Center_curRow[2];
						Box_Center_curRow[2] <= Box_Center_curRow[2];
						Box_Center_curRow[3] <= Box_Center_curRow[2];
						Box_Center_curCol[0] <= Box_Center_curCol[0]-4'd2;
						Box_Center_curCol[1] <= Box_Center_curCol[0]-4'd1;
						Box_Center_curCol[2] <= Box_Center_curCol[0];
						Box_Center_curCol[3] <= Box_Center_curCol[0]+4'd1;
						Rot_State <= 1'b0;
					end
						
					else if (  (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[0]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[0]+4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[0]+4'd2] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[0]+4'd3] != 1'b1)
							&& (Box_Center_curCol[0] <= 4'd6))
					begin
						Box_Center_curRow[0] <= Box_Center_curRow[2];
						Box_Center_curRow[1] <= Box_Center_curRow[2];
						Box_Center_curRow[2] <= Box_Center_curRow[2];
						Box_Center_curRow[3] <= Box_Center_curRow[2];
						Box_Center_curCol[0] <= Box_Center_curCol[0];
						Box_Center_curCol[1] <= Box_Center_curCol[0]+4'd1;
						Box_Center_curCol[2] <= Box_Center_curCol[0]+4'd2;
						Box_Center_curCol[3] <= Box_Center_curCol[0]+4'd3;
						Rot_State <= 1'b0;
					end
					
					else if (  (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[0]-4'd3] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[0]-4'd2] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[0]-4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[0]] != 1'b1)
							&& (Box_Center_curCol[0] >= 4'd3))
					begin
						Box_Center_curRow[0] <= Box_Center_curRow[2];
						Box_Center_curRow[1] <= Box_Center_curRow[2];
						Box_Center_curRow[2] <= Box_Center_curRow[2];
						Box_Center_curRow[3] <= Box_Center_curRow[2];
						Box_Center_curCol[0] <= Box_Center_curCol[0]-4'd3;
						Box_Center_curCol[1] <= Box_Center_curCol[0]-4'd2;
						Box_Center_curCol[2] <= Box_Center_curCol[0]-4'd1;
						Box_Center_curCol[3] <= Box_Center_curCol[0];
						Rot_State <= 1'b0;
					end
				end
			end
		end
			
		if (Reset)
		begin
			cur_State <= STOP;
		end
		else
			cur_State <= Next_State;	
		
	end
	
	logic [3:0][4:0] NextRow;
	assign NextRow[0] = Box_Center_curRow[0]+5'd1;
	assign NextRow[1] = Box_Center_curRow[1]+5'd1;
	assign NextRow[2] = Box_Center_curRow[2]+5'd1;
	assign NextRow[3] = Box_Center_curRow[3]+5'd1;
	
	int  Row,Column;
	assign Row = (DrawY-10'd31)/10'd21+10'd4;
	assign Column = (DrawX-10'd215)/10'd21;
	
    int DistX, DistY, Size;
    assign Size = 10'd9;
	
	always_comb
	begin
		unique case (cur_State)
			STOP:
			begin
				if (Active)
					Next_State = FALL;
				else
					Next_State = STOP;
			end
			
			FALL:
			begin
				if (touch)
				begin
					if (frame_clk_rising_edge)
						Next_State = TOUCH;
					else
						Next_State = FALL;
				end
				else
					Next_State = FALL;
			end
			
			TOUCH:
			begin
				Next_State = STOP;
			end
			
			default:
				Next_State = STOP;
		endcase

		
		if (Static_arr[NextRow[0]][Box_Center_curCol[0]] == 1'b1)
			touch = 1'b1;
		else if (Static_arr[NextRow[1]][Box_Center_curCol[1]] == 1'b1)
			touch = 1'b1;
		else if (Static_arr[NextRow[2]][Box_Center_curCol[2]] == 1'b1)
			touch = 1'b1;
		else if (Static_arr[NextRow[3]][Box_Center_curCol[3]] == 1'b1)
			touch = 1'b1;
		else if (Box_Center_curRow[0] == 5'd23)
			touch = 1'b1;
		else if (Box_Center_curRow[1] == 5'd23)
			touch = 1'b1;
		else if (Box_Center_curRow[2] == 5'd23)
			touch = 1'b1;
		else if (Box_Center_curRow[3] == 5'd23)
			touch = 1'b1;
		else
			touch = 1'b0;
			
		case (cur_State)
			STOP:
			begin
				En_New_Static = 1'b0;
				State_onehot = 3'b001;
			end
			FALL:
			begin
				En_New_Static = 1'b0;
				State_onehot = 3'b010;
			end
			TOUCH:
			begin
				En_New_Static = 1'b1;
				State_onehot = 3'b100;
			end
			default: ;
		endcase

		if ((Box_Center_curCol[0]==Column)&&(Box_Center_curRow[0]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else if ((Box_Center_curCol[1]==Column)&&(Box_Center_curRow[1]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else if ((Box_Center_curCol[2]==Column)&&(Box_Center_curRow[2]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else if ((Box_Center_curCol[3]==Column)&&(Box_Center_curRow[3]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else
		begin
			DistX = 20;
			DistY = 20;
		end
	end
	
    always_comb
	begin
       if ( (DistX*DistX<=Size*Size) && (DistY*DistY<=Size*Size) )
           Color_Dynamic = 3'b011;
       else
           Color_Dynamic = 3'b000;

   end
	
endmodule

// The Square-shaped Block
module O_block ( input Clk,
					   frame_clk,
					   Reset,
					   Active,
					   LEFT, RIGHT, UP, DOWN, NULL,
				 input [9:0] DrawX, DrawY,
				 input [23:0][15:0] Static_arr,
				 output En_New_Static,
				 output [3:0][4:0] New_Static_Row,
				 output [3:0][3:0] New_Static_col,
				 output [2:0] Color_Dynamic,
				 output [2:0] State_onehot
);

	
	logic [3:0][4:0] Box_Center_initRow;
	logic [3:0][3:0] Box_Center_initCol;
	logic [3:0][4:0] Box_Center_curRow;
	logic [3:0][3:0] Box_Center_curCol;
	logic touch;
	logic [15:0][9:0] Box_X_C;
	logic [23:0][9:0] Box_Y_C;
	
	// Initial Position: Need Modify
	//    x x
	//    x x

	assign Box_Center_initRow[0] = 5'd0;
	assign Box_Center_initRow[1] = 5'd0;
	assign Box_Center_initRow[2] = 5'd1;
	assign Box_Center_initRow[3] = 5'd1;
	assign Box_Center_initCol[0] = 4'd7;
	assign Box_Center_initCol[1] = 4'd8;
	assign Box_Center_initCol[2] = 4'd7;
	assign Box_Center_initCol[3] = 4'd8;

	// same as previous module
	assign New_Static_Row[0] = Box_Center_curRow[0];
	assign New_Static_Row[1] = Box_Center_curRow[1];
	assign New_Static_Row[2] = Box_Center_curRow[2];
	assign New_Static_Row[3] = Box_Center_curRow[3];
	assign New_Static_col[0] = Box_Center_curCol[0];
	assign New_Static_col[1] = Box_Center_curCol[1];
	assign New_Static_col[2] = Box_Center_curCol[2];
	assign New_Static_col[3] = Box_Center_curCol[3];
	
	// same as previous module
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
	
	// same as previous module
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
	
	enum logic [2:0] {STOP, FALL, TOUCH}	cur_State, Next_State;
	
   // Detect rising edge of frame_clk
	logic frame_clk_prev, frame_clk_rising_edge;
	always_ff @ (posedge Clk)
	begin
		frame_clk_prev <= frame_clk;
		frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_prev == 1'b0);
	end
	
	always_ff @ (posedge Clk)
	begin
		if (frame_clk_rising_edge)
			case (cur_State)
				STOP:
				begin
					Box_Center_curRow[0] <= Box_Center_initRow[0];
					Box_Center_curRow[1] <= Box_Center_initRow[1];
					Box_Center_curRow[2] <= Box_Center_initRow[2];
					Box_Center_curRow[3] <= Box_Center_initRow[3];
					Box_Center_curCol[0] <= Box_Center_initCol[0];
					Box_Center_curCol[1] <= Box_Center_initCol[1];
					Box_Center_curCol[2] <= Box_Center_initCol[2];
					Box_Center_curCol[3] <= Box_Center_initCol[3];
				end
				
				FALL:
					if (~touch)
					begin
						Box_Center_curRow[0] <= Box_Center_curRow[0]+5'd1;
						Box_Center_curRow[1] <= Box_Center_curRow[1]+5'd1;
						Box_Center_curRow[2] <= Box_Center_curRow[2]+5'd1;
						Box_Center_curRow[3] <= Box_Center_curRow[3]+5'd1;
					end
				
				TOUCH: ;
				default: ;
			endcase
			
		if (cur_State == FALL)
			begin
				if (LEFT)
				begin
					if (       (Static_arr[Box_Center_curRow[0]][Box_Center_curCol[0]-4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]-4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]-4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[3]][Box_Center_curCol[3]-4'd1] != 1'b1)
							&& (Box_Center_curCol[0] != 4'd0)
							&& (Box_Center_curCol[1] != 4'd0)
							&& (Box_Center_curCol[2] != 4'd0)
							&& (Box_Center_curCol[3] != 4'd0))
					begin
						Box_Center_curCol[0] <= Box_Center_curCol[0]-4'd1;
						Box_Center_curCol[1] <= Box_Center_curCol[1]-4'd1;
						Box_Center_curCol[2] <= Box_Center_curCol[2]-4'd1;
						Box_Center_curCol[3] <= Box_Center_curCol[3]-4'd1;
					end
				end
				
				else if (RIGHT)
				begin
					if (       (Static_arr[Box_Center_curRow[0]][Box_Center_curCol[0]+4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[1]][Box_Center_curCol[1]+4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]][Box_Center_curCol[2]+4'd1] != 1'b1)
							&& (Static_arr[Box_Center_curRow[3]][Box_Center_curCol[3]+4'd1] != 1'b1)
							&& (Box_Center_curCol[0] != 4'd15)
							&& (Box_Center_curCol[1] != 4'd15)
							&& (Box_Center_curCol[2] != 4'd15)
							&& (Box_Center_curCol[3] != 4'd15))
					begin
						Box_Center_curCol[0] <= Box_Center_curCol[0]+4'd1;
						Box_Center_curCol[1] <= Box_Center_curCol[1]+4'd1;
						Box_Center_curCol[2] <= Box_Center_curCol[2]+4'd1;
						Box_Center_curCol[3] <= Box_Center_curCol[3]+4'd1;
					end
				end
				
				else if (DOWN)
				begin
					if (       (Static_arr[Box_Center_curRow[0]+5'd1][Box_Center_curCol[0]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[1]+5'd1][Box_Center_curCol[1]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]+5'd1][Box_Center_curCol[2]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[3]+5'd1][Box_Center_curCol[3]] != 1'b1)
							&& (Box_Center_curRow[0] != 5'd23)
							&& (Box_Center_curRow[1] != 5'd23)
							&& (Box_Center_curRow[2] != 5'd23)
							&& (Box_Center_curRow[3] != 5'd23))
					begin
						Box_Center_curRow[0] <= Box_Center_curRow[0]+5'd1;
						Box_Center_curRow[1] <= Box_Center_curRow[1]+5'd1;
						Box_Center_curRow[2] <= Box_Center_curRow[2]+5'd1;
						Box_Center_curRow[3] <= Box_Center_curRow[3]+5'd1;
					end
				end
				
				else if (NULL)
				begin
					if (       (Static_arr[Box_Center_curRow[0]+5'd1][Box_Center_curCol[0]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[1]+5'd1][Box_Center_curCol[1]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[2]+5'd1][Box_Center_curCol[2]] != 1'b1)
							&& (Static_arr[Box_Center_curRow[3]+5'd1][Box_Center_curCol[3]] != 1'b1)
							&& (Box_Center_curRow[0] != 5'd23)
							&& (Box_Center_curRow[1] != 5'd23)
							&& (Box_Center_curRow[2] != 5'd23)
							&& (Box_Center_curRow[3] != 5'd23))
					begin
						Box_Center_curRow[0] <= Box_Center_curRow[0]+5'd1;
						Box_Center_curRow[1] <= Box_Center_curRow[1]+5'd1;
						Box_Center_curRow[2] <= Box_Center_curRow[2]+5'd1;
						Box_Center_curRow[3] <= Box_Center_curRow[3]+5'd1;
					end
				end
			end

		
		if (Reset) 
			cur_State <= STOP;
		else 
			cur_State <= Next_State;			
		
	end
	
	logic [3:0][4:0] NextRow;
	assign NextRow[0] = Box_Center_curRow[0]+5'd1;
	assign NextRow[1] = Box_Center_curRow[1]+5'd1;
	assign NextRow[2] = Box_Center_curRow[2]+5'd1;
	assign NextRow[3] = Box_Center_curRow[3]+5'd1;
	
	int  Row,Column;
	assign Row = (DrawY-10'd31)/10'd21+10'd4;
	assign Column = (DrawX-10'd215)/10'd21;
	
    int DistX, DistY, Size;
    assign Size = 10'd9;
	
	always_comb
	begin
		unique case (cur_State)
			STOP:
			begin
				if (Active)
					Next_State = FALL;
				else
					Next_State = STOP;
			end
			
			FALL:
			begin
				if (touch)
				begin
					if (frame_clk_rising_edge)
						Next_State = TOUCH;
					else
						Next_State = FALL;
				end
				else
					Next_State = FALL;
			end
			
			TOUCH:
			begin
				Next_State = STOP;
			end
			
			default:
				Next_State = STOP;
		endcase

		if (Static_arr[NextRow[0]][Box_Center_curCol[0]] == 1'b1)
			touch = 1'b1;
		else if (Static_arr[NextRow[1]][Box_Center_curCol[1]] == 1'b1)
			touch = 1'b1;
		else if (Static_arr[NextRow[2]][Box_Center_curCol[2]] == 1'b1)
			touch = 1'b1;
		else if (Static_arr[NextRow[3]][Box_Center_curCol[3]] == 1'b1)
			touch = 1'b1;
		else if (Box_Center_curRow[0] == 5'd23)
			touch = 1'b1;
		else if (Box_Center_curRow[1] == 5'd23)
			touch = 1'b1;
		else if (Box_Center_curRow[2] == 5'd23)
			touch = 1'b1;
		else if (Box_Center_curRow[3] == 5'd23)
			touch = 1'b1;
		else
			touch = 1'b0;
			
		case (cur_State)
			STOP:
			begin
				En_New_Static = 1'b0;
				State_onehot = 3'b001;
			end
			FALL:
			begin
				En_New_Static = 1'b0;
				State_onehot = 3'b010;
			end
			TOUCH:
			begin
				En_New_Static = 1'b1;
				State_onehot = 3'b100;
			end
			default: ;
		endcase
		
			
		if ((Box_Center_curCol[0]==Column)&&(Box_Center_curRow[0]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else if ((Box_Center_curCol[1]==Column)&&(Box_Center_curRow[1]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else if ((Box_Center_curCol[2]==Column)&&(Box_Center_curRow[2]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else if ((Box_Center_curCol[3]==Column)&&(Box_Center_curRow[3]==Row))
		begin
			DistX = DrawX - Box_X_C[Column];
			DistY = DrawY - Box_Y_C[Row];
		end
		else
		begin
			DistX = 20;
			DistY = 20;
		end
	end
	
   always_comb
	begin
       if ( (DistX*DistX<=Size*Size) && (DistY*DistY<=Size*Size) )
           Color_Dynamic = 3'b011;
       else
           Color_Dynamic = 3'b000;
   end
	
endmodule
