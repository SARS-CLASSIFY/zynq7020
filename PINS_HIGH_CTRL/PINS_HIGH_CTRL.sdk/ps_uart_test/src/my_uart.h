/*
 * my_uart.h
 *
 *  Created on: 2023年9月5日
 *      Author: 86150
 */

#ifndef SRC_MY_UART_H_
#define SRC_MY_UART_H_

#include "xuartps.h"

#include "xparameters.h"
#include <stdio.h>
#include "xil_printf.h"
#include "sleep.h"
#include "xscugic.h"


#define UART_DEVICE_ID      XPAR_XUARTPS_0_DEVICE_ID
#define INTC_DEVICE_ID		XPAR_SCUGIC_SINGLE_DEVICE_ID
#define UART_INT_IRQ_ID		XPAR_XUARTPS_1_INTR

/* Statement */
#define MAIN_STATE      0
#define UART_RXCHECK 1
#define UART_WAIT    2


/* Substate */
#define SET_FRE      0
#define SET_PIN 	 1
#define START    	 2
#define WORK         3

/* maximum receiver length */
#define MAX_LEN    2000

/************************** Variable Definitions *****************************/

XUartPs Uart_PS;		/* Instance of the UART Device */
XScuGic IntcInstPtr ;

/* UART receiver buffer */
u8 ReceivedBuffer[MAX_LEN] ;
/* UART receiver buffer pointer*/
u8 *ReceivedBufferPtr ;
/* UART receiver byte number */
volatile u32 ReceivedByteNum ;

volatile u32 ReceivedFlag  ;

int64_t fre  ;
int64_t pins ;
int64_t running_flag ;
//
u8 rec_data[100];//暂存接收数据


int UartPsSend(XUartPs *InstancePtr, u8 *BufferPtr, u32 NumBytes) ;
int UartPsRev (XUartPs *InstancePtr, u8 *BufferPtr, u32 NumBytes) ;

int SetupInterruptSystem(XScuGic *IntcInstancePtr,	XUartPs *UartInstancePtr, u16 UartIntrId);
void Handler(void *CallBackRef);


#endif /* SRC_MY_UART_H_ */
