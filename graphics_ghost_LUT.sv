module graphics_ghost_LUT (
    input [9:0] blinky_in, 
    input [9:0] pinky_in, 
    input [9:0] inky_in, 
    input [9:0] clyde_in, 
    input [1:0] ghosts_eaten,
    input hide_ghosts,

    output [2:0] blinky_out,
    output [2:0] pinky_out,
    output [2:0] inky_out, 
    output [2:0] clyde_out
);

// bitfield definition 
localparam BLNK = 3'b000;   // BLaNK

localparam BODY = 3'b001;   // BODY color   
localparam EYES = 3'b010;   // shared EYE pixelS
localparam WHT0 = 3'b011;   // WHT for right/up, else body
localparam BLU0 = 3'b100;   // BLU for right/up, else body
localparam WHT1 = 3'b101;   // WHT for left/down, else body
localparam BLU1 = 3'b110;   // BLU for left/down, else body

localparam FRL0 = 3'b010;   // FRiLly thing, frame 0 
localparam FRL1 = 3'b011;   // FRiLly thing, frame 1

localparam FILL = 1'b1;     // FILLed for score

// 3 bits x 256 pixels x 3 sprites
// EACH SPRITE IS 8X8 PIXELS, EACH PIXEL IS 3 BITS WIDE
// 

reg [2:0] ghost_LUT [0:767] = '{
//  0       1       2       3       4       5       6       7       8       9       10      11      12      13      14      15
// 
//  SPRITE0 - LOOKING RIGHT (0) OR LEFT (1) - STARTS W/ ADDRESS 0
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 0
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 1
    BLNK,   BLNK,   BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   BLNK,   BLNK,   // 2
    BLNK,   BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   BLNK,   // 3
    BLNK,   BLNK,   BODY,   WHT1,   WHT1,   WHT0,   WHT0,   BODY,   BODY,   WHT1,   WHT1,   WHT0,   WHT0,   BODY,   BLNK,   BLNK,   // 4
    BLNK,   BLNK,   WHT1,   WHT1,   EYES,   EYES,   WHT0,   WHT0,   WHT1,   WHT1,   EYES,   EYES,   WHT0,   WHT0,   BLNK,   BLNK,   // 5
    BLNK,   BLNK,   BLU1,   BLU1,   EYES,   EYES,   BLU0,   BLU0,   BLU1,   BLU1,   EYES,   EYES,   BLU0,   BLU0,   BLNK,   BLNK,   // 6
    BLNK,   BODY,   BLU1,   BLU1,   EYES,   EYES,   BLU0,   BLU0,   BLU1,   BLU1,   EYES,   EYES,   BLU0,   BLU0,   BODY,   BLNK,   // 7
    BLNK,   BODY,   BODY,   WHT1,   WHT1,   WHT0,   WHT0,   BODY,   BODY,   WHT1,   WHT1,   WHT0,   WHT0,   BODY,   BODY,   BLNK,   // 8
    BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 9
    BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 10
    BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 11
    BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 12
    BLNK,   BODY,   BODY,   FRL1,   BODY,   FRL0,   BODY,   FRL1,   FRL1,   BODY,   FRL0,   BODY,   FRL1,   BODY,   BODY,   BLNK,   // 13
    BLNK,   FRL0,   FRL1,   FRL1,   BLNK,   FRL0,   FRL0,   FRL1,   FRL1,   FRL0,   FRL0,   BLNK,   FRL1,   FRL1,   FRL0,   BLNK,   // 14
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 15
// 
//  SPRITE1 - LOOKING UP (0) OR DOWN (1) - STARTS W/ ADDRESS 256
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 16
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 17
    BLNK,   BLNK,   BLNK,   BLNK,   BLU0,   BLU0,   BODY,   BODY,   BODY,   BODY,   BLU0,   BLU0,   BLNK,   BLNK,   BLNK,   BLNK,   // 18
    BLNK,   BLNK,   BLNK,   WHT0,   BLU0,   BLU0,   WHT0,   BODY,   BODY,   WHT0,   BLU0,   BLU0,   WHT0,   BLNK,   BLNK,   BLNK,   // 19
    BLNK,   BLNK,   BODY,   WHT0,   WHT0,   WHT0,   WHT0,   BODY,   BODY,   WHT0,   WHT0,   WHT0,   WHT0,   BODY,   BLNK,   BLNK,   // 20
    BLNK,   BLNK,   BODY,   WHT0,   EYES,   EYES,   WHT0,   BODY,   BODY,   WHT0,   EYES,   EYES,   WHT0,   BODY,   BLNK,   BLNK,   // 21
    BLNK,   BLNK,   BODY,   WHT1,   EYES,   EYES,   WHT1,   BODY,   BODY,   WHT1,   EYES,   EYES,   WHT1,   BODY,   BLNK,   BLNK,   // 22
    BLNK,   BODY,   BODY,   WHT1,   WHT1,   WHT1,   WHT1,   BODY,   BODY,   WHT1,   WHT1,   WHT1,   WHT1,   BODY,   BODY,   BLNK,   // 23
    BLNK,   BODY,   BODY,   WHT1,   BLU1,   BLU1,   WHT1,   BODY,   BODY,   WHT1,   BLU1,   BLU1,   WHT1,   BODY,   BODY,   BLNK,   // 24
    BLNK,   BODY,   BODY,   BODY,   BLU1,   BLU1,   BODY,   BODY,   BODY,   BODY,   BLU1,   BLU1,   BODY,   BODY,   BODY,   BLNK,   // 25
    BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 26
    BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 27
    BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 28
    BLNK,   BODY,   BODY,   FRL1,   BODY,   FRL0,   BODY,   FRL1,   FRL1,   BODY,   FRL0,   BODY,   FRL1,   BODY,   BODY,   BLNK,   // 29
    BLNK,   FRL0,   FRL1,   FRL1,   BLNK,   FRL0,   FRL0,   FRL1,   FRL1,   FRL0,   FRL0,   BLNK,   FRL1,   FRL1,   FRL0,   BLNK,   // 30
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 31
// 
//  SPRITE2 - FRIGHTENED - STARTS W/ ADDRESS 512
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 32
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 33
    BLNK,   BLNK,   BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   BLNK,   BLNK,   // 34
    BLNK,   BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   BLNK,   // 35
    BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   // 36
    BLNK,   BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   BLNK,   // 37
    BLNK,   BLNK,   BODY,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   BODY,   BLNK,   BLNK,   // 38
    BLNK,   BODY,   BODY,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 39
    BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 40
    BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 41
    BLNK,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   BLNK,   // 42
    BLNK,   BODY,   EYES,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   EYES,   EYES,   BODY,   BODY,   EYES,   BODY,   BLNK,   // 43
    BLNK,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BODY,   BLNK,   // 44
    BLNK,   BODY,   BODY,   FRL1,   BODY,   FRL0,   BODY,   FRL1,   FRL1,   BODY,   FRL0,   BODY,   FRL1,   BODY,   BODY,   BLNK,   // 45
    BLNK,   FRL0,   FRL1,   FRL1,   BLNK,   FRL0,   FRL0,   FRL1,   FRL1,   FRL0,   FRL0,   BLNK,   FRL1,   FRL1,   FRL0,   BLNK,   // 46
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK    // 47
}; 

reg score_LUT [0:1023] = '{
//  0       1       2       3       4       5       6       7       8       9       10      11      12      13      14      15
// 
//  SPRITE0 - 200 - STARTS W/ ADDRESS 0
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 0
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 1
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 2
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 3
    BLNK,   BLNK,   FILL,   FILL,   FILL,   BLNK,   BLNK,   BLNK,   FILL,   FILL,   BLNK,   BLNK,   BLNK,   FILL,   FILL,   BLNK,   // 4
    BLNK,   FILL,   BLNK,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   // 5
    BLNK,   FILL,   BLNK,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   // 6
    BLNK,   BLNK,   BLNK,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   // 7
    BLNK,   BLNK,   BLNK,   FILL,   BLNK,   BLNK,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   // 8
    BLNK,   BLNK,   FILL,   BLNK,   BLNK,   BLNK,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   // 9
    BLNK,   FILL,   FILL,   FILL,   FILL,   FILL,   BLNK,   BLNK,   FILL,   FILL,   BLNK,   BLNK,   BLNK,   FILL,   FILL,   BLNK,   // 10
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 11
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 12
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 13
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 14
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 15
// 
//  SPRITE1 - 400 - STARTS W/ ADDRESS 0
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 0
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 1
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 2
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 3
    BLNK,   BLNK,   BLNK,   BLNK,   FILL,   BLNK,   BLNK,   BLNK,   FILL,   FILL,   BLNK,   BLNK,   BLNK,   FILL,   FILL,   BLNK,   // 4
    BLNK,   BLNK,   BLNK,   FILL,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   // 5
    BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   // 6
    BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   // 7
    BLNK,   FILL,   FILL,   FILL,   FILL,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   // 8
    BLNK,   BLNK,   BLNK,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   // 9
    BLNK,   BLNK,   BLNK,   BLNK,   FILL,   BLNK,   BLNK,   BLNK,   FILL,   FILL,   BLNK,   BLNK,   BLNK,   FILL,   FILL,   BLNK,   // 10
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 11
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 12
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 13
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 14
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 15
// 
//  SPRITE2 - 800 - STARTS W/ ADDRESS 0
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 0
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 1
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 2
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 3
    BLNK,   BLNK,   FILL,   FILL,   FILL,   BLNK,   BLNK,   BLNK,   FILL,   FILL,   BLNK,   BLNK,   BLNK,   FILL,   FILL,   BLNK,   // 4
    BLNK,   FILL,   BLNK,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   // 5
    BLNK,   FILL,   BLNK,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   // 6
    BLNK,   BLNK,   FILL,   FILL,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   // 7
    BLNK,   FILL,   BLNK,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   // 8
    BLNK,   FILL,   BLNK,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   // 9
    BLNK,   BLNK,   FILL,   FILL,   FILL,   BLNK,   BLNK,   BLNK,   FILL,   FILL,   BLNK,   BLNK,   BLNK,   FILL,   FILL,   BLNK,   // 10
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 11
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 12
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 13
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 14
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 15
//
//  SPRITE3 - 1600 - STARTS W/ ADDRESS 0
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 0
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 1
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 2
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 3
    FILL,   BLNK,   BLNK,   FILL,   FILL,   FILL,   BLNK,   BLNK,   FILL,   FILL,   BLNK,   BLNK,   BLNK,   FILL,   FILL,   BLNK,   // 4
    FILL,   BLNK,   FILL,   BLNK,   BLNK,   BLNK,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   // 5
    FILL,   BLNK,   FILL,   BLNK,   BLNK,   BLNK,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   // 6
    FILL,   BLNK,   FILL,   FILL,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   // 7
    FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   // 8
    FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   BLNK,   FILL,   BLNK,   BLNK,   FILL,   // 9
    FILL,   BLNK,   BLNK,   FILL,   FILL,   BLNK,   BLNK,   BLNK,   FILL,   FILL,   BLNK,   BLNK,   BLNK,   FILL,   FILL,   BLNK,   // 10
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 11
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 12
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 13
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   // 14
    BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK,   BLNK   // 15
};
always_comb begin
    if (~hide_ghosts) begin
        if (blinky_in < 'd768) begin
            blinky_out = ghost_LUT [blinky_in];
        end else begin
            blinky_out = score_LUT [(blinky_in - 'd768) + (ghosts_eaten << 'd8)];
        end
        if (pinky_in < 'd768) begin
            pinky_out = ghost_LUT [pinky_in];
        end else begin
            pinky_out = score_LUT [(pinky_in - 'd768) + (ghosts_eaten << 'd8)];
        end
        if (inky_in < 'd768) begin
            inky_out = ghost_LUT [inky_in];
        end else begin
            inky_out = score_LUT [(inky_in - 'd768) + (ghosts_eaten << 'd8)];
        end
        if (clyde_in < 'd768) begin
            clyde_out = ghost_LUT [clyde_in];
        end else begin
            clyde_out = score_LUT [(clyde_in - 'd768) + (ghosts_eaten << 'd8)];
        end
    end else begin
        blinky_out = BLNK;
        pinky_out = BLNK;
        inky_out = BLNK;
        clyde_out = BLNK;
    end
end

// assign blinky_out = ghost_LUT [blinky_in];
// assign pinky_out = ghost_LUT [pinky_in]; 
// assign inky_out = ghost_LUT [inky_in];
// assign clyde_out = ghost_LUT [clyde_in]; 

endmodule