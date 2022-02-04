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

//#define TX
#define RX
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
void RxCC1200_init(int Sel, int Pkt_size);

int main()
{
	int loop;
	int data;
	int Link;
	int busy;
	int Sel = 0;
    init_platform();

    xil_printf("Hello World\n\r");

	xil_printf("===== Set Up Receiver =====\n\r");
    xil_printf("Reset CC1200\n\r");
    ResetCC1200(Sel);
	sleep(1);

    xil_printf("Configure CC1200\n\r");
	RxCC1200_init(Sel, Rx_Pkt_size);
	writeLCC120(Sel , 0x2F0C,   0x5A);// freq905
	writeLCC120(Sel , 0x2F0D,   0x80);



    CC1200[0x100*Sel+4] = 4;        // switch to command mode
    xil_printf("set chip to Rx\n\r");
    CC1200[0x100*Sel+2] = 0x340000; // set chip to Tx
    CC1200[0x100*Sel+0] = 1;
	loop = 1;
	while (loop)
	{
		loop = CC1200[0x100*Sel+1];
	};
	    CC1200[0x100*Sel+10] = Rx_Pkt_size + 2; // Rx Pkt Size
	    CC1200[0x100*Sel+0] = 4; // Enable Rx

while (1){
	busy = 1;
	while (busy == 1){
		busy = CC1200[0x100*Sel+1];
	}
	data = CC1200[0x100*Sel+13];
	Link = data-81;
	if (Link == -209){
		xil_printf("Link is Down \r\n");
	} else {
		xil_printf("RF = %d DBm\t",Link);
	}

	sleep (1);
}
    xil_printf("GoodBye World\n\r");

    cleanup_platform();
    return 0;
}
