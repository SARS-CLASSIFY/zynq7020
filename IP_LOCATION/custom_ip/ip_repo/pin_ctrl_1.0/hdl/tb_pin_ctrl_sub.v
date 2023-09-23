`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/16 21:54:58
// Design Name: 
// Module Name: tb_pin_ctrl_sub
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


module tb_pin_ctrl_sub();

reg         sys_clk;
reg         sys_rst_n;

reg         sw_en;          
reg         set_fre_en;     
reg         [31:0] set_fre;
reg         set_pins_en;    
reg         [31:0] set_pins;

wire        [19:0] pin_out;

initial begin
    sys_clk = 0;
    sys_rst_n = 0;
    sw_en = 0;
    set_fre_en = 0;
    set_pins_en = 0;
    set_fre = 31'd1000;
    set_pins = 31'd1111_1111_1111_1111_1111_1111_1111_1111;//设置初始频率1K引脚全1
    #200
    sys_rst_n = 1;
    #2000
    sw_en = 1;

    #2000
    sw_en = 0;
    set_fre_en = 1;
    #50
    set_fre = 31'd20_000_000;
    set_pins = 31'd699050;
    #200
    set_pins_en = 1;
    #200
    set_fre_en = 0;
    set_pins_en=0;
    sw_en = 1;
    
    #2000
    sw_en =0;
    set_fre_en = 1;
    #500
    set_fre = 31'd1_000_000;
    set_pins = 31'd1024; 
    #200
    set_pins_en = 1;
    #200
    set_fre_en = 0;
    set_pins_en=0;
    sw_en = 1;
    
end



always #10 sys_clk = ~sys_clk;


pin_ctrl_sub    u_pin_ctrl_sub(
        .sys_clk        (sys_clk    ),
        .sys_rst_n      (sys_rst_n  ),          
        .sw_en          (sw_en      ),
        .set_fre_en     (set_fre_en ),
        .set_fre        (set_fre    ),
        .set_pins_en    (set_pins_en),
        .set_pins       (set_pins   ),
        .pins_out       (pin_out)
);




endmodule
