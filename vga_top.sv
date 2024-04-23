module vga_top ( 
    input clk, 
    input rst,
    input btn,
    
    input [9:0] switches,
	output [9:0] leds,

    // vga outputs
    output hsync, 
    output vsync,
    output reg [3:0] red,
    output reg [3:0] green,
    output reg [3:0] blue
);

	assign leds = switches;
    
    //
    // GRAPHICS
    reg [9:0] xpos; 
    reg [9:0] ypos;
    reg [15:0] address;
    wire [7:0] color;
    wire [7:0] vga_data;

    // 
    // MAZE
    wire [7:0] maze_color = 8'b0;
    wire [5:0] xpellet;
    wire [5:0] ypellet;
    assign xpellet = switches[9:7] << 1;
    assign ypellet = switches[6:3];

    // 
    // VGA DRIVER
    wire vgaclk;
    wire [9:0] hc; 
    wire [9:0] vc;
    // wire [2:0] input_red = switches[9:7];
    // wire [2:0] input_green = switches[6:4];
    // wire [1:0] input_blue = switches[3:2];

    // wire [2:0] input_red = color [7:5];
    // wire [2:0] input_green = color [4:2];
    // wire [1:0] input_blue = color [1:0];

    wire [2:0] input_red = vga_data [7:5];
    wire [2:0] input_green = vga_data [4:2];
    wire [1:0] input_blue = vga_data [1:0];

    wire [9:0] pacman_xloc = 10'd120 + (switches[9:7] << 2);
    wire [9:0] pacman_yloc = 10'd228 + (switches[6:4] << 2);

    wire writeEnable;   // HIGH when writing to ram1

    clk_vga TICK(clk, vgaclk);
    vga TOCK(vgaclk, input_red, input_green, input_blue, rst, hc, vc, hsync, vsync, red, green, blue);

    // vga_ram PONG(vgaclk, address, hc, vc, color, writeEnable, vga_data);
    graphics_new BOO(vgaclk, rst, btn, hc, vc, switches, pacman_xloc, pacman_yloc, maze_color, vga_data);
    
    // maze MAZEPIN(xpos, ypos, pacman_xloc, pacman_yloc, clk, rst, maze_color);

endmodule

// vga_graphics -> vga_ram -> vga