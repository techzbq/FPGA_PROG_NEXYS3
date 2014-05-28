`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:24:55 04/25/2013 
// Design Name: 
// Module Name:    UNLOCK_RDID_ERASE_RDSTATUSREG 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description:    SZY
//FIRST:UNLOCK THE BLOCK 020000  CMD : 0X60  0XD0
//SECOND: READ THE ID, LOCK STATUS; CMD : 0X90  READ
//THIRD: ERASE THE BLOCK 020000  CMD : 0X20 0XD0
//FORTH: READ THE STATUS REGISTER; READ DIRECTLY OR CMD : 0X70   READ OP
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module UNLOCK_RDID_ERASE_RDSTATUSREG(CLK,
												 RESET,
												 CE,
												 WE,
												 OE,
												 ADDR,
												 SHOW,
												 DATA
    );
	 
	 /*THE INPUTS AND OUTPUTS*/
	 input CLK;
	 input RESET;
	 output CE;
	 output WE;
	 output OE;
	 output[23:0] ADDR;
	 output[7:0] SHOW;
	 inout[15:0] DATA;
	 
	 /*REGS HERE*/
	 
	 reg CE = 'b1;
	 reg WE = 'b1;
	 reg OE = 'b1;
	 reg[23:0] ADDR = 'h3f0000;
	 reg[7:0] SHOW = 'h00;
	 reg[15:0] UNLOCK_CMD1 = 'h0060;
	 reg[15:0] UNLOCK_CMD2 = 'h00d0;
	 reg[15:0] RDID_CMD1 = 'h0090;
	 reg[15:0] RDID_OFF = 'h0002;
	 reg[7:0] C_STATE = 'd0;
	 //reg[31:0] count = 'd0;
	 
	 assign DATA = ((C_STATE > 'd4) && (C_STATE < 'd8)) ? UNLOCK_CMD1 : 
						((C_STATE > 'd7) && (C_STATE < 'd11)) ? UNLOCK_CMD2 :
						((C_STATE > 'd10) && (C_STATE < 'd14)) ? RDID_CMD1 :  'hzzzz;
	 
	 /*LOGIC BEGINS HERE*/
	 
	 always @(posedge CLK)
	 begin
	 if(RESET)
	 begin
	 CE <= 'b1;
	 WE <= 'b1;
	 OE <= 'b1;
	 ADDR <= 'h3f0000;
	 SHOW <= 'h00;
//	 count <= 'd0;
	 C_STATE <= 'd0;
	 end
	 case(C_STATE)
	 /*150ns NEED BEFORE WE LOW AFTER RESET*/
	 'd0 : C_STATE <= 'd1;
	 'd1 : C_STATE <= 'd2;
	 'd2 : C_STATE <= 'd3;
	 'd3 : C_STATE <= 'd4;
	 'd4 : C_STATE <= 'd5;
	 /*FIRST UNLOCK THE BLOCK 020000*/
	 'd5 : 
		begin
		CE <= 'b0;
		WE <= 'b0;
		ADDR <= 'h3f0000;
		C_STATE <= 'd6;
		end
	 'd6 : C_STATE <= 'd7;
	 'd7 : 
		begin
		CE <= 'b1;
		WE <= 'b1;
		C_STATE <= 'd8;
		end
	 'd8 :
		begin
		CE <= 'b0;
		WE <= 'b0;
		C_STATE <= 'd9;
		end
	 'd9 : C_STATE <= 'd10;
	 'd10 : 
		begin
		CE <= 'b1;
		WE <= 'b1;
		C_STATE <= 'd11;
		end
	 
		/*BLOCK CAN BE LOCK OR UNLOCK WITH NO LATENCY, SO DO NOT NEED TO WAIT HERE*/
		/*START READ THE ID HERE*/
	 'd11 : 
		begin
		CE <= 'b0;
		WE <= 'b0;
		C_STATE <= 'd12;
		end
	 'd12 : C_STATE <= 'd13;
	 'd13 : 
		begin
		CE <= 'b1;
		WE <= 'b1;
		C_STATE <= 'd14;
		end
	 'd14 : 
		begin
		CE <= 'b0;
		OE <= 'b0;
		ADDR <= ADDR + RDID_OFF;
		C_STATE <= 'd15;
		end
	 /*110ns NEED HERE*/
	 'd15 : C_STATE <= 'd16;
	 'd16 : C_STATE <= 'd17;
	 'd17 : C_STATE <= 'd18;
	 'd18 : 
		begin
		SHOW[7:0] <= DATA[7:0];
		C_STATE <= 'd19;
		end
	 'd19 :
		begin
		CE <= 'b1;
		OE <= 'b1;
		C_STATE <= 'd19;
		end
		
		
	 default : C_STATE <= 'd0;
		
	 endcase
	 end
endmodule
