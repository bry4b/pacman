`timescale 1ns/1ns

module controller_tb (
    output reg clk,
    output reg start,
    output reg data_in,
    output reg latch_out,
    output reg pulse_out,
    output reg [7:0] buttons_pressed
);

controller_nes UUT (
    .clk (clk),
    .start (start),
    .data_in (data_in),
    .latch_out (latch_out),
    .pulse_out (pulse_out),
    .buttons_pressed (buttons_pressed)
);

initial begin
    clk = 1;
    start = 0;
    data_in = 0;
    #200 start = 1;
    #10 data_in = 1;
    #20 data_in = 0;
    
end

always begin
    #5 clk = ~clk;
end

endmodule