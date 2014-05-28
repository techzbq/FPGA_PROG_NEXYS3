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
//FIFTH: CLEAR THE STATUS REG
//SIXTH: PROGRAM ONE WORD
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
	 parameter UNLOCK_CMD1 = 'h0060;
	 parameter UNLOCK_CMD2 = 'h00d0;
	 parameter RDID_CMD1 = 'h0090;
	 parameter ERASE_CMD1 = 'h0020;
	 parameter ERASE_CMD2 = 'h00d0;
	 parameter CLEAN_STATUS = 'h0050;
	 parameter RD_STATUSREG = 'h0070;
	 parameter PROGRAM_WORD = 'h0040;
	 reg[15:0] RDID_OFF = 'h0002;
	 reg[7:0] C_STATE = 'd0;
	 reg[15:0] P_DATA = 'h0052;
	 reg[31:0] COUNT_ERASE = 'd0;				//FOR THE ERASE OPERATION
	 reg[31:0] COUNT_PROGRAM = 'd0;			//FOR THE PROGRAM OPERATION
	 reg[31:0] SHOW_COUNT = 'd0;				//FOR THE LEDS SHOW TIME
	 
	 assign DATA = ((C_STATE > 'd4) && (C_STATE < 'd8)) ? UNLOCK_CMD1 : 
						((C_STATE > 'd7) && (C_STATE < 'd11)) ? UNLOCK_CMD2 :
						((C_STATE > 'd10) && (C_STATE < 'd14)) ? RDID_CMD1 :  
						((C_STATE > 'd19) && (C_STATE < 'd23)) ? ERASE_CMD1 : 
						((C_STATE > 'd22) && (C_STATE < 'd26)) ? ERASE_CMD2 : 
						((C_STATE > 'd33) && (C_STATE < 'd37)) ? CLEAN_STATUS : 
						((C_STATE > 'd37) && (C_STATE < 'd41)) ? RD_STATUSREG : 
						((C_STATE > 'd46) && (C_STATE < 'd50)) ? PROGRAM_WORD : 
						((C_STATE > 'd49) && (C_STATE < 'd53)) ? P_DATA : 'hzzzz;
	 
	 /*LOGIC BEGINS HERE*/
	 
	 always @(posedge CLK)
	 begin
	 if(RESET)  	/*SEEMED NOT SUCCEED, RESET NOT WORK*/
	 begin
	 CE <= 'b1;
	 WE <= 'b1;
	 OE <= 'b1;
	 ADDR <= 'h3f0000;
	 SHOW <= 'h00;
	 COUNT_ERASE <= 'd0;
	 COUNT_PROGRAM <= 'd0;
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
		C_STATE <= 'd20;
		end
		
		/*CHECKED UNLOCK AND READ THE ID SUCCEED, NEXT ERASE THE BLOCK */
	 'd20 : 
		begin
		CE <= 'b0;
		WE <= 'b0;
		ADDR <= 'h3f0000; 
		C_STATE <= 'd21;
		end
	 'd21 : C_STATE <= 'd22;			//WRITE THE CMD1
	 'd22 : 
		begin
		CE <= 'b1;
		WE <= 'b1;
		C_STATE <= 'd23;
		end
	 'd23 : 
		begin
		CE <= 'b0;
		WE <= 'b0;
		C_STATE <= 'd24;
		end
	 'd24 : C_STATE <= 'd25;			//WRITE THE CMD2
	 'd25 : 
		begin
		WE <= 'b1;
		CE <= 'b1;
		C_STATE <= 'd26;
		end
	 'd26 : C_STATE <= 'd27;
	 
	 
		/*FIRST WAIT FOR 4S,AND THEN READ THE STATUS REGISTER*/ 
	 'd27 : 
		begin
		if(COUNT_ERASE < 200000000)
		begin
		COUNT_ERASE <= COUNT_ERASE +1;
		C_STATE <= 'd27;
		end 
		else
		begin
		COUNT_ERASE <= 0;
		C_STATE <= 'd28;
		end
		end
		
	/*BEGIN TO READ THE STATUS REGISTER*/
	 'd28 : 
		begin
		CE <= 'b0;
		OE <= 'b0;
		ADDR <= 'h3f0000;
		C_STATE <= 'd29;
		end
	 'd29 : C_STATE <= 'd30;
	 'd30 : C_STATE <= 'd31;
	 'd31 : C_STATE <= 'd32;
	 'd32 : 
		begin
		SHOW[7:0] <= DATA[7:0];
		C_STATE <= 'd33;
		end
	 'd33 : 
		begin
		CE <= 'b1;
		OE <= 'b1;
		C_STATE <= 'd34;
		end
		
	/*CLEAR THE STATUS REGISTER HERE*/
	 'd34 : 
		begin
		CE <= 'b0;
		WE <= 'b0;
		ADDR <= 'h3f000000;
		C_STATE <= 'd35;
		end
	 'd35 : C_STATE <= 'd36;
	 'd36 :
		begin
		CE <= 'b1;
		WE <= 'b1;
		C_STATE <= 'd37;
		end
	 'd37 :
		begin
		//SHOW[7:0] <= DATA[7:0];
		C_STATE <= 'd38;
		end
	 /*AFTER CLEAN THE STATUS REGISTER, SEND THE COMMAND READ IN TO READ THE IDENTIFY*/
	 'd38 : 
		begin
		CE <= 'b0;
		WE <= 'b0;
		ADDR <= 'h3f0000;
		C_STATE <= 'd39;
		end
	 'd39 : C_STATE <= 'd40;
	 'd40 : 
		begin
		CE <= 'b1;
		WE <= 'b1;
		C_STATE <= 'd41;
		end
	 'd41 : 
		begin
		CE <= 'b0;
		OE <= 'b0;
		//ADDR <= ADDR + RDID_OFF;
		C_STATE <= 'd42;
		end
	 'd42 : C_STATE <= 'd43;
	 'd43 : C_STATE <= 'd44;
	 'd44 : C_STATE <= 'd45;
	 'd45 : 
		begin
		SHOW[7:0] <= DATA[7:0];
		C_STATE <= 'd46;
		end
	 'd46 : 
		begin
		CE <= 'b1;
		OE <= 'b1;
		SHOW[7:0] <= 'h00;			//FIRST LET THE SHOW TO BE 0, AND THEN CHECK WETHER THE PROGRAM IS DONE OR NOT
		if(SHOW_COUNT < 'd100000000)
		begin
		SHOW_COUNT <= SHOW_COUNT+1;
		C_STATE <= 'd46;
		end
		else
		begin
		SHOW_COUNT <= 'd0;
		C_STATE <= 'd47;
		end
		end
		
		/*DO THE WORD PROGRAM HERE
		**TWO CYCLE
		**THE FIRST WRITE THE COMMAND 0X40
		**THE SECOND CYCLE: INPUT THE ADDRESS AND THE DATA TO BE WRITEN
		*/
		
	 'd47 : 
		begin
		CE <= 'b0;
		WE <= 'b0;
		ADDR <= 'h3f0000;
		C_STATE <= 'd48;
		end
	 'd48 : C_STATE <= 'd49;
	 'd49 : 
		begin
		CE <= 'b1;
		WE <= 'b1;
		C_STATE <= 'd50;
		end
	 'd50 : 							/*THE SECOND CYCLE START HERE, PREPARE THE DATA AND ADDRESS*/
		begin
		CE <= 'b0;
		WE <= 'b0;
		ADDR <= 'h3f0000;
		C_STATE <= 'd51;
		end
	 'd51 : C_STATE <= 'd52;
	 'd52 : 
		begin
		WE <= 'b1;
		C_STATE <= 'd53;
		end
		
		/*PROGRAM NEED MAX 456us, GIVE 600us HERE*/
	 'd53 : 
		begin
		if(COUNT_PROGRAM < 20000)		//WAIT FOR 600us
			begin
			COUNT_PROGRAM <= COUNT_PROGRAM +1;
			C_STATE <= 'd53;
			end
		else
			/*PROGRAM ENDS HERE, DEASSERT THE CE AND THEN READ THE STATUS REGISTER*/
			begin
			CE <= 'b1;
			COUNT_PROGRAM <= 'd0;
			C_STATE <= 'd54;
			end
		end
	 'd54 : 
		begin
		CE <= 'b0;
		OE <= 'b0;
		C_STATE <= 'd55;
		end
		/*CE HOLD FOR 110ns HERE*/
	 'd55 : C_STATE <= 'd56;
	 'd56 : C_STATE <= 'd57;
	 'd57 : C_STATE <= 'd58;
	 'd58 : 
		begin
		SHOW[7:0] <= DATA[7:0];
		C_STATE <= 'd59;
		end
	 'd59 : 
		begin
		CE <= 'b1;
		OE <= 'b1;
		C_STATE <= 'd59;
		end
		
	/*NEXT: CLEAR THE STATUS REGISTER*/
		
		
	 default : C_STATE <= 'd0;
		
	 endcase
	 end
endmodule
