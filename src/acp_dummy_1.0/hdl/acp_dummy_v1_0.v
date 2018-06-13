
`timescale 1 ns / 1 ps

module acp_dummy_v1_0 # (
    // Users to add parameters here
    parameter BRAM_WIDTH = 128,
    parameter BRAM_OUTPUT_FIFO_LENGTH = 16,
    parameter BRAM_DEPTH = 16384,
    parameter BRAM_DELAY_OFFSET = 4,

    // User parameters ends

    // Parameters of Axi Slave Bus Interface S00_AXI
    parameter integer C_S00_AXI_DATA_WIDTH    = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH    = 7,

    // Parameters of Axi Master Bus Interface M00_AXI
    parameter  C_M00_AXI_TARGET_SLAVE_BASE_ADDR    = 32'h10000000,
    parameter integer C_M00_AXI_ID_WIDTH    = 1,
    parameter integer C_M00_AXI_ADDR_WIDTH    = 32,
    parameter integer C_M00_AXI_DATA_WIDTH    = 128,
    parameter integer C_M00_AXI_AWUSER_WIDTH    = 0,
    parameter integer C_M00_AXI_ARUSER_WIDTH    = 0,
    parameter integer C_M00_AXI_WUSER_WIDTH    = 0,
    parameter integer C_M00_AXI_RUSER_WIDTH    = 0,
    parameter integer C_M00_AXI_BUSER_WIDTH    = 0
)
(
    // Users to add ports here

    // User ports ends
    
    // Do not modify the ports beyond this line


    // Ports of Axi Slave Bus Interface S00_AXI
    input wire  s00_axi_aclk,
    input wire  s00_axi_aresetn,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
    input wire [2 : 0] s00_axi_awprot,
    input wire  s00_axi_awvalid,
    output wire  s00_axi_awready,
    input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
    input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
    input wire  s00_axi_wvalid,
    output wire  s00_axi_wready,
    output wire [1 : 0] s00_axi_bresp,
    output wire  s00_axi_bvalid,
    input wire  s00_axi_bready,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
    input wire [2 : 0] s00_axi_arprot,
    input wire  s00_axi_arvalid,
    output wire  s00_axi_arready,
    output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
    output wire [1 : 0] s00_axi_rresp,
    output wire  s00_axi_rvalid,
    input wire  s00_axi_rready,

    // Ports of Axi Master Bus Interface M00_AXI
    input wire  m00_axi_aclk,
    input wire  m00_axi_aresetn,
    output wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_awid,
    output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_awaddr,
    output wire [7 : 0] m00_axi_awlen,
    output wire [2 : 0] m00_axi_awsize,
    output wire [1 : 0] m00_axi_awburst,
    output wire  m00_axi_awlock,
    output wire [3 : 0] m00_axi_awcache,
    output wire [2 : 0] m00_axi_awprot,
    output wire [3 : 0] m00_axi_awqos,
    output wire [C_M00_AXI_AWUSER_WIDTH-1 : 0] m00_axi_awuser,
    output wire  m00_axi_awvalid,
    input wire  m00_axi_awready,
    output wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_wdata,
    output wire [C_M00_AXI_DATA_WIDTH/8-1 : 0] m00_axi_wstrb,
    output wire  m00_axi_wlast,
    output wire [C_M00_AXI_WUSER_WIDTH-1 : 0] m00_axi_wuser,
    output wire  m00_axi_wvalid,
    input wire  m00_axi_wready,
    input wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_bid,
    input wire [1 : 0] m00_axi_bresp,
    input wire [C_M00_AXI_BUSER_WIDTH-1 : 0] m00_axi_buser,
    input wire  m00_axi_bvalid,
    output wire  m00_axi_bready,
    output wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_arid,
    output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_araddr,
    output wire [7 : 0] m00_axi_arlen,
    output wire [2 : 0] m00_axi_arsize,
    output wire [1 : 0] m00_axi_arburst,
    output wire  m00_axi_arlock,
    output wire [3 : 0] m00_axi_arcache,
    output wire [2 : 0] m00_axi_arprot,
    output wire [3 : 0] m00_axi_arqos,
    output wire [C_M00_AXI_ARUSER_WIDTH-1 : 0] m00_axi_aruser,
    output wire  m00_axi_arvalid,
    input wire  m00_axi_arready,
    input wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_rid,
    input wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_rdata,
    input wire [1 : 0] m00_axi_rresp,
    input wire  m00_axi_rlast,
    input wire [C_M00_AXI_RUSER_WIDTH-1 : 0] m00_axi_ruser,
    input wire  m00_axi_rvalid,
    output wire  m00_axi_rready
);

    function integer clogb2 (input integer bit_depth); begin                                                           
        for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
            bit_depth = bit_depth >> 1;                                 
        end                                                           
    endfunction
    
    integer i;
   
    // regs and wire for AXI master
    reg m00_axi_read_init_buffer;
    wire m00_axi_read_init;
    wire m00_axi_read_done;
    reg m00_axi_write_init_buffer;
    wire m00_axi_write_init;
    reg m00_axi_write_init_ff;
    wire m00_axi_write_done;
    wire [7:0] m00_axi_burst_length;
    reg [C_S00_AXI_DATA_WIDTH-1:0] m00_axi_base_addr;
    wire [C_M00_AXI_DATA_WIDTH-1:0] m00_axi_read_data;
    wire [C_M00_AXI_DATA_WIDTH-1:0] m00_axi_write_data;
    wire [C_S00_AXI_DATA_WIDTH-1:0] m00_axi_num_bursts;
    reg [8:0] m00_axi_burst_counter;

    reg internal_write_init;
    reg internal_read_init;
    reg internal_clear_interrupts;
    
    reg [C_M00_AXI_DATA_WIDTH-1:0] bram_write_start_address;
    reg [C_M00_AXI_DATA_WIDTH-1:0] bram_read_start_address;
    
    reg [C_S00_AXI_DATA_WIDTH-1:0] bram_write_address;
    reg [C_S00_AXI_DATA_WIDTH-1:0] bram_write_address_ff;
    reg [C_S00_AXI_DATA_WIDTH-1:0] bram_read_address;
    
    reg [31:0] bram_delay_counter;
    reg bram_increment_address;
    reg [C_M00_AXI_ADDR_WIDTH-1:0] bram_burst_address_counter;
    
    reg bram_output_fifo_reset;
    reg [3:0] bram_num_reads;
    
    reg reads_in_progress;
    reg writes_in_progress;
    
    reg reads_done;
    reg writes_done;
    
    // bram
    wire bram_write_enable;
    reg bram_read_enable;
    wire [BRAM_WIDTH-1:0] bram_data_in;
    wire [BRAM_WIDTH-1:0] bram_data_out;
    
    // bram output fifo
    wire [C_M00_AXI_DATA_WIDTH-1:0] bram_output_fifo_data_in;
    wire [C_M00_AXI_DATA_WIDTH-1:0] bram_output_fifo_data_out;
    wire bram_output_fifo_read_enable;
    wire bram_output_fifo_full;
    reg bram_output_fifo_write_enable;
    
    // slave
    wire axi_bus_ready;
    
    wire read_data;
    wire write_data;
    wire clear_interrupts;
    
    wire [C_S00_AXI_DATA_WIDTH-1:0] ddr_start_address;
    wire [C_S00_AXI_DATA_WIDTH-1:0] burst_length;
    wire [C_S00_AXI_DATA_WIDTH-1:0] num_bursts;
    wire [C_S00_AXI_DATA_WIDTH-1:0] bram_start_address;
                                          
    wire [3:0] axcache_value;
    wire [1:0] axuser_value;
    

    // Instantiation of Axi Bus Interface S00_AXI
    acp_dummy_v1_0_S00_AXI # ( 
        .C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
    ) acp_dummy_v1_0_S00_AXI_inst (
    
        .axi_bus_ready(axi_bus_ready),
    
        // command register
        .read_data(read_data),
        .write_data(write_data),
    
        .clear_interrupts(clear_interrupts),
    
        // command parameters
        .ddr_start_address(ddr_start_address),
        .burst_length(burst_length),
        .num_bursts(num_bursts),
        .bram_start_address(bram_start_address),
    
        .axcache_value(axcache_value),
        .axuser_value(axuser_value),
    
        .S_AXI_ACLK(s00_axi_aclk),
        .S_AXI_ARESETN(s00_axi_aresetn),
        .S_AXI_AWADDR(s00_axi_awaddr),
        .S_AXI_AWPROT(s00_axi_awprot),
        .S_AXI_AWVALID(s00_axi_awvalid),
        .S_AXI_AWREADY(s00_axi_awready),
        .S_AXI_WDATA(s00_axi_wdata),
        .S_AXI_WSTRB(s00_axi_wstrb),
        .S_AXI_WVALID(s00_axi_wvalid),
        .S_AXI_WREADY(s00_axi_wready),
        .S_AXI_BRESP(s00_axi_bresp),
        .S_AXI_BVALID(s00_axi_bvalid),
        .S_AXI_BREADY(s00_axi_bready),
        .S_AXI_ARADDR(s00_axi_araddr),
        .S_AXI_ARPROT(s00_axi_arprot),
        .S_AXI_ARVALID(s00_axi_arvalid),
        .S_AXI_ARREADY(s00_axi_arready),
        .S_AXI_RDATA(s00_axi_rdata),
        .S_AXI_RRESP(s00_axi_rresp),
        .S_AXI_RVALID(s00_axi_rvalid),
        .S_AXI_RREADY(s00_axi_rready)
    );
   
    // Instantiation of Axi Bus Interface M00_AXI
    acp_dummy_v1_0_M00_AXI # ( 
        .C_M_AXI_ID_WIDTH(C_M00_AXI_ID_WIDTH),
        .C_M_AXI_ADDR_WIDTH(C_M00_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH(C_M00_AXI_DATA_WIDTH),
        .C_M_AXI_AWUSER_WIDTH(C_M00_AXI_AWUSER_WIDTH),
        .C_M_AXI_ARUSER_WIDTH(C_M00_AXI_ARUSER_WIDTH),
        .C_M_AXI_WUSER_WIDTH(C_M00_AXI_WUSER_WIDTH),
        .C_M_AXI_RUSER_WIDTH(C_M00_AXI_RUSER_WIDTH),
        .C_M_AXI_BUSER_WIDTH(C_M00_AXI_BUSER_WIDTH)
    ) acp_dummy_v1_0_M00_AXI_inst (
    
        .clear_interrupts(clear_interrupts | internal_clear_interrupts),
    
        .M_AXI_READ_INIT(m00_axi_read_init),
        .M_AXI_READ_ADDR(m00_axi_base_addr),
        .M_AXI_READ_DATA(m00_axi_read_data),
        .M_AXI_READ_DONE(m00_axi_read_done),
    
        .M_AXI_WRITE_INIT(m00_axi_write_init_ff),
        .M_AXI_WRITE_ADDR(m00_axi_base_addr),
        .M_AXI_WRITE_DATA(m00_axi_write_data),
        .M_AXI_WRITE_DONE(m00_axi_write_done),
    
        .M_AXI_BURST_LENGTH(m00_axi_burst_length),
    
        .M_AXI_AXCACHE_VALUE(axcache_value),
        .M_AXI_AXUSER_VALUE(axuser_value),
    
        .M_AXI_ACLK(m00_axi_aclk),
        .M_AXI_ARESETN(m00_axi_aresetn),
        .M_AXI_AWID(m00_axi_awid),
        .M_AXI_AWADDR(m00_axi_awaddr),
        .M_AXI_AWLEN(m00_axi_awlen),
        .M_AXI_AWSIZE(m00_axi_awsize),
        .M_AXI_AWBURST(m00_axi_awburst),
        .M_AXI_AWLOCK(m00_axi_awlock),
        .M_AXI_AWCACHE(m00_axi_awcache),
        .M_AXI_AWPROT(m00_axi_awprot),
        .M_AXI_AWQOS(m00_axi_awqos),
        .M_AXI_AWUSER(m00_axi_awuser),
        .M_AXI_AWVALID(m00_axi_awvalid),
        .M_AXI_AWREADY(m00_axi_awready),
        .M_AXI_WDATA(m00_axi_wdata),
        .M_AXI_WSTRB(m00_axi_wstrb),
        .M_AXI_WLAST(m00_axi_wlast),
        .M_AXI_WUSER(m00_axi_wuser),
        .M_AXI_WVALID(m00_axi_wvalid),
        .M_AXI_WREADY(m00_axi_wready),
        .M_AXI_BID(m00_axi_bid),
        .M_AXI_BRESP(m00_axi_bresp),
        .M_AXI_BUSER(m00_axi_buser),
        .M_AXI_BVALID(m00_axi_bvalid),
        .M_AXI_BREADY(m00_axi_bready),
        .M_AXI_ARID(m00_axi_arid),
        .M_AXI_ARADDR(m00_axi_araddr),
        .M_AXI_ARLEN(m00_axi_arlen),
        .M_AXI_ARSIZE(m00_axi_arsize),
        .M_AXI_ARBURST(m00_axi_arburst),
        .M_AXI_ARLOCK(m00_axi_arlock),
        .M_AXI_ARCACHE(m00_axi_arcache),
        .M_AXI_ARPROT(m00_axi_arprot),
        .M_AXI_ARQOS(m00_axi_arqos),
        .M_AXI_ARUSER(m00_axi_aruser),
        .M_AXI_ARVALID(m00_axi_arvalid),
        .M_AXI_ARREADY(m00_axi_arready),
        .M_AXI_RID(m00_axi_rid),
        .M_AXI_RDATA(m00_axi_rdata),
        .M_AXI_RRESP(m00_axi_rresp),
        .M_AXI_RLAST(m00_axi_rlast),
        .M_AXI_RUSER(m00_axi_ruser),
        .M_AXI_RVALID(m00_axi_rvalid),
        .M_AXI_RREADY(m00_axi_rready)
    );
    
    
    // Add user logic here
    BRAM #(
        .RAM_DEPTH(BRAM_DEPTH)
    ) bram (
        .clk(m00_axi_aclk),
        .reset((m00_axi_aresetn == 1'b0)),
    
        .write_enable(bram_write_enable),
        .write_address(bram_write_address[clogb2(((BRAM_WIDTH/8)*BRAM_DEPTH)-1)-1:0]),
        .data_in(bram_data_in),
    
        .read_enable(bram_read_enable),
        .read_address(bram_read_address[clogb2(((BRAM_WIDTH/8)*BRAM_DEPTH)-1)-1:0]),
        .data_out(bram_data_out)
    );
    
    BRAM_OUTPUT_FIFO #(
        .DATA_WIDTH(C_M00_AXI_DATA_WIDTH),
        .LENGTH(BRAM_OUTPUT_FIFO_LENGTH)
    ) bram_output_fifo (
        .clk(m00_axi_aclk),
        .reset((m00_axi_aresetn == 1'b0) | (bram_output_fifo_reset == 1'b1)),
        .write_enable(bram_output_fifo_write_enable),
        .data_in(bram_output_fifo_data_in),
        .read_enable(bram_output_fifo_read_enable),
        .full(bram_output_fifo_full),
        .data_out(bram_output_fifo_data_out)
    );
    
    
    // BRAM <-> AXI read write FSM
    always @(posedge m00_axi_aclk) begin
        if(m00_axi_aresetn == 1'b0) begin

            // reset all registers

            // AXI master
            m00_axi_read_init_buffer <= 0;
            m00_axi_write_init_buffer <= 0;
            m00_axi_write_init_ff <= 0;
            m00_axi_base_addr <= 0;
            m00_axi_burst_counter <= 0;
   
            // BRAM
            bram_read_enable <= 0;

            bram_write_start_address <= 0;
            bram_write_address <= 0;
            bram_write_address_ff <= 0;

            bram_read_start_address <= 0;
            bram_read_address <= 0;
    
            bram_delay_counter <= 0;
            bram_increment_address <= 0;
            bram_burst_address_counter <= 0;
    
            bram_num_reads <= 0;
    
            // bram output fifo
            bram_output_fifo_write_enable <= 0;
            bram_output_fifo_reset <= 0;

            // control signals
            reads_in_progress <= 0;
            writes_in_progress <= 0;
    
            reads_done <= 0;
            writes_done <= 0;

            internal_write_init <= 0;
            internal_read_init <= 0;
            internal_clear_interrupts <= 0;
        end
        else begin
            if(reads_in_progress == 1) begin
                // if an AXI4 burst read starts initialize bram address
                if(m00_axi_arvalid == 1'b1) begin
                    bram_write_address <= bram_write_start_address;
                    bram_write_address_ff <= bram_write_start_address;
                end
                // if AXI4 burst read data is valid write it into bram and
                // increment the bram address for port a
                if(m00_axi_rvalid == 1'b1) begin
                    bram_write_address_ff <= bram_write_address_ff + 16;
                    bram_write_address <= bram_write_address_ff;
                end
            end
    
            if(writes_in_progress == 1) begin
                // if an AXI4 burst write starts initialize bram_delay_counter
                // to cope with BRAM read delays
                if(bram_delay_counter != 0) begin
                    bram_delay_counter <= bram_delay_counter + 1;
                end

                // start increasing the BRAM read address
                if(bram_delay_counter == 1) begin
                    bram_increment_address <= 1;
                end

                // release the bram_output_fifo reset such that data can be
                // written into it
                if(bram_delay_counter == 2) begin
                    bram_output_fifo_reset <= 0;
                end

                // first value read from BRAM is ready now and can be written
                // into the bram_output_fifo
                if(bram_delay_counter == 3) begin
                    bram_output_fifo_write_enable <= 1;
                end

                // trigger (pulse) AXI master FSM to initialize a write
                if(bram_delay_counter == BRAM_DELAY_OFFSET) begin
                    m00_axi_write_init_ff <= 1;
                end

                // set bram_delay_counter to zero because the BRAM delay is
                // over
                if(bram_delay_counter == BRAM_DELAY_OFFSET+1) begin
                    bram_delay_counter <= 0;
                end

                // release pulse for AXI master FSM
                if(m00_axi_write_init_ff == 1) begin
                    m00_axi_write_init_ff <= 0;
                end

                // increase BRAM address when BRAM address should be increased,
                // the bram_output_fifo is not full and the AXI burst is not 
                // over yet
                if(bram_increment_address == 1'b1 && bram_output_fifo_full != 1'b1 && bram_num_reads != burst_length+2) begin
                    bram_read_address <= bram_read_address + 16;
                    bram_num_reads <= bram_num_reads + 1;
                end

                // if the burst is over disable write 
                if(bram_num_reads == burst_length+2) begin
                    bram_output_fifo_write_enable <= 0;
                end

                // decrease the bram_burst_address_counter until it is zero
                if(bram_burst_address_counter != 0) begin
                    bram_burst_address_counter <= bram_burst_address_counter - 1;
                end
            end
    
            // write_data pulse from the AXI slave triggers an AXI master write
            // by generating a puls on m00_axi_write_init_buffer
            if(write_data) begin
                m00_axi_write_init_buffer <= 1;
            end
   
            if(m00_axi_write_init_buffer == 1) begin
                m00_axi_write_init_buffer <= 0;
            end
    
            // if an AXI4 burst write starts initialize BRAM address
            if(m00_axi_write_init) begin
                bram_burst_address_counter <= m00_axi_burst_length;
                bram_delay_counter <= 1;
    
                bram_output_fifo_write_enable <= 0;
    
                writes_in_progress <= 1;

                bram_read_enable <= 1;
    
                bram_num_reads <= 0;
               
                // if all consecutive write bursts are finished the write
                // transcation is over
                if(m00_axi_burst_counter == 0) begin
                    bram_output_fifo_reset <= 1;
                    m00_axi_burst_counter <= m00_axi_num_bursts - 1;
                    m00_axi_base_addr <= ddr_start_address; 
                    bram_read_address <= bram_start_address;
                    bram_read_start_address <= bram_start_address;
                end
            end
  
            // if one AXI write burst is finished either finish the whole
            // transaction when all consecutives bursts are done or trigger 
            // the next consecutive burst transaction by generating a pulse on
            // internal_write_init
            if(m00_axi_write_done & writes_in_progress) begin
                                
                bram_increment_address <= 0;
    
                if(m00_axi_burst_counter == 0) begin
                    bram_output_fifo_write_enable <= 0;
                    
                    bram_read_enable <= 0;
    
                    writes_in_progress <= 0;
                    writes_done <= 1;
                end
                else begin
                    internal_clear_interrupts <= 1;
                    internal_write_init <= 1;
                end
    
            end
   
            if(internal_write_init == 1) begin
                internal_write_init <= 0;
            end
  
            // increase the addresses for the next consecutive AXI burst write
            if(internal_clear_interrupts == 1 && writes_in_progress) begin
                internal_clear_interrupts <= 0;
                m00_axi_burst_counter <= m00_axi_burst_counter - 1;
                m00_axi_base_addr <= m00_axi_base_addr + ((m00_axi_burst_length+1) << 4);
                bram_read_address <= bram_read_start_address + ((m00_axi_burst_length+1) << 4);
                bram_read_start_address <= bram_read_start_address + ((m00_axi_burst_length+1) << 4);
            end
    
            // read_data pulse from the AXI slave triggers an AXI master read 
            // by generating a puls on m00_axi_read_init_buffer
            if(read_data) begin
                m00_axi_read_init_buffer <= 1;
            end
    
            if(m00_axi_read_init_buffer == 1) begin
                m00_axi_read_init_buffer <= 0;
            end
   
            // if all consectutive bursts are finished set all signals
            // appropreately
            if(m00_axi_read_init) begin
                reads_in_progress <= 1;
    
                if(m00_axi_burst_counter == 0) begin
                    m00_axi_burst_counter <= m00_axi_num_bursts - 1;
                    m00_axi_base_addr <= ddr_start_address; 
                    bram_write_start_address <= bram_start_address;
                end
            end
    
            // if one AXI read burst is finished either finish the whole
            // transaction when all consecutives bursts are done or trigger 
            // the next consecutive burst transaction by generating a pulse on
            // internal_write_init
            if(m00_axi_read_done & reads_in_progress) begin
             
                if(m00_axi_burst_counter == 0) begin
                    reads_in_progress <= 0;
                    reads_done <= 1;
                end
                else begin
                    internal_clear_interrupts <= 1;
                    internal_read_init <= 1;
                end
            end
           
            if(internal_read_init == 1) begin
                internal_read_init <= 0;
            end
   
            // increase the addresses for the next consecutive AXI burst write
            if(internal_clear_interrupts == 1 && reads_in_progress) begin
                internal_clear_interrupts <= 0;
                m00_axi_burst_counter <= m00_axi_burst_counter - 1;
                m00_axi_base_addr <= m00_axi_base_addr + ((m00_axi_burst_length+1) << 4);
                bram_write_start_address <= bram_write_start_address + ((m00_axi_burst_length+1) << 4);
            end
   
            // unset read and write done singals
            if(clear_interrupts) begin
                reads_done <= 0;
                writes_done <= 0;
            end
        end
    end
   
    // the AXI bus is busy if a read or a write is in progress
    assign axi_bus_ready = !writes_in_progress & !reads_in_progress;
    
    assign m00_axi_read_init = m00_axi_read_init_buffer | internal_read_init;
    assign m00_axi_write_init = m00_axi_write_init_buffer | internal_write_init;
    
    // burst length
    assign m00_axi_burst_length = burst_length;
    
    // number of consecutive bursts
    assign m00_axi_num_bursts = num_bursts;
    
    // write data
    assign m00_axi_write_data = bram_output_fifo_data_out;
    
    // input data bram
    assign bram_write_enable = m00_axi_rvalid;
    assign bram_data_in = m00_axi_read_data;
    
    // bram output fifo
    assign bram_output_fifo_read_enable = m00_axi_wready & m00_axi_wvalid;
    
    // bram_output_fifo_data_in
    assign bram_output_fifo_data_in = bram_data_out;
    
    // User logic ends
endmodule
