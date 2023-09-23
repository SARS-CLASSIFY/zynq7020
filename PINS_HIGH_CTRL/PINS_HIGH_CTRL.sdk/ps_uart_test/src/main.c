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

//�Ĵ�������ַ
#define PINS_CTRL_ADDR  XPAR_PIN_CTRL_0_S00_AXI_BASEADDR
#define PINS_CTRL_REG0	PIN_CTRL_S00_AXI_SLV_REG0_OFFSET
#define PINS_CTRL_REG1	PIN_CTRL_S00_AXI_SLV_REG1_OFFSET
#define PINS_CTRL_REG2	PIN_CTRL_S00_AXI_SLV_REG2_OFFSET
#define PINS_CTRL_REG3	PIN_CTRL_S00_AXI_SLV_REG3_OFFSET
#define PINS_CTRL_REG4	PIN_CTRL_S00_AXI_SLV_REG4_OFFSET
#define PINS_CTRL_REG5	PIN_CTRL_S00_AXI_SLV_REG5_OFFSET
#define PINS_CTRL_REG6	PIN_CTRL_S00_AXI_SLV_REG6_OFFSET
#define PINS_CTRL_REG7	PIN_CTRL_S00_AXI_SLV_REG7_OFFSET

extern u8 rec_data[100];//�ݴ��������


u8 INIT_SEND_FLAG = 1;//��ʼ���淢�ͱ�־λ

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
	//����״̬��PS�˴��ڽṹ��
	int Status;

	XUartPs_Config *Config;

	u32 SendByteNum ;//�����ֽ���
	u8 *SendBufferPtr ;//�������ݵ�ַ

	u8 sub_state = SET_FRE;

	memset(0,rec_data,sizeof(rec_data));

	ReceivedBufferPtr = ReceivedBuffer ;//ָ��������ݵ�ַ
	//���ݽ��ձ�־λ�����ռ�����
	ReceivedFlag = 0 ;
	ReceivedByteNum = 0 ;

	/*-------------------------�����������-----------------------------*/
	//���Ҵ���ID
	Config = XUartPs_LookupConfig(UART_DEVICE_ID);
	if (NULL == Config) {
		return XST_FAILURE;
	}
	//���ڳ�ʼ��
	Status = XUartPs_CfgInitialize(&Uart_PS, Config, Config->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	//���ô����ж�ģʽ
	/* Use Normal mode. */
	XUartPs_SetOperMode(&Uart_PS, XUARTPS_OPER_MODE_NORMAL);
	/* Set uart mode Baud Rate 115200, 8bits, no parity, 1 stop bit */
	XUartPs_SetDataFormat(&Uart_PS, &UartFormat) ;
	/*Set receiver FIFO interrupt trigger level, here set to 1*/
	XUartPs_SetFifoThreshold(&Uart_PS,1) ;
	/* Enable the receive FIFO trigger level interrupt and empty interrupt for the device */
	XUartPs_SetInterruptMask(&Uart_PS,XUARTPS_IXR_RXOVR|XUARTPS_IXR_RXEMPTY);//�жϴ����¼�

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
			/*-----------------------�����Ӧ�ַ�����ӡ����-------------------*/
			//���ĩλΪ"hz"
			switch(sub_state)
			{
				case SET_FRE : {

					if(my_strcmp(SendBufferPtr+ReceivedByteNum-2,"hz",2)==1){
						//����Ƶ��
						fre = myatoi(SendBufferPtr);
						//ת��״̬
						sub_state = SET_PIN;

						//�趨Ƶ��
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
						//�����ܽŵ�ƽ
						pins = myatoi(SendBufferPtr);

						//�趨�ܽŵ�ƽ
						PIN_CTRL_mWriteReg(PINS_CTRL_ADDR,PINS_CTRL_REG4,(u32)pins);

						PIN_CTRL_mWriteReg(PINS_CTRL_ADDR,PINS_CTRL_REG2,0X00000001);
						usleep(5);
						PIN_CTRL_mWriteReg(PINS_CTRL_ADDR,PINS_CTRL_REG2,0X00000000);
						usleep(5);
						PIN_CTRL_mWriteReg(PINS_CTRL_ADDR,PINS_CTRL_REG1,0X00000000);

						//ת��״̬
						sub_state = START;
						printf("set_pins:%d \r\n",pins);
						printf("enter start to run\r\n");
					}
					//����״̬
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
						//ʹ��ָ��
						running_flag = 1;
						sub_state = WORK;
						//ʹ�����
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
						//ֹͣ���
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
		usleep(20000);//��ʱ20ms
	}

}

