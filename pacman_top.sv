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

// 
// VGA DRIVER
wire vgaclk;
wire [9:0] hc; 
wire [9:0] vc;

wire [2:0] input_red = vga_data [7:5];
wire [2:0] input_green = vga_data [4:2];
wire [1:0] input_blue = vga_data [1:0];

//
// GAME
wire gameclk;
    
// 
// CHARACTERS
wire [9:0] pacman_xloc;
wire [9:0] pacman_yloc;
wire [1:0] pacman_dir; 
wire [1:0] pacman_anim;
wire pacman_alive;

wire [24:0] pacman_outputs = {pacman_xloc, pacman_yloc, pacman_dir, pacman_anim, pacman_alive};
wire [13:0] pacman_tiles = {pacman_xtile, pacman_ytile};

wire [24:0] blinky_outputs;
wire [24:0] pinky_outputs;
wire [24:0] inky_outputs;
wire [24:0] clyde_outputs;

// wire [9:0] blinky_xloc; 
// wire [9:0] blinky_yloc;
// wire [1:0] blinky_dir; 
// wire [1:0] blinky_mode;

// wire [9:0] pinky_xloc; 
// wire [9:0] pinky_yloc;
// wire [1:0] pinky_dir; 
// wire [1:0] pinky_mode;

// wire [9:0] inky_xloc; 
// wire [9:0] inky_yloc;
// wire [1:0] inky_dir; 
// wire [1:0] inky_mode;

// wire [9:0] clyde_xloc; 
// wire [9:0] clyde_yloc;
// wire [1:0] clyde_dir; 
// wire [1:0] clyde_mode;

wire ghost_animation;
wire pause;
reg [1:0] ghosts_eaten;
reg [1:0] ghosts_eaten_d;
wire blinky_eaten; 
wire pinky_eaten;
wire inky_eaten;
wire clyde_eaten;

// wire [6:0] blinky_xtile_next;
// wire [6:0] blinky_ytile_next;
// wire [6:0] pinky_xtile_next;
// wire [6:0] pinky_ytile_next;
// wire [6:0] inky_xtile_next;
// wire [6:0] inky_ytile_next;
// wire [6:0] clyde_xtile_next;
// wire [6:0] clyde_ytile_next;

wire [13:0] blinky_tiles;
wire [13:0] pinky_tiles;
wire [13:0] inky_tiles;
wire [13:0] clyde_tiles;

wire [6:0] pacman_xtile;
wire [6:0] pacman_ytile;
wire pacman_pellet;
wire power_pellet;
wire [1:0] pacman_tile_info [0:3]; 

wire [1:0] blinky_tile_info [0:3]; 
wire [1:0] pinky_tile_info [0:3]; 
wire [1:0] inky_tile_info [0:3];
wire [1:0] clyde_tile_info [0:3];

wire writeEnable;   // HIGH when writing to ram1

// TESTING GAME STATE WITH SWTICHES
// assign pacman_xloc = 10'd119 + (switches[9:7] << 3);
// assign pacman_yloc = 10'd227 + (switches[6:4] << 3);

// assign pacman_xloc = (pacman_xtile << 2'd3) + 2'd3;
// assign pacman_yloc = ((pacman_ytile + 2'd3) << 2'd3) + 2'd3;
// assign pacman_xtile = 'd15 + (switches[9:6]);
// assign pacman_ytile = 'd25 + (switches[5:4]);
// assign pacman_dir = switches [1:0]; 

// assign pacman_anim = switches[3:2]; 
// assign pacman_alive = 2'b00;
// assign pacman_anim = 2'b01;
assign pacman_alive = 1'b0;
    
// 
// GHOST STATES (HARDCODED)
// assign blinky_xloc = switches[9:6] << 3;
// assign blinky_yloc = switches[5:3] << 3;
// assign blinky_xloc = 'd119;
// assign blinky_yloc = 'd227;
// assign blinky_dir = 2'b00;
// assign blinky_mode = 2'b00;

// assign pinky_xloc   = 'd103;
// assign pinky_yloc   = 'd154;
// assign pinky_dir    = 2'b00;
// assign pinky_mode   = 2'b00;

// assign inky_xloc    = 'd119;
// assign inky_yloc    = 'd155;
// assign inky_dir     = 2'b00;
// assign inky_mode    = 2'b00;

// assign clyde_xloc   = 'd135;
// assign clyde_yloc   = 'd155;
// assign clyde_dir    = 2'b00;
// assign clyde_mode   = 2'b00;

assign ghost_animation = ~btn;
// assign pause = switches[0];
// assign ghosts_eaten = switches [1:0]; 

clk_vga TICK(clk, vgaclk);
vga DISPLAY(vgaclk, input_red, input_green, input_blue, ~rst, hc, vc, hsync, vsync, red, green, blue);

vga_ram PONG(vgaclk, address, hc, vc, color, writeEnable, vga_data);

graphics BOO(
    .clk (vgaclk), 
    .rst (~rst), 
    .hc (hc), 
    .vc (vc), 
    .pacman_inputs (pacman_outputs),
    .blinky_inputs (blinky_outputs), 
    .pinky_inputs (pinky_outputs),
    .inky_inputs (inky_outputs),
    .clyde_inputs (clyde_outputs),
    .ghost_animation (ghost_animation), 
    .ghosts_eaten (ghosts_eaten),
    .maze_color (maze_color), 

    .color (color), 
    .address (address)
);

clockDivider TOCK(clk, 'd60, 1'b0, gameclk);

maze MAZEPIN(
    .clk (gameclk),
    .rst (~rst),
    .xpos (xpos), 
    .ypos (ypos),
    .pacman_inputs (pacman_tiles),
    .blinky_inputs (blinky_tiles),
    .pinky_inputs (pinky_tiles), 
    .inky_inputs (inky_tiles),
    .clyde_inputs (clyde_tiles),
    .pellet_anim (btn),

    .pellet_out (pacman_pellet), 
    .power_pellet (power_pellet), 
    .pacman_outputs (pacman_tile_info),
    .blinky_outputs (blinky_tile_info),
    .pinky_outputs (pinky_tile_info), 
    .inky_outputs (inky_tile_info), 
    .clyde_outputs (clyde_tile_info),
    .color (maze_color) 
);

game_ghost BLINKY (
    .clk (gameclk),
    .rst (~rst),
    .start (~btn),
    .pause (pause),
    .personality (2'b00),
    .pacman_inputs (pacman_outputs [24:3]),
    .power_pellet (power_pellet),
    .tile_info (blinky_tile_info),
    .blinky_pos (20'b0),

    .eaten (blinky_eaten),
    .tile_checks (blinky_tiles),
    .ghost_outputs (blinky_outputs)
);

game_ghost PINKY ( 
    .clk (gameclk),
    .rst (~rst),
    .start (~btn),
    .pause (pause),
    .personality (2'b01),
    .pacman_inputs (pacman_outputs [24:3]),
    .power_pellet (power_pellet),
    .tile_info (pinky_tile_info), 
    .blinky_pos (20'b0),

    .eaten (pinky_eaten),
    .tile_checks (pinky_tiles),
    .ghost_outputs (pinky_outputs)
);
    
game_ghost INKY ( 
    .clk (gameclk),
    .rst (~rst),
    .start (~btn),
    .pause (pause),
    .personality (2'b10),
    .pacman_inputs (pacman_outputs [24:3]),
    .power_pellet (power_pellet),
    .tile_info (inky_tile_info), 
    .blinky_pos (blinky_outputs [23:4]), 

    .eaten (inky_eaten),
    .tile_checks (inky_tiles),
    .ghost_outputs (inky_outputs)
);

game_ghost CLYDE (
    .clk (gameclk),
    .rst (~rst),
    .start (~btn),
    .pause (pause),
    .personality (2'b11),
    .pacman_inputs (pacman_outputs [24:3]),
    .power_pellet (power_pellet),
    .tile_info (clyde_tile_info), 
    .blinky_pos (20'b0),

    .eaten (clyde_eaten),
    .tile_checks (clyde_tiles),
    .ghost_outputs (clyde_outputs)
);
    
pacman PACMAN ( 
    .clk60 (gameclk), 
    .reset (~rst), 
    .start (~btn),
    .pause (pause),
    .left (switches[9]),
    .right (switches[8]),
    .uturn (switches[7]),
    .tile_info (pacman_tile_info), 

    .xloc (pacman_xloc), 
    .yloc (pacman_yloc), 
    .dir (pacman_dir), 
    .anim_cycle (pacman_anim),
    .curr_xtile (pacman_xtile), 
    .curr_ytile (pacman_ytile)
);

localparam SCOR = 2'b10;

always_comb begin
    ghosts_eaten = blinky_eaten + pinky_eaten + inky_eaten + clyde_eaten - 1'b1;
    pause = blinky_outputs[2:1] == SCOR || pinky_outputs [2:1] == SCOR || inky_outputs [2:1] == SCOR || clyde_outputs [2:1] == SCOR;
end
// 
// COORDINATE BLOCKING & ROTATION
// localparam XMAX  = 160;  // horizontal pixels
// localparam YMAX  = 320;  // vertical pixels
localparam XMAX = 240;      // horizontal pixels (480/2)
localparam YMAX = 320;      // vertical pixels (640/2)

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

endmodule

// vga_graphics -> vga_ram -> vga