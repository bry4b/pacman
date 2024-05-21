// TODO: FIX BUG W/ COMBINATIONALLY ASSIGNING GHOST_EATEN; MAY BE RESET BEFORE FRIGHTENED STATE ENDS

module game_controller (
    input clk,      // input 60 Hz clock
    input rst,
    input start,

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

    // character outputs
    output [22:0] pacman_outputs,
    output [22:0] blinky_outputs,
    output [22:0] pinky_outputs,
    output [22:0] inky_outputs,
    output [22:0] clyde_outputs,
    output reg ghost_anim,

    // game outputs
    output [1:0] ghosts_eaten,
    output reg [17:0] score,
    output pause

);

// Game variables
logic [1:0] revives, revives_d;
wire [17:0] score_d;
wire reset_players;
// wire pause;

// Game states
typedef enum logic [2:0] {RESET, START, PLAY, DEATH, LOSE, WIN} State;
State state, state_d;


// CHARACTERS
wire ghost_anim_d;
reg [2:0] ghost_anim_counter;
wire [2:0] ghost_anim_counter_d;

wire pellet_anim_d;
reg [3:0] pellet_anim_counter;
wire [3:0] pellet_anim_counter_d;

wire blinky_eaten; 
wire pinky_eaten;
wire inky_eaten;
wire clyde_eaten;

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
    .pacman_outputs (pacman_outputs)
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
    .tile_checks (clyde_tiles),
    .ghost_outputs (clyde_outputs)
);

initial begin
    state = RESET;
    revives = 2;
    score = 0;
end

always_comb begin
    case (state)
        RESET : begin
            revives_d = 'd2;
            reset_players = 1'b1;
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
            pause = 1'b1;
            if (start) begin
                state_d = PLAY;
            end else begin
                state_d = START;
            end
        end

        PLAY : begin
            revives_d = revives;
            reset_players = 1'b0;
            if (rst) begin
                state_d = RESET;
            end else if (   // Pacman hits a ghost and dies
                (pacman_xtile == blinky_xtile && pacman_ytile == blinky_ytile && blinky_outputs[2:1] == 2'b00) || 
                (pacman_xtile == pinky_xtile && pacman_ytile == pinky_ytile && pinky_outputs[2:1] == 2'b00) ||
                (pacman_xtile == inky_xtile && pacman_ytile == inky_ytile && inky_outputs[2:1] == 2'b00) ||
                (pacman_xtile == clyde_xtile && pacman_ytile == clyde_ytile && clyde_outputs[2:1] == 2'b00) ) begin
                state_d = DEATH;
            end else if ('b0/* all pellets eaten */) begin
                state_d = WIN;
            end else begin
                state_d = PLAY;
            end

            // GLOBAL PAUSE
            pause = blinky_outputs[2:1] == SCOR || pinky_outputs [2:1] == SCOR || inky_outputs [2:1] == SCOR || clyde_outputs [2:1] == SCOR;
        end

        DEATH : begin
            reset_players = 1'b0;
            pause = 1'b0;
            if (revives == 'b0) begin
                revives_d = revives;
                state_d = LOSE;
            end else begin
                revives_d = revives - 1'b1; // Use extra life; start again
                state_d = START;
            end
        end

        LOSE : begin
            revives_d = revives;
            reset_players = 1'b0;
            pause = 1'b1;
            if (rst) begin
                state_d = RESET;
            end else begin
                state_d = LOSE;
            end
        end
        WIN : begin
            revives_d = revives;
            reset_players = 1'b0;
            pause = 1'b1;
            if (rst) begin
                state_d = RESET;
            end else begin
                state_d = WIN;
            end
        end
    endcase
end

always @(posedge clk) begin
    state <= state_d;
    revives <= revives_d;
    score <= score_d;
end

always_comb begin
    ghosts_eaten = blinky_eaten + pinky_eaten + inky_eaten + clyde_eaten - 1'b1;
end

// ghost animation
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
    end else begin
        pellet_anim_d = pellet_anim;
    end
end

always @(posedge clk) begin
    ghost_anim_counter <= ghost_anim_counter_d;
    ghost_anim <= ghost_anim_d;
    pellet_anim_counter <= pellet_anim_counter_d;
    pellet_anim <= pellet_anim_d;
end

endmodule