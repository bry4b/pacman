module game_pacman (
    input clk60, // input 60 Hz clock
    input rst,
    input start,
    
    input left,
    input right,
    input uturn,

    input pause,
    input [1:0] tile_info [0:3], // maze info

    // output logic [5:0] curr_xtile,
    // output logic [5:0] curr_ytile,
    output [11:0] tile_checks,

    // output logic [8:0] xloc,
    // output logic [8:0] yloc,
    // output logic [1:0] dir,
    // output logic [1:0] anim_cycle
    output [22:0] pacman_outputs
);
    // output packing
    wire [5:0] curr_xtile; 
    wire [5:0] curr_ytile;
    assign tile_checks = {curr_xtile, curr_ytile};

    wire [8:0] xloc; 
    wire [8:0] yloc;
    wire [1:0] dir; 
    wire [1:0] anim_cycle;
    wire alive;
    assign pacman_outputs = {xloc, yloc, dir, anim_cycle, alive};
    assign alive = 1'b1;

    // Game states
    typedef enum logic [1:0] {START, NORMAL, DEATH, PAUSE} State;
    State curr_state, next_state, prev_state;

    // Direction standard
    localparam RIGHT = 2'b00;
    localparam UP    = 2'b01;
    localparam LEFT  = 2'b11;
    localparam DOWN  = 2'b10;

    // Maze information
    localparam WALL = 2'b00;    // wall (not walkable)
    localparam WKNP = 2'b01;    // walkable, no pellet
    localparam WKRP = 2'b10;    // walkable, pellet
    localparam WKGH = 2'b11;    // walkable (ghost house)

    logic [1:0] left_sr = 2'b00;
    logic [1:0] right_sr = 2'b00;
    logic [1:0] uturn_sr = 2'b00;

    logic [8:0] xloc_d;
    logic [8:0] yloc_d;
    logic [1:0] dir_d;
    logic [1:0] anim_cycle_d;
    logic anim_clock;
    logic anim_clock_d;
    logic [1:0] anim_count;


    logic [1:0] dir_queue; // stores direction to turn; turns this direction as soon as physically possible
    logic [1:0] dir_queue_d;

    assign curr_xtile = xloc >> 'd3;
    assign curr_ytile = (yloc >> 'd3) - 'd3;

    logic wall_in_front;
    assign wall_in_front = (tile_info[dir] == WALL);

    logic in_center_of_tile;
    assign in_center_of_tile = (xloc[2:0] == 'd3 && yloc[2:0] == 'd3);

    initial begin
        curr_state = START;
    end

    /* STATE FSM */
    always_comb begin
        case (curr_state)
            START : begin
                if (start) begin
                    next_state = NORMAL;
                end else begin
                    next_state = START;
                end
            end
            NORMAL : begin
                if (0 /* DEATH */) begin
                    next_state = DEATH;
                end else if (rst) begin
                    next_state = START;
                end else if (pause) begin
                    next_state = PAUSE;
                end else begin
                    next_state = NORMAL;
                end
            end
            DEATH : begin
                if (rst) begin
                    next_state = START;
                end else begin
                    next_state = DEATH;
                end
            end
            PAUSE : begin
                if (rst) begin
                    next_state = START;
                end else if (pause) begin
                    next_state = PAUSE;
                end else begin
                    next_state = prev_state;
                end
            end
        endcase
    end

    /* QUEUEING NEXT MOVE */
    always_comb begin
        if (curr_state == NORMAL || curr_state == PAUSE) begin
            if (left_sr == 2'b01) begin // if left button is pressed, rotate CCW
                case (dir)
                    RIGHT : begin
                        dir_queue_d = UP;
                    end

                    UP : begin
                        dir_queue_d = LEFT;
                    end

                    LEFT : begin
                        dir_queue_d = DOWN;
                    end

                    DOWN : begin
                        dir_queue_d = RIGHT;
                    end
                endcase
            end else if (right_sr == 2'b01) begin // if right button is pressed, rotate CW
                case (dir)
                    RIGHT : begin
                        dir_queue_d = DOWN;
                    end

                    UP : begin
                        dir_queue_d = RIGHT;
                    end

                    LEFT : begin
                        dir_queue_d = UP;
                    end

                    DOWN : begin
                        dir_queue_d = LEFT;
                    end
                endcase
            end else if (uturn_sr == 2'b01) begin // if 180 is triggered, do a 180
                dir_queue_d = ~dir;
            end else begin
                dir_queue_d = dir_queue;
            end
        end else begin
            dir_queue_d = RIGHT;
        end
    end

    /* PACMAN ROTATION */
    always_comb begin
        if (curr_state == START) begin
            dir_d = RIGHT;
        end else if (curr_state == NORMAL) begin
            if (dir_queue == ~dir) begin // if 180, execute move immediately
                dir_d = dir_queue;
            end else if (tile_info[dir_queue] != WALL && tile_info[dir_queue] != WKGH && in_center_of_tile) begin
                dir_d = dir_queue; // if legal move and in center of tile, execute move
            end else begin
                dir_d = dir;
            end
        end else begin
            dir_d = dir;
        end
    end

    /* PACMAN MOVEMENT */
    always_comb begin
        if (curr_state == START) begin
            xloc_d = 'd119;
            yloc_d = 'd227;
        end else if (curr_state == NORMAL) begin
            if ( !(in_center_of_tile && wall_in_front) && ( (dir_d == dir) || (dir_d == ~dir) ) ) begin
                case (dir)
                    RIGHT: begin
                        xloc_d = xloc + 1'b1;
                        yloc_d = yloc;
                    end

                    UP: begin
                        xloc_d = xloc;
                        yloc_d = yloc - 1'b1;
                    end

                    LEFT: begin
                        xloc_d = xloc - 1'b1;
                        yloc_d = yloc;
                    end

                    DOWN: begin
                        xloc_d = xloc;
                        yloc_d = yloc + 1'b1;
                    end
                endcase
            end else begin
                xloc_d = xloc;
                yloc_d = yloc;
            end
        end else begin
            xloc_d = xloc;
            yloc_d = yloc;
        end
    end

    /* ANIMATION CYCLE */
    // currently changes frame at 30 hz, maybe slow down a tad
    always_comb begin
        if (xloc_d != xloc || yloc_d != yloc) begin
            anim_clock_d = ~anim_clock;
        end else begin
            anim_clock_d = 1'b0;
        end
        if (curr_state == NORMAL) begin
            if (anim_clock) begin
                anim_cycle_d = anim_cycle + 1'b1;
            end else begin
                if (anim_cycle == 2'b00) begin
                    anim_cycle_d = 2'b01;
                end else begin
                    anim_cycle_d = anim_cycle;
                end
            end
        end else begin
            anim_cycle_d = 2'b01;
        end
    end

    always @(posedge clk60) begin
        curr_state <= next_state;
        xloc <= xloc_d;
        yloc <= yloc_d;
        dir <= dir_d;
        dir_queue <= dir_queue_d;
        anim_cycle <= anim_cycle_d;
        anim_clock <= anim_clock_d;

        left_sr  <= {left_sr[0], left};
        right_sr <= {right_sr[0], right};
        uturn_sr <= {uturn_sr[0], uturn};

        if (curr_state != next_state && curr_state != PAUSE) begin
            prev_state <= curr_state;
        end
    end

endmodule