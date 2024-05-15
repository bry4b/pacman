`timescale 1ns/1ns

module pacman_tb (
    output reg [9:0] pac_x,
    output reg [9:0] pac_y,
    output reg [1:0] pac_dir

);

    reg [1:0] pac_tile_info [0:3];
    reg pac_pellet;
    reg power_pellet;

    wire [6:0] pac_xtile; //= pac_x >> 3;
    wire [6:0] pac_ytile; //= (pac_y >> 3) - 3;

    logic start = 0;
    logic clk = 0;
    logic left = 0;
    logic right = 0;
    logic uturn = 0;

    reg [1:0] blinky_tile_info [0:3];
    reg [1:0] pinky_tile_info [0:3];
    reg [1:0] inky_tile_info [0:3];
    reg [1:0] clyde_tile_info [0:3];
    reg [7:0] color;

    maze UUT_MAZE(clk, 0, /*xpos*/1'bz, /*ypos*/1'bz, {pac_xtile, pac_ytile}, 0, 0, 0, 0, 1'b1, pac_pellet, power_pellet, pac_tile_info, blinky_tile_info, pinky_tile_info, inky_tile_info, clyde_tile_info, color);
    // pacman player(clk, left, right, uturn, start, 0, 0, pac_tile_info, pac_x, pac_y, pac_dir, 2'b00, pac_xtile, pac_ytile);

    initial begin
        start = 0;
        #10 start = 1;
        left = 1;   
        #10 start = 0;
        // #200 uturn = 1;
        // #10 uturn = 0;
        // #600 left = 1;
        // #10 left = 0;
		// #800;
        // $stop;
    end

    always #5 clk = ~clk;

endmodule