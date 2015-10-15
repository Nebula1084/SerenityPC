`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:06:45 03/31/2015 
// Design Name: 
// Module Name:    Adder64 
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
module Adder64(
    input [63:0] A,
    input [63:0] B,
    input C0,
    output [3:0] P,
    output [3:0] G,
    output [63:0] sum,
    output SF,
    output CF,
    output OF,
    output PF,
    output ZF
    );
wire[15:0] p,g;
wire[4:0] C;
wire[3:0] sf,cf,of,pf,zf;

pg_to_PG pgtoPG(p,g,P,G);
ParallelCarry4 PC(P,G,C0,C);

Adder16	a1(A[15:0],B[15:0],C[0],p[3:0],g[3:0],sum[15:0],sf[0],cf[0],of[0],pf[0],zf[0]),
	a2(A[31:16],B[31:16],C[1],p[7:4],g[7:4],sum[31:16],sf[1],cf[1],of[1],pf[1],zf[1]),
	a3(A[47:32],B[47:32],C[2],p[11:8],g[11:8],sum[47:32],sf[2],cf[2],of[2],pf[2],zf[2]),
	a4(A[63:48],B[63:48],C[3],p[15:12],g[15:12],sum[63:48],sf[3],cf[3],of[3],pf[3],zf[3]);

assign	SF=sf[3],
	CF=C[4],
	OF=of[3],
	PF=^pf[3:0],
	ZF= ~|(~zf[3:0]);

endmodule
