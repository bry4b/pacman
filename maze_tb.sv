`timescale 1ns/1ns

module maze_tb (
    output reg clk,
    output reg rst,
    output reg [9:0] xpos,
    output reg [9:0] ypos,
    output reg [9:0] pac_x,
    output reg [9:0] pac_y,
    output reg [1:0] tile_info, 
    output [7:0] color
);

maze UUT(clk, rst, xpos, ypos, pac_x, pac_y, 1, tile_info, color);

initial begin
    clk = 0;
    rst = 1;
    xpos = 0;
    ypos = 0;
    pac_x = 'd8;
    pac_y = 'd40;
end

always @(posedge clk) begin
    if (xpos < 159) begin
        #5 xpos <= xpos + 1;
    end else if (ypos < 319) begin
        #5 ypos <= ypos + 1;
        xpos <= 0;
    end else begin
        $stop;
    end
end

always begin
    #5 clk = ~clk;
end



endmodule