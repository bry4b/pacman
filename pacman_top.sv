module pacman_top ( 
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
    wire [7:0] maze_color;
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

    wire [9:0] pacman_xloc = 'd119 + (switches[9:7] << 2);
    wire [9:0] pacman_yloc = 'd228 + (switches[6:4] << 2);


    clk_vga TICK(clk, vgaclk);
    vga TOCK(vgaclk, input_red, input_green, input_blue, rst, hc, vc, hsync, vsync, red, green, blue);

    vga_ram PONG(vgaclk, address, hc, vc, color, vga_data);
    graphics BOO(vgaclk, rst, btn, xpos, ypos, switches, pacman_xloc, pacman_yloc, maze_color, color);
    
    maze MAZEPIN(xpos, ypos, pacman_xloc, pacman_yloc, clk, rst, maze_color);

    // 
    // COORDINATE BLOCKING & ROTATION
    // localparam XMAX  = 160;  // horizontal pixels
    // localparam YMAX  = 320;  // vertical pixels
    localparam XMAX = 240;      // horizontal pixels (480/2)
    localparam YMAX = 320;      // vertical pixels (640/2)
    localparam YOFFSET = 24;    // vertical RAM offset (3 tiles * 8)
    localparam ADDRESS_MAX = 65535;
    always_comb begin
        if (hc < 640 && vc < 480) begin
            // xpos = XMAX - 1 - vc_in / 3;
            xpos = XMAX - 1 - (vc >> 1);
            ypos = hc / 2;
        end else if (vc < 480) begin
            // xpos = XMAX - 1 - vc_in / 3;
            xpos = XMAX - 1 - (vc >> 2);
            ypos = YMAX - 1;
        end else begin 
            xpos = 0;
            ypos = 0;
        end
    end

    //  
    // RAM ADDRESS CALCULATION
    // only loads tiles 3-36 into ping-pong RAM due to space constraints 
    always_comb begin
        if (ypos > (YOFFSET-1) && ypos < (264+YOFFSET)) begin
            address = xpos*264 + (ypos-YOFFSET);
        end else begin
            address = ADDRESS_MAX;
        end
    end

endmodule

// vga_graphics -> vga_ram -> vga