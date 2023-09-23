# 高速PIN信号控制应用

- 基于ZYNQ7020，实现串口控制20个pin管信号的高速0-1电平变换
- 串口波特率115200 数据位8 停止位1 无奇偶校验位
- 命令格式：
  - 设置频率：set_fre:1-20000000HZ End with hz   eg:1000000hz
  - 设置pin管初始状态：set_pin: Decimal representation Ctrl 20 pins End with pin   eg:2777777pin (需要先将十六进制pin管数据转换为十进制)
  - 使能/关闭 pin管输出：start/stop
  - 重设置参数：reset

