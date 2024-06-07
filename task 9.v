module shift_stream #(
    parameter  DATA_BUS_WIDTH  = 4, // n in specification
               SHIFT_BYTES     = 2,
    localparam FULL_DATA_WIDTH = 8 * DATA_BUS_WIDTH
) (
    // Base signals 
    input logic clk_i,
    input logic areset_ni,
    // AXI STREAM slave signals
    input  logic                           tvalid_i ,
    output logic                           tready_o ,
    input  logic [FULL_DATA_WIDTH - 1 : 0] tdata_i,   //,

    // AXI STREAM master signals
    output logic                           tvalid_o ,
    input  logic                           tready_i ,
    output logic [FULL_DATA_WIDTH - 1 : 0] tdata_o  //,

    
);
    logic [2*FULL_DATA_WIDTH - 1 : 0] data_r;
    logic [2*FULL_DATA_WIDTH - 1 : 0] shifted_data_w;
    logic [FULL_DATA_WIDTH - 1 : 0] out_data_w [2];
    
    assign shifted_data_w = {data_r[8* SHIFT_BYTES - 1 : 0], data_r[FULL_DATA_WIDTH - 1 : 8* SHIFT_BYTES]};
    assign out_data_w[0] = shifted_data_w[FULL_DATA_WIDTH - 1:0];
    assign out_data_w[1] = shifted_data_w[2*FULL_DATA_WIDTH - 1: FULL_DATA_WIDTH];
    logic addr_in_r;
    logic addr_out_r;

    logic  in_transact_w;
    assign in_transact_w = tvalid_i && tready_o;

    logic  out_transact_w;
    assign out_transact_w = tvalid_o && tready_i;

    always_ff @(posedge clk_i or negedge areset_ni)
    if (!areset_ni) addr_in_r <= '0;
    else            addr_in_r <= addr_in_r ^ in_transact_w;

    always_ff @(posedge clk_i or negedge areset_ni)
    if (!areset_ni) addr_out_r <= '0;
    else            addr_out_r <= addr_out_r ^ out_transact_w;

    assign tvalid_o = addr_in_r ^ addr_out_r;
    assign tready_o = addr_in_r == addr_out_r;

    always_ff @(posedge clk_i or negedge areset_ni)
    if      (!areset_ni)                 data_r                                         <= '0;
    else if (in_transact_w && addr_in_r) data_r[2*FULL_DATA_WIDTH - 1: FULL_DATA_WIDTH] <= tdata_i;
    else if (in_transact_w)              data_r[FULL_DATA_WIDTH - 1:0]                  <= tdata_i;
    else                                 data_r                                         <= data_r;

    always_ff @(posedge clk_i or negedge areset_ni)
    if      (!areset_ni)     tdata_o <= '0;
    else if (out_transact_w) tdata_o <= out_data_w[addr_out_r];
    else                     tdata_o <= tdata_o;
endmodule
