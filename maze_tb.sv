`timescale 1ns/1ns

module graphics_maze_tb (
    output reg clk,
    output reg [9:0] xpos,
    output reg [9:0] ypos,
    output reg [5:0] xpellet,
    output reg [5:0] ypellet,
    output [7:0] color
);

graphics_maze UUT(xpos, ypos, xpellet, ypellet, clk, 1, color);

initial begin
    clk = 0;
    xpos = 0;
    ypos = 0;
    xpellet = 0;
    ypellet = 0;

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