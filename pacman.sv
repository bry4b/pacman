module pacman (
    input clk60, // input 60 Hz clock
    input left,
    input right,
    input uturn,
    input start,
    input reset,

    input [1:0] tile_info [0:3], // maze info

    output logic [9:0] xloc,
    output logic [9:0] yloc,
    output logic [1:0] dir,

    output logic [6:0] curr_xtile,
    output logic [6:0] curr_ytile
);
    
    // Game states
    typedef enum logic [1:0] {START, NORMAL, DEATH} State;
    State curr_state, next_state;

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

    logic [9:0] xloc_d;
    logic [9:0] yloc_d;
    logic [1:0] dir_d;

    logic [1:0] dir_queue; // stores direction to turn; turns this direction as soon as physically possible
    logic [1:0] dir_queue_d;

    assign curr_xtile = xloc >> 3;
    assign curr_ytile = (yloc >> 3) - 3;

    logic wall_in_front;
    assign wall_in_front = (tile_info[dir_d] == WALL);

    logic in_center_of_tile;
    assign in_center_of_tile = (xloc_d % 8 == 3 && yloc_d % 8 == 3);

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
                end else if (reset) begin
                    next_state = START;
                end else begin
                    next_state = NORMAL;
                end
            end
            DEATH : begin
                if (reset) begin
                    next_state = START;
                end else begin
                    next_state = DEATH;
                end
            end
        endcase
    end

    /* QUEUEING NEXT MOVE */
    always_comb begin
        if (curr_state == NORMAL) begin
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
            xloc_d = 119;
            yloc_d = 227;
        end else if (curr_state == NORMAL) begin
            if (!(in_center_of_tile && wall_in_front)) begin
                case (dir)
                    RIGHT: begin
                        xloc_d = xloc + 1;
                        yloc_d = yloc;
                    end

                    UP: begin
                        xloc_d = xloc;
                        yloc_d = yloc - 1;
                    end

                    LEFT: begin
                        xloc_d = xloc - 1;
                        yloc_d = yloc;
                    end

                    DOWN: begin
                        xloc_d = xloc;
                        yloc_d = yloc + 1;
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

    always @(posedge clk60) begin
        curr_state <= next_state;
        xloc <= xloc_d;
        yloc <= yloc_d;
        dir <= dir_d;
        dir_queue <= dir_queue_d;

        left_sr  <= {left_sr[0], left};
        right_sr <= {right_sr[0], right};
        uturn_sr <= {uturn_sr[0], uturn};
    end

endmodule