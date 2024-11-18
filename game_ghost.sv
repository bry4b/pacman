//TODO: 
// write code to determine next location, direction changes, etc. (so like the actual outputs of the module LOL)
//      this is done for ALL GHOSTS!!!! rahhhh
// write scatter state targeting
//      this is done
// write timers for states
//      this is done
// write frightened state random turning
//      this is done, uses 16-bit LFSR w/ a different seed for each ghost, x^15 + x + 1
// maybe create new state for exiting ghost house?
//      this is done: STATE_EXTGH hardcodes exit lmao
// implement STATE_SCORE
//      WHY IS THIS SO HARD
//      mostly working now, with global pause
//      bug may occur when eating ghost very close to frighten timer ending, ends up showing 1600 as score even if not supposed to, not sure why bc the pause thing should prevent this
// implement ghost animation
//      i did it yay it's in the top module 
// move pacman death check into this module

module game_ghost (
    input clk, 
    input rst,
    input start,
    input pause,

    input [1:0] personality,

    // input [8:0] pacman_xloc,
    // input [8:0] pacman_yloc, 
    // input [1:0] pacman_dir,
    input [19:0] pacman_inputs,

    input power_pellet,             // HIGH when a power pellet gets eaten
    input [1:0] tile_info [0:3], 

    // input [8:0] blinky_xloc,        // only for inky :/
    // input [8:0] blinky_yloc,        // only for inky :/
    input [17:0] blinky_pos, 

    input any_frightened,
    output eaten, 
    output kill,

    // output reg [6:0] xtile_next,
    // output reg [6:0] ytile_next,
    output [11:0] tile_checks,

    // output reg [8:0] xloc,
    // output reg [8:0] yloc,

    // output reg [1:0] dir,
    // output reg [1:0] mode,
    // output reg flash         // controls flashing when frightened mode is ending
    output [22:0] ghost_outputs
);

// input unpacking
wire [5:0] pacman_xtile = pacman_inputs [19:11] >> 2'd3;
wire [5:0] pacman_ytile = (pacman_inputs [10:2] >> 2'd3) - 2'd3; 
wire [1:0] pacman_dir = pacman_inputs [1:0];

wire [8:0] blinky_xloc = blinky_pos [17:9];
wire [8:0] blinky_yloc = blinky_pos [8:0];

// output packing
wire [5:0] xtile_next; 
wire [5:0] ytile_next;
assign tile_checks = {xtile_next, ytile_next};

wire [8:0] xloc;
wire [8:0] yloc;
wire [1:0] dir;
wire [1:0] mode;
wire flash;          
assign ghost_outputs = {xloc, yloc, dir, mode, flash};

wire [8:0] xloc_d;
wire [8:0] yloc_d;
wire [1:0] dir_d;
wire [1:0] mode_d;
wire flash_d;

wire eaten_d;

// ghost personality definitions
localparam BLINKY   = 2'b00;
localparam PINKY    = 2'b01;
localparam INKY     = 2'b10;
localparam CLYDE    = 2'b11;

// ghost states
localparam STATE_START = 3'b000;
localparam STATE_CHASE = 3'b001;
localparam STATE_SCTTR = 3'b010;
localparam STATE_FRGHT = 3'b011;
localparam STATE_SCORE = 3'b100;
localparam STATE_RSPWN = 3'b101;
localparam STATE_EXTGH = 3'b110;
localparam STATE_PAUSE = 3'b111;        // pauses when other ghosts are eaten unless when respawning

// ghost directions
localparam RT   = 2'b00;
localparam UP   = 2'b01;
localparam DN   = 2'b10;
localparam LT   = 2'b11;

// state timers 
localparam CHASE_TIME = 'd20 * 'd60;    // chase time
localparam SCTTR_TIME = 'd7 * 'd60;     // scatter time
localparam FRGHT_TIME = 'd10 * 'd60;    // frightened time

// ghost modes
localparam NORM = 2'b00;
localparam FRGT = 2'b01;
localparam SCOR = 2'b10;
localparam DEAD = 2'b11;

// wall types
localparam WALL = 2'b00;    // wall (not walkable)
localparam PTNP = 2'b01;    // path, no pellet
localparam PTYP = 2'b10;    // path, yes pellet
localparam PTGH = 2'b11;    // path, ghost house

// maze constants
localparam YOFFSET = 2'd3;  // Y offset for tiles = 3
localparam XTILES = 6'd30;  // horizontal width in tiles 
localparam YTILES = 6'd33;  // vertical height in tiles

// state registers
reg [2:0] state;
wire [2:0] state_d;
reg [2:0] state_prev;
reg [2:0] state_cont;
reg [2:0] state_exit;

// timer registers
reg [10:0] timer_reg;
wire [10:0] timer_reg_d;
reg [9:0] timer_frt;
wire [9:0] timer_frt_d;

// location information
wire [8:0] start_xloc; 
wire [8:0] start_yloc;

reg [5:0] xtile;
reg [5:0] ytile;

wire [5:0] xtile_d = xloc_d >> 2'd3;   
wire [5:0] ytile_d = (yloc_d >> 2'd3) - YOFFSET;

wire [1:0] movespeed; 

// targeting software
wire [5:0] target_xtile;
wire [5:0] target_ytile;

wire [12:0] distance_rt;
wire [12:0] distance_up; 
wire [12:0] distance_dn;
wire [12:0] distance_lt;

reg [1:0] dir_exit;         // direction that ghost should exit current tile from
reg [1:0] dir_plan;         // direction that ghost should exit next tile from
reg [1:0] dir_prev;         // direction that ghost exited last tile from

// frightened state PRNG 
reg [15:0] lfsr_state;       
reg [1:0] rand_dir;
assign rand_dir = lfsr_state[1:0];

// targeting for inky
wire [5:0] blinky_xtile = blinky_xloc >> 2'd3;  
wire [5:0] blinky_ytile = (blinky_yloc >> 2'd3) - YOFFSET;

initial begin
    state = STATE_START;
    state_prev = STATE_START;
    dir_exit = RT;
    dir_prev = RT;
end

// UPDATE STATE, DIRECTION, SPRITE MODE, TIMERS
always @(posedge clk) begin
    state <= state_d;
    dir <= dir_d;
    mode <= mode_d;

    timer_reg <= timer_reg_d;
    timer_frt <= timer_frt_d;
    flash <= flash_d;
    eaten <= eaten_d;

    if ( (state_d != state) && (state == STATE_SCTTR || state == STATE_CHASE || state == STATE_RSPWN) ) begin
        state_prev <= state;
    end else if (( state == STATE_START && start) || rst) begin
        state_prev <= STATE_START;
    end
    if ( (state_d != state) && (state == STATE_SCTTR || state == STATE_CHASE) )begin
        state_exit <= state;
    end
     

    if (state_d == STATE_PAUSE && state != STATE_PAUSE && state != STATE_RSPWN) begin
        state_cont <= state;
    end 
end

// STATE TRANSITIONS, DIRECTION CHANGES, SPRITE DISPLAY MODES
always_comb begin
    case (state)
        STATE_START: begin
            if (start) begin
                if (xtile > 'd11 && xtile < 'd18 && ytile > 'd14 && ytile < 'd18) begin
                    state_d = STATE_EXTGH;
                end else begin
                    state_d = STATE_SCTTR;
                end
            end else if (pause) begin
                state_d = STATE_PAUSE;
            end else if (timer_reg_d > 'd300) begin
                state_d = STATE_EXTGH;
            end else begin
                state_d = STATE_START;
            end
            
            // timer_reg_d = 1'b0;
            if (state_prev == STATE_RSPWN) begin
                timer_reg_d = timer_reg + 1'b1;
            end else begin
                timer_reg_d = 1'b0;
            end

            case (personality)
                BLINKY: dir_d = RT;
                PINKY:  dir_d = RT;
                INKY:   dir_d = UP;
                CLYDE:  dir_d = LT;
            endcase

            mode_d = NORM;
            flash_d = 1'b0;
            kill = 1'b0;
        end

        STATE_CHASE: begin
            if (pacman_xtile == xtile && pacman_ytile == ytile) begin
                state_d = STATE_PAUSE;
                timer_reg_d = 1'b0;
                dir_d = dir;
                kill = 1'b1;
            end else if (power_pellet) begin
                state_d = STATE_FRGHT;
                timer_reg_d = timer_reg;
                dir_d = ~dir;
                kill = 1'b0;
            end else if (rst) begin
                state_d = STATE_START;
                timer_reg_d = 1'b0;
                dir_d = dir;
                kill = 1'b0;
            end else if (pause) begin
                state_d = STATE_PAUSE;
                timer_reg_d = timer_reg;
                dir_d = dir;
                kill = 1'b0;
            end else if (timer_reg > CHASE_TIME) begin
                state_d = STATE_SCTTR;
                timer_reg_d = 1'b0;
                dir_d = ~dir;
                kill = 1'b0;
            end else begin
                state_d = STATE_CHASE;
                timer_reg_d = timer_reg + 1'b1;
                kill = 1'b0;
                case (dir_exit) 
                    RT, LT: begin
                        if (yloc_d[2:0] == 'd3) begin
                            dir_d = dir_exit;
                        end else begin
                            dir_d = dir;
                        end
                    end
                    UP, DN: begin
                        if (xloc_d[2:0] == 'd3) begin
                            dir_d = dir_exit;
                        end else begin
                            dir_d = dir;
                        end
                    end
                endcase
            end

            mode_d = NORM;
            flash_d = 1'b0;
        end

        STATE_SCTTR: begin
            if (pacman_xtile == xtile && pacman_ytile == ytile) begin
                state_d = STATE_PAUSE;
                timer_reg_d = 1'b0;
                dir_d = dir;
                kill = 1'b1;
            end else if (power_pellet) begin
                state_d = STATE_FRGHT;
                timer_reg_d = timer_reg;
                dir_d = ~dir;
                kill = 1'b0;
            end else if (rst) begin
                state_d = STATE_START;
                timer_reg_d = 1'b0;
                dir_d = dir;
                kill = 1'b0;
            end else if (pause) begin
                state_d = STATE_PAUSE;
                timer_reg_d = timer_reg;
                dir_d = dir;
                kill = 1'b0;
            end else if (timer_reg > SCTTR_TIME) begin
                state_d = STATE_CHASE;
                timer_reg_d = 1'b0;
                dir_d = ~dir;
                kill = 1'b0;
            end else begin
                state_d = STATE_SCTTR;
                timer_reg_d = timer_reg + 1'b1;
                kill = 1'b0;
                case (dir_exit) 
                    RT, LT: begin
                        if (yloc_d[2:0] == 'd3) begin
                            dir_d = dir_exit;
                        end else begin
                            dir_d = dir;
                        end
                    end
                    UP, DN: begin
                        if (xloc_d[2:0] == 'd3) begin
                            dir_d = dir_exit;
                        end else begin
                            dir_d = dir;
                        end
                    end
                endcase
            end

            mode_d = NORM;
            flash_d = 1'b0;
        end

        STATE_FRGHT: begin
            if (pacman_xtile == xtile && pacman_ytile == ytile) begin
                state_d = STATE_SCORE;
                mode_d = SCOR;
                // state_d = STATE_RSPWN;
                // mode_d = DEAD;

                timer_reg_d = 1'b0;
                // timer_frt_d = 1'b0;
                dir_d = dir;
                flash_d = 1'b0;
            end else if (rst) begin
                state_d = STATE_START;
                timer_reg_d = 1'b0;
                // timer_frt_d = 1'b0;
                dir_d = dir;
                mode_d = NORM;
                flash_d = 1'b0;
            end else if (pause) begin
                state_d = STATE_PAUSE;
                timer_reg_d = timer_reg;
                dir_d = dir;
                mode_d = mode;
                flash_d = flash;
            end else if (timer_frt > FRGHT_TIME) begin
                if (state_prev == STATE_SCTTR) begin
                    state_d = STATE_SCTTR;
                    timer_reg_d = timer_reg + 1'b1;
                    // timer_frt_d = 1'b0;
                    dir_d = dir;
                end else begin
                    state_d = STATE_CHASE;
                    timer_reg_d = timer_reg + 1'b1;
                    // timer_frt_d = 1'b0;
                    dir_d = dir;
                end

                mode_d = NORM;
                flash_d = 1'b0;
            end else begin
                state_d = STATE_FRGHT;
                timer_reg_d = timer_reg;

                case (dir_exit) 
                    RT, LT: begin
                        if (yloc_d[2:0] == 'd3) begin
                            dir_d = dir_exit;
                        end else begin
                            dir_d = dir;
                        end
                    end
                    UP, DN: begin
                        if (xloc_d[2:0] == 'd3) begin
                            dir_d = dir_exit;
                        end else begin
                            dir_d = dir;
                        end
                    end
                endcase

                if (timer_frt > FRGHT_TIME - 'd120) begin
                    if ((FRGHT_TIME - timer_frt) % 15 == 0) begin
                        flash_d = ~flash;
                    end else begin
                        flash_d = flash;
                    end 
                end else begin
                    flash_d = 1'b0;
                end

                mode_d = FRGT;
            end

            kill = 1'b0;
        end
        
        STATE_SCORE: begin
            if (timer_reg > 'd60) begin
                state_d = STATE_RSPWN;
                timer_reg_d = 1'b0;
            end else if (rst) begin
                state_d = STATE_START;
                timer_reg_d = 1'b0;
            end else begin
                state_d = STATE_SCORE;
                timer_reg_d = timer_reg + 1'b1;
            end

            dir_d = dir;
            mode_d = SCOR;
            flash_d = 1'b0;
            kill = 1'b0;
        end

        STATE_RSPWN: begin
            if (rst || (xtile == 'd14 && ytile == 'd16) )begin
                state_d = STATE_START;
                mode_d = DEAD;
            end else begin
                state_d = STATE_RSPWN;
                mode_d = DEAD;
            end

            case (dir_exit) 
                RT, LT: begin
                    if (yloc_d[2:0] == 'd3) begin
                        dir_d = dir_exit;
                    end else begin
                        dir_d = dir;
                    end
                end
                UP, DN: begin
                    if (xloc_d[2:0] == 'd3) begin
                        dir_d = dir_exit;
                    end else begin
                        dir_d = dir;
                    end
                end
            endcase

            timer_reg_d = 1'b0;
            flash_d = 1'b0;
            kill = 1'b0;
        end

        STATE_EXTGH: begin
            if (pacman_xtile == xtile && pacman_ytile == ytile) begin
                state_d = STATE_PAUSE;
                timer_reg_d = 1'b0;
                dir_d = dir;
                kill = 1'b1;
            end else if (rst) begin
                state_d = STATE_START;
                dir_d = dir;
                kill = 1'b0;
            end else if (pause) begin
                state_d = STATE_PAUSE;
                dir_d = dir;
                kill = 1'b0;
            end else if (xtile > 'd11 && xtile < 'd18 && ytile > 'd14 && ytile < 'd18) begin
                state_d = STATE_EXTGH;
                kill = 1'b0;
                case (dir_exit) 
                    RT, LT: begin
                        if (yloc_d[2:0] == 'd3) begin
                            dir_d = dir_exit;
                        end else begin
                            dir_d = dir;
                        end
                    end
                    UP, DN: begin
                        if (xloc_d[2:0] == 'd3) begin
                            dir_d = dir_exit;
                        end else begin
                            dir_d = dir;
                        end
                    end
                endcase
            end else if (state_prev == STATE_START) begin
                state_d = STATE_SCTTR;
                dir_d = dir;
                kill = 1'b0;
            end else begin
                state_d = state_exit;
                dir_d = dir;
                kill = 1'b0;
            end

            timer_reg_d = 1'b0;
            mode_d = NORM;
            flash_d = 1'b0;
        end
        
        STATE_PAUSE: begin
            if (rst) begin
                state_d = STATE_START;
                timer_reg_d = 1'b0;
            end else if (pause) begin
                state_d = STATE_PAUSE;
                timer_reg_d = timer_reg;
            end else begin
                state_d = state_cont;
                timer_reg_d = timer_reg + 1'b1;
            end

            case (dir_exit) 
                RT, LT: begin
                    if (yloc_d[2:0] == 'd3) begin
                        dir_d = dir_exit;
                    end else begin
                        dir_d = dir;
                    end
                end
                UP, DN: begin
                    if (xloc_d[2:0] == 'd3) begin
                        dir_d = dir_exit;
                    end else begin
                        dir_d = dir;
                    end
                end
            endcase

            mode_d = mode;
            flash_d = flash;
            kill = 1'b0;
        end

        default: begin
            state_d = STATE_START;
            timer_reg_d = 1'b0;
            dir_d = RT;
            mode_d = NORM;
            flash_d = 1'b0;
            kill = 1'b0;
        end

    endcase
end

// FRIGHTENED TIMER & EATEN STATUS
always_comb begin
    if (power_pellet || rst) begin
        eaten_d = 1'b0;
        timer_frt_d = 1'b1;
    end else if (state == STATE_PAUSE || state == STATE_SCORE) begin
        eaten_d = eaten;
        timer_frt_d = timer_frt;
    end else if (timer_frt > 'd0 && timer_frt <= FRGHT_TIME) begin
        if ( (pacman_xtile == xtile && pacman_ytile == ytile) || eaten ) begin
            eaten_d = 1'b1;
        end else begin
            eaten_d = eaten;
        end
        timer_frt_d = timer_frt + 1'b1;
    end else if (~any_frightened) begin
        eaten_d = 1'b0;
        timer_frt_d = 1'b0;
    end else begin
        eaten_d = eaten;
        timer_frt_d = 1'b0;
    end
end

// UPDATE TILE LOCATION AND EXIT DIRECTION
always @(posedge clk) begin
    xloc <= xloc_d;
    yloc <= yloc_d;
    xtile <= xtile_d;
    ytile <= ytile_d;

    if (state == STATE_START) begin
        if (state_prev == STATE_RSPWN) begin
            dir_exit <= UP;
        end else begin
            case (personality)
                BLINKY: dir_exit <= RT;
                PINKY: dir_exit <= RT;
                INKY: dir_exit <= UP;
                CLYDE: dir_exit <= LT;
            endcase
        end
    end else begin
        if ( (state_d == STATE_CHASE && state == STATE_SCTTR) || (state_d == STATE_SCTTR && state == STATE_CHASE) || (state_d == STATE_FRGHT && state == STATE_CHASE) || (state_d == STATE_FRGHT && state == STATE_SCTTR) ) begin
            dir_exit <= ~dir_prev;
        end else if (xtile != xtile_d || ytile != ytile_d) begin
            dir_prev <= dir_exit;
            dir_exit <= dir_plan;
        end
    end
end

// DETERMINE NEXT TILE TO CHECK FOR WALLS
always_comb begin
    if (state == STATE_START) begin
        xtile_next = xtile; 
        ytile_next = ytile;
    end else begin
        case (dir_exit)
            RT: begin
                xtile_next = xtile + 1'b1;
                ytile_next = ytile;
            end

            UP: begin
                xtile_next = xtile;
                ytile_next = ytile - 1'b1;
            end

            DN: begin
                xtile_next = xtile;
                ytile_next = ytile + 1'b1;
            end

            LT: begin
                xtile_next = xtile - 1'b1;
                ytile_next = ytile;
            end
        endcase
    end
end

// PLAN NEXT DIRECTION
always_comb begin
    if (state == STATE_EXTGH) begin // hardcode exit ghost house
        if (xtile < 'd14) begin
            dir_plan = RT;
        end else if (xtile > 15) begin
            dir_plan = LT;
        end else begin
            dir_plan = UP;
        end
        
        distance_rt = 'd1989;
        distance_up = 'd1989;
        distance_dn = 'd1989;
        distance_lt = 'd1989;

    end else if (state == STATE_FRGHT) begin
        if (tile_info[rand_dir] != WALL && tile_info[rand_dir] != PTGH && dir_exit != ~rand_dir) begin
            dir_plan = rand_dir;
        end else if (tile_info[UP] != WALL && tile_info[UP] != PTGH && dir_exit != ~UP) begin
            dir_plan = UP;
        end else if (tile_info[LT] != WALL && tile_info[LT] != PTGH && dir_exit != ~LT) begin
            dir_plan = LT;
        end else if (tile_info[DN] != WALL && tile_info[DN] != PTGH && dir_exit != ~DN) begin
            dir_plan = DN;
        end else begin
            dir_plan = RT;
        end

        distance_rt = 'd1989;
        distance_up = 'd1989;
        distance_dn = 'd1989;
        distance_lt = 'd1989;

    end else begin // if (state == STATE_CHASE || state == STATE_SCTTR || state == STATE_RSPWN) 
        if (state == STATE_RSPWN) begin
            if (tile_info[RT] != WALL && dir_exit != ~RT) begin
                distance_rt = (target_xtile-(xtile_next+1'b1))*(target_xtile-(xtile_next+1'b1)) + (target_ytile-ytile_next)*(target_ytile-ytile_next);
            end else begin
                distance_rt = 'd1989;
            end 
            if (tile_info[UP] != WALL && dir_exit != ~UP) begin
                distance_up = (target_xtile-xtile_next)*(target_xtile-xtile_next) + (target_ytile-(ytile_next-1'b1))*(target_ytile-(ytile_next-1'b1));
            end else begin
                distance_up = 'd1989;
            end
            if (tile_info[DN] != WALL && dir_exit != ~DN) begin
                distance_dn = (target_xtile-xtile_next)*(target_xtile-xtile_next) + (target_ytile-(ytile_next+1'b1))*(target_ytile-(ytile_next+1'b1));
            end else begin
                distance_dn = 'd1989;
            end
            if (tile_info[LT] != WALL && dir_exit != ~LT) begin
                distance_lt = (target_xtile-(xtile_next-1'b1))*(target_xtile-(xtile_next-1'b1)) + (target_ytile-ytile_next)*(target_ytile-ytile_next);
            end else begin
                distance_lt = 'd1989;
            end
        end else begin
            if (tile_info[RT] != WALL && dir_exit != ~RT && (tile_info[0] != PTGH || (xtile > 11 && xtile < 18 && ytile > 14 && ytile < 18)) ) begin
                distance_rt = (target_xtile-(xtile_next+1'b1))*(target_xtile-(xtile_next+1'b1)) + (target_ytile-ytile_next)*(target_ytile-ytile_next);
            end else begin
                distance_rt = 'd1989;
            end 
            if (tile_info[UP] != WALL && dir_exit != ~UP && (tile_info[1] != PTGH || (xtile > 11 && xtile < 18 && ytile > 14 && ytile < 18)) && !( (xtile_next == 13 && ytile_next == 13) || (xtile_next == 16 && ytile_next == 13) || (xtile_next == 13 && ytile_next == 25) || (xtile_next == 16 && ytile_next == 25) ) ) begin
                distance_up = (target_xtile-xtile_next)*(target_xtile-xtile_next) + (target_ytile-(ytile_next-1'b1))*(target_ytile-(ytile_next-1'b1));
            end else begin
                distance_up = 'd1989;
            end
            if (tile_info[DN] != WALL && dir_exit != ~DN && (tile_info[2] != PTGH || (xtile > 11 && xtile < 18 && ytile > 14 && ytile < 18)) ) begin
                distance_dn = (target_xtile-xtile_next)*(target_xtile-xtile_next) + (target_ytile-(ytile_next+1'b1))*(target_ytile-(ytile_next+1'b1));
            end else begin
                distance_dn = 'd1989;
            end
            if (tile_info[LT] != WALL && dir_exit != ~LT && (tile_info[3] != PTGH || (xtile > 11 && xtile < 18 && ytile > 14 && ytile < 18)) ) begin
                distance_lt = (target_xtile-(xtile_next-1'b1))*(target_xtile-(xtile_next-1'b1)) + (target_ytile-ytile_next)*(target_ytile-ytile_next);
            end else begin
                distance_lt = 'd1989;
            end
        end

        if (distance_up <= distance_rt && distance_up <= distance_dn && distance_up <= distance_lt) begin
            dir_plan = UP;
        end else if (distance_lt <= distance_rt && distance_lt <= distance_up && distance_lt <= distance_dn) begin
            dir_plan = LT; 
        end else if (distance_dn <= distance_rt && distance_dn <= distance_up && distance_dn <= distance_lt) begin
            dir_plan = DN;
        end else begin
            dir_plan = RT;
        end
    end
end

// TARGETING SOFTWARE © 
always_comb begin
    if (state == STATE_RSPWN) begin
        target_xtile = 'd14;
        target_ytile = 'd16;
    end else if (state == STATE_SCTTR) begin
        case (personality)
            BLINKY: begin    
                target_xtile = 'd29;
                target_ytile = 'd0;
            end

            PINKY: begin    
                target_xtile = 'd0;
                target_ytile = 'd0;
            end

            INKY: begin    
                target_xtile = 'd29;
                target_ytile = 'd32;
            end

            CLYDE: begin   
                target_xtile = 'd0;
                target_ytile = 'd32;
            end
        endcase
    end else begin // if (state == STATE_CHASE) 
        case (personality)
            BLINKY: begin    
                target_xtile = pacman_xtile;
                target_ytile = pacman_ytile;
            end

            PINKY: begin    
                case (pacman_dir) 
                    RT: begin
                        if (pacman_xtile < XTILES - 3'd4) begin
                            target_xtile = pacman_xtile + 3'd4;
                        end else begin
                            target_xtile = XTILES-1'b1;
                        end
                        target_ytile = pacman_ytile;
                    end
                    UP: begin
                        target_xtile = pacman_xtile;
                        if (pacman_ytile > 3'd4) begin
                            target_ytile = pacman_ytile - 3'd4;
                        end else begin
                            target_ytile = 1'b0;
                        end
                    end
                    DN: begin
                        target_xtile = pacman_xtile;
                        if (pacman_ytile < YTILES - 3'd4) begin
                            target_ytile = pacman_ytile + 3'd4;
                        end else begin
                            target_ytile = YTILES-1'b1;
                        end 
                    end
                    LT: begin
                        if (pacman_xtile > 3'd4) begin
                            target_xtile = pacman_xtile - 3'd4;
                        end else begin
                            target_xtile = 1'b0;
                        end 
                        target_ytile = pacman_ytile;
                    end
                endcase
            end

            INKY: begin
                case (pacman_dir) 
                    RT: begin
                        if (pacman_xtile+2'd2 + pacman_xtile+2'd2 - blinky_xtile >= XTILES) begin
                            target_xtile = XTILES-1'b1;
                        end else if (pacman_xtile+2'd2 + pacman_xtile+2'd2 - blinky_xtile < 0) begin
                            target_xtile = 1'b0;
                        end else begin
                            target_xtile = pacman_xtile+2'd2 + pacman_xtile+2'd2 - blinky_xtile;
                        end
                        if (pacman_ytile + pacman_ytile-blinky_ytile >= YTILES) begin
                            target_ytile = YTILES-1'b1;
                        end else if (pacman_ytile + pacman_ytile-blinky_ytile < 0) begin
                            target_ytile = 1'b0;
                        end else begin
                            target_ytile = pacman_ytile + pacman_ytile-blinky_ytile;
                        end
                    end
                    UP: begin
                        if (pacman_xtile + (pacman_xtile - blinky_xtile) >= XTILES) begin
                            target_xtile = XTILES-1'b1;
                        end else if (pacman_xtile  + (pacman_xtile-blinky_xtile) < 0) begin
                            target_xtile = 1'b0;
                        end else begin
                            target_xtile = pacman_xtile + (pacman_xtile-blinky_xtile);
                        end
                        if (pacman_ytile-2'd2 + (pacman_ytile-2'd2 - blinky_ytile) >= YTILES) begin
                            target_ytile = YTILES-1'b1;
                        end else if (pacman_ytile-2'd2 + (pacman_ytile-2'd2 - blinky_ytile) < 0) begin
                            target_ytile = 1'b0;
                        end else begin
                            target_ytile = pacman_ytile-2'd2 + (pacman_ytile-2'd2 - blinky_ytile);
                        end
                    end
                    DN: begin
                        if (pacman_xtile + (pacman_xtile - blinky_xtile) >= XTILES) begin
                            target_xtile = XTILES-1'b1;
                        end else if (pacman_xtile  + (pacman_xtile-blinky_xtile) < 0) begin
                            target_xtile = 1'b0;
                        end else begin
                            target_xtile = pacman_xtile + (pacman_xtile-blinky_xtile);
                        end
                        if (pacman_ytile+2'd2 + (pacman_ytile+2'd2 - blinky_ytile) >= YTILES) begin
                            target_ytile = YTILES-1'b1;
                        end else if (pacman_ytile+2'd2 + (pacman_ytile+2'd2 - blinky_ytile) < 0) begin
                            target_ytile = 1'b0;
                        end else begin
                            target_ytile = pacman_ytile+2'd2 + (pacman_ytile+2'd2 - blinky_ytile);
                        end
                    end
                    LT: begin
                        if (pacman_xtile-2'd2 + (pacman_xtile-2'd2 - blinky_xtile) >= XTILES) begin
                            target_xtile = XTILES-1'b1;
                        end else if (pacman_xtile-2'd2 + (pacman_xtile-2'd2 - blinky_xtile) < 0) begin
                            target_xtile = 1'b0;
                        end else begin
                            target_xtile = pacman_xtile-2'd2 + (pacman_xtile-2'd2 - blinky_xtile);
                        end
                        if (pacman_ytile + (pacman_ytile-blinky_ytile) >= YTILES) begin
                            target_ytile = YTILES-1'b1;
                        end else if (pacman_ytile + (pacman_ytile-blinky_ytile) < 0) begin
                            target_ytile = 1'b0;
                        end else begin
                            target_ytile = pacman_ytile + (pacman_ytile-blinky_ytile);
                        end
                    end
                endcase
            end

            CLYDE: begin    
                if ((pacman_xtile-xtile)*(pacman_xtile-xtile) + (pacman_ytile-ytile)*(pacman_ytile-ytile) > 64) begin
                    target_xtile = pacman_xtile;
                    target_ytile = pacman_ytile;
                end else begin
                    target_xtile = 'd0;
                    target_ytile = 'd32;
                end
            end
        endcase
    end
end 

// INCREMENT LOCATION
always_comb begin
    if (state == STATE_START) begin
        if (state_prev == STATE_RSPWN) begin
            xloc_d = 'd119;
            yloc_d = 'd155;
        end else begin
            xloc_d = start_xloc;
            yloc_d = start_yloc;
        end
        movespeed = 1'b0;
    end else if (state == STATE_SCORE || state == STATE_PAUSE) begin
        xloc_d = xloc;
        yloc_d = yloc;
        movespeed = 1'b0;
    end else if (state == STATE_FRGHT) begin    // cut 50% speed in frightened state
        if (timer_frt[0]) begin
            case (dir)
                RT: begin
                    xloc_d = xloc + movespeed;
                    yloc_d = yloc;
                end

                UP: begin
                    xloc_d = xloc;
                    yloc_d = yloc - movespeed;
                end

                DN: begin
                    xloc_d = xloc;
                    yloc_d = yloc + movespeed;
                end

                LT: begin
                    xloc_d = xloc - movespeed;
                    yloc_d = yloc;
                end
            endcase
        end else begin
            xloc_d = xloc;
            yloc_d = yloc;
        end
        movespeed = 1'b1;
    end else begin
        if (state == STATE_RSPWN) begin
            if (xloc[0] == 0 || yloc[0] == 0) begin
                movespeed = 1'b1;
            end else begin
                movespeed = 2'd2;
            end 
        end else begin
            movespeed = 1'b1;
        end

        case (dir)
            RT: begin
                xloc_d = xloc + movespeed;
                yloc_d = yloc;
            end

            UP: begin
                xloc_d = xloc;
                yloc_d = yloc - movespeed;
            end

            DN: begin
                xloc_d = xloc;
                yloc_d = yloc + movespeed;
            end

            LT: begin
                xloc_d = xloc - movespeed;
                yloc_d = yloc;
            end
        endcase
    end
end

// START LOCATIONS
always_comb begin
    case (personality)
        BLINKY: begin
            start_xloc = 'd119;
            start_yloc = 'd131;
        end

        PINKY: begin
            start_xloc = 'd103;
            start_yloc = 'd155;
        end

        INKY: begin
            start_xloc = 'd119;
            start_yloc = 'd155;
        end

        CLYDE: begin
            start_xloc = 'd135;
            start_yloc = 'd155;
        end
    endcase
end

// GENERATE PSEUDORANDOM DIRECTION FOR FRIGHTENED STATE
always @(posedge clk) begin
    if (start || rst) begin
        case (personality)
           BLINKY:  lfsr_state <= 16'b1010101010101010;
           PINKY:   lfsr_state <= 16'b1100110011001100;
           INKY:    lfsr_state <= 16'b1111000011110000;
           CLYDE:   lfsr_state <= 16'b0101010101010101;
        endcase
    end else if (xtile != xtile_d || ytile != ytile_d) begin
        lfsr_state <= {lfsr_state[14:0], lfsr_state[0] ^ lfsr_state[15]};
    end
end

endmodule