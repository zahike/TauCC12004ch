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
#define Cor_Thre 20
u32 *CC1200 = XPAR_APB_M_0_BASEADDR;

void ResetCC1200(int Sel);

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
	int loop0,loop1,loop2,loop3;
	int data0,data1,data2,data3;
	int Link0,Link1,Link2,Link3;
	int busy0,busy1,busy2,busy3;
	int Sel = 0;
    init_platform();

    xil_printf("Hello World\n\r");

	xil_printf("===== Set Up Receiver =====\n\r");
    xil_printf("Reset CC1200\n\r");
    ResetCC1200(0);
    ResetCC1200(1);
    ResetCC1200(2);
    ResetCC1200(3);
	sleep(1);

    xil_printf("Configure CC1200\n\r");
    RxCC1200_init(0, Tx_Pkt_size);// freq920
    RxCC1200_init(1, Tx_Pkt_size);
	writeLCC120(1 , 0x2F0C,   0x5B);// freq915
	writeLCC120(1 , 0x2F0D,   0x80);
	RxCC1200_init(2, Tx_Pkt_size); 
	writeLCC120(1 , 0x0020,   0x14);// Old Board
	writeLCC120(1 , 0x2F0C,   0x5E);
	writeLCC120(1 , 0x2F0D,   0x00);
	RxCC1200_init(3, Tx_Pkt_size);
	writeLCC120(3 , 0x2F0C,   0x5B); // freq910
	writeLCC120(3 , 0x2F0D,   0x00);



    CC1200[0x100*0+4] = 4;        // switch to command mode
    CC1200[0x100*1+4] = 4;        // switch to command mode
    CC1200[0x100*2+4] = 4;        // switch to command mode
    CC1200[0x100*3+4] = 4;        // switch to command mode
    xil_printf("set chip to Rx\n\r");
    CC1200[0x100*0+2] = 0x340000; // set chip to Tx
    CC1200[0x100*1+2] = 0x340000; // set chip to Tx
    CC1200[0x100*2+2] = 0x340000; // set chip to Tx
    CC1200[0x100*3+2] = 0x340000; // set chip to Tx
    CC1200[0x100*0+0] = 1;
    CC1200[0x100*1+0] = 1;
    CC1200[0x100*2+0] = 1;
    CC1200[0x100*3+0] = 1;
	loop0 = 1;
	loop1 = 1;
	loop2 = 1;
	loop3 = 1;
	while (loop0||loop1||loop2||loop3)
//	while (loop0||loop1||loop2)
//	while (loop0||loop1)
//	while (loop0)
	{
		loop0 = CC1200[0x100*0+1];
		loop1 = CC1200[0x100*1+1];
		loop2 = CC1200[0x100*2+1];
		loop3 = CC1200[0x100*3+1];
	};

    CC1200[0x100*0+10] = Rx_Pkt_size + 2; // Rx Pkt Size
    CC1200[0x100*1+10] = Rx_Pkt_size + 2; // Rx Pkt Size
    CC1200[0x100*2+10] = Rx_Pkt_size + 2; // Rx Pkt Size
    CC1200[0x100*3+10] = Rx_Pkt_size + 2; // Rx Pkt Size
    CC1200[0x100*0+0] = 4; // Enable Rx
    CC1200[0x100*1+0] = 4; // Enable Rx
    CC1200[0x100*2+0] = 4; // Enable Rx
    CC1200[0x100*3+0] = 4; // Enable Rx

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
