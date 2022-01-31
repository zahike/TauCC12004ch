`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.09.2021 10:03:14
// Design Name: 
// Module Name: RxMem
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


module RxMem(
input Cclk,
input rstn,

input [47:0] RxData,
input  [3:0] RxValid,
input [63:0] RxAdd,
input  [3:0] RxAddValid,

output PixelClk,

input [3:0] Out_Off_Link,

input HVsync  ,
input HMemRead,
input pVDE    ,
output [23:0] HDMIdata

//output DeMemEn,
//output [11:0] DeMemData,
//output [15:0] DeMemADD,
//output [19:0] DeHDMIadd

    );
// Zero pading watch dog 
//reg ZeroPadOn;
//reg [7:0] ZeroPadCount;
//reg [19:0] Reg_Pck_WD_count;
//always @(posedge Cclk or negedge rstn) 
//    if (!rstn) Reg_Pck_WD_count <= 20'h00000;
//     else if (RxAddValid) Reg_Pck_WD_count <= 20'h00000;
//     else if (ZeroPadCount == 8'h50) Reg_Pck_WD_count <= 20'h00000;
//     else if (Reg_Pck_WD_count == 20'h23500) Reg_Pck_WD_count <= 20'h23500;
//     else Reg_Pck_WD_count <= Reg_Pck_WD_count + 1;

//always @(posedge Cclk or negedge rstn) 
//    if (!rstn) ZeroPadOn <= 1'b0;
//     else if (Reg_Pck_WD_count == 20'h234ff) ZeroPadOn <= 1'b1;
//     else if (ZeroPadCount == 8'h4f) ZeroPadOn <= 1'b0;
     
//always @(posedge Cclk or negedge rstn) 
//    if (!rstn) ZeroPadCount <= 8'h00;
//     else if (!ZeroPadOn) ZeroPadCount <= 8'h00; 
//     else ZeroPadCount <= ZeroPadCount + 1; 
//// Write memory address
//reg [15:0] NextLineAdd;
//always @(posedge Cclk or negedge rstn) 
//    if (!rstn) NextLineAdd <= 16'h0050;
//     else if (Out_Off_Link && (NextLineAdd == 16'h9600)) NextLineAdd <= 16'h0050;
//     else if (RxAddValid) NextLineAdd <= RxAdd + 16'h0050;
//     else if (Reg_Pck_WD_count == 20'h234ff) NextLineAdd <= NextLineAdd + 16'h0050;
//     else if (NextLineAdd == 16'h9600) NextLineAdd <= 16'h9600;
    
//reg [15:0] WMadd;
//always @(posedge Cclk or negedge rstn) 
//    if (!rstn) WMadd <= 16'h0000;
//     else if (Out_Off_Link && (WMadd == 16'h9600)) WMadd <= 16'h0000;
//     else if (RxAddValid)  WMadd <= RxAdd; 
//     else if (WMadd == 16'h9600) WMadd <= 16'h9600;
//     else if (RxValid)   WMadd <= WMadd + 1;
//     else if (ZeroPadOn)   WMadd <= WMadd + 1;
//     else if (Reg_Pck_WD_count == 20'h234ff)  WMadd <= NextLineAdd; 

//wire        WriteMemEn   = (ZeroPadOn) ? ZeroPadOn : RxValid;    
//wire [11:0] WriteMemData = (ZeroPadOn) ?   12'h000 : RxData;  


wire [3:0] ZeroPadOn; 

wire  [3:0] WriteMemEn       ; 
wire [15:0] WMadd[0:3]       ;   
wire [11:0] WriteMemData[0:3];     

reg [11:0] LineNum;
wire [3:0] ReceivedPkt;

genvar i;
generate 
for (i=0;i<4;i=i+1)begin
RxDataCollect RxDataCollect_inst(
.clk (Cclk ),                   // input clk,
.rstn(rstn),                  // input rstn,
                        // 
.RxData    (RxData[12*i+11:12*i]),        // input [11:0] RxData,
.RxValid   (RxValid[i]),        // input        RxValid,
.RxAdd     (RxAdd[16*i+15:16*i]),        // input [15:0] RxAdd,
.RxAddValid(RxAddValid[i]),        // input        RxAddValid,

.LineNum(LineNum) , // input  [11:0] LineNum,
.ReceivedPkt(ReceivedPkt[i]),   // output        ReceivedPkt,

.Out_Off_Link(Out_Off_Link[i]),   // input        Out_Off_Link,
                 // 
.WriteMemEn  (WriteMemEn[i]  ),    // output        WriteMemEn   , 
.WMadd       (WMadd[i]       ),         // output [15:0] WMadd,   
.WriteMemData(WriteMemData[i])   // output [11:0] WriteMemData     
    );
end 
endgenerate    

reg [11:0] YMem0 [0:38399]; // 95ff
reg [11:0] YMem1 [0:38399]; // 95ff
reg [11:0] YMem2 [0:38399]; // 95ff
reg [11:0] YMem3 [0:38399]; // 95ff
always @(posedge Cclk)
    if (WriteMemEn[0]) YMem0[WMadd[0]] <= WriteMemData[0];
always @(posedge Cclk)                 
    if (WriteMemEn[1]) YMem1[WMadd[1]] <= WriteMemData[1];
always @(posedge Cclk)                
    if (WriteMemEn[2]) YMem2[WMadd[2]] <= WriteMemData[2];
always @(posedge Cclk)                  
    if (WriteMemEn[3]) YMem3[WMadd[3]] <= WriteMemData[3];
 
//assign  DeMemEn   = WriteMemEn   ;
//assign  DeMemData = WriteMemData ;
//assign  DeMemADD  = WMadd        ;

//reg [479:0] Reg_Getpkt;
//wire [15:0] CheckAdd[0:479];
//genvar j;
//generate 
//for (i=0;i<4;i=i+1)begin
//    for (j=0;j<480;j=i+1) begin 
//    assign CheckAdd[j] = 16'h0005 + (8'h50*j);
//        always @(posedge Cclk or negedge rstn) 
//            if (!rstn) Reg_Getpkt[j] <= 1'b0;
//             else if (Out_Off_Link) Reg_Getpkt[j] <= 1'b0;
//             else if ((WMadd == CheckAdd[j]) && ZeroPadOn) Reg_Getpkt[j] <= 1'b0;
//             else if (WMadd == CheckAdd[j]) Reg_Getpkt[j] <= 1'b1;
//    end
//end    
//endgenerate     
///////////////////////////  TRANSFRT DATA TO SCREAN  ///////////////////////////  
reg [2:0] Cnt_Div_Clk;
always @(posedge Cclk or negedge rstn)
    if (!rstn) Cnt_Div_Clk <= 3'b000;
     else if (Cnt_Div_Clk == 3'b100) Cnt_Div_Clk <= 3'b000;
     else Cnt_Div_Clk <= Cnt_Div_Clk + 1;
reg Reg_Div_Clk;
always @(posedge Cclk or negedge rstn)
    if (!rstn) Reg_Div_Clk <= 1'b0;
     else if (Cnt_Div_Clk == 3'b000)  Reg_Div_Clk <= 1'b1;
     else if (Cnt_Div_Clk == 3'b010)  Reg_Div_Clk <= 1'b0;

   BUFG BUFG_inst (
      .O(PixelClk), // 1-bit output: Clock output
      .I(Reg_Div_Clk)  // 1-bit input: Clock input
   );

reg Reg_SwReadAdd;
always @(posedge Cclk or negedge rstn)
    if (!rstn) Reg_SwReadAdd <= 1'b0;
     else if (Cnt_Div_Clk == 3'b000)  Reg_SwReadAdd <= 1'b1;
     else if (Cnt_Div_Clk == 3'b011)  Reg_SwReadAdd <= 1'b0;
        
reg [19:0] HRadd;

wire [15:0] readMemAdd = HRadd[19:3];

reg [11:0] Reg_YMem0;
reg [11:0] Reg_YMem1;
reg [11:0] Reg_YMem2;
reg [11:0] Reg_YMem3;
always @(posedge Cclk)
    Reg_YMem0 <=  YMem0[readMemAdd];
always @(posedge Cclk)
    Reg_YMem1 <=  YMem1[readMemAdd];
always @(posedge Cclk)
    Reg_YMem2 <=  YMem2[readMemAdd];
always @(posedge Cclk)
    Reg_YMem3 <=  YMem3[readMemAdd];

always @(posedge Cclk or negedge rstn)
    if (!rstn) HRadd <= 20'h00001;
     else if (!HVsync) HRadd <= 20'h00001;
     else if ((Cnt_Div_Clk == 3'b000) && HMemRead) HRadd <= HRadd + 1;
//assign DeHDMIadd = HRadd;

reg DisRFpktOn;
always @(posedge Cclk or negedge rstn)
    if (!rstn) DisRFpktOn <= 1'b0;
     else if (!HMemRead) DisRFpktOn <= 1'b1;
     else if ((Cnt_Div_Clk == 3'b000) && (HRadd[1:0] == 2'b10)) DisRFpktOn <= 1'b0;
always @(posedge Cclk or negedge rstn)
    if (!rstn) LineNum <= 16'h0000;
     else if (!HMemRead) LineNum <= readMemAdd[15:4]/5;   
reg [11:0] DisRFpktAdd; 
always @(posedge Cclk or negedge rstn)
    if (!rstn) DisRFpktAdd <= 12'h000;
     else if (!DisRFpktOn) DisRFpktAdd <= LineNum;
wire [2:0] ReceivedPktSum = ReceivedPkt[3]+ReceivedPkt[2]+ReceivedPkt[1]+ReceivedPkt[0]+3'b011;
wire [7:0] GreenRF = {ReceivedPktSum,5'b11111};    
wire [7:0] RedRF   = 8'hff-{ReceivedPktSum,5'b11111};    
//wire [23:0] DisRFpktData = (Reg_Getpkt[DisRFpktAdd]) ? 24'h0000ff : 24'hff0000;     
wire [23:0] DisRFpktData = {RedRF,8'h00,GreenRF};     


reg Del_HMemRead;
always @(posedge Cclk or negedge rstn) 
    if (!rstn) Del_HMemRead <= 1'b0;
     else Del_HMemRead <= HMemRead;
reg [3:0] REnslant;
always @(posedge Cclk or negedge rstn)
    if (!rstn) REnslant <= 4'h1;
     else if (!HVsync) REnslant <= 4'h1;
     else if ((Cnt_Div_Clk == 3'b001) && !HMemRead && Del_HMemRead) REnslant <= {REnslant[0],REnslant[3:1]};
     else if ((Cnt_Div_Clk == 3'b000) && HMemRead && !HRadd[0]) REnslant <= {REnslant[2:0],REnslant[3]};

reg [95:0] RGB4Pix;
always @(posedge Cclk or negedge rstn)
    if (!rstn) RGB4Pix <= {96{1'b0}};
     else if (Cnt_Div_Clk == 3'b000) RGB4Pix <= {Reg_YMem3[11:8],4'hf,Reg_YMem3[7:4],4'hf,Reg_YMem3[3:0],4'hf,
                                                 Reg_YMem2[11:8],4'hf,Reg_YMem2[7:4],4'hf,Reg_YMem2[3:0],4'hf,
                                                 Reg_YMem1[11:8],4'hf,Reg_YMem1[7:4],4'hf,Reg_YMem1[3:0],4'hf,
                                                 Reg_YMem0[11:8],4'hf,Reg_YMem0[7:4],4'hf,Reg_YMem0[3:0],4'hf
                                                 };

assign  HDMIdata = (DisRFpktOn)  ? DisRFpktData   : 
                   (REnslant[0]) ? RGB4Pix[23: 0] :
                   (REnslant[1]) ? RGB4Pix[47:24] :
                   (REnslant[2]) ? RGB4Pix[71:48] :
                   (REnslant[3]) ? RGB4Pix[95:72] : 24'h000000;
/////////////////////////// End Of TRANSFRT DATA TO SCREAN  ///////////////////////////  
endmodule
