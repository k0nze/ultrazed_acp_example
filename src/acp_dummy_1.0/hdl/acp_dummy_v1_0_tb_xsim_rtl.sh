# run this script while you are in the hdl directory

SRC_PATH="../src"

xvlog ${SRC_PATH}/xilinx_bram.v
xvlog ${SRC_PATH}/bram.v
xvlog ${SRC_PATH}/bram_output_fifo.v

xvlog acp_dummy_v1_0_M00_AXI.v
xvlog acp_dummy_v1_0_S00_AXI.v
xvlog acp_dummy_v1_0.v
xvlog --sv acp_dummy_v1_0_tb.sv 

xelab -debug typical acp_dummy_v1_0_tb -s tb

xsim tb -gui -t acp_dummy_v1_0_tb_xsim_rtl.tcl 
