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
/* sw_en:              引脚输出使能信号，sw = 1 输出正常  sw = 0 引脚输出全1
   set_fre_en：     频率设置使能信号，1 设置频率有效   0 设置频率无效 
   set_pins_en：    引脚电平设置信号，上升沿有效
   set_fre：        频率设置，32位无符号数
   set_pins：       引脚电平设置，32位无符号数，低20位为电平设置有效位
   pins_out：       引脚输出位
   设置顺序：        sw_en = 0 -> set_fre_en = 1 -> set_fre;set_pins -> set_pins_en = 1 -> set_pins_en = 0;set_fre_en = 0;sw_en = 1
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
    parameter START_FREQ_STEP   = 32'd1000; //设置频率步长初始值1000hz
    parameter START_PINS_STATUS = 20'b1111_1111_1111_1111_1111;
    
    
    reg [19:0] pins_status;
    reg [31:0] fre_status;
    
    reg [31:0] cnt;
    reg [31:0] cnt_max;
    
    
    //上升沿提取
    
    reg        set_pins_en_d0;
    reg        set_pins_en_d1;
    wire       start_flag;

assign  start_flag = (~set_pins_en_d1 )& set_pins_en_d0;//是上升沿捕获
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
//引脚输出    
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        pins_out <= START_PINS_STATUS;
    else if(sw_en) begin
        pins_out <= pins_status;
    end
    else
        pins_out <= START_PINS_STATUS;
        
end

//频率设置 
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        fre_status <= START_FREQ_STEP;
    else if(set_fre_en) 
        fre_status <= set_fre;//输出设定引脚
    else
        fre_status <= fre_status;
end 

//引脚配置
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        pins_status <= START_PINS_STATUS;
    else if(start_flag) begin
        pins_status <= set_pins[19:0];//输出设定引脚
    end
    else if(cnt == cnt_max-32'd1)begin
        pins_status <= ~pins_status;
    end  
    else begin
        pins_status <= pins_status; 
    end
end    


//计数器
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
