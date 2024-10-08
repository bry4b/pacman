//  TODO: implement pacman death animation

module graphics_pacman (
    input [8:0] xpos,           // current x position read by vga
    input [8:0] ypos,           // current y position read by vga

    // input [8:0] xloc,           // x coordinate of center of pacman location (7,7 in bitfield)
    // input [8:0] yloc,           // y coordinate of center of pacman location (7,7 in bitfield)
    // input [1:0] pacman_dir,     // RighT, UP, DowN, LefT
    // input [1:0] animation_cycle,  
    // input pacman_alive,         // alive, dead
    input [22:0] pacman_inputs,

    input [3:0] pacman_death_frame,
    input hide_pacman,

    output reg [7:0] color
);

wire [8:0] xloc = pacman_inputs [22:14];
wire [8:0] yloc = pacman_inputs [13:5];
wire [1:0] pacman_dir = pacman_inputs [4:3];
wire [1:0] animation_cycle = pacman_inputs [2:1];
wire pacman_alive = pacman_inputs [0];

// COLORS
localparam YLW  = 8'b11111100;
localparam BLK  = 8'b00000000; 

// ROTATIONS
localparam NM = 2'b00;      // NorMal
localparam CC = 2'b01;      // Counter-Clockwise
localparam CW = 2'b10;      // ClockWise
localparam FL = 2'b11;      // FLipped (180)

reg [0:224] frames [0:3] = '{
    {{12'h000,3'o0},{12'h07c,3'o0},{12'h1ff,3'o0},{12'h3ff,3'o4},{12'h3ff,3'o4},{12'h7ff,3'o6},{12'h7ff,3'o6},{12'h7ff,3'o6},{12'h7ff,3'o6},{12'h7ff,3'o6},{12'h3ff,3'o4},{12'h3ff,3'o4},{12'h1ff,3'o0},{12'h07c,3'o0},{12'h000,3'o0}},     // closed
    {{12'h000,3'o0},{12'h07c,3'o0},{12'h1ff,3'o0},{12'h3ff,3'o4},{12'h3ff,3'o4},{12'h7fe,3'o0},{12'h7f0,3'o0},{12'h780,3'o0},{12'h7f0,3'o0},{12'h7fe,3'o0},{12'h3ff,3'o4},{12'h3ff,3'o4},{12'h1ff,3'o0},{12'h07c,3'o0},{12'h000,3'o0}},     // half open
    {{12'h000,3'o0},{12'h07c,3'o0},{12'h1fc,3'o0},{12'h3f8,3'o0},{12'h3f0,3'o0},{12'h7e0,3'o0},{12'h7c0,3'o0},{12'h780,3'o0},{12'h7c0,3'o0},{12'h7e0,3'o0},{12'h3f0,3'o0},{12'h3f8,3'o0},{12'h1fc,3'o0},{12'h07c,3'o0},{12'h000,3'o0}},     // full open
    {{12'h000,3'o0},{12'h07c,3'o0},{12'h1ff,3'o0},{12'h3ff,3'o4},{12'h3ff,3'o4},{12'h7fe,3'o0},{12'h7f0,3'o0},{12'h780,3'o0},{12'h7f0,3'o0},{12'h7fe,3'o0},{12'h3ff,3'o4},{12'h3ff,3'o4},{12'h1ff,3'o0},{12'h07c,3'o0},{12'h000,3'o0}}      // half open
};

reg [0:224] death_frames [0:11] = '{
    // line 1      // line 2      // line 3      // line 4      // line 5      // line 6      // line 7      // line 8      // line 9      // line 10     // line 11     // line 12     // line 13     // line 14     // line 15
    {{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h600,3'o6},{12'h701,3'o6},{12'h783,3'o6},{12'h7c7,3'o6},{12'h7ef,3'o6},{12'h3ff,3'o4},{12'h3ff,3'o4},{12'h1ff,3'o0},{12'h07c,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0}},     
    {{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h400,3'o2},{12'hf01,3'o7},{12'hf83,3'o7},{12'hfef,3'o7},{12'h7ff,3'o6},{12'h7ff,3'o6},{12'h3ff,3'o4},{12'h0ee,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0}},
    {{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'he00,3'o7},{12'hfc7,3'o7},{12'hfff,3'o7},{12'h7ff,3'o6},{12'h3ff,3'o4},{12'h0ee,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0}},
    {{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'hf01,3'o7},{12'hfff,3'o7},{12'hfff,3'o7},{12'h7ff,3'o6},{12'h1ef,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0}},
    {{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h0fe,3'o0},{12'hfff,3'o7},{12'hfff,3'o7},{12'h7ff,3'o6},{12'h1ef,3'o0},{12'h000,3'o0},{12'h000,3'o0}},
    {{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h038,3'o0},{12'h0fe,3'o0},{12'h7ff,3'o6},{12'hfff,3'o7},{12'h7ef,3'o6},{12'h1c7,3'o0},{12'h000,3'o0}}, 
    {{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h010,3'o0},{12'h038,3'o0},{12'h0fe,3'o0},{12'h1ff,3'o0},{12'h7ff,3'o6},{12'h7ef,3'o6},{12'h3c7,3'o4}},
    {{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h010,3'o0},{12'h038,3'o0},{12'h07c,3'o0},{12'h07c,3'o0},{12'h0fe,3'o0},{12'h1ff,3'o0},{12'h0ee,3'o0}},
    {{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h010,3'o0},{12'h010,3'o0},{12'h038,3'o0},{12'h038,3'o0},{12'h038,3'o0},{12'h07c,3'o0},{12'h028,3'o0}},
    {{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h010,3'o0},{12'h010,3'o0},{12'h010,3'o0},{12'h010,3'o0},{12'h010,3'o0},{12'h010,3'o0},{12'h000,3'o0}},
    {{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h044,3'o0},{12'h128,3'o0},{12'h081,3'o0},{12'h002,3'o0},{12'h600,3'o0},{12'h001,3'o4},{12'h080,3'o0},{12'h102,3'o0},{12'h029,3'o0},{12'h044,3'o0}},
    {{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0},{12'h000,3'o0}}
};
wire [0:224] pacman_sprite = frames[animation_cycle];
wire [0:224] death_sprite = death_frames[pacman_death_frame];
wire pixel;

always_comb begin
    if ( ( (xloc < 7 || xloc-7 <= xpos) && xpos <= xloc+7) && ( (yloc < 7 || yloc-7 <= ypos) && ypos <= yloc+7) && ~hide_pacman) begin
        if (~pacman_alive) begin
            pixel = death_sprite ['d15 * (ypos-yloc+7) + (xpos-xloc+7)];
        end else begin
            case (pacman_dir)
                NM: begin
                    pixel = pacman_sprite ['d15 * (ypos-yloc+7) + (xpos-xloc+7)];
                end

                CC: begin
                    pixel = pacman_sprite ['d14 + 15 * (xpos-xloc+7) - (ypos-yloc+7)];
                end

                CW: begin
                    pixel = pacman_sprite ['d210 - 15 * (xpos-xloc+7) + (ypos-yloc+7)];
                end

                FL: begin
                    pixel = pacman_sprite ['d224 - 15 * (ypos-yloc+7) - (xpos-xloc+7)];
                end
            endcase
        end
        // case (pacman_dir)
        //     NM: begin
        //         pixel = pacman_sprite ['d15 * (ypos-yloc+7) + (xpos-xloc+7)];
        //     end

        //     CC: begin
        //         pixel = pacman_sprite ['d14 + 15 * (xpos-xloc+7) - (ypos-yloc+7)];
        //     end

        //     CW: begin
        //         pixel = pacman_sprite ['d210 - 15 * (xpos-xloc+7) + (ypos-yloc+7)];
        //     end

        //     FL: begin
        //         pixel = pacman_sprite ['d224 - 15 * (ypos-yloc+7) - (xpos-xloc+7)];
        //     end
        // endcase

        if (pixel) begin
            color = YLW;
        end else begin
            color = BLK;
        end
    end else begin
        pixel = 0;
        color = BLK;
    end

end

endmodule
