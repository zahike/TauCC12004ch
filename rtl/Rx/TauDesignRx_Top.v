`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2021 08:12:35 AM
// Design Name: 
// Module Name: TauDesignRx_Top
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


module TauDesignRx_Top(
input  sysclk,
input [3:0] btn,

inout [14:0] DDR_addr,
inout [2:0] DDR_ba,
inout  DDR_cas_n,
inout  DDR_ck_n,
inout  DDR_ck_p,
inout  DDR_cke,
inout  DDR_cs_n,
inout [3:0] DDR_dm,
inout [31:0] DDR_dq,
inout [3:0] DDR_dqs_n,
inout [3:0] DDR_dqs_p,
inout  DDR_odt,
inout  DDR_ras_n,
inout  DDR_reset_n,
inout  DDR_we_n,
inout  FIXED_IO_ddr_vrn,
inout  FIXED_IO_ddr_vrp,
inout [53:0] FIXED_IO_mio,
inout  FIXED_IO_ps_clk,
inout  FIXED_IO_ps_porb,
inout  FIXED_IO_ps_srstb,

  output      hdmi_tx_clk_n   ,
  output      hdmi_tx_clk_p   ,
  output [2:0]hdmi_tx_data_n  ,
  output [2:0]hdmi_tx_data_p  ,
  
  inout  [2:1] jb_p,
  inout  [2:1] jb_n,
  output SCLKb,
  output MOSIb,
  input  MISOb,
  output CS_nb,
  
  inout  [2:1] jc_p,
  inout  [2:1] jc_n,
  output SCLKc,
  output MOSIc,
  input  MISOc,
  output CS_nc,
  
  inout  [2:1] jd_p,
  inout  [2:1] jd_n,
  output SCLKd,
  output MOSId,
  input  MISOd,
  output CS_nd,
  
  inout  [4:1] je,
  output SCLKe,
  output MOSIe,
  input  MISOe,
  output CS_ne
    );

wire rstn = ~btn[0];    

/////////////////////////////////////////////////////////// 
/////////////// TauDesignRx_BD Block design ///////////////
/////////////////////////////////////////////////////////// 
//wire [3:0] GPIO_OutEn;		//output [3:0] GPIO_OutEn_0;
//wire [3:0] GPIO_Out;		//output [3:0] GPIO_Out_0;
//wire [3:0] GPIO_In;		//input [3:0] GPIO_In_0;

//wire  SCLK_1;		//output  SCLK_0;
//wire  MOSI_1;		//output  MOSI_0;
//wire  MISO_1; 		//input  MISO_0;
//wire  CS_n_1;		//output  CS_n_0;

wire [15:0] CC1200GPIO_In;     //   input  [15:0] GPIO_In;
wire [15:0] CC1200GPIO_OutEn;  //   output [15:0] GPIO_OutEn;
wire [15:0] CC1200GPIO_Out;    //   output [15:0] GPIO_Out;
wire  [3:0] CC1200SCLK;        //   output  [3:0] SCLK;
wire  [3:0] CC1200CS_n;        //   output  [3:0] CS_n;
wire  [3:0] CC1200MOSI;        //   output  [3:0] MOSI;
wire  [3:0] CC1200MISO;        //   input   [3:0] MISO;

TauDesignRx_BD TauDesignRx_BD_inst
(
.sysclk(sysclk),        //input  sysclk
.ext_reset_in(rstn),        //input  ext_reset_in
.DDR_addr(DDR_addr),        //inout [14:0] DDR_addr
.DDR_ba(DDR_ba),        //inout [2:0] DDR_ba
.DDR_cas_n(DDR_cas_n),        //inout  DDR_cas_n
.DDR_ck_n(DDR_ck_n),        //inout  DDR_ck_n
.DDR_ck_p(DDR_ck_p),        //inout  DDR_ck_p
.DDR_cke(DDR_cke),        //inout  DDR_cke
.DDR_cs_n(DDR_cs_n),        //inout  DDR_cs_n
.DDR_dm(DDR_dm),        //inout [3:0] DDR_dm
.DDR_dq(DDR_dq),        //inout [31:0] DDR_dq
.DDR_dqs_n(DDR_dqs_n),        //inout [3:0] DDR_dqs_n
.DDR_dqs_p(DDR_dqs_p),        //inout [3:0] DDR_dqs_p
.DDR_odt(DDR_odt),        //inout  DDR_odt
.DDR_ras_n(DDR_ras_n),        //inout  DDR_ras_n
.DDR_reset_n(DDR_reset_n),        //inout  DDR_reset_n
.DDR_we_n(DDR_we_n),        //inout  DDR_we_n
.FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),        //inout  FIXED_IO_ddr_vrn
.FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),        //inout  FIXED_IO_ddr_vrp
.FIXED_IO_mio(FIXED_IO_mio),        //inout [53:0] FIXED_IO_mio
.FIXED_IO_ps_clk(FIXED_IO_ps_clk),        //inout  FIXED_IO_ps_clk
.FIXED_IO_ps_porb(FIXED_IO_ps_porb),        //inout  FIXED_IO_ps_porb
.FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),        //inout  FIXED_IO_ps_srstb
.GPIO_In   (CC1200GPIO_In   ),  // input  [15:0] GPIO_In   ;
.GPIO_OutEn(CC1200GPIO_OutEn),  // output [15:0] GPIO_OutEn;
.GPIO_Out  (CC1200GPIO_Out  ),  // output [15:0] GPIO_Out  ;
.SCLK      (CC1200SCLK      ),  // output  [3:0] SCLK      ;
.CS_n      (CC1200CS_n      ),  // output  [3:0] CS_n      ;
.MOSI      (CC1200MOSI      ),  // output  [3:0] MOSI      ;
.MISO      (CC1200MISO      ),  // input   [3:0] MISO      ;
.TMDS_Clk_n_0 (hdmi_tx_clk_n ),        //output  TMDS_Clk_n_0
.TMDS_Clk_p_0 (hdmi_tx_clk_p ),        //output  TMDS_Clk_p_0
.TMDS_Data_n_0(hdmi_tx_data_n),        //output [2:0] TMDS_Data_n_0
.TMDS_Data_p_0(hdmi_tx_data_p)        //output [2:0] TMDS_Data_p_0
);
    

assign CC1200GPIO_In = {  je[3],  je[2],  je[1],  je[0],
                        jd_n[2],jd_p[2],jd_n[1],jd_p[1],
                        jc_n[2],jc_p[2],jc_n[1],jc_p[1],
                        jb_n[2],jb_p[2],jb_n[1],jb_p[1]
                        };

assign jb_p[1] = (CC1200GPIO_OutEn[0]) ? CC1200GPIO_Out[0] : 1'bz;
assign jb_n[1] = (CC1200GPIO_OutEn[1]) ? CC1200GPIO_Out[1] : 1'bz;
assign jb_p[2] = (CC1200GPIO_OutEn[2]) ? CC1200GPIO_Out[2] : 1'bz;
assign jb_n[2] = (CC1200GPIO_OutEn[3]) ? CC1200GPIO_Out[3] : 1'bz;

assign SCLKb = CC1200SCLK[0];
assign MOSIb = CC1200MOSI[0];
assign CS_nb = CC1200CS_n[0];
assign CC1200MISO[0] = MISOb;

assign jc_p[1] = (CC1200GPIO_OutEn[4]) ? CC1200GPIO_Out[4] : 1'bz;
assign jc_n[1] = (CC1200GPIO_OutEn[5]) ? CC1200GPIO_Out[5] : 1'bz;
assign jc_p[2] = (CC1200GPIO_OutEn[6]) ? CC1200GPIO_Out[6] : 1'bz;
assign jc_n[2] = (CC1200GPIO_OutEn[7]) ? CC1200GPIO_Out[7] : 1'bz;

assign SCLKc = CC1200SCLK[1];
assign MOSIc = CC1200MOSI[1];
assign CS_nc = CC1200CS_n[1];
assign CC1200MISO[1] = MISOc;

assign jd_p[1] = (CC1200GPIO_OutEn[8])  ? CC1200GPIO_Out[8] : 1'bz;
assign jd_n[1] = (CC1200GPIO_OutEn[9])  ? CC1200GPIO_Out[9] : 1'bz;
assign jd_p[2] = (CC1200GPIO_OutEn[10]) ? CC1200GPIO_Out[10] : 1'bz;
assign jd_n[2] = (CC1200GPIO_OutEn[11]) ? CC1200GPIO_Out[11] : 1'bz;

assign SCLKd = CC1200SCLK[2];
assign MOSId = CC1200MOSI[2];
assign CS_nd = CC1200CS_n[2];
assign CC1200MISO[2] = MISOd;

assign je[0] = (CC1200GPIO_OutEn[12]) ? CC1200GPIO_Out[12] : 1'bz;
assign je[1] = (CC1200GPIO_OutEn[13]) ? CC1200GPIO_Out[13] : 1'bz;
assign je[2] = (CC1200GPIO_OutEn[14]) ? CC1200GPIO_Out[14] : 1'bz;
assign je[3] = (CC1200GPIO_OutEn[15]) ? CC1200GPIO_Out[15] : 1'bz;

assign SCLKe = CC1200SCLK[3];
assign MOSIe = CC1200MOSI[3];
assign CS_ne = CC1200CS_n[3];
assign CC1200MISO[3] = MISOe;
endmodule
