# run this script while you are in the hdl directory

quit -sim

# Create the library.
if [file exists work] {
   vdel -all
}
vlib work

set SRC_PATH "../src"

vlog -novopt ${SRC_PATH}/xilinx_bram.v
vlog -novopt ${SRC_PATH}/bram.v
vlog -novopt ${SRC_PATH}/bram_output_fifo.v

vlog -novopt acp_dummy_v1_0_M00_AXI.v
vlog -novopt acp_dummy_v1_0_S00_AXI.v
vlog -novopt acp_dummy_v1_0.v
vlog -novopt acp_dummy_v1_0_tb.sv 
vopt acp_dummy_v1_0_tb -debugdb -o tb

vsim tb -debugdb -novopt -l rtl.log -wlf rtl.wlf 

add wave  \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_aclk

# slave regs
add wave -color magenta -radix binary \
sim:/acp_dummy_v1_0_tb/DUT/acp_dummy_v1_0_S00_AXI_inst/slv_reg0 \
sim:/acp_dummy_v1_0_tb/DUT/acp_dummy_v1_0_S00_AXI_inst/slv_reg1

add wave -color magenta -radix hexadecimal \
sim:/acp_dummy_v1_0_tb/DUT/acp_dummy_v1_0_S00_AXI_inst/slv_reg2 \

add wave -color magenta -radix unsigned \
sim:/acp_dummy_v1_0_tb/DUT/acp_dummy_v1_0_S00_AXI_inst/slv_reg3 \
sim:/acp_dummy_v1_0_tb/DUT/acp_dummy_v1_0_S00_AXI_inst/slv_reg4 \
sim:/acp_dummy_v1_0_tb/DUT/acp_dummy_v1_0_S00_AXI_inst/slv_reg5

add wave -color magenta -radix binary \
sim:/acp_dummy_v1_0_tb/DUT/acp_dummy_v1_0_S00_AXI_inst/slv_reg29 \
sim:/acp_dummy_v1_0_tb/DUT/acp_dummy_v1_0_S00_AXI_inst/slv_reg30

add wave  \
sim:/acp_dummy_v1_0_tb/DUT/read_data \
sim:/acp_dummy_v1_0_tb/DUT/write_data

add wave -color cyan \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_aclk \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_aresetn \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_awaddr \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_awlen \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_awsize \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_awburst \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_awcache \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_awuser \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_awvalid \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_awready \

add wave -color cyan \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_aclk \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_wdata \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_wstrb \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_wlast \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_wvalid \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_wready \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_bresp \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_bvalid \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_bready \

add wave -color cyan \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_aclk \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_araddr \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_arlen \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_arsize \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_arburst \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_arcache \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_aruser \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_arvalid \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_arready \

add wave -color cyan \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_aclk \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_rid \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_rdata \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_rresp \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_rlast \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_rvalid \
sim:/acp_dummy_v1_0_tb/DUT/m00_axi_rready

add wave -color orange \
sim:/acp_dummy_v1_0_tb/DUT/bram/clk \
sim:/acp_dummy_v1_0_tb/DUT/bram/reset \
sim:/acp_dummy_v1_0_tb/DUT/bram/write_enable \
sim:/acp_dummy_v1_0_tb/DUT/bram/write_address \
sim:/acp_dummy_v1_0_tb/DUT/bram/data_in \
sim:/acp_dummy_v1_0_tb/DUT/bram/read_enable \
sim:/acp_dummy_v1_0_tb/DUT/bram/read_address \
sim:/acp_dummy_v1_0_tb/DUT/bram/data_out

add wave -color yellow  \
sim:/acp_dummy_v1_0_tb/DUT/bram_output_fifo/clk \
sim:/acp_dummy_v1_0_tb/DUT/bram_output_fifo/reset \
sim:/acp_dummy_v1_0_tb/DUT/bram_output_fifo/write_enable \
sim:/acp_dummy_v1_0_tb/DUT/bram_output_fifo/data_in \
sim:/acp_dummy_v1_0_tb/DUT/bram_output_fifo/read_enable \
sim:/acp_dummy_v1_0_tb/DUT/bram_output_fifo/full \
sim:/acp_dummy_v1_0_tb/DUT/bram_output_fifo/data_out

run 2000ns
