`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:24:00 06/09/2015 
// Design Name: 
// Module Name:    MultiCycleCpu 
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
module MultiCycleCpu(
input clk,
input clk_50M,
input rst_n,

//extra
input[4:0] RegNum,
output[31:0] RegData,
output[31:0] ProgramCounter,
output[15:0] ExtraOut,
output reg[31:0] IR,

output hsync, //行同步信号
output vsync, //场同步信号
output vga_r,
output vga_g,
output vga_b
    );
/*
reg clk;
reg clk_50M;
reg rst_n;
reg[4:0] RegNum;

initial begin
	// Initialize Inputs
	clk = 0;
	clk_50M = 0;
	clk = 0;
	// Wait 100 ns for global reset to finish
	#100;
       
	// Add stimulus here
end

always#10 begin
	clk_50M = ~clk_50M;
end
always#20 begin
	clk = ~clk;
end*/

//PC
reg[31:0] PC;
initial begin
	PC <=0;
end
//Countrol Unit
wire[5:0] opcode,func;
wire 
PCWrite,
PCWriteCond,
IorD,
MemWrite,
IRWrite,
ALUSrcA,
RegWrite,
SaveHalf,
LoadHalf;
wire[1:0] RegDst,ALUop, ALUSrcB, PCSource,WriteData;
wire[4:0] state;
ControlUnit cu (
    .clk(clk), 
    .opcode(opcode), 
	 .func(func),
    .PCWrite(PCWrite), 
    .PCWriteCond(PCWriteCond), 
    .IorD(IorD), 
    .MemWrite(MemWrite), 
    .WriteData(WriteData), 
    .IRWrite(IRWrite), 
    .ALUSrcA(ALUSrcA), 
    .RegWrite(RegWrite), 
    .RegDst(RegDst), 
    .SaveHalf(SaveHalf), 
    .LoadHalf(LoadHalf), 
    .ALUop(ALUop), 
    .ALUSrcB(ALUSrcB), 
    .PCSource(PCSource),
	 .state(state)
    );
assign ProgramCounter = {11'b0,state[4:0],PC[15:0]};

//MMU
wire[31:0] readData; 
wire[31:0] memWdata;
wire[31:0] addr;
MemoryManagerUnit MMU (
    .clk(clk), 
    .clk_50M(clk_50M), 
    .addr(addr[14:0]), 
    .we(MemWrite), 
    .sh(SaveHalf), 
    .lh(LoadHalf), 
    .writeData(memWdata), 
    .rst_n(rst_n), 
    .readData(readData), 
    .hsync(hsync), 
    .vsync(vsync), 
    .vga_r(vga_r), 
    .vga_g(vga_g), 
    .vga_b(vga_b)
    );
reg[31:0] MDR;
//reg[31:0] IR;
assign opcode = IR[31:26];
assign func = IR[5:0];
always @(posedge clk) begin
	MDR <= readData;
	if(IRWrite) begin
		IR <= readData;
	end
end

//Register File
wire[4:0] WR;
wire[31:0] regWdata,Rdata1,Rdata2;
assign WR = {5{(RegDst==2'b00)}} & IR[20:16] |
            {5{(RegDst==2'b01)}} & IR[15:11] |
				{5{(RegDst==2'b10)}} & 5'd31;
RegisterFile regFile (
    .clk(clk), 
    .R1(IR[25:21]), 
    .R2(IR[20:16]), 
    .WR(WR), 
    .Wdata(regWdata), 
    .we(RegWrite), 
    .Rdata1(Rdata1), 
    .Rdata2(Rdata2), 
    .R3(RegNum), 
    .Rdata3(RegData)
    );
reg[31:0] A;
reg[31:0] B;
always @(posedge clk) begin
	A <= Rdata1;
	B <= Rdata2;
end

//ALU
wire[31:0] srcA, srcB, SignExtendedImmediateNum, offset32, result;
wire ZF;
assign SignExtendedImmediateNum = { {16{IR[15]}}, IR[15:0]};
assign offset32 = {SignExtendedImmediateNum[30:0],1'b0};
assign srcA = ALUSrcA? A : PC;
assign srcB =  {32{(ALUSrcB == 2'b00)}} & B     |
					{32{(ALUSrcB == 2'b01)}} & 32'h2 |
					{32{(ALUSrcB == 2'b10)}} & SignExtendedImmediateNum     |
					{32{(ALUSrcB == 2'b11)}} & offset32;		
ALU alu (
    .A(srcA), 
    .B(srcB), 
    .ALUop(ALUop), 
    .Func(IR[5:0]), 
    .result(result), 
    .ZF(ZF)
    );
reg[31:0] ALUout;
always @(posedge clk) begin 
	ALUout <= result;
end

//circuit
assign addr = IorD? ALUout : PC;
assign memWdata = B;
assign regWdata = {32{(WriteData == 2'b00)}} & ALUout |
					   {32{(WriteData == 2'b01)}} & MDR |
					   {32{(WriteData == 2'b10)}} & PC;
always @(posedge clk) begin 
	if( PCWrite | (PCWriteCond & ZF)) begin
		case(PCSource)
			2'b00: begin
				PC <= result;
			end
			2'b01: begin
				PC <= ALUout;
			end
			2'b10: begin
				PC <= {PC[31:27],IR[25:0],1'b0};
			end
			2'b11: begin
				PC <= A;
			end
		endcase
	end
end

/*
initial begin
	clk = 0;
	clk_50M = 0;
	rst_n = 1;
	RegNum = 19;
end
always#10
	clk_50M = ~clk_50M;
always#50
	clk = ~clk;
	*/
endmodule
