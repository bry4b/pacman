module graphics_lives (
    input [8:0] xpos,
    input [8:0] ypos,

    input [2:0] lives,

    output [7:0] color
);

localparam LIVES_X_OFFSET = 8;
localparam LIVES_Y_OFFSET = 296;
localparam LIVES_X_WIDTH = 80;      // max 5 lives * 16 pixels per life
localparam LIVES_Y_HEIGHT = 16;     

localparam YLW  = 8'b11111100;
localparam BLK  = 8'b00000000; 

reg [0:255] lives_sprite = 256'h0000000007c00fe01ff007f801f8007801f807f81ff00fe007c0000000000000;

wire [3:0] xpixel = (xpos - LIVES_X_OFFSET) % 'd16;
wire [3:0] ypixel = ypos - LIVES_Y_OFFSET;
wire [2:0] lives_num = (xpos - LIVES_X_OFFSET) >> 'd4;

always_comb begin
    if ( xpos >= LIVES_X_OFFSET && xpos < (LIVES_X_OFFSET + LIVES_X_WIDTH) && ypos >= LIVES_Y_OFFSET && ypos < (LIVES_Y_OFFSET + LIVES_Y_HEIGHT) ) begin
        if (lives_sprite[xpixel + (ypixel*'d16)] && lives > lives_num) begin
            color = YLW;
        end else begin
            color = BLK;
        end
    end else begin
        color = BLK;
    end
end


endmodule
