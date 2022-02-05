/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "SCCB.h"
#include "CC1200.h"

#define START_FREQ   0x100
#define Tx_Pkt_size 126
#define Rx_Pkt_size 126

u32 *APB = XPAR_APB_M_0_BASEADDR;
u32 *CC1200 = XPAR_APB_M_1_BASEADDR;

int writeSCCB (int WriteData);
int write4readSCCB (int WriteData);
int readSCCB (int WriteData);
void Camera_init();
void cfg_VGA_60fps();
void cfg_advanced_awb();

int ResetCC1200(int Sel);

int writeSCC120 (int Sel, int add, int data);
int readSCC120  (int Sel, int add);
int writeLCC120 (int Sel, int add, int data);
int readLCC120  (int Sel, int add);

void TxCC1200_init(int Sel, int Pkt_size);
void TxCC1200_initOld(int Sel, int Pkt_size);
void TxCC1200_initNew(int Sel, int Pkt_size);
void RxCC1200_init(int Sel, int Pkt_size);
void RxCC1200_initOld(int Sel, int Pkt_size);
void RxCC1200_initNew(int Sel, int Pkt_size);

int main()
{
	int freq;
	int Hdata,Ldata,CamID;
	int ChipResetOK[4];
	int loop;
//	int Sel = 0;
    init_platform();

    xil_printf("Hello World\n\r");

	xil_printf("===== Set Up Transmitter =====\n\r");
    xil_printf("Reset CC1200\n\r");
    for (int i=0;i<4;i++){
    	ChipResetOK[i] = ResetCC1200(i);
    }

    xil_printf("Configure CC1200\n\r");
    for (int i=0;i<4;i++){
    	if (ChipResetOK[i]){
        TxCC1200_init(i, Tx_Pkt_size);// freq920

    	}
    }

	if (ChipResetOK[1]){
		writeLCC120(1 , 0x2F0C,   0x5B);// freq915
		writeLCC120(1 , 0x2F0D,   0x80);
	}
	if (ChipResetOK[2]){
		writeLCC120(2 , 0x0020,   0x14);// Old Board
		writeLCC120(2 , 0x2F0C,   0x5E);
		writeLCC120(2 , 0x2F0D,   0x00);
	}
	if (ChipResetOK[3]){
		writeLCC120(3 , 0x2F0C,   0x5B); // freq910
		writeLCC120(3 , 0x2F0D,   0x00);
	}

    xil_printf("set chip to Tx\n\r");
    for (int i=0;i<4;i++){
    	if (ChipResetOK[1]){
    		CC1200[0x100*i+4] = 4;        // switch to command mode
    		CC1200[0x100*i+2] = 0x350000; // set chip to Tx
    	    CC1200[0x100*i+0] = 1;
    		loop = 1;
    		while (loop)
    		{
    			loop = CC1200[0x100*i+1];
    		};
    	    CC1200[0x100*i+9] = Tx_Pkt_size; // Tx Pkt Size
    	}
    }
   	CC1200[0x100*0+0] = 2; // Enable Tx
   	CC1200[0x100*1+0] = 2; // Enable Tx
   	CC1200[0x100*2+0] = 2; // Enable Tx
   	CC1200[0x100*3+0] = 2; // Enable Tx

	xil_printf("===== Set Up Camera =====\n\r");
    APB[5] = START_FREQ; // set SCCB clock to ~200Khz
	freq = 1000000/(START_FREQ*20);
	xil_printf("frequency %d \n\r",freq);

	APB[7] = 0x0;    	// set Camera reset
	usleep(100);
	APB[7] = 0x1;    	// Clear Camera reset
	usleep(100);
								// Read Camarea ID
	write4readSCCB(0x78300a00);
	Hdata = readSCCB(0x78300a00);
	write4readSCCB(0x78300b00);
	Ldata = readSCCB(0x78300b00);

	CamID = (Hdata << 8) + Ldata;
	if (CamID == 0x5640) {
		xil_printf("Camera ID correct :):) Read %x \n\r",CamID);
	} else {
		xil_printf("Camera ID incorrect :(:(  Read %x \n\r",CamID);
	}

	//[1]=0 System input clock from pad; Default read = 0x11
	writeSCCB(0x78310311);
	//[7]=1 Software reset; [6]=0 Software power down; Default=0x02
	writeSCCB(0x78300882);

	usleep(1000);

	Camera_init();
	//Stay in power down
	usleep(1000);
					///// set mode to 640x480
    xil_printf("set mode to 640x480\n\r");
	//[7]=0 Software reset; [6]=1 Software power down; Default=0x02
	writeSCCB(0x78300842);

	cfg_VGA_60fps();

	//[7]=0 Software reset; [6]=0 Software power down; Default=0x02
	writeSCCB(0x78300802);

    				///// set awb to AWB_ADVANCED
    xil_printf("set awb to AWB_ADVANCED\n\r");
	writeSCCB(0x78300842);

	cfg_advanced_awb();

	//[7]=0 Software reset; [6]=0 Software power down; Default=0x02
	writeSCCB(0x78300802);

    xil_printf("GoodBye World\n\r");

    cleanup_platform();
    return 0;
}
