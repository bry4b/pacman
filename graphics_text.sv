module graphics_text (
    input [8:0] xpos,
    input [8:0] ypos,

    input [2:0] game_state,

    output [7:0] color
);

localparam TEXT_X_OFFSET = 80; 
localparam TEXT_Y_OFFSET = 176; 
localparam TEXT_X_WIDTH = 80;   // 10 letters * 8 pixels per letter

localparam RESET = 3'b000;
localparam START = 3'b001;
localparam PLAY = 3'b010;
localparam DEATH = 3'b011;
localparam LOSE = 3'b100;
localparam WIN = 3'b101;

localparam RED = 8'b11100000;
localparam YLW  = 8'b11111100;
localparam BLK  = 8'b00000000; 

reg [0:639] words [0:1] = '{
    {{80'h00007e3f1e7e330e0000},
     {80'h000063303666330e0000},
     {80'h000063306363331c0000},
     {80'h0000673e63631e180000},
     {80'h00007c307f630c100000},
     {80'h00006e3063660c000000},
     {80'h0000673f637c0c200000},
     {80'h00000000000000000000}},

    {{80'h1f1c633f00003e633f7e},
     {80'h30367730000063633063},
     {80'h60637f30000063633063},
     {80'h67637f3e000063773e67},
     {80'h637f6b300000633e307c},
     {80'h336363300000631c306e},
     {80'h1f63633f00003e083f67},
     {80'h00000000000000000000}}
};

always_comb begin
    if ( xpos >= TEXT_X_OFFSET && xpos < (TEXT_X_OFFSET + TEXT_X_WIDTH) && ypos >= TEXT_Y_OFFSET && ypos < (TEXT_Y_OFFSET + 8) ) begin
        if (game_state == RESET || game_state == START) begin
            if (words[0][xpos - TEXT_X_OFFSET + 'd80*(ypos - TEXT_Y_OFFSET)]) begin
                color = YLW;
            end else begin
                color = BLK;
            end
        end else if (game_state == LOSE) begin
            if (words[1][xpos - TEXT_X_OFFSET + 'd80*(ypos - TEXT_Y_OFFSET)]) begin
                color = RED;
            end else begin
                color = BLK;
            end
        end else begin
            color = BLK;
        end
    end else begin
        color = BLK;
    end
end

endmodule