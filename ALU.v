`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:12:42 05/20/2015 
// Design Name: 
// Module Name:    ALU 
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
module ALU(
input[31:0] A,
input[31:0] B,
input[1:0] ALUop,
input[5:0] Func,
output[31:0] result,
output ZF
    );
//AluControl
wire[2:0] operation;
AluControl aluControl(ALUop,Func,operation);

//AdderAndSubber64
wire AddOrSub,SF,OF;
wire[63:0] AddOrSubResult;
assign AddOrSub = operation[2];
AdderAndSubber64 adder64 (
    .A({ {32{A[31]}}, A}), 
    .B({ {32{B[31]}}, B}), 
    .mode(AddOrSub), 
    .result(AddOrSubResult), 
    .OF(OF), 
    .SF(SF), 
    .ZF(ZF)/*, 
    .CF(CF), 
    .PF(PF)*/
    );
assign result = 
    (operation[1:0]==2'b10)? AddOrSubResult[31:0]:(//add,sub
        (operation[2:0]==3'b000)? A&B : (    //and
            (operation[2:0]==3'b001)? A|B :( //or
                (operation[2:0]==3'b111)? {31'b0,SF^OF} : 0  //slt,default
            )
        )
    ) ;
endmodule
