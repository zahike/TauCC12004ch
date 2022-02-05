/*
 * CC1200.c
 *
 *  Created on: Nov 21, 2021
 *      Author: udi
 */

#include "CC1200.h"

int writeSCC120 (int Sel, int add, int data)
{
	int data_reg;
	int loop;
	CC1200[0x100*Sel+4] = 2;
	data_reg = add << 16;
	data_reg = data_reg + (data<<8);
	CC1200[0x100*Sel+2] = data_reg;
	CC1200[0x100*Sel+0] = 1;
	loop = 1;
	while (loop)
	{
		loop = CC1200[0x100*Sel+1];
	};
	usleep(10);
};

int readSCC120 (int Sel, int add)
{
	int data;
	int data_reg;
	int loop;
	CC1200[0x100*Sel+4] = 2;
	data_reg = add << 16;
	data_reg = data_reg + 0x00800000;
	CC1200[0x100*Sel+2] = data_reg;
	CC1200[0x100*Sel+0] = 1;
	loop = 1;
	while (loop)
	{
		loop = CC1200[0x100*Sel+1];
	};
	data = CC1200[0x100*Sel+3];
	usleep(10);
	return data;

};

int writeLCC120 (int Sel, int add, int data)
{
	int data_reg;
	int loop;
	CC1200[0x100*Sel+4] = 1;
	data_reg = add << 8;
	data_reg = data_reg + data;
	CC1200[0x100*Sel+2] = data_reg;
	CC1200[0x100*Sel+0] = 1;
	loop = 1;
	while (loop)
	{
		loop = CC1200[0x100*Sel+1];
	};
	usleep(10);

};

int readLCC120 (int Sel, int add)
{
	int data;
	int data_reg;
	int loop;
	CC1200[0x100*Sel+4] = 1;
	data_reg = add << 8;
	data_reg = data_reg + 0x00800000;
	CC1200[0x100*Sel+2] = data_reg;
	CC1200[0x100*Sel+0] = 1;
	loop = 1;
	while (loop)
	{
		loop = CC1200[0x100*Sel+1];
	};
	data = CC1200[0x100*Sel+3];
	usleep(10);
	return data;

};

int ResetCC1200(int Sel)
{
	int loop;
	int cout;
	int Wordcout;
	int data;

    CC1200[0x100*Sel+6] = 1;		// enable GPIO_0 as output
    CC1200[0x100*Sel+7] = 0;
    usleep(100);
    CC1200[0x100*Sel+7] = 1;       // Hard Reset chip
    CC1200[0x100*Sel+5] = 16;      // set SPI clock to FPGA clock/17

    CC1200[0x100*Sel+4] = 4;        // switch to command mode
    CC1200[0x100*Sel+2] = 0x300000; // Soft Reset chip
    CC1200[0x100*Sel+0] = 1;
	loop = 1;
	cout = 0;
	while (loop)
	{
		loop = CC1200[0x100*Sel+1];
		cout++;
		if (cout == 10000){
			xil_printf("Chip %d Not respond\r\n",Sel);
			return 0;
			break;
		}
	};

    CC1200[0x100*0+2] = 0x3d0000;  // check if module in reset
    data = 0;
    Wordcout = 0;
    while (data != 0x0f)
    {
		CC1200[0x100*Sel+0] = 1;
		loop = 1;
		cout = 0;
		while (loop)
		{
			loop = CC1200[0x100*Sel+1];
			cout++;
			if (cout == 10000){
				xil_printf("Chip %d Not respond\r\n",Sel);
				return 0;
				break;
			}
		};
		data = CC1200[0x100*Sel+3] & 0xff;
		if (data != 0x0f)  {
			xil_printf("Chip %d not set\n\r",Sel);
			Wordcout++;
			if (Wordcout == 10000){
				xil_printf("Chip %d Not reset\r\n",Sel);
				return 0;
				break;
			}

		}
    }
    xil_printf("Chip %d reset succesfuly \n\r",Sel);
	return 1;
}

