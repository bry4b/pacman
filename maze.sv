module maze (
    input clk,
    input rst,

    input [9:0] xpos, 
    input [9:0] ypos, 

    input [9:0] pacman_xloc,
    input [9:0] pacman_yloc,    // testing module connections

    input pellet_animation,

    output reg [1:0] pacman_tile_info,     // communicates with game contoller
    output reg power_pellet,

    output reg [7:0] color      // communicates with graphics
);

// COLORS
localparam WHT  = 8'b11111111;
localparam CRM  = 8'b11111110;
localparam BLU  = 8'b00000011;
localparam BLK  = 8'b00000000; 

// ROTATIONS
localparam NM = 2'b00;      // NorMal
localparam CC = 2'b01;      // Counter-Clockwise
localparam CW = 2'b10;      // ClockWise
localparam FL = 2'b11;      // FLipped (180)

// MAZE WALL TYPES
localparam BLNK = 3'b000;   // BLaNK
localparam OCOR = 3'b001;   // Outer CORner (outer top-left corner, inner top-left corner)
localparam OSC0 = 3'b010;   // Outer Straight, inner Corner 0 (outer top straight, inner bottom-left corner)
localparam OSC1 = 3'b011;   // Outer Straight, inner Corner 1 (outer left straight, inner top-right corner)
localparam OSTR = 3'b100;   // Outer STRaight (outer top straight, inner top straight)
localparam ICR0 = 3'b101;   // Inner CoRner 0 (inner top-left corner, inner edge)
localparam ICR1 = 3'b110;   // Inner CoRner 1 (inner top-left corner, outer edge)
localparam ISTR = 3'b111;   // Inner STRaight (inner top straight)

// HOUSE WALL TYPES
localparam CORN = 3'b001;   // CORNer
localparam STRT = 3'b010;   // STRaighT
localparam DORL = 3'b011;   // DOoR Left
localparam DORR = 3'b100;   // DOoR Right
localparam DOOR = 3'b101;   // DOOR

reg [63:0] maze_walls [0:7] = '{
    64'h0000000000000000,   // blank
    64'h0f30404788909090,   // outer top-left corner, inner top-left corner
    64'hff0000e010080808,   // outer top straight, inner bottom-left corner
    64'h9090908887808080,   // outer left straight, inner top-right corner
    64'hff0000ff00000000,   // outer top straight, inner top straight
    64'h0000000003040808,   // inner top-left corner, inner edge
    64'h0000000708101010,   // inner top-left corner, outer edge
    64'h00000000ff000000    // inner bottom straight
};

reg [63:0] house_walls [0:5] = '{
    64'h0000000000000000,   // blank
    64'h000000000f080809,   // corner
    64'h00000000ff0000ff,   // straight
    64'h00000000ff0101ff,   // left of house door
    64'h00000000ff8080ff,   // right of house door
    64'h0000000000ffff00    // house door
};

// 
// MAZE DEFINITION
// 20W x 33H = 660 total tiles
reg [4:0] maze [0:989] = '{
//  0           1           2           3           4           5           6           7           8           9           10          11          12          13          14          15          16          17          18          19          20          21          22          23          24          25          26          27          28          29
    {OCOR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSC0,NM},  {OSC1,CW},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OCOR,CW},      // 0
    {OSTR,CC},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {OSTR,CW},      // 1
    {OSTR,CC},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {OSTR,CW},      // 2
    {OSTR,CC},  {BLNK,NM},  {ISTR,CC},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CW},  {BLNK,NM},  {ISTR,CC},  {ICR1,NM},  {ISTR,FL},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {ICR0,CC},  {ICR0,FL},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ISTR,FL},  {ICR1,CW},  {ISTR,CW},  {BLNK,NM},  {ISTR,CC},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CW},  {BLNK,NM},  {OSTR,CW},      // 3
    {OSTR,CC},  {BLNK,NM},  {ISTR,CC},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CW},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {ISTR,CC},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CW},  {BLNK,NM},  {OSTR,CW},      // 4
    {OSTR,CC},  {BLNK,NM},  {ISTR,CC},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CW},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {ISTR,CC},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CW},  {BLNK,NM},  {OSTR,CW},      // 5
    {OSTR,CC},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {ICR0,CC},  {ICR0,FL},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {ICR0,CC},  {ICR0,FL},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {OSTR,CW},      // 6
    {OSTR,CC},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {OSTR,CW},      // 7
    {OSTR,CC},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {ICR0,NM},  {ICR0,CW},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {ICR0,NM},  {ICR0,CW},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {OSTR,CW},      // 8
    {OSTR,CC},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ISTR,FL},  {ICR1,CW},  {ICR1,NM},  {ISTR,FL},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {OSTR,CW},      // 9
    {OSTR,CC},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {OSTR,CW},      // 10
    {OCOR,CC},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {ICR0,CW},  {BLNK,NM},  {ISTR,CC},  {ICR1,CC},  {ISTR,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ISTR,NM},  {ICR1,FL},  {ISTR,CW},  {BLNK,NM},  {ICR0,NM},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OCOR,FL},      // 11
    {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {OSTR,CC},  {BLNK,NM},  {ISTR,CC},  {ICR1,NM},  {ISTR,FL},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {ICR0,CC},  {ICR0,FL},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ISTR,FL},  {ICR1,CW},  {ISTR,CW},  {BLNK,NM},  {OSTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},      // 12
    {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {OSTR,CC},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {OSTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},      // 13
    {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {OSTR,CC},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {CORN,NM},  {STRT,NM},  {DORL,NM},  {DOOR,NM},  {DOOR,NM},  {DORR,NM},  {STRT,NM},  {CORN,CW},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {OSTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},      // 14
    {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {ICR0,FL},  {BLNK,NM},  {ICR0,CC},  {ICR0,FL},  {BLNK,NM},  {STRT,CC},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {STRT,CW},  {BLNK,NM},  {ICR0,CC},  {ICR0,FL},  {BLNK,NM},  {ICR0,CC},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},      // 15
    {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {STRT,CC},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {STRT,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},      // 16
    {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {ICR0,CW},  {BLNK,NM},  {ICR0,NM},  {ICR0,CW},  {BLNK,NM},  {STRT,CC},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {STRT,CW},  {BLNK,NM},  {ICR0,NM},  {ICR0,CW},  {BLNK,NM},  {ICR0,NM},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},      // 17
    {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {OSTR,CC},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {CORN,CC},  {STRT,FL},  {STRT,FL},  {STRT,FL},  {STRT,FL},  {STRT,FL},  {STRT,FL},  {CORN,FL},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {OSTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},      // 18
    {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {OSTR,CC},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {OSTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},      // 19
    {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {OSTR,CC},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {OSTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},      // 20
    {OCOR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {ICR0,FL},  {BLNK,NM},  {ICR0,CC},  {ICR0,FL},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ISTR,FL},  {ICR1,CW},  {ICR1,NM},  {ISTR,FL},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {ICR0,CC},  {ICR0,FL},  {BLNK,NM},  {ICR0,CC},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OSTR,NM},  {OCOR,CW},      // 21
    {OSTR,CC},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {OSTR,CW},      // 22
    {OSTR,CC},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {OSTR,CW},      // 23
    {OSTR,CC},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ISTR,FL},  {ICR1,CW},  {ISTR,CW},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ICR0,FL},  {BLNK,CC},  {ICR0,CC},  {ICR0,FL},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {ISTR,CC},  {ICR1,NM},  {ISTR,FL},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {OSTR,CW},      // 24
    {OSTR,CC},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {OSTR,CW},      // 25
    {OSC1,NM},  {ISTR,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {ICR0,NM},  {ICR0,CW},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {ICR0,NM},  {ICR0,CW},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ISTR,NM},  {OSC0,CW},      // 26
    {OSC0,CC},  {ISTR,FL},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {ICR0,CC},  {ICR0,FL},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ISTR,FL},  {ICR1,CW},  {ICR1,NM},  {ISTR,FL},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {ICR0,CC},  {ICR0,FL},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ISTR,FL},  {OSC1,FL},      // 27
    {OSTR,CC},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {OSTR,CW},      // 28
    {OSTR,CC},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ICR1,FL},  {ICR1,CC},  {ISTR,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {ISTR,CC},  {ISTR,CW},  {BLNK,NM},  {ICR0,NM},  {ISTR,NM},  {ISTR,NM},  {ICR1,FL},  {ICR1,CC},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ISTR,NM},  {ICR0,CW},  {BLNK,NM},  {OSTR,CW},      // 29
    {OSTR,CC},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ICR0,FL},  {BLNK,CC},  {ICR0,CC},  {ICR0,FL},  {BLNK,NM},  {ICR0,CC},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ISTR,FL},  {ICR0,FL},  {BLNK,NM},  {OSTR,CW},      // 30
    {OSTR,CC},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {BLNK,NM},  {OSTR,CW},      // 31
    {OCOR,CC},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OSTR,FL},  {OCOR,FL}       // 32
};

localparam XTILES = 30; // horizontal width in tiles 
localparam YTILES = 33; // vertical height in tiles
localparam YOFFSET = 3; // tiles of vertical offset (from top border)
wire [6:0] xtile = xpos >> 3;
wire [6:0] ytile = ypos >> 3;

reg [4:0] wall;
reg [1:0] wall_rot; 
reg [0:63] wall_sprite;

reg pixel;
wire [2:0] xpixel = xpos % 8;
wire [2:0] ypixel = ypos % 8;
reg [7:0] wall_color;

always_comb begin
    if (ytile > (YOFFSET-1) && ytile < (40-YOFFSET)) begin
        wall = maze [(ytile-YOFFSET) * XTILES + xtile];
    end else begin
        wall = {BLNK,NM};
    end

    if (xtile >= 11 && xtile <= 18 && ytile >= (14+YOFFSET) && ytile <= (18+YOFFSET)) begin
        wall_sprite = house_walls [wall [4:2]];
    end else begin
        wall_sprite = maze_walls [wall [4:2]];
    end

    wall_rot = wall [1:0];

    case (wall_rot)
        NM: begin
            pixel = wall_sprite [ypixel*8 + xpixel];
        end

        CC: begin
            pixel = wall_sprite [6'd7 + xpixel*8 - ypixel];
        end

        CW: begin
            pixel = wall_sprite [6'd56 - xpixel*8 + ypixel];
        end

        FL: begin
            pixel = wall_sprite [6'd63 - ypixel*8 - xpixel];
        end
    endcase

    if (pixel && ytile == (15+YOFFSET-1) && xtile > 13 && xtile < 16) begin
        wall_color = WHT;
    end else if (pixel) begin
        wall_color = BLU;
    end else begin
        wall_color = BLK;
    end
end

wire [6:0] pacman_xtile = pacman_xloc >> 3;
wire [6:0] pacman_ytile = (pacman_yloc >> 3) - YOFFSET;
localparam WALL = 2'b00;    // wall (not walkable)
localparam WKNP = 2'b01;    // walkable, no pellet
localparam WKRP = 2'b10;    // walkable, pellet
localparam WKGH = 2'b11;    // walkable (ghost house)

// TODO: load this into ROM, and have it read every time pellets need to be reset
// ROM has 1 cycle delay w/ read address
reg [1:0] pellets [0:989] = '{
//  0       1       2       3       4       5       6       7       8       9       10      11      12      13      14      15      16      17      18      19      20      21      22      23      24      25      26      27      28      29      
    WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   // 0
    WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   // 1
    WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   // 2
    WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   // 3
    WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   // 4
    WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   // 5
    WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   // 6
    WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   // 7
    WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   // 8
    WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   // 9
    WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   // 10
    WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   // 11
    WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   // 12
    WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKNP,   WKNP,   WKNP,   WKNP,   WKNP,   WKNP,   WKNP,   WKNP,   WKNP,   WKNP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   // 13
    WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKNP,   WALL,   WALL,   WALL,   WKGH,   WKGH,   WALL,   WALL,   WALL,   WKNP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   // 14
    WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKNP,   WALL,   WKGH,   WKGH,   WKGH,   WKGH,   WKGH,   WKGH,   WALL,   WKNP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   // 15
    WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WKNP,   WKNP,   WKNP,   WALL,   WKGH,   WKGH,   WKGH,   WKGH,   WKGH,   WKGH,   WALL,   WKNP,   WKNP,   WKNP,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   // 16
    WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKNP,   WALL,   WKGH,   WKGH,   WKGH,   WKGH,   WKGH,   WKGH,   WALL,   WKNP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   // 17
    WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKNP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKNP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   // 18
    WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKNP,   WKNP,   WKNP,   WKNP,   WKNP,   WKNP,   WKNP,   WKNP,   WKNP,   WKNP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   // 19
    WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   // 20
    WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   // 21
    WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   // 22
    WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   // 23
    WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   // 24
    WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   // 25
    WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   // 26
    WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   // 27
    WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   // 28
    WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   // 29
    WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   // 30
    WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   // 31
    WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL    // 32    
};

always @(posedge clk) begin
    pacman_tile_info <= pellets [pacman_ytile * 30 + pacman_xtile];
    if (!rst) begin     // reset pellet map
        pellets <= '{
    //  0       1       2       3       4       5       6       7       8       9       10      11      12      13      14      15      16      17      18      19      20      21      22      23      24      25      26      27      28      29      
        WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   // 0
        WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   // 1
        WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   // 2
        WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   // 3
        WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   // 4
        WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   // 5
        WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   // 6
        WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   // 7
        WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   // 8
        WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   // 9
        WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   // 10
        WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   // 11
        WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   // 12
        WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKNP,   WKNP,   WKNP,   WKNP,   WKNP,   WKNP,   WKNP,   WKNP,   WKNP,   WKNP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   // 13
        WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKNP,   WALL,   WALL,   WALL,   WKGH,   WKGH,   WALL,   WALL,   WALL,   WKNP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   // 14
        WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKNP,   WALL,   WKGH,   WKGH,   WKGH,   WKGH,   WKGH,   WKGH,   WALL,   WKNP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   // 15
        WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WKNP,   WKNP,   WKNP,   WALL,   WKGH,   WKGH,   WKGH,   WKGH,   WKGH,   WKGH,   WALL,   WKNP,   WKNP,   WKNP,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   // 16
        WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKNP,   WALL,   WKGH,   WKGH,   WKGH,   WKGH,   WKGH,   WKGH,   WALL,   WKNP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   // 17
        WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKNP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKNP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   // 18
        WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKNP,   WKNP,   WKNP,   WKNP,   WKNP,   WKNP,   WKNP,   WKNP,   WKNP,   WKNP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   // 19
        WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   // 20
        WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   // 21
        WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   // 22
        WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   // 23
        WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   // 24
        WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   // 25
        WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   // 26
        WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   // 27
        WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   // 28
        WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   // 29
        WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   WALL,   WKRP,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WKRP,   WALL,   // 30
        WALL,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WKRP,   WALL,   // 31
        WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL,   WALL    // 32    
    };

    end else begin
        if (pellets [pacman_ytile * 30 + pacman_xtile] == WKRP) begin
            pellets [pacman_ytile * 30 + pacman_xtile] <= WKNP;
        end
    end
end

localparam POWER_X = 1;     // 1st tile from left
localparam POWER1_Y = 4;    // 4th tile from top
localparam POWER2_Y = 7;    // 7th tile from bottom

wire [0:63] pellet_small = 64'h0000001818000000;
wire [0:63] pellet_large = 64'h3c7effffffff7e3c;

reg [0:63] pellet_sprite; 
reg [7:0] pellet_color;
always_comb begin
    // locations of power pellets
    if (((ytile == POWER1_Y + YOFFSET) && (xtile == POWER_X)) || ((ytile == POWER1_Y + YOFFSET) && (xtile == XTILES - POWER_X-1)) || ((ytile == YTILES + YOFFSET - POWER2_Y-1) && (xtile == POWER_X)) || ((ytile == YTILES + YOFFSET - POWER2_Y-1) && (xtile == XTILES - POWER_X - 1)) ) begin
        if (pellet_animation) begin
            pellet_sprite = pellet_large;
        end else begin
            pellet_sprite = 64'h0;
        end
        power_pellet = 1'b1;
    end else begin
        pellet_sprite = pellet_small;
        power_pellet = 1'b0;
    end

    if (ytile > (YOFFSET-1) && ytile < (40-YOFFSET)) begin
        if (pellets[(ytile-YOFFSET) * XTILES + xtile]) begin
            if (pellet_sprite [ypixel*8 + xpixel]) begin
                pellet_color = CRM;
            end else begin
                pellet_color = BLK;
            end
        end else begin
            pellet_color = BLK;
        end 
    end else begin
        pellet_color = BLK;
    end
end

always_comb begin
    if (pellet_color != BLK) begin
        color = pellet_color;
    end else if (wall_color != BLK) begin
        color = wall_color;
    end else begin
        color = BLK;
    end
end

endmodule