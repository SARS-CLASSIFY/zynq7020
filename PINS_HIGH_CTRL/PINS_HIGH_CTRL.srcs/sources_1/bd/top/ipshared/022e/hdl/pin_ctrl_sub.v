`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/16 15:59:28
// Design Name: 
// Module Name: pin_strl_sub
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
/* sw_en:              �������ʹ���źţ�sw = 1 �������  sw = 0 �������ȫ1
   set_fre_en��     Ƶ������ʹ���źţ�1 ����Ƶ����Ч   0 ����Ƶ����Ч 
   set_pins_en��    ���ŵ�ƽ�����źţ���������Ч
   set_fre��        Ƶ�����ã�32λ�޷�����
   set_pins��       ���ŵ�ƽ���ã�32λ�޷���������20λΪ��ƽ������Чλ
   pins_out��       �������λ
   ����˳��        sw_en = 0 -> set_fre_en = 1 -> set_fre;set_pins -> set_pins_en = 1 -> set_pins_en = 0;set_fre_en = 0;sw_en = 1
*/
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pin_ctrl_sub(
    input                   sys_clk             ,
    input                   sys_rst_n           ,
    
    input                   sw_en               ,
    input                   set_fre_en          ,
    input        [31:0]     set_fre             ,
    input                   set_pins_en         ,
    input        [31:0]     set_pins            ,    
    output reg   [19:0]     pins_out         
);
    parameter START_FREQ_STEP   = 32'd1000; //����Ƶ�ʲ�����ʼֵ1000hz
    parameter START_PINS_STATUS = 20'b1111_1111_1111_1111_1111;
    
    
    reg [19:0] pins_status;
    reg [31:0] fre_status;
    
    reg [31:0] cnt;
    reg [31:0] cnt_max;
    
    
    //��������ȡ
    
    reg        set_pins_en_d0;
    reg        set_pins_en_d1;
    wire       start_flag;

assign  start_flag = (~set_pins_en_d1 )& set_pins_en_d0;//�������ز���
always @(posedge sys_clk or negedge sys_rst_n) begin 
    if (!sys_rst_n) begin 
        set_pins_en_d0 <= 1'b0;
        set_pins_en_d1 <= 1'b0;          
    end
    else begin
        set_pins_en_d0 <= set_pins_en;                   
        set_pins_en_d1 <= set_pins_en_d0;
    end   
end    
//�������    
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        pins_out <= START_PINS_STATUS;
    else if(sw_en) begin
        pins_out <= pins_status;
    end
    else
        pins_out <= START_PINS_STATUS;
        
end

//Ƶ������ 
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        fre_status <= START_FREQ_STEP;
    else if(set_fre_en) 
        fre_status <= set_fre;//����趨����
    else
        fre_status <= fre_status;
end 

//��������
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        pins_status <= START_PINS_STATUS;
    else if(start_flag) begin
        pins_status <= set_pins[19:0];//����趨����
    end
    else if(cnt == cnt_max-32'd1)begin
        pins_status <= ~pins_status;
    end  
    else begin
        pins_status <= pins_status; 
    end
end    


//������
always @ (posedge sys_clk, negedge sys_rst_n) begin
    if (sys_rst_n == 0)
        cnt_max <= 32'd50_000_000 / START_FREQ_STEP;
    else 
        cnt_max <= 32'd50_000_000 / fre_status;
end

always @ (posedge sys_clk, negedge sys_rst_n) begin
    if (sys_rst_n == 0)
        cnt <= 32'd0;
    else if(cnt >= cnt_max-32'd1)
        cnt <= 32'd0;
    else 
        cnt <= cnt+32'd1;
end
    
    
endmodule
