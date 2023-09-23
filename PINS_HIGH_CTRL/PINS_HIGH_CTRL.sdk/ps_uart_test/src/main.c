/* ------------------------------------------------------------ */
/*				Include File Definitions						*/
/* ------------------------------------------------------------ */

#include "xparameters.h"
#include <stdio.h>
#include "string.h"
#include "xil_printf.h"
#include "sleep.h"
#include "xscugic.h"
#include "uart_parameter.h"

#include "my_uart.h"

#include "pin_ctrl.h"

//寄存器基地址
#define PINS_CTRL_ADDR  XPAR_PIN_CTRL_0_S00_AXI_BASEADDR
#define PINS_CTRL_REG0	PIN_CTRL_S00_AXI_SLV_REG0_OFFSET
#define PINS_CTRL_REG1	PIN_CTRL_S00_AXI_SLV_REG1_OFFSET
#define PINS_CTRL_REG2	PIN_CTRL_S00_AXI_SLV_REG2_OFFSET
#define PINS_CTRL_REG3	PIN_CTRL_S00_AXI_SLV_REG3_OFFSET
#define PINS_CTRL_REG4	PIN_CTRL_S00_AXI_SLV_REG4_OFFSET
#define PINS_CTRL_REG5	PIN_CTRL_S00_AXI_SLV_REG5_OFFSET
#define PINS_CTRL_REG6	PIN_CTRL_S00_AXI_SLV_REG6_OFFSET
#define PINS_CTRL_REG7	PIN_CTRL_S00_AXI_SLV_REG7_OFFSET

extern u8 rec_data[100];//暂存接收数据


u8 INIT_SEND_FLAG = 1;//初始界面发送标志位

extern int64_t fre = 0  ;
extern int64_t pins = 0 ;
extern int64_t running_flag = 0 ;


//void sub_state_handle()
//{
//	switch(sub_state)
//	{
//		case SET_FRE : {
//
//
//		}
//
//
//
//
//
//	}
//
//
//}


int main(void)
{
	//定义状态及PS端串口结构体
	int Status;

	XUartPs_Config *Config;

	u32 SendByteNum ;//发送字节数
	u8 *SendBufferPtr ;//发送数据地址

	u8 sub_state = SET_FRE;

	memset(0,rec_data,sizeof(rec_data));

	ReceivedBufferPtr = ReceivedBuffer ;//指向接收数据地址
	//数据接收标志位及接收计数器
	ReceivedFlag = 0 ;
	ReceivedByteNum = 0 ;

	/*-------------------------串口相关配置-----------------------------*/
	//查找串口ID
	Config = XUartPs_LookupConfig(UART_DEVICE_ID);
	if (NULL == Config) {
		return XST_FAILURE;
	}
	//串口初始化
	Status = XUartPs_CfgInitialize(&Uart_PS, Config, Config->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	//设置串口中断模式
	/* Use Normal mode. */
	XUartPs_SetOperMode(&Uart_PS, XUARTPS_OPER_MODE_NORMAL);
	/* Set uart mode Baud Rate 115200, 8bits, no parity, 1 stop bit */
	XUartPs_SetDataFormat(&Uart_PS, &UartFormat) ;
	/*Set receiver FIFO interrupt trigger level, here set to 1*/
	XUartPs_SetFifoThreshold(&Uart_PS,1) ;
	/* Enable the receive FIFO trigger level interrupt and empty interrupt for the device */
	XUartPs_SetInterruptMask(&Uart_PS,XUARTPS_IXR_RXOVR|XUARTPS_IXR_RXEMPTY);//中断触发事件

	SetupInterruptSystem(&IntcInstPtr, &Uart_PS, UART_INT_IRQ_ID) ;

	printf("set_fre:1-20000000HZ End with hz\r\n");
	while(1)
	{

		if (ReceivedFlag)
		{
				/* Reset receiver pointer, flag, byte number */
			ReceivedBufferPtr = ReceivedBuffer ;
			SendBufferPtr = ReceivedBuffer ;
			SendByteNum = ReceivedByteNum ;
			/*-----------------------检测相应字符串打印函数-------------------*/
			//检测末位为"hz"
			switch(sub_state)
			{
				case SET_FRE : {

					if(my_strcmp(SendBufferPtr+ReceivedByteNum-2,"hz",2)==1){
						//锁定频率
						fre = myatoi(SendBufferPtr);
						//转换状态
						sub_state = SET_PIN;

						//设定频率
						PIN_CTRL_mWriteReg(PINS_CTRL_ADDR,PINS_CTRL_REG0,0X00000000);//SW = 0
						PIN_CTRL_mWriteReg(PINS_CTRL_ADDR,PINS_CTRL_REG1,0X00000001);
						PIN_CTRL_mWriteReg(PINS_CTRL_ADDR,PINS_CTRL_REG3,(u32)fre);//1000 HZ

						printf("ok set fre = %d hz\r\n",fre);

						printf("set_pin: Decimal representation Ctrl 20 pins End with pin\r\n");
					}

					else{
						sub_state = SET_FRE;
						printf("set_fre:1-20000000HZ End with hz\r\n");
					}
					break;
				}
				case SET_PIN : {

					if(my_strcmp(SendBufferPtr+ReceivedByteNum-3,"pin",3)==1){
						//锁定管脚电平
						pins = myatoi(SendBufferPtr);

						//设定管脚电平
						PIN_CTRL_mWriteReg(PINS_CTRL_ADDR,PINS_CTRL_REG4,(u32)pins);

						PIN_CTRL_mWriteReg(PINS_CTRL_ADDR,PINS_CTRL_REG2,0X00000001);
						usleep(5);
						PIN_CTRL_mWriteReg(PINS_CTRL_ADDR,PINS_CTRL_REG2,0X00000000);
						usleep(5);
						PIN_CTRL_mWriteReg(PINS_CTRL_ADDR,PINS_CTRL_REG1,0X00000000);

						//转换状态
						sub_state = START;
						printf("set_pins:%d \r\n",pins);
						printf("enter start to run\r\n");
					}
					//重置状态
					else if(my_strcmp(SendBufferPtr,"reset",5)==1){
						sub_state = SET_FRE;
						running_flag = 0;
						printf("set_fre:1-20000000HZ End with hz\r\n");
					}
					else{
						sub_state = SET_PIN;
						printf("set_pin: Decimal representation Ctrl 20 pins End with pin\r\n");
					}
					break;
				}

				case START : {

					if(my_strcmp(SendBufferPtr,"start",5)==1){
						//使能指令
						running_flag = 1;
						sub_state = WORK;
						//使能输出
						PIN_CTRL_mWriteReg(PINS_CTRL_ADDR,PINS_CTRL_REG0,0X00000001);

						printf("already start: Please enter stop to stop\r\n");
					}
					else if(my_strcmp(SendBufferPtr,"reset",5)==1){
						sub_state = SET_FRE;
						running_flag = 0;
						printf("set_fre:1-20000000HZ End with hz\r\n");
					}
					else{
						sub_state = START;
						printf("enter start to run\r\n");
					}
					break;
				}

				case WORK : {

					if(my_strcmp(SendBufferPtr,"stop",4)==1){
						running_flag = 0;
						sub_state = START;
						//停止输出
						PIN_CTRL_mWriteReg(PINS_CTRL_ADDR,PINS_CTRL_REG0,0X00000000);

						printf("already stop: Please enter start to start\r\n");
					}
					else if(my_strcmp(SendBufferPtr,"reset",5)==1){
						sub_state = SET_FRE;
						running_flag = 0;
						printf("set_fre:1-20000000HZ End with hz\r\n");
					}
					else{
						sub_state = WORK;
						printf("enter stop to stop\r\n");
					}
					break;
				}

			default : break ;
			}







				ReceivedFlag = 0 ;
				ReceivedByteNum = 0 ;
		}
		usleep(20000);//延时20ms
	}

}


