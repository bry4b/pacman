module pacman_top ( 
    input clk, 
    input rst,
    input btn,
	 
    input [9:0] switches,
    
    // NES controller I/O
    input nes_data,         // red      -> Arduino I/O 0
    output nes_latch,       // yellow   -> Arduino I/O 1
    output nes_pulse,       // orange   -> Arduino I/O 2

    // bongo controller I/O: 3V3 -> 4th 3V3 pin from the left (the other ones dont work) 
    inout gamecube_data,    // red      -> Arduino I/O 6
	 
    // vga outputs
    output hsync, 
    output vsync,
    output reg [3:0] red,
    output reg [3:0] green,
    output reg [3:0] blue,
    
    output [9:0] leds
);

// CONTROLLERS
wire nesclk;
wire [0:7] nes_btns;

wire gamecubeclk;
wire [0:15] bongo_btns;
wire [7:0] bongo_mic;

wire start;
wire lturn;
wire rturn;
wire uturn;

wire ctrl_select;   // HIGH to use gamecube controller, LOW to use NES controller
assign ctrl_select = switches[0];
assign leds[0] = switches[0];

// GRAPHICS
reg [9:0] xpos; 
reg [9:0] ypos;
reg [15:0] address;
wire [7:0] color;
wire [7:0] vga_data;

wire writeEnable;

// VGA DRIVER
wire vgaclk;
wire [9:0] hc; 
wire [9:0] vc;

wire [2:0] input_red = vga_data [7:5];
wire [2:0] input_green = vga_data [4:2];
wire [1:0] input_blue = vga_data [1:0];

// GAME
wire gameclk;

// MAZE
wire [7:0] maze_color;

// CHARACTERS INPUTS/OUTPUTS
wire [22:0] pacman_outputs;
wire [22:0] blinky_outputs;
wire [22:0] pinky_outputs;
wire [22:0] inky_outputs;
wire [22:0] clyde_outputs;

localparam RT   = 2'b00;
localparam UP   = 2'b01;
localparam DN   = 2'b10;
localparam LT   = 2'b11;
wire [1:0] pacman_dir = pacman_outputs [4:3];

wire [11:0] pacman_tiles;
wire [11:0] blinky_tiles;
wire [11:0] pinky_tiles;
wire [11:0] inky_tiles;
wire [11:0] clyde_tiles;

wire ghost_anim;
wire pellet_anim;
wire flash_maze;

wire pause;
wire [1:0] ghosts_eaten;
wire blinky_eaten; 
wire pinky_eaten;
wire inky_eaten;
wire clyde_eaten;
wire hide_pacman;
wire hide_ghosts;
wire [3:0] pacman_death_frame;

wire pacman_pellet;
wire power_pellet;
wire [1:0] pacman_tile_info [0:3]; 
wire [1:0] blinky_tile_info [0:3]; 
wire [1:0] pinky_tile_info [0:3]; 
wire [1:0] inky_tile_info [0:3];
wire [1:0] clyde_tile_info [0:3];

localparam RESET = 3'b000;
localparam START = 3'b001;
localparam PLAY = 3'b010;
localparam DEATH = 3'b011;
localparam LOSE = 3'b100;
localparam WIN = 3'b101;

wire [2:0] state;
wire [17:0] score;

assign leds[1] = flash_maze;
assign leds[9:7] = state[2:0];

wire win;
assign win = switches[1];

clk_controller CLK_CTRL (
    .inclk0 (clk),
    .c0 (nesclk),
    .c1 (gamecubeclk)
);

always_comb begin
    if (ctrl_select) begin      // gamecube controller
        start = bongo_btns[3];
        lturn = bongo_btns[4] | bongo_btns[6];
        rturn = bongo_btns[5] | bongo_btns[7];
        uturn = (bongo_mic > 8'b01000000) && ~(lturn | rturn);
    end else begin              // nes controller
        start = nes_btns[3];
   
        case (pacman_dir) 
            RT: begin
                lturn = nes_btns[4];
                rturn = nes_btns[5];
                uturn = nes_btns[6];
            end 

            UP: begin
                lturn = nes_btns[6];
                rturn = nes_btns[7];
                uturn = nes_btns[5];
            end

            DN: begin
                lturn = nes_btns[7];
                rturn = nes_btns[6];
                uturn = nes_btns[4];
            end

            LT: begin
                lturn = nes_btns[5];
                rturn = nes_btns[4];
                uturn = nes_btns[7];
            end
        endcase       
        // lturn = nes_btns[1];
        // rturn = nes_btns[0];
        // // uturn = nes_btns[2];
        // uturn = nes_btns[5];
    end
end

// assign start = nes_btns[3];
// assign lturn = nes_btns[1];
// assign rturn = nes_btns[0];
// assign uturn = nes_btns[2];

// assign start = bongo_btns[3];
// assign lturn = bongo_btns[4] | bongo_btns[6];
// assign rturn = bongo_btns[5] | bongo_btns[7];
// assign uturn = (bongo_mic > 8'b01000000) && ~(lturn | rturn);

controller_nes NESCTRL (
    .clk (nesclk),
    .start (gameclk),
    .data_in (nes_data),
    .latch_out (nes_latch),
    .pulse_out (nes_pulse),
    .buttons_out (nes_btns)
);

controller_bongo BONGOCTRL (
    .clk (gamecubeclk),
    .start (gameclk),
    .buttons_out (bongo_btns),
    .rbtn_out (bongo_mic),
    .data (gamecube_data)
);

clk_vga CLK_VGA(clk, vgaclk);
vga DISPLAY(vgaclk, input_red, input_green, input_blue, ~rst, hc, vc, hsync, vsync, red, green, blue);
vga_ram RAM_VGA(vgaclk, address, hc, vc, color, writeEnable, vga_data);

// graphics_old BOO(
//     .clk (vgaclk), 
//     .rst (~rst), 
//     .hc (hc), 
//     .vc (vc), 
//     .pacman_inputs (pacman_outputs),
//     .blinky_inputs (blinky_outputs), 
//     .pinky_inputs (pinky_outputs),
//     .inky_inputs (inky_outputs),
//     .clyde_inputs (clyde_outputs),
//     .ghost_anim (ghost_anim), 
//     .ghosts_eaten (ghosts_eaten),
//     .maze_color (maze_color), 

//     .color (color), 
//     .xpos (xpos), 
//     .ypos (ypos),
//     .address (address)
// );

graphics_async BOO(
    .vgaclk (vgaclk), 
    .gameclk (gameclk),
    .rst (~rst), 
    .scanall (state == WIN || state == START || state == RESET), 
    .hc (hc), 
    .vc (vc), 
    .writeEnable (writeEnable),
    .pacman_inputs (pacman_outputs),
    .blinky_inputs (blinky_outputs), 
    .pinky_inputs (pinky_outputs),
    .inky_inputs (inky_outputs),
    .clyde_inputs (clyde_outputs),
    .ghost_anim (ghost_anim), 
    .ghosts_eaten (ghosts_eaten),
    .pacman_death_frame (pacman_death_frame),
    .hide_pacman (hide_pacman),
    .hide_ghosts (hide_ghosts),
    .game_state (state),
    .score (score),
    .maze_color (maze_color), 

    .color (color), 
    .xpos (xpos), 
    .ypos (ypos),
    .address (address)
);

clockDivider CLK_GAME(clk, 'd60, 1'b0, gameclk);

maze MAZEPIN(
    .clk (gameclk),
    .rst (state == RESET),
    .xpos (xpos), 
    .ypos (ypos),
    .pacman_inputs (pacman_tiles),
    .blinky_inputs (blinky_tiles),
    .pinky_inputs (pinky_tiles), 
    .inky_inputs (inky_tiles),
    .clyde_inputs (clyde_tiles),
    .pellet_anim (pellet_anim),
    .flash_maze (flash_maze),

    .pellet_out (pacman_pellet), 
    .power_pellet (power_pellet), 
    .pacman_outputs (pacman_tile_info),
    .blinky_outputs (blinky_tile_info),
    .pinky_outputs (pinky_tile_info), 
    .inky_outputs (inky_tile_info), 
    .clyde_outputs (clyde_tile_info),
    .color (maze_color) 
);

game_controller GAME_CTRL (
    .clk (gameclk),
    .rst (~rst),
    .start (start),
    .win (win),
    .lturn  (lturn),
    .rturn (rturn),
    .uturn (uturn),
    .pacman_pellet (pacman_pellet),
    .power_pellet (power_pellet),
    .pacman_tile_info (pacman_tile_info),
    .blinky_tile_info (blinky_tile_info),
    .pinky_tile_info (pinky_tile_info),
    .inky_tile_info (inky_tile_info),
    .clyde_tile_info (clyde_tile_info),

    .pacman_tiles (pacman_tiles),
    .blinky_tiles (blinky_tiles),
    .pinky_tiles (pinky_tiles),
    .inky_tiles (inky_tiles),
    .clyde_tiles (clyde_tiles),
    .pellet_anim (pellet_anim),
    .flash_maze (flash_maze),
    .pacman_outputs (pacman_outputs),
    .blinky_outputs (blinky_outputs),
    .pinky_outputs (pinky_outputs),
    .inky_outputs (inky_outputs),
    .clyde_outputs (clyde_outputs),
    .ghost_anim (ghost_anim),
    .pacman_death_frame (pacman_death_frame),
    .hide_pacman (hide_pacman),
    .hide_ghosts (hide_ghosts),

    .ghosts_eaten (ghosts_eaten),
    .state (state),
    .score (score),
    .pause (pause)

);

// game_ghost BLINKY (
//     .clk (gameclk),
//     .rst (~rst),
//     .start (start),
//     .pause (pause),
//     .personality (2'b00),
//     .pacman_inputs (pacman_outputs [22:3]),
//     .power_pellet (power_pellet),
//     .tile_info (blinky_tile_info),
//     .blinky_pos (1'b0),

//     .eaten (blinky_eaten),
//     .tile_checks (blinky_tiles),
//     .ghost_outputs (blinky_outputs)
// );

// game_ghost PINKY ( 
//     .clk (gameclk),
//     .rst (~rst),
//     .start (start),
//     .pause (pause),
//     .personality (2'b01),
//     .pacman_inputs (pacman_outputs [22:3]),
//     .power_pellet (power_pellet),
//     .tile_info (pinky_tile_info), 
//     .blinky_pos (1'b0),

//     .eaten (pinky_eaten),
//     .tile_checks (pinky_tiles),
//     .ghost_outputs (pinky_outputs)
// );
    
// game_ghost INKY ( 
//     .clk (gameclk),
//     .rst (~rst),
//     .start (start),
//     .pause (pause),
//     .personality (2'b10),
//     .pacman_inputs (pacman_outputs [22:3]),
//     .power_pellet (power_pellet),
//     .tile_info (inky_tile_info), 
//     .blinky_pos (blinky_outputs [22:5]), 

//     .eaten (inky_eaten),
//     .tile_checks (inky_tiles),
//     .ghost_outputs (inky_outputs)
// );

// game_ghost CLYDE (
//     .clk (gameclk),
//     .rst (~rst),
//     .start (start),
//     .pause (pause),
//     .personality (2'b11),
//     .pacman_inputs (pacman_outputs [22:3]),
//     .power_pellet (power_pellet),
//     .tile_info (clyde_tile_info), 
//     .blinky_pos (1'b0),

//     .eaten (clyde_eaten),
//     .tile_checks (clyde_tiles),
//     .ghost_outputs (clyde_outputs)
// );
    
// game_pacman PACMAN ( 
//     .clk60 (gameclk), 
//     .reset (~rst), 
//     .start (start),
//     .pause (pause),
//     .left (lturn),
//     .right (rturn),
//     .uturn (uturn),
//     .tile_info (pacman_tile_info),

//     .tile_checks (pacman_tiles),
//     .pacman_outputs (pacman_outputs)
// );

// localparam SCOR = 2'b10;

// always_comb begin
//     ghosts_eaten = blinky_eaten + pinky_eaten + inky_eaten + clyde_eaten - 1'b1;
//     pause = blinky_outputs[2:1] == SCOR || pinky_outputs [2:1] == SCOR || inky_outputs [2:1] == SCOR || clyde_outputs [2:1] == SCOR;
// end

// // ghost animation
// always_comb begin
//     if (gameclk && ~pause) begin
//         ghost_anim_counter_d = ghost_anim_counter + 1'b1;
//         pellet_anim_counter_d = pellet_anim_counter + 1'b1;
//     end else begin
//         ghost_anim_counter_d = ghost_anim_counter;
//         pellet_anim_counter_d = pellet_anim_counter;
//     end

//     if (ghost_anim_counter == 1'b0 && ~pause) begin
//         ghost_anim_d = ~ghost_anim;
//     end else begin
//         ghost_anim_d = ghost_anim;
//     end

//     if (pellet_anim_counter == 1'b0 && ~pause) begin
//         pellet_anim_d = ~pellet_anim;
//     end else begin
//         pellet_anim_d = pellet_anim;
//     end
// end

// always @(posedge gameclk) begin
//     ghost_anim_counter <= ghost_anim_counter_d;
//     ghost_anim <= ghost_anim_d;
//     pellet_anim_counter <= pellet_anim_counter_d;
//     pellet_anim <= pellet_anim_d;
// end

endmodule
