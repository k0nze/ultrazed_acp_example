`timescale 1 ns / 1 ps
`define RAM_WIDTH 128
module BRAM #(
    parameter RAM_DEPTH = 128                       // Specify RAM depth (number of lines)
) (
    input wire clk,
    input wire reset,

    input wire write_enable,
    input wire [clogb2(((`RAM_WIDTH/8)*RAM_DEPTH)-1)-1:0] write_address,
    input wire [`RAM_WIDTH-1:0] data_in,

    input wire read_enable,
    input wire [clogb2(((`RAM_WIDTH/8)*RAM_DEPTH)-1)-1:0] read_address,
    output wire [`RAM_WIDTH-1:0] data_out,
    output wire [15:0] data_out_16bit
);

    function integer clogb2 (input integer bit_depth); begin                                                           
        for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
            bit_depth = bit_depth >> 1;                                 
        end                                                           
    endfunction

    wire [3:0] write_byte_address = write_address[3:0];
    wire [clogb2(((`RAM_WIDTH/8)*RAM_DEPTH)-1)-4-1:0] write_line_address = (write_address >> 4);

    wire [3:0] read_byte_address = read_address[3:0];
    reg [3:0] read_byte_address_ff [2:0];
    wire [clogb2(((`RAM_WIDTH/8)*RAM_DEPTH)-1)-4-1:0] read_line_address = (read_address >> 4);

    xilinx_single_port_ram_read_first #(
        .RAM_WIDTH(`RAM_WIDTH),                       // Specify RAM data width
        .RAM_DEPTH(RAM_DEPTH),                     // Specify RAM depth (number of entries)
        .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
        .INIT_FILE("")                        // Specify name/location of RAM initialization file if using one (leave blank if not)
    ) xilinx_bram (
        .addra((write_enable == 1'b1) ? write_line_address : read_line_address ),     // Address bus, width determined from RAM_DEPTH
        .dina(data_in),       // RAM input data, width determined from RAM_WIDTH
        .clka(clk),       // Clock
        .wea(write_enable),         // Write enable
        .ena(write_enable | read_enable),         // RAM Enable, for additional power savings, disable port when not in use
        .rsta(reset),       // Output reset (does not affect memory contents)
        .regcea(read_enable),   // Output register enable
        .douta(data_out)      // RAM output data, width determined from RAM_WIDTH
    );

    always @(posedge clk) begin
        if(reset == 1'b1) begin
            read_byte_address_ff[0] <= 0;
            read_byte_address_ff[1] <= 0;
            read_byte_address_ff[2] <= 0;
        end
        else begin
            read_byte_address_ff[0] <= read_byte_address;
            read_byte_address_ff[1] <= read_byte_address_ff[0];
            read_byte_address_ff[2] <= read_byte_address_ff[1];
        end
    end

endmodule
