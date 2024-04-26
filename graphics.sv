module graphics (
    input clk, 
    input rst, 

    input [9:0] hc, 
    input [9:0] vc,

    // input [9:0] switches, // testing outputs

    // testing module connections
    input [9:0] pacman_xloc,
    input [9:0] pacman_yloc,    
    input [1:0] pacman_dir, 
    input [1:0] pacman_animation,
    input pacman_alive,

    input [9:0] blinky_xloc, 
    input [9:0] blinky_yloc,
    input [1:0] blinky_dir, 
    input [1:0] blinky_mode,

    input [9:0] pinky_xloc, 
    input [9:0] pinky_yloc,
    input [1:0] pinky_dir, 
    input [1:0] pinky_mode,

    input ghost_animation,

    input [7:0] maze_color,
    
    output reg [7:0] color,
    output reg [15:0] address
);

reg [8:0] xpos;
reg [8:0] ypos;

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
// wire [9:0] blinky_xloc;
// wire [9:0] blinky_yloc;
// wire [1:0] blinky_dir;
// wire [1:0] blinky_mode;
wire [9:0] blinky_address;
wire [2:0] blinky_pixel;
wire [7:0] blinky_color;

// wire [9:0] pinky_xloc;
// wire [9:0] pinky_yloc;
// wire [1:0] pinky_dir;
// wire [1:0] pinky_mode;
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

// wire ghost_animation;

graphics_ghost_LUT GLUT (blinky_address, pinky_address, inky_address, clyde_address, blinky_pixel, pinky_pixel, inky_pixel, clyde_pixel);
graphics_ghost BLINKY   (xpos, ypos, blinky_xloc,   blinky_yloc,    2'b00, blinky_dir,  blinky_mode,   ghost_animation, blinky_pixel,  blinky_address, blinky_color);
graphics_ghost PINKY    (xpos, ypos, pinky_xloc,    pinky_yloc,     2'b01, pinky_dir,   pinky_mode,    ghost_animation, pinky_pixel,   pinky_address,  pinky_color);
graphics_ghost INKY     (xpos, ypos, inky_xloc,     inky_yloc,      2'b10, inky_dir,    inky_mode,     ghost_animation, inky_pixel,    inky_address,   inky_color);
graphics_ghost CLYDE    (xpos, ypos, clyde_xloc,    clyde_yloc,     2'b11, clyde_dir,   clyde_mode,    ghost_animation, clyde_pixel,   clyde_address,  clyde_color);

// 
// PACMAN INSTANTIATION
wire [7:0] pacman_color;
graphics_pacman PACMAN  (xpos, ypos, pacman_xloc,   pacman_yloc,    pacman_dir,     pacman_alive,   pacman_animation,   pacman_color);

// 
// GHOST STATES (HARDCODED)
// assign blinky_xloc = switches[9:6] << 3;
// assign blinky_yloc = switches[5:3] << 3;
// assign blinky_xloc = 'd119;
// assign blinky_yloc = 'd132;
// assign blinky_dir = switches[2:1];
// assign blinky_mode [1] = switches[0];

// assign pinky_xloc   = 'd103;
// assign pinky_yloc   = 'd154;
// assign pinky_dir    = 2'b00;
// assign pinky_mode   = 2'b00;

assign inky_xloc    = 'd119;
assign inky_yloc    = 'd155;
assign inky_dir     = 2'b00;
assign inky_mode    = 2'b00;

assign clyde_xloc   = 'd135;
assign clyde_yloc   = 'd155;
assign clyde_dir    = 2'b00;
assign clyde_mode   = 2'b00;

// assign ghost_animation = btn;

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
