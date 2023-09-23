set XIL_CSE_ZYNQ_DISPLAY_UBOOT_MESSAGES=1
call F:\Xilinx\SDK\2017.4\bin\program_flash -f BOOT.bin -offset 0 -flash_type qspi_single -fsbl zynq_fsbl_flash.elf -verify
pause