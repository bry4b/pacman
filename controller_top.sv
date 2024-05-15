module controller_top (
    input clk,      
    input data_in,
    input btn,
	output ctrl_clk,
    output start,
    output latch_out,
    output pulse_out,
    output [9:0] leds
);

wire [7:0] buttons_pressed;
assign leds = {buttons_pressed, 2'b00};
// assign start = ~btn;
// wire ctrl_clk;
// wire start;

clk_controller NESCLK (clk, ctrl_clk); // 166667 Hz
clockDivider GAMECLK (clk, 'd60, 0, start);
controller_nes UUT (
    .clk (ctrl_clk),
    .start (start),
    .data_in (data_in),
    .latch_out (latch_out),
    .pulse_out (pulse_out),
    .buttons_pressed (buttons_pressed)
);

endmodule