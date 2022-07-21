//-------------------------------------------------------------------------
//      lab8.sv                                                          --
//      Christine Chen                                                   --
//      Fall 2014                                                        --
//                                                                       --
//      Modified by Po-Han Huang                                         --
//      10/06/2017                                                       --
//                                                                       --
//      Fall 2017 Distribution                                           --
//                                                                       --
//      For use with ECE 385 Lab 8                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module final_toplevel( input               CLOCK_50,
                       input        [3:0]  KEY,          //bit 0 is set up as Reset
				       output		  [3:0]	LEDG,
                       output logic [6:0]  HEX0, HEX1,
             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
             
			 // CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
             
			 // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK,      //SDRAM Clock
				 
				 input AUD_ADCDAT,
				 input AUD_DACLRCK,
				 input AUD_ADCLRCK,
				 input AUD_BCLK,
				 output logic AUD_DACDAT,
				 output logic AUD_XCK,
				 output logic I2C_SCLK,
				 output logic I2C_SDAT
                    );
    
    logic Reset_h, Clk;
    logic [7:0] keycode;
	 logic [9:0] DrawX,DrawY;
	 logic [2:0] Color_Static, Color_Dynamic, Color, New_Static_Color, Color_UI;
	 logic [23:0][15:0] Static_arr;
	 logic frame_clk_1;
	 logic INIT,data_over,INIT_FINISH;
	 logic [16:0]Addr;
	 logic [16:0]music_note;
	 logic adc_full;
	 
	 
	 
	 // Need Modify
	 logic [2:0] Color_O_Block, Color_T_Block, Color_RL_Block, Color_LL_Block, Color_RF_Block, Color_LF_Block, Color_I_Block;
	 logic En_New_Static, En_O_block, En_T_block, En_RL_block, En_RF_block, En_LL_block, En_LF_block, En_I_block;	 
	 logic [3:0][4:0] New_Static_Row, New_Static_Row_O, New_Static_Row_T, New_Static_Row_RL, New_Static_Row_RF, New_Static_Row_LL, New_Static_Row_LF, New_Static_Row_I;
	 logic [3:0][3:0] New_Static_col, New_Static_col_O, New_Static_col_T, New_Static_col_RL, New_Static_col_RF, New_Static_col_LL, New_Static_col_LF, New_Static_col_I;
	 logic Active_O_block, Active_T_block, Active_RL_block, Active_RF_block, Active_LL_block, Active_LF_block, Active_I_block, Active;
	 logic LEFT, RIGHT, UP, DOWN, NULL, ENTER, START;
	 logic Win, Lose;
	 logic [2:0] randnum;
	 logic [5:0] Line_Count;
	 logic [6:0] Fall_Count, Score;
	 logic [2:0] Game_State, State_O_block, State_T_block, State_RL_block, State_RF_block, State_LL_block, State_LF_block, State_I_block;
	 
	 assign Color = Color_Static | Color_Dynamic | Color_UI;
	 assign LEDG[3:1] = randnum;
	 assign LEDG[0] = frame_clk_1;
	 
    assign Clk = CLOCK_50;
	 
	logic [28:0] loss_counter = 29'b0;  // since the CLK frequency is 50MHz, the "loss" sign will stay for 2^28 / 50M = 5.3687s
	 
    always_ff @ (posedge Clk) 
	 begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
		  if (Lose) begin
		      loss_counter = loss_counter + 1;
		  end
		  if (loss_counter[28] == 1'b1) begin
				Reset_h <= 1'b1;
				loss_counter = 29'b0;
		  end
    end
    
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs, hpi_reset;
    
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(Clk),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            .from_sw_reset(hpi_reset),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),
                            .OTG_RST_N(OTG_RST_N)
    );
     
     final_soc nios_system(
                             .clk_clk(Clk),         
                             .reset_reset_n(1'b1),    // Never reset NIOS
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_clk_clk(DRAM_CLK),
                             .keycode_export(keycode),  
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w),
                             .otg_hpi_reset_export(hpi_reset)
    );
    

    vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));
    
    VGA_controller vga_controller_instance(.*, .Reset(Reset_h));
	 
	 kbinput as_instance (.*, .frame_clk(frame_clk_1));
	 
	 // O BLOCK
	 O_block o_instance(
								.*,
								.Active(Active_O_block),
								.Reset(Reset_h),
								.State_onehot(State_O_block),
								.frame_clk(frame_clk_1),
								.Color_Dynamic(Color_O_Block),
								.En_New_Static(En_O_block),
								.New_Static_Row(New_Static_Row_O),
								.New_Static_col(New_Static_col_O)
	 );
	 
	 // T block
	 T_block t_instance(
								.*,
								.Active(Active_T_block),
								.Reset(Reset_h),
								.State_onehot(State_T_block),
								.frame_clk(frame_clk_1),
								.Color_Dynamic(Color_T_Block),
								.En_New_Static(En_T_block),
								.New_Static_Row(New_Static_Row_T),
								.New_Static_col(New_Static_col_T)
	 );
	 
	 
	 // I block
	 I_block i_instance(
								.*,
								.Active(Active_I_block),
								.Reset(Reset_h),
								.State_onehot(State_I_block),
								.frame_clk(frame_clk_1),
								.Color_Dynamic(Color_I_Block),
								.En_New_Static(En_I_block),
								.New_Static_Row(New_Static_Row_I),
								.New_Static_col(New_Static_col_I)
	 );
	 
	 // LL block
	 LL_block ll_instance(
								.*,
								.Active(Active_LL_block),
								.Reset(Reset_h),
								.State_onehot(State_LL_block),
								.frame_clk(frame_clk_1),
								.Color_Dynamic(Color_LL_Block),
								.En_New_Static(En_LL_block),
								.New_Static_Row(New_Static_Row_LL),
								.New_Static_col(New_Static_col_LL)
	 );
	 
	 // RL block
	 RL_block rl_instance(
								.*,
								.Active(Active_RL_block),
								.Reset(Reset_h),
								.State_onehot(State_RL_block),
								.frame_clk(frame_clk_1),
								.Color_Dynamic(Color_RL_Block),
								.En_New_Static(En_RL_block),
								.New_Static_Row(New_Static_Row_RL),
								.New_Static_col(New_Static_col_RL)
	 );
	 
	 // LF block
	 LF_block lf_instance(  .*,
							.Active(Active_LF_block),
							.Reset(Reset_h),
							.State_onehot(State_LF_block),
							.frame_clk(frame_clk_1),
							.Color_Dynamic(Color_LF_Block),
							.En_New_Static(En_LF_block),
							.New_Static_Row(New_Static_Row_LF),
							.New_Static_col(New_Static_col_LF)
	 );
	 	 
	 // RF block
	 RF_block rf_instance(  .*,
							.Active(Active_RF_block),
							.Reset(Reset_h),
							.State_onehot(State_RF_block),
							.frame_clk(frame_clk_1),
							.Color_Dynamic(Color_RF_Block),
							.En_New_Static(En_RF_block),
							.New_Static_Row(New_Static_Row_RF),
							.New_Static_col(New_Static_col_RF)
	 );

	static_box_array static_instance(   .*,
										.Reset(Reset_h),
										.frame_clk(frame_clk_1)
	);
	 

	audio Audio_istance (.*, .Reset(Reset_h));
	 
	music music_instance(.*);
	 

	audio_interface music ( .LDATA (music_content),
						    .RDATA (music_content),
							.Clk(Clk),
							.Reset(Reset_h),
							.INIT(INIT),
							.INIT_FINISH(INIT_FINISH),
							.adc_full (adc_full),
							.data_over(data_over),
							.AUD_MCLK(AUD_XCK),
							.AUD_BCLK(AUD_BCLK),
							.AUD_ADCDAT(AUD_ADCDAT),
							.AUD_DACDAT(AUD_DACDAT),
							.AUD_DACLRCK(AUD_DACLRCK),
							.AUD_ADCLRCK(AUD_ADCLRCK),
							.I2C_SDAT(I2C_SDAT),
							.I2C_SCLK(I2C_SCLK),
							.ADCDATA(ADCDATA),
	);
	 
	total_dynamic total_dynamic_instance(.*);

	userinterface ui_instance(.*);
	 
	color_mapper color_instance(.*);
	 
	frame_clk_generator frameclk_instance(.*, .Reset(Reset_h), .frame_clk_in(VGA_VS), .frame_clk_out(frame_clk_1));
	 
	randnumbergenerator randnumbergenerator_instance (.*, .Reset(Reset_h), .frame_clk(frame_clk_1));
 
    // Display keycode on hex display
    HexDriver hex_inst_0 (Line_Count%7'd10, HEX0);
    HexDriver hex_inst_1 (Line_Count/7'd10, HEX1);
    
endmodule
