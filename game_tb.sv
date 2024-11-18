`timescale 1ns/1ns

module game_tb (
    output reg gameclk,
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
wire start;

wire [9:0] blinky_xloc;
wire [9:0] blinky_yloc;

wire [24:0] pacman_outputs = {pacman_x, pacman_y, pacman_dir, 3'b0};
wire [13:0] pacman_tiles = {pacman_x >> 3, (pacman_y >> 3) - 3};

wire [23:0] blinky_outputs = {blinky_xloc, blinky_yloc, 3'b0};
// wire [23:0] pinky_outputs;
wire [23:0] inky_outputs = {inky_xloc, inky_yloc, inky_dir, inky_mode};
// wire [23:0] clyde_outputs;

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

// game_ghost BLINKY(gameclk, ~rst, ~btn, 2'b00, pacman_xtile, pacman_ytile, pacman_dir, power_pellet, blinky_tile_info, 10'b0, 10'b0, blinky_xtile_next, blinky_ytile_next, blinky_xloc, blinky_yloc, blinky_dir, blinky_mode);
// game_ghost PINKY(gameclk, ~rst, ~btn, 2'b01, pacman_xtile, pacman_ytile, pacman_dir, power_pellet, pinky_tile_info, 10'b0, 10'b0, pinky_xtile_next, pinky_ytile_next, pinky_xloc, pinky_yloc, pinky_dir, pinky_mode);
    game_ghost INKY ( 
        .clk (gameclk),
        .rst (~rst),
        .start (~btn),
        .personality (2'b10),
        .pacman_inputs (pacman_outputs [24:3]),
        .power_pellet (power_pellet),
        .tile_info (inky_tile_info), 
        .blinky_pos (blinky_outputs [23:4]), 

        .tile_checks (inky_tiles),
        .ghost_outputs (inky_outputs)
    );

// game_ghost UUT_CLYDE(gameclk, ~rst, ~btn, 2'b11, 
//     pacman_xtile, pacman_ytile, pacman_dir, power_pellet, 
//     clyde_tile_info, 10'b0, 10'b0, 
//     clyde_xtile_next, clyde_ytile_next, 
//     clyde_xloc, clyde_yloc, clyde_dir, clyde_mode
// );

initial begin
    gameclk = 0;
    rst = 1;
    xpos = 0;
    ypos = 0;
    pacman_x = 'd119;
    pacman_y = 'd227;
    pacman_dir = 'd0;
    blinky_xloc = 'd227;
    blinky_yloc = 'd227;

    # 10 start = 1'b1;
    // blinky_x = 'd119;
    // blinky_y = 'd151;
end

always @(posedge gameclk) begin
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
    #5 gameclk = ~gameclk;
end



endmodule