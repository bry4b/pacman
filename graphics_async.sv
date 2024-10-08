//TODO: FIX BUG: WHEN SPRITES CHANGE POSITION, THEIR PREVIOUS POSITION IS REWRITTEN IN ONE RAM BUT NOT IN THE OTHER, WHICH CAUSES A GLITCH 
//      done :)

module graphics_async (
    input vgaclk, 
    input gameclk,
    input rst, 
    input scanall,

    input [9:0] hc, 
    input [9:0] vc,
    input writeEnable,

    // input [9:0] pacman_xloc,
    // input [9:0] pacman_yloc,    
    // input [1:0] pacman_dir, 
    // input [1:0] pacman_anim,
    // input pacman_alive,
    input [22:0] pacman_inputs,

    // input [9:0] blinky_xloc, 
    // input [9:0] blinky_yloc,
    // input [1:0] blinky_dir, 
    // input [1:0] blinky_mode,
    input [22:0] blinky_inputs,

    // input [9:0] pinky_xloc, 
    // input [9:0] pinky_yloc,
    // input [1:0] pinky_dir, 
    // input [1:0] pinky_mode,
    input [22:0] pinky_inputs,

    // input [9:0] inky_xloc, 
    // input [9:0] inky_yloc,
    // input [1:0] inky_dir, 
    // input [1:0] inky_mode,
    input [22:0] inky_inputs,

    // input [9:0] clyde_xloc, 
    // input [9:0] clyde_yloc,
    // input [1:0] clyde_dir, 
    // input [1:0] clyde_mode,
    input [22:0] clyde_inputs,

    input ghost_anim,

    input [1:0] ghosts_eaten,
    input [3:0] pacman_death_frame,
    input hide_pacman,
    input hide_ghosts,

    input [2:0] game_state,
    input [17:0] score,
    input [2:0] lives,

    input [7:0] maze_color,
    
    output reg [7:0] color,
    output reg [8:0] xpos, 
    output reg [8:0] ypos,
    output reg [15:0] address
);

reg [22:0] pacman_curr, blinky_curr, pinky_curr, inky_curr, clyde_curr;
reg [22:0] pacman_prev0, blinky_prev0, pinky_prev0, inky_prev0, clyde_prev0;
reg [22:0] pacman_prev1, blinky_prev1, pinky_prev1, inky_prev1, clyde_prev1;
wire [22:0] pacman_prev, blinky_prev, pinky_prev, inky_prev, clyde_prev;

// wire [8:0] pacman_xloc  = pacman_curr [22:14];
// wire [8:0] pacman_yloc  = pacman_curr [13:5];     
// wire [1:0] pacman_dir   = pacman_curr [4:3]; 
// wire [1:0] pacman_anim  = pacman_curr [2:1];
// wire pacman_alive       = pacman_curr [0];

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

// GHOSTS
graphics_ghost_LUT GLUT (
    .blinky_in (blinky_address), 
    .pinky_in (pinky_address), 
    .inky_in (inky_address), 
    .clyde_in (clyde_address), 
    .ghosts_eaten (ghosts_eaten), 
    .hide_ghosts (hide_ghosts),

    .blinky_out(blinky_pixel), 
    .pinky_out(pinky_pixel), 
    .inky_out (inky_pixel), 
    .clyde_out (clyde_pixel)
);

graphics_ghost BLINKY (
    .xpos (xpos),
    .ypos (ypos),
    .ghost_color (2'b00),
    .ghost_inputs (blinky_curr), 
    .animation_cycle (ghost_anim),
    .pixel (blinky_pixel),

    .pixel_address (blinky_address), 
    .color (blinky_color),
);
    
graphics_ghost PINKY (
    .xpos (xpos),
    .ypos (ypos),
    .ghost_color (2'b01),
    .ghost_inputs (pinky_curr), 
    .animation_cycle (ghost_anim),
    .pixel (pinky_pixel),

    .pixel_address (pinky_address), 
    .color (pinky_color),
);

graphics_ghost INKY (
    .xpos (xpos),
    .ypos (ypos),
    .ghost_color (2'b10),
    .ghost_inputs (inky_curr), 
    .animation_cycle (ghost_anim),
    .pixel (inky_pixel),

    .pixel_address (inky_address), 
    .color (inky_color),
);

graphics_ghost CLYDE (
    .xpos (xpos),
    .ypos (ypos),
    .ghost_color (2'b11),
    .ghost_inputs (clyde_curr), 
    .animation_cycle (ghost_anim),
    .pixel (clyde_pixel),

    .pixel_address (clyde_address), 
    .color (clyde_color),
);

// PACMAN
wire [7:0] pacman_color;
graphics_pacman PACMAN  (
    .xpos (xpos), 
    .ypos (ypos), 
    .pacman_inputs (pacman_curr),
    .pacman_death_frame (pacman_death_frame),
    .hide_pacman (hide_pacman),

    .color (pacman_color)
);

// SCOREBOARD
wire [7:0] scoreboard_color;
graphics_scoreboard SCOREBOARD (
    .xpos (xpos), 
    .ypos (ypos), 
    .score (score),

    .color (scoreboard_color)
);

wire [7:0] lives_color;
graphics_lives LIVES (
    .xpos (xpos), 
    .ypos (ypos), 
    .lives (lives),

    .color (lives_color)
);

// TEXT
wire [7:0] text_color;
graphics_text TEXT (
    .xpos (xpos), 
    .ypos (ypos), 
    .game_state (game_state),

    .color (text_color)
);

// LOGIC FOR SPRITE HIERARCHY
// allows sprites to show through "below" other sprites 
always_comb begin
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
    end else if (scoreboard_color != BLK) begin
        color = scoreboard_color;
    end else if (text_color != BLK) begin
        color = text_color;
    end else if (lives_color != BLK) begin
        color = lives_color;
    end else begin
        color = BLK;
    end
end

// SCANNING AREA MAGIC
localparam XMAX = 240;      // horizontal pixels (480/2)
localparam YMAX = 320;      // vertical pixels (640/2)

localparam MAZE_Y_OFFSET = 24;  // vertical maze offset (3 tiles * 8)
localparam MAZE_Y_HEIGHT = 264; // vertical maze height (33 tiles * 8)
localparam SCORE_X_OFFSET = 8;  // 1 tile * 8
localparam SCORE_Y_OFFSET = 8;  // 1 tile * 8
localparam SCORE_X_WIDTH = 56;  // 7 digits * 8 pixels per digit
localparam SCORE_Y_HEIGHT = 8;  // 1 tile * 8
localparam TEXT_X_OFFSET = 80;  // 10 tiles * 8
localparam TEXT_Y_OFFSET = 176; // 22 tiles * 8
localparam TEXT_X_WIDTH = 80;   // 10 letters * 8 pixels per letter
localparam LIVES_X_OFFSET = 8;
localparam LIVES_Y_OFFSET = 296;
localparam LIVES_X_WIDTH = 80;      // max 5 lives * 16 pixels per life
localparam LIVES_Y_HEIGHT = 16;     

// localparam START_0      = 4'b0000;  // load entire screen to ram0
// localparam START_1      = 4'b0001;  // load entire screen to ram1
// localparam PACMAN_OLD   = 4'b0010;  // load pacman prev area
// localparam PACMAN_NEW   = 4'b0011;  // load pacman curr area
// localparam BLINKY_OLD   = 4'b0100;  // load blinky prev area
// localparam BLINKY_NEW   = 4'b0101;  // load blinky curr area
// localparam PINKY_OLD    = 4'b0110;  // load pinky prev area
// localparam PINKY_NEW    = 4'b0111;  // load pinky curr area
// localparam INKY_OLD     = 4'b1000;  // load inky prev area
// localparam INKY_NEW     = 4'b1001;  // load inky curr area
// localparam CLYDE_OLD    = 4'b1010;  // load clyde prev area
// localparam CLYDE_NEW    = 4'b1011;  // load clyde curr area
// localparam MAZE_SCAN    = 4'b1100;  // load power pellets
// localparam SCORE_SCAN   = 4'b1101;  // load scoreboard & revives
// localparam TEXT_SCAN    = 4'b1110;  // load text
// localparam SCAN_IDLE    = 4'b1111;  // idle after all scan

localparam START_0      = 5'b00000;     // load entire screen to ram0
localparam START_1      = 5'b00001;     // load entire screen to ram1
localparam PACMAN_OLD   = 5'b00010;     // load pacman prev area
localparam PACMAN_NEW   = 5'b00011;     // load pacman curr area
localparam BLINKY_OLD   = 5'b00100;     // load blinky prev area
localparam BLINKY_NEW   = 5'b00101;     // load blinky curr area
localparam PINKY_OLD    = 5'b00110;     // load pinky prev area
localparam PINKY_NEW    = 5'b00111;     // load pinky curr area
localparam INKY_OLD     = 5'b01000;     // load inky prev area
localparam INKY_NEW     = 5'b01001;     // load inky curr area
localparam CLYDE_OLD    = 5'b01010;     // load clyde prev area
localparam CLYDE_NEW    = 5'b01011;     // load clyde curr area
localparam MAZE_SCAN    = 5'b01100;     // load power pellets
localparam SCORE_SCAN   = 5'b01101;     // load scoreboard
localparam TEXT_SCAN    = 5'b01110;     // load text
localparam LIVES_SCAN   = 5'b01111;     // load lives
localparam SCAN_IDLE    = 5'b11111;     // idle after all scan

reg [4:0] scan_state;
wire [4:0] scan_state_d;

reg [10:0] scan_counter;
wire [10:0] scan_counter_d;

always @(posedge vgaclk) begin
    scan_state <= scan_state_d;
    scan_counter <= scan_counter_d;

    if (hc == 'd799 && vc == 'd524) begin
        pacman_curr <= pacman_inputs;
        blinky_curr <= blinky_inputs;
        pinky_curr <= pinky_inputs;
        inky_curr <= inky_inputs;
        clyde_curr <= clyde_inputs;

        if (writeEnable) begin
            pacman_prev0 <= pacman_curr;
            blinky_prev0 <= blinky_curr;
            pinky_prev0 <= pinky_curr;
            inky_prev0 <= inky_curr;
            clyde_prev0 <= clyde_curr;
        end else begin
            pacman_prev1 <= pacman_curr;
            blinky_prev1 <= blinky_curr;
            pinky_prev1 <= pinky_curr;
            inky_prev1 <= inky_curr;
            clyde_prev1 <= clyde_curr;
        end
    end
end

always_comb begin
    if (writeEnable) begin
        pacman_prev = pacman_prev0;
        blinky_prev = blinky_prev0;
        pinky_prev = pinky_prev0;
        inky_prev = inky_prev0;
        clyde_prev = clyde_prev0;
    end else begin
        pacman_prev = pacman_prev1;
        blinky_prev = blinky_prev1;
        pinky_prev = pinky_prev1;
        inky_prev = inky_prev1;
        clyde_prev = clyde_prev1;
    end
end

always_comb begin
    case (scan_state)
        START_0: begin      // load entire screen into ram0
            scan_counter_d = 1'b0;

            if (hc < 'd640 && vc < 'd480) begin
                // xpos = XMAX - 1 - vc_in / 3;
                xpos = XMAX - 1'b1 - (vc >> 1'b1);
                ypos = hc >> 1'b1;
            end else if (vc < 'd480) begin
                // xpos = XMAX - 1 - vc_in / 3;
                xpos = XMAX - 1'b1 - (vc >> 1'b1);
                ypos = YMAX - 1'b1;
            end else begin 
                xpos = 1'b0;
                ypos = 1'b0;
            end

            if (hc == 'd799 && vc == 'd524) begin
                scan_state_d = START_1; 
            end else begin
                scan_state_d = START_0;
            end
        end

        START_1: begin      // load entire screen into ram1
            scan_counter_d = 1'b0;

            if (hc < 'd640 && vc < 'd480) begin
                // xpos = XMAX - 1 - vc_in / 3;
                xpos = XMAX - 1'b1 - (vc >> 1'b1);
                ypos = hc >> 1'b1;
            end else if (vc < 'd480) begin
                // xpos = XMAX - 1 - vc_in / 3;
                xpos = XMAX - 1'b1 - (vc >> 1'b1);
                ypos = YMAX - 1'b1;
            end else begin 
                xpos = 1'b0;
                ypos = 1'b0;
            end

            if (rst) begin
                scan_state_d = START_0;
            end else if (hc == 'd799 && vc == 'd524) begin
                if (scanall) begin
                    scan_state_d = START_0;
                end else begin
                    scan_state_d = PACMAN_NEW; 
                end
            end else begin
                scan_state_d = START_1;
            end
        end

        PACMAN_NEW: begin
            xpos = pacman_curr[22:14] - 'd7 + scan_counter[3:0];
            ypos = pacman_curr[13:5] - 'd7 + scan_counter[7:4];

            if (rst) begin
                scan_state_d = START_0;
                scan_counter_d = 1'b0;
            end else if (scan_counter == 'd255) begin
                scan_state_d = PACMAN_OLD; 
                scan_counter_d = 1'b0;
            end else begin
                scan_state_d = PACMAN_NEW;
                scan_counter_d = scan_counter + 1'b1;
            end
        end

        PACMAN_OLD: begin
            xpos = pacman_prev[22:14] - 'd7 + scan_counter[3:0];
            ypos = pacman_prev[13:5] - 'd7 + scan_counter[7:4];

            if (rst) begin
                scan_state_d = START_0;
                scan_counter_d = 1'b0;
            end else if (scan_counter == 'd255) begin
                scan_state_d = BLINKY_NEW; 
                scan_counter_d = 1'b0;
            end else begin
                scan_state_d = PACMAN_OLD;
                scan_counter_d = scan_counter + 1'b1;
            end
        end

        BLINKY_NEW: begin
            xpos = blinky_curr[22:14] - 'd7 + scan_counter[3:0];
            ypos = blinky_curr[13:5] - 'd7 + scan_counter[7:4];

            if (rst) begin
                scan_state_d = START_0;
                scan_counter_d = 1'b0;
            end else if (scan_counter == 'd255) begin
                scan_state_d = BLINKY_OLD; 
                scan_counter_d = 1'b0;
            end else begin
                scan_state_d = BLINKY_NEW;
                scan_counter_d = scan_counter + 1'b1;
            end
        end

        BLINKY_OLD: begin
            xpos = blinky_prev[22:14] - 'd7 + scan_counter[3:0];
            ypos = blinky_prev[13:5] - 'd7 + scan_counter[7:4];

            if (rst) begin
                scan_state_d = START_0;
                scan_counter_d = 1'b0;
            end else if (scan_counter == 'd255) begin
                scan_state_d = PINKY_NEW;
                scan_counter_d = 1'b0; 
            end else begin
                scan_state_d = BLINKY_OLD;
                scan_counter_d = scan_counter + 1'b1;
            end
        end

        PINKY_NEW: begin
            xpos = pinky_curr[22:14] - 'd7 + scan_counter[3:0];
            ypos = pinky_curr[13:5] - 'd7 + scan_counter[7:4];

            if (rst) begin
                scan_state_d = START_0;
                scan_counter_d = 1'b0;
            end else if (scan_counter == 'd255) begin
                scan_state_d = PINKY_OLD; 
                scan_counter_d = 1'b0;
            end else begin
                scan_state_d = PINKY_NEW;
                scan_counter_d = scan_counter + 1'b1;
            end
        end

        PINKY_OLD: begin
            xpos = pinky_prev[22:14] - 'd7 + scan_counter[3:0];
            ypos = pinky_prev[13:5] - 'd7 + scan_counter[7:4];

            if (rst) begin
                scan_state_d = START_0;
                scan_counter_d = 1'b0;
            end else if (scan_counter == 'd255) begin
                scan_state_d = INKY_NEW; 
                scan_counter_d = 1'b0;
            end else begin
                scan_state_d = PINKY_OLD;
                scan_counter_d = scan_counter + 1'b1;
            end
        end

        INKY_NEW: begin
            xpos = inky_curr[22:14] - 'd7 + scan_counter[3:0];
            ypos = inky_curr[13:5] - 'd7 + scan_counter[7:4];

            if (rst) begin
                scan_state_d = START_0;
                scan_counter_d = 1'b0;
            end else if (scan_counter == 'd255) begin
                scan_state_d = INKY_OLD; 
                scan_counter_d = 1'b0;
            end else begin
                scan_state_d = INKY_NEW;
                scan_counter_d = scan_counter + 1'b1;
            end
        end

        INKY_OLD: begin
            xpos = inky_prev[22:14] - 'd7 + scan_counter[3:0];
            ypos = inky_prev[13:5] - 'd7 + scan_counter[7:4];

            if (rst) begin
                scan_state_d = START_0;
                scan_counter_d = 1'b0;
            end else if (scan_counter == 'd255) begin
                scan_state_d = CLYDE_NEW; 
                scan_counter_d = 1'b0;
            end else begin
                scan_state_d = INKY_OLD;
                scan_counter_d = scan_counter + 1'b1;
            end
        end

        CLYDE_NEW: begin
            xpos = clyde_curr[22:14] - 'd7 + scan_counter[3:0];
            ypos = clyde_curr[13:5] - 'd7 + scan_counter[7:4];

            if (rst) begin
                scan_state_d = START_0;
                scan_counter_d = 1'b0;
            end else if (scan_counter == 'd255) begin
                scan_state_d = CLYDE_OLD; 
                scan_counter_d = 1'b0;
            end else begin
                scan_state_d = CLYDE_NEW;
                scan_counter_d = scan_counter + 1'b1;
            end
        end

        CLYDE_OLD: begin
            xpos = clyde_prev[22:14] - 'd7 + scan_counter[3:0];
            ypos = clyde_prev[13:5] - 'd7 + scan_counter[7:4];

            if (rst) begin
                scan_state_d = START_0;
                scan_counter_d = 1'b0;
            end else if (scan_counter == 'd255) begin
                scan_state_d = MAZE_SCAN; 
                scan_counter_d = 1'b0;
            end else begin
                scan_state_d = CLYDE_OLD;
                scan_counter_d = scan_counter + 1'b1;
            end
        end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          

        MAZE_SCAN: begin        // hardcode power pellet locations
            case (scan_counter[7:6]) 
                2'b00: begin
                    xpos = 'd8 + scan_counter[2:0];
                    ypos = 'd56 + scan_counter[5:3];
                end

                2'b01: begin
                    xpos = 'd224 + scan_counter[2:0];
                    ypos = 'd56 + scan_counter[5:3];
                end

                2'b10: begin
                    xpos = 'd8 + scan_counter[2:0];
                    ypos = 'd224 + scan_counter[5:3];
                end

                2'b11: begin
                    xpos = 'd224 + scan_counter[2:0];
                    ypos = 'd224 + scan_counter[5:3];
                end
            endcase

            if (rst) begin
                scan_state_d = START_0;
                scan_counter_d = 1'b0;
            end else if (scan_counter == 'd255) begin
                scan_state_d = SCORE_SCAN; 
                scan_counter_d = 1'b0;
            end else begin
                scan_state_d = MAZE_SCAN;
                scan_counter_d = scan_counter + 1'b1;
            end
        end

        SCORE_SCAN: begin
            if (scan_counter < 448) begin
                xpos = SCORE_X_OFFSET + (scan_counter % SCORE_X_WIDTH);
                ypos = SCORE_Y_OFFSET + (scan_counter / SCORE_X_WIDTH);
            end else begin
                xpos = LIVES_X_OFFSET + ((scan_counter-'d448) % LIVES_X_WIDTH);
                ypos = LIVES_Y_OFFSET + ((scan_counter-'d448) / LIVES_X_WIDTH);
            end
            // xpos = SCORE_X_OFFSET + (scan_counter % SCORE_X_WIDTH);
            // ypos = SCORE_Y_OFFSET + (scan_counter / SCORE_X_WIDTH);

            if (rst) begin
                scan_state_d = START_0;
                scan_counter_d = 1'b0;
            end else if (scan_counter == 'd1728) begin
                scan_state_d = TEXT_SCAN; 
                scan_counter_d = 1'b0;
            end else begin
                scan_state_d = SCORE_SCAN;
                scan_counter_d = scan_counter + 1'b1;
            end
        end

        TEXT_SCAN: begin
            xpos = TEXT_X_OFFSET + (scan_counter % TEXT_X_WIDTH);
            ypos = TEXT_Y_OFFSET + (scan_counter / TEXT_X_WIDTH);

            if (rst) begin
                scan_state_d = START_0;
                scan_counter_d = 1'b0;
            end else if (scan_counter == 'd640) begin
                scan_state_d = SCAN_IDLE;
                scan_counter_d = 1'b0;
            end else begin
                scan_state_d = TEXT_SCAN;
                scan_counter_d = scan_counter + 1'b1;
            end
        end

        // LIVES_SCAN: begin
        //     xpos = LIVES_X_OFFSET + (scan_counter % LIVES_X_WIDTH);
        //     ypos = LIVES_Y_OFFSET + (scan_counter / LIVES_X_WIDTH);

        //     if (rst) begin
        //         scan_state_d = START_0;
        //         scan_counter_d = 1'b0;
        //     end else if (scan_counter == 'd1280) begin
        //         scan_state_d = SCAN_IDLE;
        //         scan_counter_d = 1'b0;
        //     end else begin
        //         scan_state_d = LIVES_SCAN;
        //         scan_counter_d = scan_counter + 1'b1;
        //     end
        // end

        SCAN_IDLE: begin
            scan_counter_d = 1'b0;

            xpos = 1'b0;
            ypos = 1'b0;

            if (rst) begin
                scan_state_d = START_0;
            end else if (hc == 'd799 && vc == 'd524) begin
                if (scanall) begin
                    scan_state_d = START_0;
                end else begin
                    scan_state_d = PACMAN_NEW; 
                end
            end else begin
                scan_state_d = SCAN_IDLE;
            end
        end

    endcase
end


// RAM ADDRESS CALCULATION
// only loads tiles 3-36 into ping-pong RAM due to space constraints 
localparam X_MAX = 240;         // horizontal pixels (480/2)
localparam Y_MAX = 320;         // vertical pixels (640/2)
localparam ADDRESS_MAX = 65535; // max RAM address

localparam SCORE_ADDR0 = 63360; // start of score area

always_comb begin
    if (ypos >= MAZE_Y_OFFSET && ypos < (MAZE_Y_HEIGHT+MAZE_Y_OFFSET)) begin
        address = xpos + (ypos-MAZE_Y_OFFSET)*X_MAX;
    end else if (ypos >= SCORE_Y_OFFSET && ypos < (SCORE_Y_HEIGHT + SCORE_Y_OFFSET) && xpos >= SCORE_X_OFFSET && xpos < (SCORE_X_WIDTH+SCORE_X_OFFSET)) begin          // score area
        address = SCORE_ADDR0 + xpos + (ypos-SCORE_Y_OFFSET)*SCORE_X_WIDTH;
    end else if (ypos >= LIVES_Y_OFFSET && ypos < (LIVES_Y_HEIGHT + LIVES_Y_OFFSET) && xpos >= LIVES_X_OFFSET && xpos < (LIVES_X_WIDTH+LIVES_X_OFFSET)) begin          // lives area
        address = SCORE_ADDR0 + 448 + xpos + (ypos-LIVES_Y_OFFSET)*LIVES_X_WIDTH;
    end else begin
        address = ADDRESS_MAX;
    end
end

endmodule
