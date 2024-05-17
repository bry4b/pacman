module controller_top (
    input clk,      
    input data_in,
    input btn,
	output nes_clk,
    output gamecube_clk,
    output start,
    output latch_out,
    output pulse_out,
    inout data_out, 
    output [9:0] leds
);
wire [0:7] nes_buttons;
// assign leds = {buttons_pressed, 2'b00};
wire [0:15] bongo_buttons;
wire [7:0] bongo_mic;

// assign leds[9] = bongo_buttons[3];  // start
// assign leds[8] = bongo_buttons[4];  // Y
// assign leds[7] = bongo_buttons[5];  // X
// assign leds[6] = bongo_buttons[6];  // A
// assign leds[5] = bongo_buttons[7];  // B
// assign leds[4] = bongo_buttons[9];  // L
// assign leds[3] = bongo_buttons[10]; // R
// assign leds[2] = bongo_buttons[11]; // Z
// assign leds[1] = bongo_buttons[12]; // D-Up
// assign leds[0] = bongo_buttons[13]; // D-Down

assign leds[9] = bongo_buttons[4];
assign leds[8] = bongo_buttons[5];
assign leds[7:0] = bongo_mic [7:0];

// assign start = ~btn;
// wire start;
// nes clock: 6us period, 166667 Hz
// gamecube clock: 1us period, 1 MHz
clk_controller NESCLK (clk, nes_clk, gamecube_clk); 
clockDivider GAMECLK (clk, 'd60, 0, start);

controller_nes UUT1 (
    .clk (nes_clk),
    .start (start),
    .data_in (data_in),
    .latch_out (latch_out),
    .pulse_out (pulse_out),
    .buttons_out (nes_buttons)
);

controller_bongo UUT2 (
    .clk (gamecube_clk),
    .start (start), 
    .buttons_out (bongo_buttons), 
    .rbtn_out (bongo_mic),
    .data (data_out)
);

endmodule