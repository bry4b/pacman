jmodule graphics (
    input clk, 
    input rst, 

    input [9:0] hc, 
    input [9:0] vc,

    // input [9:0] switches, // testing outputs

    // testing module connections
    // input [9:0] pacman_xloc,
    // input [9:0] pacman_yloc,    
    // input [1:0] pacman_dir, 
    // input [1:0] pacman_anim,
    // input pacman_alive,
    input [24:0] pacman_inputs,

    // input [9:0] blinky_xloc, 
    // input [9:0] blinky_yloc,
    // input [1:0] blinky_dir, 
    // input [1:0] blinky_mode,
    input [24:0] blinky_inputs,

    // input [9:0] pinky_xloc, 
    // input [9:0] pinky_yloc,
    // input [1:0] pinky_dir, 
    // input [1:0] pinky_mode,
    input [24:0] pinky_inputs,

    // input [9:0] inky_xloc, 
    // input [9:0] inky_yloc,
    // input [1:0] inky_dir, 
    // input [1:0] inky_mode,
    input [24:0] inky_inputs,

    // input [9:0] clyde_xloc, 
    // input [9:0] clyde_yloc,
    // input [1:0] clyde_dir, 
    // input [1:0] clyde_mode,
    input [24:0] clyde_inputs,

    input ghost_animation,

    input [1:0] ghosts_eaten,

    input [7:0] maze_color,
    
    output reg [7:0] color,
    output reg [15:0] address
);

reg [8:0] xpos;
reg [8:0] ypos;

wire [9:0] pacman_xloc  = pacman_inputs [24:15];
wire [9:0] pacman_yloc  = pacman_inputs [14:5];     
wire [1:0] pacman_dir   = pacman_inputs [4:3]; 
wire [1:0] pacman_anim  = pacman_inputs [2:1];
wire pacman_alive       = pacman_inputs [0];

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

// wire [9:0] blinky_xloc  = blinky_inputs [24:15]; 
// wire [9:0] blinky_yloc  = blinky_inputs [14:5];
// wire [1:0] blinky_dir   = blinky_inputs [4:3];
// wire [1:0] blinky_mode  = blinky_inputs [2:1];
// wire blinky_flash       = blinky_inputs [0];
wire [9:0] blinky_address;
wire [2:0] blinky_pixel;
wire [7:0] blinky_color;

// wire [9:0] pinky_xloc  = pinky_inputs [24:15]; 
// wire [9:0] pinky_yloc  = pinky_inputs [14:5];
// wire [1:0] pinky_dir   = pinky_inputs [4:3];
// wire [1:0] pinky_mode  = pinky_inputs [2:1];
// wire pinky_flash       = pinky_inputs [0];
wire [9:0] pinky_address;
wire [2:0] pinky_pixel;
wire [7:0] pinky_color;

// wire [9:0] inky_xloc  = inky_inputs [24:15]; 
// wire [9:0] inky_yloc  = inky_inputs [14:5];
// wire [1:0] inky_dir   = inky_inputs [4:3];
// wire [1:0] inky_mode  = inky_inputs [2:1];
// wire inky_flash       = inky_inputs [0];
wire [9:0] inky_address;
wire [2:0] inky_pixel;
wire [7:0] inky_color;

// wire [9:0] clyde_xloc  = clyde_inputs [24:15]; 
// wire [9:0] clyde_yloc  = clyde_inputs [14:5];
// wire [1:0] clyde_dir   = clyde_inputs [4:3];
// wire [1:0] clyde_mode  = clyde_inputs [2:1];
// wire clyde_flash       = clyde_inputs [0];
wire [9:0] clyde_address;
wire [2:0] clyde_pixel;
wire [7:0] clyde_color;

// wire ghost_animation;

graphics_ghost_LUT GLUT (
    .blinky_in (blinky_address), 
    .pinky_in (pinky_address), 
    .inky_in (inky_address), 
    .clyde_in (clyde_address), 
    .ghosts_eaten (ghosts_eaten), 

    .blinky_out(blinky_pixel), 
    .pinky_out(pinky_pixel), 
    .inky_out (inky_pixel), 
    .clyde_out (clyde_pixel)
);

graphics_ghost BLINKY (
    .xpos (xpos),
    .ypos (ypos),
    .ghost_color (2'b00),
    .ghost_inputs (blinky_inputs), 
    .animation_cycle (ghost_animation),
    .pixel (blinky_pixel),

    .pixel_address (blinky_address), 
    .color (blinky_color),
);
    
graphics_ghost PINKY (
    .xpos (xpos),
    .ypos (ypos),
    .ghost_color (2'b01),
    .ghost_inputs (pinky_inputs), 
    .animation_cycle (ghost_animation),
    .pixel (pinky_pixel),

    .pixel_address (pinky_address), 
    .color (pinky_color),
);

graphics_ghost INKY (
    .xpos (xpos),
    .ypos (ypos),
    .ghost_color (2'b10),
    .ghost_inputs (inky_inputs), 
    .animation_cycle (ghost_animation),
    .pixel (inky_pixel),

    .pixel_address (inky_address), 
    .color (inky_color),
);

graphics_ghost CLYDE (
    .xpos (xpos),
    .ypos (ypos),
    .ghost_color (2'b11),
    .ghost_inputs (clyde_inputs), 
    .animation_cycle (ghost_animation),
    .pixel (clyde_pixel),

    .pixel_address (clyde_address), 
    .color (clyde_color),
);

// 
// PACMAN INSTANTIATION
wire [7:0] pacman_color;
graphics_pacman PACMAN  (xpos, ypos, pacman_xloc,   pacman_yloc,    pacman_dir,     pacman_alive,   pacman_anim,   pacman_color);

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
//  
// RAM ADDRESS CALCULATION
// only loads tiles 3-36 into ping-pong RAM due to space constraints 
localparam YOFFSET = 24;    // vertical RAM offset (3 tiles * 8)
localparam ADDRESS_MAX = 65535;
always_comb begin
    if (ypos > (YOFFSET-1) && ypos < (264+YOFFSET)) begin
        address = xpos*264 + (ypos-YOFFSET);
    end else begin
        address = ADDRESS_MAX;
    end
end

endmodule
