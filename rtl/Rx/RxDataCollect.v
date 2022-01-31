`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/29/2022 02:55:57 PM
// Design Name: 
// Module Name: RxDataCollect
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RxDataCollect(
input clk,
input rstn,

input [11:0] RxData,
input        RxValid,
input [15:0] RxAdd,
input        RxAddValid,

input        Out_Off_Link,

input  [11:0] LineNum,
output        ReceivedPkt,
//output ZeroPadOn,

output        WriteMemEn   , 
output [15:0] WMadd,   
output [11:0] WriteMemData    
    );

reg Reg_ZeroPadOn;
reg [7:0] ZeroPadCount;
reg [19:0] Reg_Pck_WD_count;
always @(posedge clk or negedge rstn) 
    if (!rstn) Reg_Pck_WD_count <= 20'h00000;
     else if (RxValid) Reg_Pck_WD_count <= 20'h00000;
     else if (ZeroPadCount == 8'h50) Reg_Pck_WD_count <= 20'h00000;
     else if (Reg_Pck_WD_count == 20'h23500) Reg_Pck_WD_count <= 20'h23500;
     else Reg_Pck_WD_count <= Reg_Pck_WD_count + 1;

always @(posedge clk or negedge rstn) 
    if (!rstn) Reg_ZeroPadOn <= 1'b0;
     else if (Reg_Pck_WD_count == 20'h234ff) Reg_ZeroPadOn <= 1'b1;
     else if (ZeroPadCount == 8'h4f) Reg_ZeroPadOn <= 1'b0;
     
always @(posedge clk or negedge rstn) 
    if (!rstn) ZeroPadCount <= 8'h00;
     else if (!Reg_ZeroPadOn) ZeroPadCount <= 8'h00; 
     else ZeroPadCount <= ZeroPadCount + 1; 
// Write memory address
reg [15:0] NextLineAdd;
always @(posedge clk or negedge rstn) 
    if (!rstn) NextLineAdd <= 16'h0050;
     else if (Out_Off_Link && (NextLineAdd == 16'h9600)) NextLineAdd <= 16'h0050;
     else if (RxAddValid) NextLineAdd <= RxAdd + 16'h0050;
     else if (Reg_Pck_WD_count == 20'h234ff) NextLineAdd <= NextLineAdd + 16'h0050;
     else if (NextLineAdd == 16'h9600) NextLineAdd <= 16'h9600;
    
reg [15:0] Reg_WMadd;
always @(posedge clk or negedge rstn) 
    if (!rstn) Reg_WMadd <= 16'h0000;
     else if (Out_Off_Link && (Reg_WMadd == 16'h9600)) Reg_WMadd <= 16'h0000;
     else if (RxAddValid)  Reg_WMadd <= RxAdd; 
     else if (Reg_WMadd == 16'h9600) Reg_WMadd <= 16'h9600;
     else if (RxValid)   Reg_WMadd <= Reg_WMadd + 1;
     else if (Reg_ZeroPadOn)   Reg_WMadd <= Reg_WMadd + 1;
     else if (Reg_Pck_WD_count == 20'h234ff)  Reg_WMadd <= NextLineAdd; 

//assign ZeroPadOn = Reg_ZeroPadOn;
assign WriteMemEn   = (Reg_ZeroPadOn) ? Reg_ZeroPadOn : RxValid;    
assign WMadd        = Reg_WMadd;  
assign WriteMemData = (Reg_ZeroPadOn) ?   12'h000 : RxData;    

reg [479:0] Reg_Getpkt;
wire [15:0] CheckAdd[0:479];
genvar i;
generate 
    for (i=0;i<480;i=i+1) begin 
    assign CheckAdd[i] = 16'h0005 + (8'h50*i);
        always @(posedge clk or negedge rstn) 
            if (!rstn) Reg_Getpkt[i] <= 1'b0;
             else if (Out_Off_Link) Reg_Getpkt[i] <= 1'b0;
             else if ((WMadd == CheckAdd[i]) && Reg_ZeroPadOn) Reg_Getpkt[i] <= 1'b0;
             else if (WMadd == CheckAdd[i]) Reg_Getpkt[i] <= 1'b1;
    end
endgenerate     

assign ReceivedPkt = Reg_Getpkt[LineNum];
    
endmodule
