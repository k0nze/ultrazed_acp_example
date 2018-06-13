`timescale 1 ns / 1 ps

/* -------------------------------------------------------------------------
 * BRAM_OUTPUT_FIFO 'BRAM output FIFO'
 * Description: this module is the output FIFO
 *
 * Authors: Konstantin Luebeck (University of Tuebingen)
 * ------------------------------------------------------------------------- */

module BRAM_OUTPUT_FIFO #(
    parameter DATA_WIDTH = 32,
    parameter LENGTH = 16
) (
    input wire clk,
    input wire reset,

    input wire write_enable,
    input wire [DATA_WIDTH-1:0] data_in,

    input wire read_enable,
    output wire full,
    output wire [DATA_WIDTH-1:0] data_out
);

    function integer clogb2 (input integer bit_depth); begin                                                           
        for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
            bit_depth = bit_depth >> 1;                                 
        end                                                           
    endfunction

    integer i;

    reg [DATA_WIDTH-1:0] data_reg [LENGTH-1:0];
    reg [clogb2(LENGTH-1)-1:0] read_pointer;
    reg [clogb2(LENGTH-1)-1:0] write_pointer;

    always @(posedge clk) begin
        if(reset == 1'b1) begin
            for(i = 0; i < LENGTH; i=i+1) begin
                data_reg[i] <= 0; 
            end

            read_pointer <= 0;
            write_pointer <= 0;
        end
        else begin
            if(read_enable == 1'b1) begin
                read_pointer <= (read_pointer + 1) % LENGTH;
            end
            if(write_enable == 1'b1 && write_pointer != ((read_pointer - 1) % LENGTH)) begin
                data_reg[write_pointer] <= data_in;
                write_pointer <= (write_pointer + 1) % LENGTH;
            end
        end
    end

    assign data_out = data_reg[read_pointer]; 
    assign full = (write_pointer == ((read_pointer - 1) % LENGTH));

endmodule
