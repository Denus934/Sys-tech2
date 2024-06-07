module fifo#(parameter FIFO_WIDTH = 3, VALUE_WIDTH = 8)(
    input  logic                   in_clk_i,
    input  logic                   out_clk_i,
    input  logic                   reset_n_i,
    input  logic                   in_valid_i,
    output logic                   in_ready_o,
    input  logic [VALUE_WIDTH-1:0] in_value_i,
    output logic [VALUE_WIDTH-1:0] out_value_o, 
    output logic                   out_valid_o,
    input  logic                   out_ready_i
    );

    localparam FIFO_COUNT = 1 << FIFO_WIDTH;
    
    logic [FIFO_COUNT-1:0] [VALUE_WIDTH-1:0] data_r ;
    logic [FIFO_WIDTH-1:0]  fifo_addr_in, inc_addr_in;
    logic [FIFO_WIDTH-1:0]  fifo_addr_out; 

    assign inc_addr_in   =  fifo_addr_in +  1;
    assign out_valid_o   =  fifo_addr_in != fifo_addr_out;
    assign in_ready_o    =   inc_addr_in != fifo_addr_out;

    always_ff @(posedge in_clk_i or negedge reset_n_i)
    if      (!reset_n_i)              data_r                <= '0;
    else if (in_valid_i & in_ready_o) data_r [fifo_addr_in] <= in_value_i;
    else                              data_r                <= data_r;

    assign out_value_o = data_r[fifo_addr_out];

    always_ff @(posedge in_clk_i or negedge reset_n_i)
    if      (!reset_n_i)              fifo_addr_in <= 'b0;
    else if (in_valid_i & in_ready_o) fifo_addr_in <= fifo_addr_in + 1;
    else                              fifo_addr_in <= fifo_addr_in;

    always_ff @(posedge out_clk_i or negedge reset_n_i)
    if      (!reset_n_i)                fifo_addr_out <= 'b0;
    else if (out_valid_o & out_ready_i) fifo_addr_out <= fifo_addr_out + 1;
    else                                fifo_addr_out <= fifo_addr_out;

endmodule
