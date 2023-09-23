`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/05 10:41:55
// Design Name: 
// Module Name: breath_led
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

module breath_led(
    input          sys_clk        , //系统时钟 50MHz
    input          sys_rst_n      , //系统复位，低电平有效
	input          sw_ctrl        , //呼吸灯开关控制信号 1：亮 0:灭
    input          set_en         , //设置呼吸灯频率设置使能信号
    input   [9:0]  set_freq_step  , //设置呼吸灯频率变化步长
    
    output         led              //LED灯
);

//parameter define
parameter  START_FREQ_STEP = 10'd1; //设置频率步长初始值
parameter CNT_2US_MAX = 7'd100;    
parameter CNT_2MS_MAX = 10'd1000; 
parameter CNT_2S_MAX  = 10'd1000; 

//reg define
reg [6:0] cnt_2us; 
reg [9:0] cnt_2ms;   
reg [9:0] cnt_2s;     
reg       inc_dec_flag; //亮度递增/递减 0:递增 1:递减
reg [9:0] freq_step   ; //呼吸灯频率间隔步长
reg       led_t       ;

//*****************************************************
//**                  main code
//*****************************************************
assign led = led_t & sw_ctrl;

//设置频率间隔,频率步长值在1-10之间
always @(posedge sys_clk) begin
    if(!sys_rst_n)
        freq_step <= START_FREQ_STEP;
    else if(set_en) begin
        if(set_freq_step == 0)
            freq_step <= 10'd1;
        else if(set_freq_step >= 10'd10)
            freq_step <= 10'd10;
        else    
            freq_step <= set_freq_step;
    end        
end

//cnt_2us:计数2us
always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        cnt_2us <= 7'b0;
    else if(cnt_2us == (CNT_2US_MAX - 7'b1 ))
        cnt_2us <= 7'b0;
    else
        cnt_2us <= cnt_2us + 7'b1;
end

//cnt_2ms:计数2ms
always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        cnt_2ms <= 10'b0;
    else if(cnt_2ms == (CNT_2MS_MAX - 10'b1) && cnt_2us == (CNT_2US_MAX - 7'b1))
        cnt_2ms <= 10'b0;
    else if(cnt_2us == CNT_2US_MAX - 7'b1)
        cnt_2ms <= cnt_2ms + 10'b1;
    else
        cnt_2ms <= cnt_2ms;
end

//cnt_2s:计数2s
always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        cnt_2s <= 10'b0;
    else if(cnt_2s >= (CNT_2S_MAX - 10'b1) && cnt_2ms == (CNT_2MS_MAX - 10'b1) && cnt_2us == (CNT_2US_MAX - 7'b1))
        cnt_2s <= 10'b0;
    else if(cnt_2ms == (CNT_2MS_MAX - 10'b1) && cnt_2us == (CNT_2US_MAX - 7'b1))
        cnt_2s <= cnt_2s + freq_step;
    else
        cnt_2s <= cnt_2s;         
end

//inc_dec_flag为低电平，led灯由暗变亮，inc_dec_flag为高电平，led灯由亮变暗
always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        inc_dec_flag <= 1'b0;
    else if(cnt_2s >= (CNT_2S_MAX - 10'b1) && cnt_2ms ==( CNT_2MS_MAX - 10'b1) && cnt_2us == (CNT_2US_MAX - 7'b1))
        inc_dec_flag <= ~inc_dec_flag;
    else
        inc_dec_flag <= inc_dec_flag;
end

//led:输出信号连接到外部的led灯
always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        led_t <= 1'b0;
    else if((inc_dec_flag == 1'b1 && cnt_2ms >= cnt_2s) || (inc_dec_flag == 1'b0 && cnt_2ms <= cnt_2s))
        led_t <= 1'b1;
    else
        led_t<= 1'b0;
end

endmodule
