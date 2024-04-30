`timescale 1ns/1ns

module game_tb (
    output reg clk,
    output reg rst,
    output reg [9:0] xpos,
    output reg [9:0] ypos,
    output reg [9:0] pacman_x,
    output reg [9:0] pacman_y,
    output reg [1:0] pacman_dir,

    output reg [9:0] inky_xloc,
    output reg [9:0] inky_yloc,
    output reg [1:0] inky_dir,
    output reg [1:0] inky_mode,

    output [7:0] maze_color
);

reg [1:0] pacman_tile_info [0:3];
reg pacman_pellet;
reg power_pellet;
reg [1:0] blinky_tile_info [0:3];
reg [1:0] pinky_tile_info [0:3];
reg [1:0] inky_tile_info [0:3];

wire [6:0] pacman_xtile = pacman_x >> 3;
wire [6:0] pacman_ytile = (pacman_y >> 3) - 3;
reg [6:0] blinky_xtile_next;
reg [6:0] blinky_ytile_next;
reg [6:0] pinky_xtile_next;
reg [6:0] pinky_ytile_next;
reg [6:0] inky_xtile_next;
reg [6:0] inky_ytile_next;


reg [9:0] blinky_xloc = 'd203;
reg [9:0] blinky_yloc = 'd227;

reg start;

maze MAZEPIN(clk, ~rst, xpos, ypos, 
    pacman_xtile, pacman_ytile, 
    blinky_xtile_next, blinky_ytile_next, 
    pinky_xtile_next, pinky_ytile_next, 
    inky_xtile_next, inky_ytile_next, 
    1'b1, pacman_pellet, power_pellet, 
    pacman_tile_info, blinky_tile_info, pinky_tile_info, inky_tile_info, 
    maze_color);
// game_ghost BLINKY(gameclk, ~rst, ~btn, 2'b00, pacman_xtile, pacman_ytile, pacman_dir, power_pellet, blinky_tile_info, 10'b0, 10'b0, blinky_xtile_next, blinky_ytile_next, blinky_xloc, blinky_yloc, blinky_dir, blinky_mode);
// game_ghost PINKY(gameclk, ~rst, ~btn, 2'b01, pacman_xtile, pacman_ytile, pacman_dir, power_pellet, pinky_tile_info, 10'b0, 10'b0, pinky_xtile_next, pinky_ytile_next, pinky_xloc, pinky_yloc, pinky_dir, pinky_mode);
game_ghost UUT(clk, ~rst, ~btn, 2'b10, 
    pacman_xtile, pacman_ytile, pacman_dir, power_pellet, inky_tile_info, 
    blinky_xloc, blinky_yloc, 
    inky_xtile_next, inky_ytile_next, 
    inky_xloc, inky_yloc, inky_dir, inky_mode);

initial begin
    clk = 0;
    rst = 1;
    xpos = 0;
    ypos = 0;
    pacman_x = 'd119;
    pacman_y = 'd227;
    pacman_dir = 'd0;

    # 10 start = 1'b1;
    // blinky_x = 'd119;
    // blinky_y = 'd151;
end

always @(posedge clk) begin
    if (xpos < 159) begin
        #5 xpos <= xpos + 1;
    end else if (ypos < 319) begin
        #5 ypos <= ypos + 1;
        xpos <= 0;
    end else begin
        $stop;
    end
end

always begin
    #5 clk = ~clk;
end



endmodule