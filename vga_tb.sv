`timescale 1ns/1ns

module vga_tb (
    output reg clk,    
	output reg hsync, 
    output reg vsync,
    output reg [3:0] red,
    output reg [3:0] green, 
    output reg [3:0] blue
);
    reg rst;
    reg btn;
    reg [9:0] switches = 10'b0; 
    reg [9:0] hc; 
    reg [9:0] vc;

    wire [15:0] address_old;
    wire [7:0] color_old;
    wire [15:0] address_new;
    wire [7:0] color_new;
    wire [7:0] vga_data_old;
    wire [7:0] vga_data_new;

    // wire [2:0] input_red = color [7:5];
    // wire [2:0] input_green = color [4:2];
    // wire [1:0] input_blue = color [1:0];

    reg writeEnable_old;
    reg writeEnable_new;
    reg [8:0] pacman_xloc;
    reg [8:0] pacman_yloc;


    // wire [2:0] input_red = vga_data [7:5];
    // wire [2:0] input_green = vga_data [4:2];
    // wire [1:0] input_blue = vga_data [1:0];

    // vga VGA(clk, input_red, input_green, input_blue, rst, hc_out, vc_out, hsync, vsync, red, green, blue);

    vga_ram RAM(clk, address_old, hc, vc, color_old,  writeEnable_old, vga_data_old);
    graphics OLD(clk, btn, rst, hc, vc, switches, pacman_xloc, pacman_yloc, 8'h00, color_old, address_old);
    // vga_ram RAM_UUT(clk, address_new, hc, vc, color_new, writeEnable_new, vga_data_new);
    graphics_new UUT(clk, btn, rst, hc, vc, switches, pacman_xloc, pacman_yloc, 8'h00, vga_data_new);

    initial begin
        clk = 0;
        btn = 1;
        rst = 1;
        // writeEnable = 0;
        pacman_xloc = 'd120;
        pacman_yloc = 'd228;
        hc = 0;
        vc = 0;
        #1000000 $stop;
    end

    always begin
        #1 clk = ~clk;
        if (hc < 800 - 1) begin
            hc <= hc + 1'b1;
        end else if (vc < 525 - 1) begin
            vc <= vc + 1'b1;
            hc <= 0;
        end else begin
            hc <= 0;
            vc <= 0;
        end
    end

endmodule