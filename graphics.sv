module graphics (
    input clk, 
    input rst, 
    input btn,

    input [9:0] xpos, 
    input [9:0] ypos,

    input [9:0] switches, // testing outputs
    input [9:0] pacman_xloc,
    input [9:0] pacman_yloc,    // testing module connections

    input [7:0] maze_color,
    output reg [7:0] color
);

// 
// COLOR DEFINITIONS
localparam RED  = 8'b11100000;
localparam PNK  = 8'b11101111;
localparam CYN  = 8'b00011111;
localparam ORG  = 8'b11110100;
localparam YLW  = 8'b11111100;
localparam WHT  = 8'b11111111;
localparam CRM  = 8'b11111110;
localparam BLU  = 8'b00000011;
localparam BLK  = 8'b00000000; 

// // 
// // VGA DRIVER TESTING
// assign color [7:5] = switches[9:7];
// assign color [4:2] = switches[6:4];
// assign color [1:0] = switches[3:2];

//
// GHOST INSTANTIATION
wire [9:0] blinky_xloc;
wire [9:0] blinky_yloc;
wire [1:0] blinky_dir;
wire [1:0] blinky_mode;
wire [9:0] blinky_address;
wire [2:0] blinky_pixel;
wire [7:0] blinky_color;

wire [9:0] pinky_xloc;
wire [9:0] pinky_yloc;
wire [1:0] pinky_dir;
wire [1:0] pinky_mode;
wire [9:0] pinky_address;
wire [2:0] pinky_pixel;
wire [7:0] pinky_color;

wire [9:0] inky_xloc;
wire [9:0] inky_yloc;
wire [1:0] inky_dir;
wire [1:0] inky_mode;
wire [9:0] inky_address;
wire [2:0] inky_pixel;
wire [7:0] inky_color;

wire [9:0] clyde_xloc;
wire [9:0] clyde_yloc;
wire [1:0] clyde_dir;
wire [1:0] clyde_mode;
wire [9:0] clyde_address;
wire [2:0] clyde_pixel;
wire [7:0] clyde_color;

wire ghost_animation;

graphics_ghost_LUT GLUT (blinky_address, pinky_address, inky_address, clyde_address, blinky_pixel, pinky_pixel, inky_pixel, clyde_pixel);
graphics_ghost BLINKY   (xpos, ypos, blinky_xloc,   blinky_yloc,    2'b00, blinky_dir,  blinky_mode,   ghost_animation, blinky_pixel,  blinky_address, blinky_color);
graphics_ghost PINKY    (xpos, ypos, pinky_xloc,    pinky_yloc,     2'b01, pinky_dir,   pinky_mode,    ghost_animation, pinky_pixel,   pinky_address,  pinky_color);
graphics_ghost INKY     (xpos, ypos, inky_xloc,     inky_yloc,      2'b10, inky_dir,    inky_mode,     ghost_animation, inky_pixel,    inky_address,   inky_color);
graphics_ghost CLYDE    (xpos, ypos, clyde_xloc,    clyde_yloc,     2'b11, clyde_dir,   clyde_mode,    ghost_animation, clyde_pixel,   clyde_address,  clyde_color);

// 
// PACMAN INSTANTIATION
// wire [9:0] pacman_xloc = 'd119 + (switches[9:7] << 2);
// wire [9:0] pacman_yloc = 'd228 + (switches[6:4] << 2);
wire [1:0] pacman_dir = switches[1:0];
wire pacman_alive = 2'b00;
wire [1:0] pacman_animation = switches[3:2];
wire [7:0] pacman_color;

graphics_pacman PACMAN  (xpos, ypos, pacman_xloc,   pacman_yloc,    pacman_dir,     pacman_alive,   pacman_animation,   pacman_color);

// 
// GHOST STATES (HARDCODED)
// assign blinky_xloc = switches[9:6] << 3;
// assign blinky_yloc = switches[5:3] << 3;
assign blinky_xloc = 'd119;
assign blinky_yloc = 'd132;
assign blinky_dir = switches[2:1];
assign blinky_mode [1] = switches[0];

assign pinky_xloc = 'd103;
assign pinky_yloc = 'd154;
assign pinky_dir = switches[2:1];
assign pinky_mode [1] = switches[0];

assign inky_xloc = 'd119;
assign inky_yloc = 'd154;
assign inky_dir = switches[2:1];
assign inky_mode [1] = switches[0];

assign clyde_xloc = 'd135;
assign clyde_yloc = 'd154;
assign clyde_dir = switches[2:1];
assign clyde_mode [1] = switches[0];

assign ghost_animation = ~btn;

//
// LOGIC FOR SPRITE HIERARCHY
// allows sprites to show through "below" other sprites 
always_comb begin
    // instantiate blinky, pinky, etc. with like 'ghost1color', 'ghost2color', etc. for outputs instead of just 'color' (so they're split on different wires)
    // in comb block determine which wire (ghost1color, ghost2color, etc) has priority, and set that to drive color
    //      red > pink > blue > orange

    if (blinky_color != BLK) begin
        color = blinky_color;
    end else if (pinky_color != BLK) begin
        color = pinky_color;
    end else if (inky_color != BLK) begin
        color = inky_color;
    end else if (clyde_color != BLK) begin
        color = clyde_color;
    end else if (pacman_color != BLK) begin
        color = pacman_color;
    end else if (maze_color != BLK) begin
        color = maze_color;
    end else begin
        color = BLK;
    end
end

endmodule
