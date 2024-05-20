module graphics_scoreboard (
    input [8:0] xpos,
    input [8:0] ypos, 

    input [17:0] score,

    output [7:0] color
);

// scoreboard displays up to 7 digits, but least significant digit is always 0 due to how scoring works
// "score" input only defines the 6 most significant digits

localparam SCORE_X_OFFSET = 8;
localparam SCORE_Y_OFFSET = 8;
localparam SCORE_X_WIDTH = 56;  // 7 digits * 8 pixels per digit

// COLORS
localparam WHT  = 8'b11111111;
localparam BLK  = 8'b00000000; 

reg [0:63] scoreboard_digits [0:9] = '{
    64'h001c26636363321c,       // 0
    64'h000c1c0c0c0c0c3f,       // 1
    64'h003e63071e3c707f,       // 2
    64'h003f060c1e03633e,       // 3
    64'h000e1e36667f0606,       // 4
    64'h007e607e0303633e,       // 5
    64'h001e30607e63633e,       // 6
    64'h007f63060c181818,       // 7
    64'h003c62723c4f433e,       // 8
    64'h003e63633f03063c        // 9
};

wire [3:0] digit [6:0]; 
wire [3:0] first_display_digit;
wire [3:0] display_digit = (SCORE_X_WIDTH - 1'b1 - (xpos-SCORE_X_OFFSET)) >> 'd3;

assign digit[6] = score/'d100000 % 'd10;
assign digit[5] = score/'d10000 % 'd10;
assign digit[4] = score/'d1000 % 'd10;
assign digit[3] = score/'d100 % 'd10;
assign digit[2] = score/'d10 % 'd10;
assign digit[1] = score % 'd10;
assign digit[0] = 'd0;

always_comb begin
    if (digit[6]) begin
        first_display_digit = 6;
    end else if (digit[5]) begin
        first_display_digit = 5;
    end else if (digit[4]) begin
        first_display_digit = 4;
    end else if (digit[3]) begin
        first_display_digit = 3;
    end else if (digit[2]) begin
        first_display_digit = 2;
    end else begin
        first_display_digit = 1;
    end
end

wire [2:0] xpixel = (xpos - SCORE_X_OFFSET) % 'd8;
wire [2:0] ypixel = ypos - SCORE_Y_OFFSET;

wire [0:63] display = scoreboard_digits[digit[display_digit]];

always_comb begin
    if ( xpos >= SCORE_X_OFFSET && xpos < (SCORE_X_OFFSET + SCORE_X_WIDTH) && ypos >= SCORE_Y_OFFSET && ypos < (SCORE_Y_OFFSET + 8) ) begin
        // if (scoreboard_digits [digit[(SCORE_X_WIDTH - 1'b1 - (xpos-SCORE_X_OFFSET)) >> 'd3]] [xpos[2:0] + (ypos[2:0] << 'd3)]) begin
        if (display[xpixel + (ypixel*'d8)] && display_digit <= first_display_digit) begin
            color = WHT;
        end else begin
            color = BLK;
        end
    end else begin
        color = BLK;
    end
end

endmodule