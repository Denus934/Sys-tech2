`timescale 1ns / 1ps

module shift_stream_tb;
    localparam DATA_BUS_WIDTH  = 4;
    localparam SHIFT_BYTES     = 2;
    localparam DELAY           = 6;
    localparam FULL_DATA_WIDTH = 8 * DATA_BUS_WIDTH;
    // Base signals 
    logic clk_i = 1'b0;
    logic areset_ni;
    logic                           tvalid_i ;
    logic                           tready_o ;
    logic [FULL_DATA_WIDTH - 1 : 0] tdata_i  ;   
    logic                           tvalid_o ;
    logic                           tready_i ;
    logic [FULL_DATA_WIDTH - 1 : 0] tdata_o  ;
    
    always #(DELAY) clk_i <= ~clk_i;
    
    shift_stream #(
        .DATA_BUS_WIDTH(DATA_BUS_WIDTH),
        .SHIFT_BYTES(SHIFT_BYTES)
    ) dut (
        .clk_i(clk_i),
        .areset_ni(areset_ni),
        .tvalid_i(tvalid_i),
        .tready_o(tready_o),
        .tdata_i(tdata_i),
        .tvalid_o(tvalid_o),
        .tready_i(tready_i),
        .tdata_o(tdata_o)
    );
    
    initial tdata_i = 0;
    always #(2*DELAY) tdata_i += 1;
    
    initial begin
        areset_ni = 1;
        tvalid_i <= 0;
        tready_i <= 0;
        #(2 * DELAY) areset_ni = 0;
        #(2 * DELAY) areset_ni = 1; 
        for (int i = 0; i < 100; i++) begin
           tvalid_i <= 1;
           tready_i <= 0;
           #(2 * DELAY); 
           tvalid_i <= 0;
           tready_i <= 1;
           #(2 * DELAY);
       end
       $finish;
    end 
 endmodule
