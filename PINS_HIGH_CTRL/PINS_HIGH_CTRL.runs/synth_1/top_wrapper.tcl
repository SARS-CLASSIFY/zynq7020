# 
# Synthesis run script generated by Vivado
# 

proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
set_msg_config -id {Synth 8-256} -limit 10000
set_msg_config -id {Synth 8-638} -limit 10000
create_project -in_memory -part xc7z020clg400-2

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir C:/Users/86150/Desktop/08_ps_uart/ps_uart.cache/wt [current_project]
set_property parent.project_path C:/Users/86150/Desktop/08_ps_uart/ps_uart.xpr [current_project]
set_property XPM_LIBRARIES {XPM_CDC XPM_FIFO XPM_MEMORY} [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_repo_paths j:/zynq/IP_LOCATION/custom_ip/ip_repo/pin_ctrl_1.0 [current_project]
set_property ip_output_repo c:/Users/86150/Desktop/08_ps_uart/ps_uart.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_verilog -library xil_defaultlib C:/Users/86150/Desktop/08_ps_uart/ps_uart.srcs/sources_1/bd/top/hdl/top_wrapper.v
add_files C:/Users/86150/Desktop/08_ps_uart/ps_uart.srcs/sources_1/bd/top/top.bd
set_property used_in_implementation false [get_files -all c:/Users/86150/Desktop/08_ps_uart/ps_uart.srcs/sources_1/bd/top/ip/top_processing_system7_0_0/top_processing_system7_0_0.xdc]
set_property used_in_implementation false [get_files -all c:/Users/86150/Desktop/08_ps_uart/ps_uart.srcs/sources_1/bd/top/ip/top_rst_ps7_0_50M_0/top_rst_ps7_0_50M_0_board.xdc]
set_property used_in_implementation false [get_files -all c:/Users/86150/Desktop/08_ps_uart/ps_uart.srcs/sources_1/bd/top/ip/top_rst_ps7_0_50M_0/top_rst_ps7_0_50M_0.xdc]
set_property used_in_implementation false [get_files -all c:/Users/86150/Desktop/08_ps_uart/ps_uart.srcs/sources_1/bd/top/ip/top_rst_ps7_0_50M_0/top_rst_ps7_0_50M_0_ooc.xdc]
set_property used_in_implementation false [get_files -all c:/Users/86150/Desktop/08_ps_uart/ps_uart.srcs/sources_1/bd/top/ip/top_auto_pc_0/top_auto_pc_0_ooc.xdc]
set_property used_in_implementation false [get_files -all C:/Users/86150/Desktop/08_ps_uart/ps_uart.srcs/sources_1/bd/top/top_ooc.xdc]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc C:/Users/86150/Desktop/08_ps_uart/ps_uart.srcs/constrs_1/new/top_wrapper.xdc
set_property used_in_implementation false [get_files C:/Users/86150/Desktop/08_ps_uart/ps_uart.srcs/constrs_1/new/top_wrapper.xdc]

read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]

synth_design -top top_wrapper -part xc7z020clg400-2


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef top_wrapper.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file top_wrapper_utilization_synth.rpt -pb top_wrapper_utilization_synth.pb"