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
#include "CC1200.h"


#define Tx_Pkt_size 126
#define Rx_Pkt_size 126
//#define MULTICH
u32 *CC1200 = XPAR_APB_M_0_BASEADDR;

int ResetCC1200(int Sel);

int writeSCC120 (int Sel, int add, int data);
int readSCC120  (int Sel, int add);
int writeLCC120 (int Sel, int add, int data);
int readLCC120  (int Sel, int add);

void TxCC1200_init(int Sel,int Pkt_size, int Mfreq, int Freq1, int Freq2);
void RxCC1200_init(int Sel,int Pkt_size, int Mfreq, int Freq1, int Freq2);

int main()
{
	int ChipResetOK[4] = {0,0,0,0};
	int Mfreq[4] = {0x14,0x12,0x12,0x12};
	int Freq1[4] = {0x5A,0x5c,0x5B,0x5B};
	int Freq2[4] = {0x00,0x00,0x80,0x00};
	int loop;
	int busy;
	int RForg;
	int RFpow;
//	int i = 2;
    init_platform();

    xil_printf("Hello World\n\r");

	xil_printf("===== Set Up Receiver =====\n\r");
    xil_printf("Reset CC1200\n\r");
    for (int i=0;i<4;i++){
    	ChipResetOK[i] = ResetCC1200(i);
    }
//sleep(1);
    xil_printf("Configure CC1200\n\r");
    for (int i=0;i<4;i++){
    	if (ChipResetOK[i]){
        RxCC1200_init(i, Tx_Pkt_size,Mfreq[i],Freq1[i],Freq2[i]);// freq920
    	}
    }

//	if (ChipResetOK[0]){
//		writeLCC120(0 , 0x0020,   0x14);// Old Board
//		writeLCC120(0 , 0x2F0C,   0x5E);
//		writeLCC120(0 , 0x2F0D,   0x00);
//	}
//	if (ChipResetOK[1]){
//		writeLCC120(1 , 0x2F0C,   0x5B);// freq915
//		writeLCC120(1 , 0x2F0D,   0x80);
//	}
//	if (ChipResetOK[2]){
//		writeLCC120(2 , 0x2F0C,   0x5B); // freq910
//		writeLCC120(2 , 0x2F0D,   0x00);
////		writeLCC120(2 , 0x0020,   0x14);// Old Board
////		writeLCC120(2 , 0x2F0C,   0x5E);
////		writeLCC120(2 , 0x2F0D,   0x00);
//	}
//	if (ChipResetOK[3]){
//		writeLCC120(3 , 0x2F0C,   0x5B); // freq910
//		writeLCC120(3 , 0x2F0D,   0x00);
//	}

    xil_printf("set chip to Rx\n\r");
    for (int i=0;i<4;i++){
    	if (ChipResetOK[i]){
    		CC1200[0x100*i+4] = 4;        // switch to command mode
    		CC1200[0x100*i+2] = 0x340000; // set chip to Rx
    	    CC1200[0x100*i+0] = 1;
    		loop = 1;
    		while (loop)
    		{
    			loop = CC1200[0x100*i+1];
    		};
    		CC1200[0x100*i+10] = Rx_Pkt_size + 2; // Rx Pkt Size
//    	    CC1200[0x100*i+0] = 4; // Enable Rx
    	}
    }
    CC1200[0x100*0+0] = 4; // Enable Rx
    CC1200[0x100*1+0] = 4; // Enable Rx
    CC1200[0x100*2+0] = 4; // Enable Rx
    CC1200[0x100*3+0] = 4; // Enable Rx

while (1){
	for(int i=0;i<4;i++){
		busy = 1;
		while (busy == 1)
		{
			if (ChipResetOK[i])busy = CC1200[0x100*i+1];
			else busy = 0;
		}
		RForg = CC1200[0x100*i+13];
		RFpow = RForg-81;
		if (RFpow == -209){
			xil_printf("Link %d Down\t",i);
		} else {
			xil_printf("RF %d = %d DBm\t",i,RFpow);
		}
	}
	xil_printf("\r\n");
	sleep (1);
}

//while (1){
//	busy0 = 1;
//	while (busy0 == 1)
//	{
//		busy0 = CC1200[0x100*0+1];
//	}
//	data0 = CC1200[0x100*0+13];
//	Link0 = data0-81;
//	if (Link0 == -209){
//		xil_printf("Link 0 is Down \r\n");
//	} else {
//		xil_printf("RF0 = %d DBm  ",Link0);
//	}
//
//	busy0 = 1;
//	while (busy0 == 1)
//	{
//		busy0 = CC1200[0x100*1+1];
//	}
//	data0 = CC1200[0x100*1+13];
//	Link0 = data0-81;
//	if (Link0 == -209){
//		xil_printf("Link 1 is Down \r\n");
//	} else {
//		xil_printf("RF1 = %d DBm\t",Link0);
//	}
//
//	sleep (1);
//}
    xil_printf("GoodBye World\n\r");

    cleanup_platform();
    return 0;
}
