// TODO: SCORING SYSTEM
//      done :3
module game_controller (
    input clk,      // input 60 Hz clock
    input rst,
    input start,
    input win,

    input lturn,
    input rturn,
    input uturn,

    // maze inputs
    input pacman_pellet,
    input power_pellet,
    input [1:0] pacman_tile_info [0:3],
    input [1:0] blinky_tile_info [0:3],
    input [1:0] pinky_tile_info [0:3],
    input [1:0] inky_tile_info [0:3],
    input [1:0] clyde_tile_info [0:3],

    // maze outputs
    output [11:0] pacman_tiles,
    output [11:0] blinky_tiles,
    output [11:0] pinky_tiles,
    output [11:0] inky_tiles,
    output [11:0] clyde_tiles,
    output reg pellet_anim,
    output reg flash_maze,

    // character outputs
    output [22:0] pacman_outputs,
    output [22:0] blinky_outputs,
    output [22:0] pinky_outputs,
    output [22:0] inky_outputs,
    output [22:0] clyde_outputs,
    output reg ghost_anim,
    output reg [3:0] pacman_death_frame,
    output hide_pacman,
    output reg hide_ghosts,

    // game outputs
    output [1:0] ghosts_eaten,
    output reg [2:0] state,
    output reg [17:0] score,
    output pause

);

// Game variables
logic [1:0] revives, revives_d;
wire [17:0] score_d;
wire reset_players;
// wire pause;

// Game states
localparam RESET = 3'b000;
localparam START = 3'b001;
localparam PLAY = 3'b010;
localparam DEATH = 3'b011;
localparam LOSE = 3'b100;
localparam WIN = 3'b101;
wire [2:0] state_d;

// CHARACTERS
wire ghost_anim_d;
reg [2:0] ghost_anim_counter;
wire [2:0] ghost_anim_counter_d;

wire pellet_anim_d;
reg [3:0] pellet_anim_counter;
wire [3:0] pellet_anim_counter_d;

wire flash_maze_d;
wire [3:0] pacman_death_frame_d;
reg [7:0] anim_counter;
wire [7:0] anim_counter_d;

wire blinky_eaten; 
wire pinky_eaten;
wire inky_eaten;
wire clyde_eaten;
reg blinky_eaten_prev;
reg pinky_eaten_prev;
reg inky_eaten_prev;
reg clyde_eaten_prev;

reg [1:0] ghosts_eaten_prev;
wire [4:0] ghosts_score_d;

reg [8:0] pellet_count;
wire [8:0] pellet_count_d;

wire blinky_kill;
wire pinky_kill;
wire inky_kill;
wire clyde_kill;
reg pacman_alive;
wire pacman_alive_d;
wire hide_ghosts_d;

assign pacman_outputs[0] = pacman_alive;

wire [5:0] pacman_xtile = pacman_outputs [22:14] >> 2'd3;
wire [5:0] pacman_ytile = pacman_outputs [13:5] >> 2'd3;
wire [5:0] blinky_xtile = blinky_outputs [22:14] >> 2'd3;
wire [5:0] blinky_ytile = blinky_outputs [13:5] >> 2'd3;
wire [5:0] pinky_xtile  = pinky_outputs [22:14] >> 2'd3;
wire [5:0] pinky_ytile  = pinky_outputs [13:5] >> 2'd3;
wire [5:0] inky_xtile   = inky_outputs [22:14] >> 2'd3;
wire [5:0] inky_ytile   = inky_outputs [13:5] >> 2'd3;
wire [5:0] clyde_xtile  = clyde_outputs [22:14] >> 2'd3;
wire [5:0] clyde_ytile  = clyde_outputs [13:5] >> 2'd3;

localparam SCOR = 2'b10;

game_pacman PACMAN ( 
    .clk60 (clk), 
    .rst (reset_players), 
    .start (start),
    .pause (pause),
    .left (lturn),
    .right (rturn),
    .uturn (uturn),
    .tile_info (pacman_tile_info),

    .tile_checks (pacman_tiles),
    .pacman_outputs (pacman_outputs[22:1])
);

game_ghost BLINKY (
    .clk (clk),
    .rst (reset_players),
    .start (start),
    .pause (pause),
    .personality (2'b00),
    .pacman_inputs (pacman_outputs [22:3]),
    .power_pellet (power_pellet),
    .tile_info (blinky_tile_info),
    .blinky_pos (1'b0),

    .eaten (blinky_eaten),
    .kill (blinky_kill),
    .tile_checks (blinky_tiles),
    .ghost_outputs (blinky_outputs)
);

game_ghost PINKY ( 
    .clk (clk),
    .rst (reset_players),
    .start (start),
    .pause (pause),
    .personality (2'b01),
    .pacman_inputs (pacman_outputs [22:3]),
    .power_pellet (power_pellet),
    .tile_info (pinky_tile_info), 
    .blinky_pos (1'b0),

    .eaten (pinky_eaten),
    .kill (pinky_kill),
    .tile_checks (pinky_tiles),
    .ghost_outputs (pinky_outputs)
);
    
game_ghost INKY ( 
    .clk (clk),
    .rst (reset_players),
    .start (start),
    .pause (pause),
    .personality (2'b10),
    .pacman_inputs (pacman_outputs [22:3]),
    .power_pellet (power_pellet),
    .tile_info (inky_tile_info), 
    .blinky_pos (blinky_outputs [22:5]), 

    .eaten (inky_eaten),
    .kill (inky_kill),
    .tile_checks (inky_tiles),
    .ghost_outputs (inky_outputs)
);

game_ghost CLYDE (
    .clk (clk),
    .rst (reset_players),
    .start (start),
    .pause (pause),
    .personality (2'b11),
    .pacman_inputs (pacman_outputs [22:3]),
    .power_pellet (power_pellet),
    .tile_info (clyde_tile_info), 
    .blinky_pos (1'b0),

    .eaten (clyde_eaten),
    .kill (clyde_kill),
    .tile_checks (clyde_tiles),
    .ghost_outputs (clyde_outputs)
);

initial begin
    state = RESET;
    revives = 2;
    score = 0;
end

// GAME STATE MACHINE
always @(posedge clk) begin
    state <= state_d;
    revives <= revives_d;
    
    anim_counter <= anim_counter_d;
    pacman_death_frame <= pacman_death_frame_d;
    flash_maze <= flash_maze_d;
    hide_ghosts <= hide_ghosts_d;
    pacman_alive <= pacman_alive_d;
end

always_comb begin
    pacman_alive_d = (state == DEATH || state == LOSE) ? 1'b0 : 1'b1;

    case (state)
        RESET : begin
            revives_d = 'd2;
            reset_players = 1'b1;
            anim_counter_d = 1'b0;
            pacman_death_frame_d = 'd12;
            flash_maze_d = 1'b0;
            pause = 1'b1;

            if (start) begin
                state_d = PLAY;
            end else begin
                state_d = RESET;
            end
        end

        START : begin
            revives_d = revives;
            reset_players = 1'b1;
            anim_counter_d = 1'b0;
            pacman_death_frame_d = 'd12;
            flash_maze_d = 1'b0;
            pause = 1'b1;

            if (rst) begin
                state_d = RESET;
            end else if (start) begin
                state_d = PLAY;
            end else begin
                state_d = START;
            end
        end

        PLAY : begin
            revives_d = revives;
            reset_players = 1'b0;
            anim_counter_d = 1'b0;
            pacman_death_frame_d = 'd12;
            flash_maze_d = 1'b0;

            if (rst) begin
                state_d = RESET;
            end else if (blinky_kill || pinky_kill || inky_kill || clyde_kill) begin
                state_d = DEATH;
            end else if (/*pellet_count == 'd278*/ win) begin
                state_d = WIN;
            end else begin
                state_d = PLAY;
            end

            // GLOBAL PAUSE
            pause = blinky_outputs[2:1] == SCOR || pinky_outputs [2:1] == SCOR || inky_outputs [2:1] == SCOR || clyde_outputs [2:1] == SCOR;
        end

        DEATH : begin
            flash_maze_d = 1'b0;
            pause = 1'b1;

            if (rst) begin
                reset_players = 1'b1;
                anim_counter_d = 1'b0;
                pacman_death_frame_d = 'd11;
                revives_d = 'd2;
                state_d = RESET;
            end else if (pacman_death_frame == 'd11 && anim_counter == 'd15) begin
                anim_counter_d = 1'b0;
                pacman_death_frame_d = 'd11;
                if (revives > 0) begin
                    reset_players = 1'b1;
                    revives_d = revives - 1'b1;
                    state_d = START;
                end else begin
                    reset_players = 1'b0;
                    revives_d = revives;
                    state_d = LOSE;
                end 
            end else if (pacman_death_frame != 'd11 && anim_counter == 'd9) begin
                reset_players = 1'b0;
                anim_counter_d = 1'b0;
                pacman_death_frame_d = pacman_death_frame + 1'b1;
                revives_d = revives;
                state_d = DEATH;
            end else begin 
                reset_players = 1'b0;
                anim_counter_d = anim_counter + 1'b1;
                pacman_death_frame_d = pacman_death_frame;
                revives_d = revives;
                state_d = DEATH;
            end
        end

        LOSE : begin
            revives_d = revives;
            reset_players = 1'b0;
            anim_counter_d = 1'b0;
            pacman_death_frame_d = 'd11;
            flash_maze_d = 1'b0;
            pause = 1'b1;


            if (rst) begin
                state_d = RESET;
            end else begin
                state_d = LOSE;
            end
        end

        WIN : begin
            revives_d = revives;
            pacman_death_frame_d = 'd11;
            pause = 1'b1;

            if (rst) begin
                reset_players = 1'b0;
                anim_counter_d = 1'b0;
                flash_maze_d = 1'b0;
                state_d = RESET;
            end else if (anim_counter == 'd175) begin
                reset_players = 1'b0;
                anim_counter_d = 1'b0;
                flash_maze_d = 1'b0;
                state_d = START;
            end else begin
                reset_players = 1'b0;
                anim_counter_d = anim_counter + 1'b1;
                if (anim_counter > 'd32 && anim_counter % 'd16 == 0) begin
                    flash_maze_d = ~flash_maze;
                end else begin
                    flash_maze_d = flash_maze;
                end
                state_d = WIN;
            end
        end

        default: begin
            revives_d = 'd2;
            reset_players = 1'b0;
            anim_counter_d = 1'b0;
            pacman_death_frame_d = 'd12;
            flash_maze_d = 1'b0;
            pause = 1'b1;
            state_d = RESET;
        end
    endcase
end

always_comb begin
    if (state == DEATH) begin
        if (pacman_death_frame < 'd12) begin
            hide_ghosts_d = 1'b1;
        end else begin
            hide_ghosts_d = 1'b0;
        end
    end else if (state == WIN || state == LOSE) begin
        hide_ghosts_d = 1'b1;
    end else begin
        hide_ghosts_d = 1'b0;
    end
end

// GHOST EATING & SCORING
always @(posedge clk) begin
    blinky_eaten_prev <= blinky_eaten;
    pinky_eaten_prev <= pinky_eaten;
    inky_eaten_prev <= inky_eaten;
    clyde_eaten_prev <= clyde_eaten;
    ghosts_eaten_prev <= ghosts_eaten;
    score <= score_d;
    pellet_count <= pellet_count_d;
end

always_comb begin
    ghosts_eaten = blinky_eaten + pinky_eaten + inky_eaten + clyde_eaten - 1'b1;
    if ( {blinky_eaten_prev, blinky_eaten} == 2'b01 || {pinky_eaten_prev, pinky_eaten} == 2'b01 || {inky_eaten_prev, inky_eaten} == 2'b01 || {clyde_eaten_prev, clyde_eaten} == 2'b01 ) begin
        case (ghosts_eaten - ghosts_eaten_prev) 
            2'd1: ghosts_score_d = (2 << ghosts_eaten);
            2'd2: ghosts_score_d = (2 << ghosts_eaten) + (2 << (ghosts_eaten-1));
            2'd3: ghosts_score_d = (2 << ghosts_eaten) + (2 << (ghosts_eaten-1)) + (2 << (ghosts_eaten-2));
            2'd0: ghosts_score_d = (2 << ghosts_eaten) + (2 << (ghosts_eaten-1)) + (2 << (ghosts_eaten-2)) + (2 << (ghosts_eaten-3));
        endcase
    end else begin
        ghosts_score_d = 0;
    end

    if (rst) begin
        score_d = 0;
        pellet_count_d = 0;
    end else if (power_pellet && pacman_pellet) begin
        score_d = score + 'd5 + ghosts_score_d*10;
        pellet_count_d = pellet_count + 1'b1;
    end else if (pacman_pellet) begin
        score_d = score + 'd1 + ghosts_score_d*10;
        pellet_count_d = pellet_count + 1'b1;
    end else begin
        score_d = score + ghosts_score_d*10;
        pellet_count_d = pellet_count;
    end

    hide_pacman = (blinky_eaten || pinky_eaten || inky_eaten || clyde_eaten) && pause;
end

// GHOST & PELLET ANIMATION
always @(posedge clk) begin
    ghost_anim_counter <= ghost_anim_counter_d;
    ghost_anim <= ghost_anim_d;
    pellet_anim_counter <= pellet_anim_counter_d;
    pellet_anim <= pellet_anim_d;
end

always_comb begin
    if (clk && ~pause) begin
        ghost_anim_counter_d = ghost_anim_counter + 1'b1;
        pellet_anim_counter_d = pellet_anim_counter + 1'b1;
    end else begin
        ghost_anim_counter_d = ghost_anim_counter;
        pellet_anim_counter_d = pellet_anim_counter;
    end

    if (ghost_anim_counter == 1'b0 && ~pause) begin
        ghost_anim_d = ~ghost_anim;
    end else begin
        ghost_anim_d = ghost_anim;
    end

    if (pellet_anim_counter == 1'b0 && ~pause) begin
        pellet_anim_d = ~pellet_anim;
    end else if (~pause) begin
        pellet_anim_d = pellet_anim;
    end else begin
        pellet_anim_d = 1'b1;
    end
end

endmodule