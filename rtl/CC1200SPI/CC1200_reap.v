`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/27/2022 10:30:14 AM
// Design Name: 
// Module Name: CC1200_reap
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


module CC1200_reap(
input  APBclk,
input  clk,
input  APBrstn,
input  rstn,

input  [31:0] APB_S_0_paddr,
input         APB_S_0_penable,
output [31:0] APB_S_0_prdata,
output        APB_S_0_pready,
input         APB_S_0_psel,
output        APB_S_0_pslverr,
input  [31:0] APB_S_0_pwdata,
input         APB_S_0_pwrite,

output [15:0] GPIO_OutEn,
output [15:0] GPIO_Out,
input  [15:0] GPIO_In,

input  TranFraimSync,

output [3:0]  TranNextData,
input  [3:0]  TranEn,
input  [47:0] TranData,
input  [63:0] TranAdd,

output [47:0] RxData,
output  [3:0] RxValid,
output [63:0] RxAdd,
output  [3:0] RxAddValid,
output  [3:0] Out_Off_Link,
output  FrameSync,

output [3:0] SCLK,
output [3:0] MOSI,
input  [3:0] MISO,
output [3:0] CS_n

    );
wire [3:0] CC1200Sel;
assign CC1200Sel[0] = (APB_S_0_paddr[11:10]==2'b00) ? 1'b1 : 1'b0;
assign CC1200Sel[1] = (APB_S_0_paddr[11:10]==2'b01) ? 1'b1 : 1'b0;
assign CC1200Sel[2] = (APB_S_0_paddr[11:10]==2'b10) ? 1'b1 : 1'b0;
assign CC1200Sel[3] = (APB_S_0_paddr[11:10]==2'b11) ? 1'b1 : 1'b0;
wire [31:0]CC1200Sel_prdata[0:3];
wire [3:0] CC1200Sel_pready;
wire [3:0] CC1200Sel_pslverr;

assign APB_S_0_prdata  = (CC1200Sel[0]) ? CC1200Sel_prdata[0] :  
                         (CC1200Sel[1]) ? CC1200Sel_prdata[1] :  
                         (CC1200Sel[2]) ? CC1200Sel_prdata[2] :  
                         (CC1200Sel[3]) ? CC1200Sel_prdata[3] : 32'h00000000; 
assign APB_S_0_pready  = (CC1200Sel[0]) ? CC1200Sel_pready[0] :
                         (CC1200Sel[1]) ? CC1200Sel_pready[1] :
                         (CC1200Sel[2]) ? CC1200Sel_pready[2] :
                         (CC1200Sel[3]) ? CC1200Sel_pready[3] : 1'b0;
assign APB_S_0_pslverr = (CC1200Sel[0]) ? CC1200Sel_pslverr[0] :
                         (CC1200Sel[1]) ? CC1200Sel_pslverr[1] :
                         (CC1200Sel[2]) ? CC1200Sel_pslverr[2] :
                         (CC1200Sel[3]) ? CC1200Sel_pslverr[3] : 1'b0;

wire [3:0]  RxFrameSync;                         
genvar i;

generate 
for (i=0;i<4;i=i+1)begin    

CC1200SPI_Top CC1200SPI_Top_inst
(    
	.APBclk(APBclk),		//input  APBclk
    .clk(clk),        //input  clk
    .APBrstn(APBrstn),        //input  APBrstn
    .rstn(rstn),        //input  rstn
    .APB_S_0_paddr  (APB_S_0_paddr  ),        //input [31:0] APB_S_0_paddr
    .APB_S_0_penable(APB_S_0_penable&&CC1200Sel[i]),        //input  APB_S_0_penable
    .APB_S_0_prdata (CC1200Sel_prdata[i] ),        //output [31:0] APB_S_0_prdata
    .APB_S_0_pready (CC1200Sel_pready[i] ),        //output  APB_S_0_pready
    .APB_S_0_psel   (APB_S_0_psel&&CC1200Sel[i]),        //input  APB_S_0_psel
    .APB_S_0_pslverr(CC1200Sel_pslverr[i]),        //output  APB_S_0_pslverr
    .APB_S_0_pwdata (APB_S_0_pwdata ),        //input [31:0] APB_S_0_pwdata
    .APB_S_0_pwrite (APB_S_0_pwrite ),        //input  APB_S_0_pwrite
    
    .GPIO_OutEn(GPIO_OutEn[4*i+3:4*i]),        //output [3:0] GPIO_OutEn
    .GPIO_Out  (GPIO_Out  [4*i+3:4*i]),        //output [3:0] GPIO_Out
    .GPIO_In   (GPIO_In   [4*i+3:4*i]),        //input [3:0] GPIO_In
    
    .TranFraimSync(TranFraimSync),        //input  TranFraimSync
    
    .TranNextData(TranNextData[i]),        //output  TranNextData
    .TranEn      (TranEn[i]),        //input  TranEn
    .TranData    (TranData[12*i+11:12*i]),        //input [11:0] TranData
    .TranAdd     (TranAdd[16*i+15:16*i]),        //input [15:0] TranAdd
    
    .RxData       (RxData[12*i+11:12*i]), // output [11:0] RxData
    .RxValid      (RxValid[i]          ), // output  RxValid
    .RxAdd        (RxAdd[16*i+15:16*i] ), // output [15:0] RxAdd
    .RxAddValid   (RxAddValid[i]  )  ,    // output  RxAddValid
    .RxFrameSync  (RxFrameSync[i] )   ,   // output  RxFrameSync,
    .Out_Off_Link (Out_Off_Link[i]),      // output  Out_Off_Link
    
    .SCLK(SCLK[i]),        //output  SCLK
    .MOSI(MOSI[i]),        //output  MOSI
    .MISO(MISO[i]),        //input  MISO
	.CS_n(CS_n[i])		//output  CS_n
);    
end
endgenerate

assign  FrameSync = |RxFrameSync;

endmodule
