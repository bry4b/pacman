module game_controller (
    input clk,      // input 60 Hz clock
    input start,
    input reset,

    input left,
    input right,
    input uturn,

    output logic [9:0] pacman_xloc,
    output logic [9:0] pacman_yloc,
    output logic [1:0] pacman_dir,
    output logic [9:0] ghosts_xloc [0:3],
    output logic [9:0] ghosts_yloc [0:3],
    output logic [1:0] ghosts_dir [0:3],
    output logic [1:0] ghosts_graphics_state [0:3]
);

    // Game variables
    logic [1:0] revives, revives_d;
    logic [13:0] score, score_d;

    // Game states
    typedef enum logic [2:0] {RESET, START, PLAY, DEATH, LOSE, WIN} State;
    State currState, nextState;

    /* GHOSTS */

    wire [24:0] blinky_outputs;
    wire [24:0] pinky_outputs;
    wire [24:0] inky_outputs;
    wire [24:0] clyde_outputs;

    game_ghost blinky(/* FILL IN */);
    game_ghost pinky();
    game_ghost inky();
    game_ghost clyde();

    // Ghost graphics states
    localparam NORMAL   = 2'b00;
    localparam FRIGHTEN = 2'b01;
    localparam SCORE    = 2'b10;
    localparam EYES     = 2'b11;

    reg ghost_animation;
    wire ghost_animation_d;
    reg [2:0] ghost_anim_counter;
    wire [2:0] ghost_anim_counter_d;

    wire pause;
    reg [1:0] ghosts_eaten;
    wire blinky_eaten; 
    wire pinky_eaten;
    wire inky_eaten;
    wire clyde_eaten;

    /* PACMAN */
    logic [6:0] pacman_curr_xtile, pacman_curr_ytile;
    logic [1:0] pacman_animation_state;
    game_pacman pacman(  
        .clk60(clk60), 
        .left(left), 
        .right(right), 
        .uturn(uturn), 
        .start(start), 
        .reset(reset), 
        .xloc(pacman_xloc),
        .yloc(pacman_yloc),
        .dir(pacman_dir),
        .curr_xtile(pacman_curr_xtile),
        .curr_ytile(pacman_curr_ytile),
        .animation_state(pacman_animation_state) 
    );

    initial begin
        currState = RESET;
        revives = 2;
        score = 0;
    end

    always_comb begin
        case (currState)
            RESET : begin
                revives_d = revives;
                if (start) begin
                    nextState = PLAY;
                end else begin
                    nextState = RESET;
                end
            end
            START : begin
                revives_d = revives;
                if (start) begin
                    nextState = PLAY;
                end else begin
                    nextState = START;
                end
            end
            PLAY : begin
                revives_d = revives;
                if (reset) begin
                    nextState = RESET;
                end else if (   // Pacman hits a ghost and dies
                    (pacman_xloc == ghosts_xloc[0] && pacman_yloc == ghosts_yloc[0] && ghosts_graphics_state[0] == NORMAL) || 
                    (pacman_xloc == ghosts_xloc[1] && pacman_yloc == ghosts_yloc[1] && ghosts_graphics_state[1] == NORMAL) ||
                    (pacman_xloc == ghosts_xloc[2] && pacman_yloc == ghosts_yloc[2] && ghosts_graphics_state[2] == NORMAL) ||
                    (pacman_xloc == ghosts_xloc[3] && pacman_yloc == ghosts_yloc[3] && ghosts_graphics_state[3] == NORMAL) ) begin
                    nextState = DEATH;
                end else if ('b0/* all pellets eaten */) begin
                    nextState = WIN;
                end else begin
                    nextState = PLAY;
                end
            end
            DEATH : begin
                if (revives == 'b0) begin
                    revives_d = revives;
                    nextState = LOSE;
                end else begin
                    revives_d = revives - 1'b1; // Use extra life; start again
                    nextState = START;
                end
            end
            LOSE : begin
                revives_d = revives;
                if (reset) begin
                    nextState = RESET;
                end else begin
                    nextState = LOSE;
                end
            end
            WIN : begin
                revives_d = revives;
                if (reset) begin
                    nextState = RESET;
                end else begin
                    nextState = WIN;
                end
            end
        endcase
    end

    always @(posedge clk) begin
        currState <= nextState;
        revives <= revives_d;
        score <= score_d;
    end

    // global pause
    localparam SCOR = 2'b10;
    always_comb begin
        ghosts_eaten = blinky_eaten + pinky_eaten + inky_eaten + clyde_eaten - 1'b1;
        pause = blinky_outputs[2:1] == SCOR || pinky_outputs [2:1] == SCOR || inky_outputs [2:1] == SCOR || clyde_outputs [2:1] == SCOR;
    end

    // ghost animation
    always_comb begin
        if (currState == PLAY && clk && ~pause) begin
            ghost_anim_counter_d = ghost_anim_counter + 1'b1;
        end else begin
            ghost_anim_counter_d = ghost_anim_counter;
        end
        if (currState == PLAY && ghost_anim_counter == 1'b0 && ~pause) begin
            ghost_animation_d = ~ghost_animation;
        end else begin
            ghost_animation_d = ghost_animation;
        end
    end

    always @(posedge clk) begin
        ghost_anim_counter <= ghost_anim_counter_d;
        ghost_animation <= ghost_animation_d;
    end

endmodule