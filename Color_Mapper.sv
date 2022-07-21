//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper ( input        [2:0] Color,            // Whether current pixel belongs to ball 
                                                              //   or background (computed in ball.sv)
                       input        [9:0] DrawX, DrawY,       // Current pixel coordinates
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
    
    logic [7:0] Red, Green, Blue;
    
    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
    
    // Assign color based on is_ball signal
    always_comb
    begin
        if (Color == 3'b000)
        begin
            // Black
            Red = 8'h00;
            Green = 8'h00;
            Blue = 8'h00;
        end
		  
		  else if (Color == 3'b111)
		  begin
            // White
            Red = 8'hff;
            Green = 8'hff;
            Blue = 8'hff;
		  end
		  
        else if (Color == 3'b001) 
        begin
            // Red
            Red = 8'hff; 
            Green = 8'h00;
            Blue = 8'h00;
        end
		  
        else if (Color == 3'b010) 
        begin
            // Green
            Red = 8'h00; 
            Green = 8'hff;
            Blue = 8'h00;
        end
		  
		  
		  else if (Color == 3'b011)
		  begin
			// Blue
			Red = 8'h00; 
            Green = 8'h00;
            Blue = 8'hff;
		  end
		  
			// mixed color in the following
		  
		  else if (Color == 3'b100)
		  begin 
			Red = 8'hff; 
            Green = 8'h00;
            Blue = 8'hff; 
		  end
		  
		  else if (Color == 3'b110)
		  begin
			Red = 8'hff; 
            Green = 8'hff;
            Blue = 8'h00;
		  end
		  
		  else if (Color == 3'b101)
		  begin
			Red = 8'h00; 
            Green = 8'hff;
            Blue = 8'hff;
		  end
		  
		  else
		  begin
			Red = 8'h00;
            Green = 8'h00;
            Blue = 8'h00;
		  end
    
	 end
	 
endmodule
