`timescale 1 ns / 1 ps

// all transactions over the AXI-Busses will be printed onto the command line
`define AXI_VERBOSE
// AX_CACHE value
`define AX_CACHE 32'h0000000f
// AX_USER value
`define AX_USER  32'h00000002
// from where in the DDR should data be read by the AXI-Master
`define SOURCE_ADDRESS 32'h21000000
// to which location in the DDR should the AXI-Master write
`define TARGET_ADDRESS 32'h28000000
// to which and from which address should the AXI-Master write in the BRAM
`define BRAM_ADDRESS 1024
// how many consecutive burst should be executed
`define NUM_BURSTS 3
// how many 128 Bit values should be transmitted in each burst
`define BURST_LENGTH 4


`define SLV_REG0    7'b0000000
`define SLV_REG1    7'b0000100
`define SLV_REG2    7'b0001000
`define SLV_REG3    7'b0001100

`define SLV_REG4    7'b0010000
`define SLV_REG5    7'b0010100
`define SLV_REG6    7'b0011000
`define SLV_REG7    7'b0011100

`define SLV_REG8    7'b0100000
`define SLV_REG9    7'b0100100
`define SLV_REG10   7'b0101000
`define SLV_REG11   7'b0101100

`define SLV_REG12   7'b0110000
`define SLV_REG13   7'b0110100
`define SLV_REG14   7'b0111000
`define SLV_REG15   7'b0111100

`define SLV_REG16   7'b1000000
`define SLV_REG17   7'b1000100
`define SLV_REG18   7'b1001000
`define SLV_REG19   7'b1001100

`define SLV_REG20   7'b1010000
`define SLV_REG21   7'b1010100
`define SLV_REG22   7'b1011000
`define SLV_REG23   7'b1011100

`define SLV_REG24   7'b1100000
`define SLV_REG25   7'b1100100
`define SLV_REG26   7'b1101000
`define SLV_REG27   7'b1101100

`define SLV_REG28   7'b1110000
`define SLV_REG29   7'b1110100
`define SLV_REG30   7'b1111000
`define SLV_REG31   7'b1111100


`define TICK #10
`define HALF_TICK #5


module acp_dummy_v1_0_tb ();

        // Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32;
		parameter integer C_S00_AXI_ADDR_WIDTH	= 7;

		// Parameters of Axi Master Bus Interface M00_AXI
		parameter  C_M00_AXI_TARGET_SLAVE_BASE_ADDR	= 32'h10000000;
		parameter integer C_M00_AXI_BURST_LEN	= 16;
		parameter integer C_M00_AXI_ID_WIDTH	= 1;
		parameter integer C_M00_AXI_ADDR_WIDTH	= 32;
		parameter integer C_M00_AXI_DATA_WIDTH	= 128;
		parameter integer C_M00_AXI_AWUSER_WIDTH    = 0;
		parameter integer C_M00_AXI_ARUSER_WIDTH	= 0;
		parameter integer C_M00_AXI_WUSER_WIDTH	= 0;
		parameter integer C_M00_AXI_RUSER_WIDTH	= 0;
		parameter integer C_M00_AXI_BUSER_WIDTH	= 0;

        parameter BRAM_DEPTH = 16384;
        
        // fake memory
        bit [63:0] mem[integer];

        reg clk;
        reg reset_n;

        bit [C_S00_AXI_DATA_WIDTH-1:0] data;
        bit txn_done;

        integer i;

        wire interrupt_writes_done;
        wire interrupt_reads_done;

		// Ports of Axi Slave Bus Interface S00_AXI
		reg [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr;
		reg [2 : 0] s00_axi_awprot;
		reg s00_axi_awvalid;
		wire s00_axi_awready;
		reg [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata;
		reg [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb;
		reg s00_axi_wvalid;
		wire s00_axi_wready;
		wire [1 : 0] s00_axi_bresp;
		wire s00_axi_bvalid;
		reg s00_axi_bready;
		reg [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr;
		reg [2 : 0] s00_axi_arprot;
		reg s00_axi_arvalid;
		wire s00_axi_arready;
		wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata;
		wire [1 : 0] s00_axi_rresp;
		wire s00_axi_rvalid;
		reg s00_axi_rready;

		// Ports of Axi Master Bus Interface M00_AXI
		wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_awid;
		wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_awaddr;
		wire [7 : 0] m00_axi_awlen;
		wire [2 : 0] m00_axi_awsize;
		wire [1 : 0] m00_axi_awburst;
		wire m00_axi_awlock;
		wire [3 : 0] m00_axi_awcache;
		wire [2 : 0] m00_axi_awprot;
		wire [3 : 0] m00_axi_awqos;
		wire [C_M00_AXI_AWUSER_WIDTH-1 : 0] m00_axi_awuser;
		wire m00_axi_awvalid;
		reg m00_axi_awready;
		wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_wdata;
		wire [C_M00_AXI_DATA_WIDTH/8-1 : 0] m00_axi_wstrb;
		wire m00_axi_wlast;
		wire [C_M00_AXI_WUSER_WIDTH-1 : 0] m00_axi_wuser;
		wire m00_axi_wvalid;
		reg m00_axi_wready;
		reg [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_bid;
		reg [1 : 0] m00_axi_bresp;
		reg [C_M00_AXI_BUSER_WIDTH-1 : 0] m00_axi_buser;
		reg m00_axi_bvalid;
		wire m00_axi_bready;
		wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_arid;
		wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_araddr;
		wire [7 : 0] m00_axi_arlen;
		wire [2 : 0] m00_axi_arsize;
		wire [1 : 0] m00_axi_arburst;
		wire  m00_axi_arlock;
		wire [3 : 0] m00_axi_arcache;
		wire [2 : 0] m00_axi_arprot;
		wire [3 : 0] m00_axi_arqos;
		wire [C_M00_AXI_ARUSER_WIDTH-1 : 0] m00_axi_aruser;
		wire m00_axi_arvalid;
		reg m00_axi_arready;
		reg [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_rid;
		reg [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_rdata;
		reg [1 : 0] m00_axi_rresp;
		reg m00_axi_rlast;
		reg [C_M00_AXI_RUSER_WIDTH-1 : 0] m00_axi_ruser;
		reg m00_axi_rvalid;
		wire m00_axi_rready;

/* -------------------------------------------------------------------------
 *                        tasks and functions
 * ------------------------------------------------------------------------- */

        task setAllRegsTo0();
            clk <= 1'b0;
            reset_n <= 1'b0;

            s00_axi_awaddr <= '0;
		    s00_axi_awprot <= '0;
            s00_axi_wdata <= '0;
		    s00_axi_wstrb <= '0;
		    s00_axi_awvalid <= '0;
		    s00_axi_wvalid <= '0;
            s00_axi_bready <= '0;
            s00_axi_araddr <= '0;
            s00_axi_arprot <= '0;
            s00_axi_arvalid <= '0;
            s00_axi_rready <= '0;

            m00_axi_awready <= '0;
            m00_axi_wready <= '0;
            m00_axi_bid <= '0;
            m00_axi_bresp <= '0;
            m00_axi_bvalid <= '0;
            m00_axi_arready <= '0;
            m00_axi_rid <= '0;
            m00_axi_rdata <= '0;
            m00_axi_rresp <= '0;
            m00_axi_rlast <= '0;
            m00_axi_rvalid <= '0;
        endtask

        task handleAXI4BurstWriteTransaction();
            // store address
            integer write_address;
            integer burst_write_length;
            integer wready_counter;
            bit wready_break;

            wready_counter = 2;
            wready_break = 1;
            // store address and burst length
            write_address = m00_axi_awaddr;
            burst_write_length = m00_axi_awlen;

            `ifdef AXI_VERBOSE
            $display(" * start burst write transaction to address 0x%h, length %d", write_address, burst_write_length + 1);
            `endif

            // tell master that provided address (over m00_axi_awaddr) was
            // recognized
            m00_axi_awready = 1'b1;

            // wait until the first valid data word arrives
            while(m00_axi_wvalid == 1'b0) begin
                `TICK 
                reset_n = reset_n;
            end

            // tell master that transferred data (over m00_axi_wdata) can be stored
            m00_axi_wready = 1'b1;

            if(burst_write_length != 0) begin
                // store data in mem until M_AXI_WLAST is HIGH
                while(m00_axi_wlast == 1'b0) begin
                    `TICK
                    //$display("mem[%h] = %d", write_address, m00_axi_wdata);
                    if(m00_axi_wready == 1'b1) begin
                        mem[write_address] = m00_axi_wdata[63:0];
                        mem[write_address+8] = m00_axi_wdata[127:64];
                        write_address = write_address + 16;
                    end

                    if(wready_break == 1) begin
                        if(m00_axi_wready == 1'b1) begin
                            if(wready_counter == 0) begin
                                wready_counter = 2;
                                m00_axi_wready = 0;
                            end
                            wready_counter = wready_counter - 1;
                        end
                        else begin
                            if(wready_counter == 0) begin
                                wready_counter = 2;
                                m00_axi_wready = 1;
                                wready_break = 0;
                            end
                            wready_counter = wready_counter - 1;
                        end
                    end
                end
            end
            else begin
                `TICK
                mem[write_address] = m00_axi_wdata[63:0];
                mem[write_address+8] = m00_axi_wdata[127:64];
            end

            // tell master that transfer was successful
            `TICK
            m00_axi_wready = 1'b0;
            m00_axi_bvalid = 1'b1;
            `TICK
            `TICK
            m00_axi_bvalid = 1'b0;

            `TICK reset_n = reset_n;
            `ifdef AXI_VERBOSE
            $display(" * end burst write transaction to address 0x%h", write_address);
            `endif
        endtask

        task handleAXI4BurstReadTransaction();
            integer i;
            integer read_address;
            integer burst_read_length;

            // store address and burst length
            read_address = m00_axi_araddr;
            burst_read_length = m00_axi_arlen;

            `ifdef AXI_VERBOSE
            $display(" * start burst read transaction from address 0x%h, length %d", read_address, burst_read_length + 1);
            `endif

            // tell master that provided address (over m00_axi_araddr) was
            // recognized
            m00_axi_arready = 1'b1;
            `TICK
            `TICK
            m00_axi_arready = 1'b0;

            if(burst_read_length == 0) begin
                m00_axi_rlast = 1'b1;
                m00_axi_rvalid = 1'b1;
                m00_axi_rdata = {mem[read_address+8],mem[read_address]};
                `TICK
                `TICK
                m00_axi_rlast = 1'b0;
                m00_axi_rvalid = 1'b0;
                m00_axi_rdata <= '0;
            end
            else begin
                for(i = 0; i <= burst_read_length; i = i + 1) begin

                    // tell master that the last piece of data will be transferred
                    if(i == burst_read_length) begin
                        m00_axi_rlast = 1'b1;
                    end

                    // transmit data
                    m00_axi_rvalid = 1'b1;
                    m00_axi_rdata = {mem[read_address+8],mem[read_address]};

                    // wait until master is ready to receive data
                    while(m00_axi_rready == 1'b0) begin
                        `TICK 
                        reset_n = reset_n;
                    end
                    `TICK
                    read_address = read_address + 16;
                    m00_axi_rvalid = 1'b0;
                end

                m00_axi_rlast = 1'b0;
            end

            `ifdef AXI_VERBOSE
            $display(" * end burst read transaction from address 0x%h", read_address);
            `endif
        endtask

        task doAXI4LiteWriteTransaction(input bit [C_S00_AXI_ADDR_WIDTH-1:0] target_slave_reg, input bit [C_S00_AXI_DATA_WIDTH-1:0] data);

            `ifdef AXI_VERBOSE
            $display(" * write transaction to slave register %b, data = %d", target_slave_reg, data);
            `endif

            // tell slave the target register and the data
            s00_axi_awaddr = target_slave_reg;
            s00_axi_awvalid = 1'b1;
            s00_axi_wdata = data;
            s00_axi_wvalid = 1'b1;
            s00_axi_wstrb = 4'b1111;

            // wait until slave recognizes the provided address and data
            while(s00_axi_awready == 1'b0 && s00_axi_wready == 1'b0) begin
                `TICK 
                reset_n = reset_n;
            end

            `TICK
            s00_axi_awaddr = {C_S00_AXI_ADDR_WIDTH{1'b0}};
            s00_axi_awvalid = 1'b0;

            // tell slave the the response can be accepted
            s00_axi_bready = 1'b1;

            // wait until slave has processed provided data
            while(s00_axi_wready == 1'b1) begin
                `TICK 
                reset_n = reset_n;
            end

            s00_axi_wdata = '0;
            s00_axi_wvalid = 1'b0;
            s00_axi_wstrb = 4'b0000;

            // wait until slave sends its response
            while(s00_axi_bvalid == 1'b0) begin
                `TICK 
                reset_n = reset_n;
            end

            `TICK
            s00_axi_bready = 1'b0;
        endtask

        task doAXI4LiteReadTransaction(input bit [C_S00_AXI_ADDR_WIDTH-1:0] target_slave_reg, output bit [C_S00_AXI_DATA_WIDTH-1:0] data);

            // tell slave the target register
            s00_axi_araddr = target_slave_reg;
            s00_axi_arvalid = 1'b1;

            // wait until slave recognizes the provided address
            while(s00_axi_arready == 1'b0) begin
                `TICK
                reset_n = reset_n;
            end

            `TICK
            s00_axi_araddr = {C_S00_AXI_ADDR_WIDTH{1'b0}};
            s00_axi_arvalid = 1'b0;
            s00_axi_rready = 1'b1;

            // wait until slave sends its response
            while(s00_axi_rvalid == 1'b0) begin
                `TICK
                reset_n = reset_n;
            end

            // store data provided by slave
            data = s00_axi_rdata;

            `ifdef AXI_VERBOSE
            $display(" * read transaction from slave register %b, data = %d", target_slave_reg, data);
            `endif

            `TICK
            s00_axi_rready = 1'b0;
        endtask

        task initMemory(input bit [C_M00_AXI_ADDR_WIDTH-1:0] start_address, input bit [C_M00_AXI_ADDR_WIDTH-1:0] length);
            integer i, j;
            i = start_address;
            //$display("%h",start_address);

            j = 0;
            for(i = start_address; i < start_address+(8*length); i = i + 8) begin
                //mem[i] = {C_M00_AXI_DATA_WIDTH{1'b0}};
                mem[i] = ((j*2+1) << 32) | (j*2);
                j = j + 1;
            end
        endtask
        
        task resetMemory();
            foreach(mem[i]) begin
                //mem[i] = {C_M00_AXI_DATA_WIDTH{1'b0}};
                mem.delete(i);
            end
        endtask

        task printMemory();
            $display("DDR:");
            foreach(mem[i]) begin
                $display("%h : 0x%h", i, mem[i]);
            end
        endtask

        task printBRAM(integer from, integer to);
            $display("BRAM:");
            for(i = from; i <= to; i=i+16) begin
                $display("%d : 0x%h", i, DUT.bram.xilinx_bram.BRAM[i/16]);
            end
        endtask

        initial begin
           
            integer i;
            bit txn_done; 
            bit [31:0] data;

            $display("START tb");

            setAllRegsTo0();

            reset_n = 1'b0;
            `TICK
            `TICK
            `TICK
            reset_n = 1'b1;

            // load data into DDR
            resetMemory();
            initMemory(`SOURCE_ADDRESS, 2*`BURST_LENGTH*`NUM_BURSTS);
            printMemory();

            // set AX_CACHE
            doAXI4LiteWriteTransaction(`SLV_REG29, `AX_CACHE);    
            // set AX_USER
            doAXI4LiteWriteTransaction(`SLV_REG30, `AX_USER);    

            // clear interrupts
            doAXI4LiteWriteTransaction(`SLV_REG1, (1 << 31));    

            // read values from DDR into BRAM
            // ddr_start_address
            doAXI4LiteWriteTransaction(`SLV_REG2, `SOURCE_ADDRESS);    
            // burst_length
            doAXI4LiteWriteTransaction(`SLV_REG3, `BURST_LENGTH-1);    
            // num_bursts
            doAXI4LiteWriteTransaction(`SLV_REG4, `NUM_BURSTS);    
            // bram_start_address
            doAXI4LiteWriteTransaction(`SLV_REG5, `BRAM_ADDRESS);    

            // read_data
            doAXI4LiteWriteTransaction(`SLV_REG1, (1 << 0));    

            txn_done = 1'b0;

            // poll slave until burst transactions are done
            doAXI4LiteReadTransaction(`SLV_REG0, data);    
            txn_done = data[0:0];

            while(txn_done == 1'b0) begin
                doAXI4LiteReadTransaction(`SLV_REG0, data);    
                txn_done = data[0:0];
            end

            // clear interrupts
            doAXI4LiteWriteTransaction(`SLV_REG1, (1 << 31));    

            printBRAM(`BRAM_ADDRESS, `BRAM_ADDRESS+`NUM_BURSTS*4*16-1);

            // write values from DDR into BRAM
            // ddr_start_address
            doAXI4LiteWriteTransaction(`SLV_REG2, `TARGET_ADDRESS);    
            // burst_length
            doAXI4LiteWriteTransaction(`SLV_REG3, `BURST_LENGTH-1);    
            // num_bursts
            doAXI4LiteWriteTransaction(`SLV_REG4, `NUM_BURSTS);    
            // bram_start_address
            doAXI4LiteWriteTransaction(`SLV_REG5, `BRAM_ADDRESS);    

            // write_data
            doAXI4LiteWriteTransaction(`SLV_REG1, (1 << 1));    

            txn_done = 1'b0;

            // poll slave until burst transactions are done
            doAXI4LiteReadTransaction(`SLV_REG0, data);    
            txn_done = data[0:0];

            while(txn_done == 1'b0) begin
                doAXI4LiteReadTransaction(`SLV_REG0, data);    
                txn_done = data[0:0];
            end

            // clear interrupts
            doAXI4LiteWriteTransaction(`SLV_REG1, (1 << 31));    

            //printMemory();

            // check if data in DDR is okay
            $display("Check data in DDR:");
            $display("SOURCE:                         TARGET:");
            for(i = 0; i < 0+(8*`NUM_BURSTS*4*2); i = i + 8) begin
                $display("%h : 0x%h   %h : 0x%h   %s", i+`SOURCE_ADDRESS, mem[i+`SOURCE_ADDRESS], i+`TARGET_ADDRESS, mem[i+`TARGET_ADDRESS], (mem[i+`SOURCE_ADDRESS] == mem[i+`TARGET_ADDRESS]) ? "OK" : "FAILED" );
            end

            $display("END tb");
        end

        always @(posedge clk) begin
            if(m00_axi_awvalid == 1'b1) begin
                handleAXI4BurstWriteTransaction(); 
            end
            else if(m00_axi_arvalid == 1'b1) begin
                handleAXI4BurstReadTransaction();
            end
        end

        always begin
            `HALF_TICK clk = !clk;
        end


    acp_dummy_v1_0 #(
		.C_S00_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S00_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH),
		.C_M00_AXI_TARGET_SLAVE_BASE_ADDR(C_M00_AXI_TARGET_SLAVE_BASE_ADDR),
		.C_M00_AXI_ID_WIDTH(C_M00_AXI_ID_WIDTH),
		.C_M00_AXI_ADDR_WIDTH(C_M00_AXI_ADDR_WIDTH),
		.C_M00_AXI_DATA_WIDTH(C_M00_AXI_DATA_WIDTH),
		.C_M00_AXI_AWUSER_WIDTH(C_M00_AXI_AWUSER_WIDTH),
		.C_M00_AXI_ARUSER_WIDTH(C_M00_AXI_ARUSER_WIDTH),
		.C_M00_AXI_WUSER_WIDTH(C_M00_AXI_WUSER_WIDTH),
		.C_M00_AXI_RUSER_WIDTH(C_M00_AXI_RUSER_WIDTH),
		.C_M00_AXI_BUSER_WIDTH(C_M00_AXI_BUSER_WIDTH),
        .BRAM_WIDTH(128),
        .BRAM_OUTPUT_FIFO_LENGTH(16),
        .BRAM_DEPTH(BRAM_DEPTH)
	) DUT (
		// Ports of Axi Slave Bus Interface S00_AXI
		.s00_axi_aclk(clk),
		.s00_axi_aresetn(reset_n),
		.s00_axi_awaddr(s00_axi_awaddr),
	    .s00_axi_awprot(s00_axi_awprot),
		.s00_axi_awvalid(s00_axi_awvalid),
		.s00_axi_awready(s00_axi_awready),
		.s00_axi_wdata(s00_axi_wdata),
		.s00_axi_wstrb(s00_axi_wstrb),
		.s00_axi_wvalid(s00_axi_wvalid),
		.s00_axi_wready(s00_axi_wready),
		.s00_axi_bresp(s00_axi_bresp),
		.s00_axi_bvalid(s00_axi_bvalid),
		.s00_axi_bready(s00_axi_bready),
		.s00_axi_araddr(s00_axi_araddr),
		.s00_axi_arprot(s00_axi_arprot),
		.s00_axi_arvalid(s00_axi_arvalid),
		.s00_axi_arready(s00_axi_arready),
		.s00_axi_rdata(s00_axi_rdata),
		.s00_axi_rresp(s00_axi_rresp),
		.s00_axi_rvalid(s00_axi_rvalid),
		.s00_axi_rready(s00_axi_rready),

		// Ports of Axi Master Bus Interface M00_AXI
		.m00_axi_aclk(clk),
		.m00_axi_aresetn(reset_n),
		.m00_axi_awid(m00_axi_awid),
		.m00_axi_awaddr(m00_axi_awaddr),
		.m00_axi_awlen(m00_axi_awlen),
		.m00_axi_awsize(m00_axi_awsize),
		.m00_axi_awburst(m00_axi_awburst),
		.m00_axi_awlock(m00_axi_awlock),
		.m00_axi_awcache(m00_axi_awcache),
		.m00_axi_awprot(m00_axi_awprot),
		.m00_axi_awqos(m00_axi_awqos),
		.m00_axi_awuser(m00_axi_awuser),
		.m00_axi_awvalid(m00_axi_awvalid),
		.m00_axi_awready(m00_axi_awready),
		.m00_axi_wdata(m00_axi_wdata),
		.m00_axi_wstrb(m00_axi_wstrb),
		.m00_axi_wlast(m00_axi_wlast),
		.m00_axi_wuser(m00_axi_wuser),
		.m00_axi_wvalid(m00_axi_wvalid),
		.m00_axi_wready(m00_axi_wready),
		.m00_axi_bid(m00_axi_bid),
		.m00_axi_bresp(m00_axi_bresp),
		.m00_axi_buser(m00_axi_buser),
		.m00_axi_bvalid(m00_axi_bvalid),
		.m00_axi_bready(m00_axi_bready),
		.m00_axi_arid(m00_axi_arid),
		.m00_axi_araddr(m00_axi_araddr),
		.m00_axi_arlen(m00_axi_arlen),
		.m00_axi_arsize(m00_axi_arsize),
		.m00_axi_arburst(m00_axi_arburst),
		.m00_axi_arlock(m00_axi_arlock),
		.m00_axi_arcache(m00_axi_arcache),
		.m00_axi_arprot(m00_axi_arprot),
		.m00_axi_arqos(m00_axi_arqos),
		.m00_axi_aruser(m00_axi_aruser),
		.m00_axi_arvalid(m00_axi_arvalid),
		.m00_axi_arready(m00_axi_arready),
		.m00_axi_rid(m00_axi_rid),
		.m00_axi_rdata(m00_axi_rdata),
	    .m00_axi_rresp(m00_axi_rresp),
		.m00_axi_rlast(m00_axi_rlast),
		.m00_axi_ruser(m00_axi_ruser),
		.m00_axi_rvalid(m00_axi_rvalid),
		.m00_axi_rready(m00_axi_rready)
	);

endmodule
