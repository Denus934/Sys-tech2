`timescale 1ns / 1ps

module bmstu_task_4_tb;
    logic        arst_n = 1'b1;
    logic        spi_sck_i   = 1'b0;
    logic        spi_cs_i    = 1'b0;
    logic        spi_copi_i;
    logic        wr_en_o;
    logic [31:0] wr_data_o;
    logic [23:0] wr_address_o;
    
    localparam CLK_HALF_PERIOD = 10;
    
    always #(CLK_HALF_PERIOD) spi_sck_i <= ~ spi_sck_i;
    
    logic [31 : 0] data;
    logic [23 : 0] address;
    logic [7  : 0] command;
   
    logic [63 : 0] full_command;
    
    
    assign full_command =   {command,  address, data};
    assign address =        {command, ~command, command};
    assign data = {~command, command, ~command, command};
    
    initial begin 
        spi_copi_i = 1'b0;
        #(4* CLK_HALF_PERIOD) arst_n = 1'b0;
        for (int j = 0; j < 256; j++) begin
            command = j; 
            for (int i = 0; i < 64; i++) begin 
                #(2 * CLK_HALF_PERIOD) spi_copi_i = full_command[i];
            end
        end
        spi_cs_i = 1'b1;
        for (int j = 0; j < 256; j++) begin
            command = j;  
            for (int i = 0; i < 64; i++) begin 
                #(2 * CLK_HALF_PERIOD) spi_copi_i = full_command[i];
            end
        end
        $finish;
    end
    
    bmstu_task_4 uut(
        .arst_n       ( arst_n       ),
        .spi_sck_i    ( spi_sck_i    ),
        .spi_cs_i     ( spi_cs_i     ),
        .spi_copi_i   ( spi_copi_i   ),
        .wr_en_o      ( wr_en_o      ),
        .wr_data_o    ( wr_data_o    ),
        .wr_address_o ( wr_address_o )
    );
    
endmodule
