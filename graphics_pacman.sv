module graphics_pacman (
    input [8:0] xpos,           // current x position read by vga
    input [8:0] ypos,           // current y position read by vga

    input [8:0] xloc,           // x coordinate of center of pacman location (7,7 in bitfield)
    input [8:0] yloc,           // y coordinate of center of pacman location (7,7 in bitfield)

    input [1:0] pacman_dir,     // RighT, UP, DowN, LefT
    input pacman_alive,         // alive, dead
    input [1:0] animation_cycle,  

    output reg [7:0] color
);

// COLORS
localparam YLW  = 8'b11111100;
localparam BLK  = 8'b00000000; 

// ROTATIONS
localparam NM = 2'b00;      // NorMal
localparam CC = 2'b01;      // Counter-Clockwise
localparam CW = 2'b10;      // ClockWise
localparam FL = 2'b11;      // FLipped (180)

reg [0:224] pacman_frames [0:2] = '{
    {{12'h000,3'o0},{12'h07c,3'o0},{12'h1ff,3'o0},{12'h3ff,3'o4},{12'h3ff,3'o4},{12'h7ff,3'o6},{12'h7ff,3'o6},{12'h7ff,3'o6},{12'h7ff,3'o6},{12'h7ff,3'o6},{12'h3ff,3'o4},{12'h3ff,3'o4},{12'h1ff,3'o0},{12'h07c,3'o0},{12'h000,3'o0}},
    {{12'h000,3'o0},{12'h07c,3'o0},{12'h1ff,3'o0},{12'h3ff,3'o4},{12'h3ff,3'o4},{12'h7fe,3'o0},{12'h7f0,3'o0},{12'h780,3'o0},{12'h7f0,3'o0},{12'h7fe,3'o0},{12'h3ff,3'o4},{12'h3ff,3'o4},{12'h1ff,3'o0},{12'h07c,3'o0},{12'h000,3'o0}},
    {{12'h000,3'o0},{12'h07c,3'o0},{12'h1fc,3'o0},{12'h3f8,3'o0},{12'h3f0,3'o0},{12'h7e0,3'o0},{12'h7c0,3'o0},{12'h780,3'o0},{12'h7c0,3'o0},{12'h7e0,3'o0},{12'h3f0,3'o0},{12'h3f8,3'o0},{12'h1fc,3'o0},{12'h07c,3'o0},{12'h000,3'o0}}
};

wire [3:0] xpixel = xpos-xloc+7;
wire [3:0] ypixel = ypos-yloc+7;
wire [0:224] pacman_sprite = pacman_frames[animation_cycle];
reg pixel;

always_comb begin
    if ( ( (xloc < 7 || xloc-7 <= xpos) && xpos <= xloc+7) && ( (yloc < 7 || yloc-7 <= ypos) && ypos <= yloc+7) ) begin
        case (pacman_dir)
            NM: begin
                pixel = pacman_sprite ['d15 * ypixel + xpixel];
            end

            CC: begin
                pixel = pacman_sprite ['d14 + 15 * xpixel - ypixel];
            end

            CW: begin
                pixel = pacman_sprite ['d210 - 15 * xpixel + ypixel];
            end

            FL: begin
                pixel = pacman_sprite ['d224 - 15 * ypixel - xpixel];
            end
        endcase
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
