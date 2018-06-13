add_wave {{/acp_dummy_v1_0_tb/DUT/m00_axi_aclk}} 

add_wave -color magenta -radix bin {{/acp_dummy_v1_0_tb/DUT/acp_dummy_v1_0_S00_AXI_inst/slv_reg0}}
add_wave -color magenta -radix bin {{/acp_dummy_v1_0_tb/DUT/acp_dummy_v1_0_S00_AXI_inst/slv_reg1}} 
add_wave -color magenta -radix hex {{/acp_dummy_v1_0_tb/DUT/acp_dummy_v1_0_S00_AXI_inst/slv_reg2}} 
add_wave -color magenta -radix unsigned {{/acp_dummy_v1_0_tb/DUT/acp_dummy_v1_0_S00_AXI_inst/slv_reg3}} 
add_wave -color magenta -radix unsigned {{/acp_dummy_v1_0_tb/DUT/acp_dummy_v1_0_S00_AXI_inst/slv_reg4}} 
add_wave -color magenta -radix unsigned {{/acp_dummy_v1_0_tb/DUT/acp_dummy_v1_0_S00_AXI_inst/slv_reg5}} 
add_wave -color magenta -radix bin {{/acp_dummy_v1_0_tb/DUT/acp_dummy_v1_0_S00_AXI_inst/slv_reg29}} 
add_wave -color magenta -radix bin {{/acp_dummy_v1_0_tb/DUT/acp_dummy_v1_0_S00_AXI_inst/slv_reg30}} 

add_wave {{/acp_dummy_v1_0_tb/DUT/read_data}}
add_wave {{/acp_dummy_v1_0_tb/DUT/write_data}}

add_wave -color magenta -radix bin {{/acp_dummy_v1_0_tb/DUT/acp_dummy_v1_0_S00_AXI_inst/slv_reg30}} 

add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_aclk}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_aresetn}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_awaddr}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_awlen}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_awsize}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_awburst}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_awcache}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_awuser}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_awvalid}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_awready}}

add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_aclk}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_wdata}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_wstrb}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_wlast}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_wvalid}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_wready}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_bresp}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_bvalid}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_bready}}

add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_aclk}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_araddr}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_arlen}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_arsize}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_arburst}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_arcache}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_arqos}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_arvalid}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_arready}}

add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_aclk}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_rid}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_rdata}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_rresp}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_rlast}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_rvalid}}
add_wave -color cyan {{/acp_dummy_v1_0_tb/DUT/m00_axi_rready}}

add_wave -color orange {{/acp_dummy_v1_0_tb/DUT/bram/clk}}
add_wave -color orange {{/acp_dummy_v1_0_tb/DUT/bram/reset}}
add_wave -color orange {{/acp_dummy_v1_0_tb/DUT/bram/write_enable}}
add_wave -color orange {{/acp_dummy_v1_0_tb/DUT/bram/write_address}}
add_wave -color orange {{/acp_dummy_v1_0_tb/DUT/bram/data_in}}
add_wave -color orange {{/acp_dummy_v1_0_tb/DUT/bram/read_enable}}
add_wave -color orange {{/acp_dummy_v1_0_tb/DUT/bram/read_address}}
add_wave -color orange {{/acp_dummy_v1_0_tb/DUT/bram/data_out}}

add_wave -color yellow {{/acp_dummy_v1_0_tb/DUT/bram_output_fifo/clk}}
add_wave -color yellow {{/acp_dummy_v1_0_tb/DUT/bram_output_fifo/reset}}
add_wave -color yellow {{/acp_dummy_v1_0_tb/DUT/bram_output_fifo/write_enable}}
add_wave -color yellow {{/acp_dummy_v1_0_tb/DUT/bram_output_fifo/data_in}}
add_wave -color yellow {{/acp_dummy_v1_0_tb/DUT/bram_output_fifo/read_enable}}
add_wave -color yellow {{/acp_dummy_v1_0_tb/DUT/bram_output_fifo/full}}
add_wave -color yellow {{/acp_dummy_v1_0_tb/DUT/bram_output_fifo/data_out}}

run 2000ns
