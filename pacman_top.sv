<<<<<<< HEAD
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
wire ctrl_mode;     // HIGH to use direction controls, LOW to use rotation controls
assign ctrl_select = switches[0];
assign ctrl_mode = switches[1];
assign leds[1] = switches[1];
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
wire reset_maze;

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
wire [2:0] lives;

assign leds [9:2] = bongo_btns [0:7];

clk_controller CLK_CTRL (
    .inclk0 (clk),
    .c0 (nesclk),
    .c1 (gamecubeclk)
);

always_comb begin
    if (ctrl_select) begin      // gamecube controller
        start = bongo_btns[3];
        if (ctrl_mode) begin    // direction controls         
            case (pacman_dir) 
                RT: begin
                    lturn = bongo_btns[12];
                    rturn = bongo_btns[13];
                    uturn = bongo_btns[15];
                end 

                UP: begin
                    lturn = bongo_btns[15];
                    rturn = bongo_btns[14];
                    uturn = bongo_btns[13];
                end

                DN: begin
                    lturn = bongo_btns[14];
                    rturn = bongo_btns[15];
                    uturn = bongo_btns[12];
                end

                LT: begin
                    lturn = bongo_btns[13];
                    rturn = bongo_btns[12];
                    uturn = bongo_btns[14];
                end
            endcase
        end else begin
            lturn = bongo_btns[4] | bongo_btns[6];
            rturn = bongo_btns[5] | bongo_btns[7];
            uturn = (bongo_mic > 8'b01000000) && ~(lturn | rturn);
        end
    end else begin              // nes controller
        start = nes_btns[3];
        if (ctrl_mode) begin    
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
        end else begin
            lturn = nes_btns[1];
            rturn = nes_btns[0];
            // uturn = nes_btns[2];
            uturn = nes_btns[5];
        end
    end
end

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
    .lives (lives),
    .maze_color (maze_color), 

    .color (color), 
    .xpos (xpos), 
    .ypos (ypos),
    .address (address)
);

clockDivider CLK_GAME(clk, 'd60, ~rst, gameclk);

maze MAZEPIN(
    .clk (gameclk),
    .rst (state == RESET || reset_maze || ~rst),
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
    .reset_maze (reset_maze),

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
    .lives (lives),
    .pause (pause)
);

endmodule
=======
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
wire ctrl_mode;     // HIGH to use direction controls, LOW to use rotation controls
assign ctrl_select = switches[0];
assign ctrl_mode = switches[1];
assign leds[1] = switches[1];
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
wire reset_maze;

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
wire [2:0] lives;

assign leds [9:2] = bongo_btns [0:7];

clk_controller CLK_CTRL (
    .inclk0 (clk),
    .c0 (nesclk),
    .c1 (gamecubeclk)
);

always_comb begin
    if (ctrl_select) begin      // gamecube controller
        start = bongo_btns[3];
        if (ctrl_mode) begin    // direction controls         
            case (pacman_dir) 
                RT: begin
                    lturn = bongo_btns[12];
                    rturn = bongo_btns[13];
                    uturn = bongo_btns[15];
                end 

                UP: begin
                    lturn = bongo_btns[15];
                    rturn = bongo_btns[14];
                    uturn = bongo_btns[13];
                end

                DN: begin
                    lturn = bongo_btns[14];
                    rturn = bongo_btns[15];
                    uturn = bongo_btns[12];
                end

                LT: begin
                    lturn = bongo_btns[13];
                    rturn = bongo_btns[12];
                    uturn = bongo_btns[14];
                end
            endcase
        end else begin
            lturn = bongo_btns[4] | bongo_btns[6];
            rturn = bongo_btns[5] | bongo_btns[7];
            uturn = (bongo_mic > 8'b01000000) && ~(lturn | rturn);
        end
    end else begin              // nes controller
        start = nes_btns[3];
        if (ctrl_mode) begin    
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
        end else begin
            lturn = nes_btns[1];
            rturn = nes_btns[0];
            // uturn = nes_btns[2];
            uturn = nes_btns[5];
        end
    end
end

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
    .lives (lives),
    .maze_color (maze_color), 

    .color (color), 
    .xpos (xpos), 
    .ypos (ypos),
    .address (address)
);

clockDivider CLK_GAME(clk, 'd60, ~rst, gameclk);

maze MAZEPIN(
    .clk (gameclk),
    .rst (~btn | ~rst | state == RESET | reset_maze),
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
    .rst (~btn),
    .start (start),
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
    .reset_maze (reset_maze),

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
    .lives (lives),
    .pause (pause)
);

endmodule
>>>>>>> c73374c11b852264e5eb6e8d08ae70edc7704dc3
