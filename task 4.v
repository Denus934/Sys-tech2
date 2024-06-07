`timescale 1ns / 1ps

typedef struct packed {
    logic [7:0]  command;
    logic [23:0] address;
    logic [31:0] data;
} spi_t;

module bmstu_task_4(
    input  logic        arst_n,
    input  logic        spi_sck_i,
    input  logic        spi_cs_i,
    input  logic        spi_copi_i,
    output logic        wr_en_o,
    output logic [31:0] wr_data_o,
    output logic [23:0] wr_address_o
);

parameter [7:0] COMMAND_WRITE = 8'hAA;

logic [5:0]  data_cnt_r;
spi_t        spi_com_s;
spi_t        spi_com_saved_s;
logic        is_accept_com;


assign wr_en_o = (spi_com_saved_s.command == COMMAND_WRITE) && is_accept_com;
assign wr_data_o = spi_com_saved_s.data;
assign wr_address_o = spi_com_saved_s.address;

always_ff @ (posedge spi_sck_i or negedge arst_n)
if         (arst_n) spi_com_s             <= 'b0;
else if (!spi_cs_i) spi_com_s             <= spi_com_s;
else                spi_com_s[data_cnt_r] <= spi_copi_i;

always_ff @ (posedge spi_sck_i or negedge arst_n)
if         (arst_n)   spi_com_saved_s <= 'b0;
else if (!spi_cs_i)   spi_com_saved_s <= spi_com_saved_s;
else if (&data_cnt_r) spi_com_saved_s <= spi_com_s;
else                  spi_com_saved_s <= spi_com_saved_s;

always_ff @ (posedge spi_sck_i or negedge arst_n)
if         (arst_n)   is_accept_com <= 'b0;
else if (!spi_cs_i)   is_accept_com <= is_accept_com;
else if (&data_cnt_r) is_accept_com <= 'b1;
else                  is_accept_com <= is_accept_com;

always_ff @ (posedge spi_sck_i or negedge arst_n)
if         (arst_n) data_cnt_r <= 'b0;
else if (!spi_cs_i) data_cnt_r <= data_cnt_r;
else                data_cnt_r <= data_cnt_r + 1;

endmodule
