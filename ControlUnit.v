`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:25:53 06/10/2015 
// Design Name: 
// Module Name:    ControlUnit 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ControlUnit(
input clk,
input[5:0] opcode,
input[5:0] func,
output PCWrite,
output PCWriteCond,
output IorD,
output MemWrite,
output[1:0] WriteData,
output IRWrite,
output ALUSrcA,
output RegWrite,
output[1:0] RegDst,
output SaveHalf,
output LoadHalf,
output[1:0] ALUop, 
output[1:0] ALUSrcB, 
output[1:0] PCSource,
output reg[4:0] state
    );
initial begin
	state <= 0;
end

wire R,LW,SW,BEQ,J,ADDI,LH,SH;
assign R   =(opcode==6'h0);
assign LW  =(opcode==6'h23);
assign SW  =(opcode==6'h2B);
assign BEQ =(opcode==6'h4);
assign J   =(opcode==6'h2);
assign ADDI=(opcode==6'h8);
assign LH  =(opcode==6'h21);
assign SH  =(opcode==6'h29);
assign JR  =(opcode==6'h0 && func==6'h8);
assign JAL =(opcode==6'h03);
always @(posedge clk) begin
	case(state)
		0: begin 
			state <= 1;
		end
		1: begin 
			if(LW | SW | ADDI | LH | SH) begin
				state <= 2;
			end
			else if (R)begin
				if(JR) begin
					state <= 14;
				end
				else begin
					state <= 6;
				end
			end
			else if (BEQ) begin
				state <= 8;
			end
			else if (J) begin
				state <= 9;
			end 
			else if(JAL) begin
				state <= 13;
			end
		end
		2: begin 
			if (LW)begin
				state <= 3;
			end
			else if (SW)begin
				state <= 5;
			end
			else if (SH)begin
				state <= 11;
			end
			else if (LH)begin
				state <= 10;
			end
			else if (ADDI)begin
				state <= 12;
			end
		end
		3: begin 
			state <= 4;
		end
		4: begin 
			state <= 0;
		end
		5: begin 
			state <= 0;
		end
		6: begin 
			state <= 7;
		end
		7: begin 
			state <= 0;
		end
		8: begin 
			state <= 0;
		end
		9: begin 
			state <= 0;
		end
		10: begin 
			state <= 4;
		end
		11: begin 
			state <= 0;
		end
		12: begin 
			state <= 0;
		end
		13: begin
			state <=0;
		end
		14: begin
			state <= 0;
		end
		default: begin
			state <= 0;
		end
	endcase
end

wire state0, state1,state2,state3,state4,state5,state6,state7,state8,state9,state10,state11,state12,state13,state14;

assign state0 = (state == 0);
assign state1 = (state == 1);
assign state2 = (state == 2);
assign state3 = (state == 3);
assign state4 = (state == 4);
assign state5 = (state == 5);
assign state6 = (state == 6);
assign state7 = (state == 7);
assign state8 = (state == 8);
assign state9 = (state == 9);
assign state10 = (state == 10);
assign state11 = (state == 11);
assign state12 = (state == 12);
assign state13 = (state == 13);
assign state14 = (state == 14);

assign PCWrite = state0 | state9 | state13 | state14;
assign PCWriteCond = state8;
assign IorD = state3 | state5 | state10 | state11;
assign MemWrite = state5 | state11;
assign WriteData[0] = state4;
assign WriteData[1] = state13;
assign IRWrite = state0;
assign ALUop[1] = state6;
assign ALUop[0] = state8;
assign ALUSrcA = state2 | state6 | state8;
assign ALUSrcB[1] = state1 | state2;
assign ALUSrcB[0] = state0 | state1;
assign RegWrite = state4 | state7 | state12 | state13;
assign RegDst[0] = state7;
assign RegDst[1] = state13;
assign SaveHalf = state11;
assign LoadHalf = state10;
assign PCSource[1] = state9 | state13 | state14;
assign PCSource[0] = state8 | state14;
endmodule
