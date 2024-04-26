`timescale 1ns/1ns

module game_tb (
    output reg clk,
    output reg rst,
    output reg [9:0] xpos,
    output reg [9:0] ypos,
    output reg [9:0] pac_x,
    output reg [9:0] pac_y,
    output reg [1:0] pac_dir,

    output reg [9:0] blinky_x,
    output reg [9:0] blinky_y,
    output reg [1:0] blinky_dir,
    output reg [1:0] blinky_mode,

    output [7:0] maze_color
);

reg [1:0] pac_tile_info [0:3];
reg pac_pellet;
reg [1:0] blinky_tile_info [0:3];
reg power_pellet;
wire [6:0] pac_xtile = pac_x >> 3;
wire [6:0] pac_ytile = (pac_y >> 3) - 3;
wire [6:0] blinky_xtile;
wire [6:0] blinky_ytile ;

maze UUT_MAZE(clk, ~rst, xpos, ypos, pac_xtile, pac_ytile, blinky_xtile, blinky_ytile, 1'b1, pac_tile_info, pac_pellet, power_pellet, blinky_tile_info, maze_color);
game_ghost UUT_BLINKY(clk, ~rst, start, 2'b00, pac_xtile, pac_ytile, pac_dir, power_pellet, blinky_tile_info, blinky_xtile, blinky_ytile, blinky_x, blinky_y, blinky_dir, blinky_mode);

initial begin
    clk = 0;
    rst = 1;
    xpos = 0;
    ypos = 0;
    pac_x = 'd119;
    pac_y = 'd227;
    pac_dir = 'd0;
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