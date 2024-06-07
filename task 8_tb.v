`timescale 1ns / 1ps

module fifo_tb();
    localparam FIFO_WIDTH = 5;
    localparam VALUE_WIDTH = 8;
    localparam DELAY = 6;
    
    reg in_clk_i;
    reg out_clk_i;
    reg reset_n_i = 1'b1;
    reg in_valid_i;
    wire in_ready_o;
    reg [VALUE_WIDTH-1:0] in_value_i;
    wire [VALUE_WIDTH-1:0] out_value_o; 
    wire out_valid_o;
    reg out_ready_i;
        
    fifo #(.FIFO_WIDTH(FIFO_WIDTH), .VALUE_WIDTH(VALUE_WIDTH)) uut (
        .in_clk_i(in_clk_i),
        .out_clk_i(out_clk_i),
        .reset_n_i(reset_n_i),
        .in_valid_i(in_valid_i),
        .in_ready_o(in_ready_o),
        .in_value_i(in_value_i),
        .out_value_o(out_value_o),
        .out_valid_o(out_valid_o),
        .out_ready_i(out_ready_i)
    );
    initial in_clk_i = 1'b0;
    always #(DELAY) in_clk_i <= ~in_clk_i;
    initial out_clk_i = 1'b0;
    always #(DELAY) out_clk_i <= ~out_clk_i;
    initial in_value_i = 0;
    always #(2*DELAY) in_value_i <= in_value_i + 1;
    
    initial begin
        #(2 * DELAY) reset_n_i = 0;
        #(2 * DELAY) reset_n_i = 1; 
        in_valid_i <= 1;
        out_ready_i <= 0;
        #(2 * DELAY); 
        in_valid_i <= 0;
        out_ready_i <= 1;
        #(2 * DELAY); 
        in_valid_i <= 0;
        out_ready_i <= 1;
        #(8 * DELAY);
        in_valid_i <= 1;
        out_ready_i <= 1;
        #(8 * DELAY);
        for (integer i = 0; i < 100; i = i + 1) begin
           in_valid_i <= 0;
           out_ready_i <= 0;
           #(2 * DELAY); 
           in_valid_i <= 1;
           out_ready_i <= 0;
           #(2 * DELAY); 
           in_valid_i <= 0;
           out_ready_i <= 1;
           #(2 * DELAY);
           in_valid_i <= 1;
           out_ready_i <= 1;
           #(2 * DELAY);  
       end
       $finish;
    end 
endmodule
