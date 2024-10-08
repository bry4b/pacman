// because on-chip RAM is not large enough, we cannot load the entire screen 
// we have a total of 65536 bytes that we can allocate
// bytes 0 to 63359 (264*240-1) belong to the actual playfield (maze)
// bytes 63360 to 63807 belong to the score display (7 digits * 64 bytes each)
// elected to cut off 3*8 rows of pixels from the top (MAZE_Y_OFFSET)

module vga_ram (
    input clk, 

    input [15:0] addrWrite,
    input [9:0] addrRead_h, 
    input [9:0] addrRead_v,
    input [7:0] dataWrite, 

    output writeEnable,         // HIGH when writing to ram0
    output reg [7:0] dataRead
);
// reg writeEnable; // 
reg [15:0] ram0_addr;
reg [15:0] ram1_addr;
reg [7:0] ram0_in;
reg [7:0] ram0_out;
reg [7:0] ram1_in; 
reg [7:0] ram1_out;

ram_ip PING(ram0_addr, clk, ram0_in, writeEnable, ram0_out);
ram_ip PONG(ram1_addr, clk, ram1_in, ~writeEnable, ram1_out);

localparam HPIXELS = 640; 
localparam VPIXELS = 480;

initial begin
    writeEnable = 0;
end

always @(posedge clk) begin
    if (addrRead_h == 'd799 && addrRead_v == 'd524) begin // finished drawing last frame
        writeEnable <= ~writeEnable;
    end

end

// CALCULATION OF XPOS, YPOS TO READ FROM 
reg [8:0] xpos;
reg [8:0] ypos;

localparam X_MAX = 240;         // horizontal pixels (480/2)
localparam Y_MAX = 320;         // vertical pixels (640/2)
localparam ADDRESS_MAX = 65535; // max RAM address

localparam MAZE_Y_OFFSET = 24;  // vertical maze offset (3 tiles * 8)
localparam MAZE_Y_HEIGHT = 264; // vertical maze height (33 tiles * 8)
localparam SCORE_X_OFFSET = 8;  // horizontal score offset
localparam SCORE_Y_OFFSET = 8;  // vertical score offset
localparam SCORE_X_WIDTH = 56;  // 7 digits * 8 pixels per digit
localparam SCORE_Y_HEIGHT = 8;  // 8 pixels per digit
localparam LIVES_X_OFFSET = 8;
localparam LIVES_Y_OFFSET = 296;
localparam LIVES_X_WIDTH = 80;  // max 5 lives * 16 pixels per life
localparam LIVES_Y_HEIGHT = 16;     

localparam SCORE_ADDR0 = 63360; // start of score area

always_comb begin
    if (addrRead_h < 'd640 && addrRead_v < 'd480) begin
        // xpos = X_MAX - 1 - vc_in / 3;
        xpos = X_MAX - 1'b1 - (addrRead_v >> 1'b1);
        ypos = addrRead_h >> 1'b1;
    end else if (addrRead_v < 'd480) begin
        // xpos = X_MAX - 1 - vc_in / 3;
        xpos = X_MAX - 1'b1 - (addrRead_v >> 1'b1);
        ypos = Y_MAX - 1'b1;
    end else begin 
        xpos = 1'b0;
        ypos = 1'b0;
    end
end

always_comb begin
    // idk what goes here
    if (writeEnable) begin
        ram0_addr = addrWrite;
        if (ypos >= MAZE_Y_OFFSET && ypos < (MAZE_Y_HEIGHT+MAZE_Y_OFFSET)) begin   // maze area
            ram1_addr = xpos + (ypos-MAZE_Y_OFFSET)*X_MAX;
        end else if (ypos >= SCORE_Y_OFFSET && ypos < (SCORE_Y_HEIGHT + SCORE_Y_OFFSET) && xpos >= SCORE_X_OFFSET && xpos < (SCORE_X_WIDTH+SCORE_X_OFFSET)) begin          // score area
            ram1_addr = SCORE_ADDR0 + xpos + (ypos-SCORE_Y_OFFSET)*SCORE_X_WIDTH;
        end else if (ypos >= LIVES_Y_OFFSET && ypos < (LIVES_Y_HEIGHT + LIVES_Y_OFFSET) && xpos >= LIVES_X_OFFSET && xpos < (LIVES_X_WIDTH+LIVES_X_OFFSET)) begin          // lives area
            ram1_addr = SCORE_ADDR0 + 448 + xpos + (ypos-LIVES_Y_OFFSET)*LIVES_X_WIDTH;
        end else begin
            ram1_addr = ADDRESS_MAX;
        end        
        ram0_in = dataWrite;
        ram1_in = 8'hz;
        dataRead = ram1_out;
    end else begin
        if (ypos > (MAZE_Y_OFFSET-1) && ypos < (MAZE_Y_HEIGHT+MAZE_Y_OFFSET)) begin
            ram0_addr = xpos + (ypos-MAZE_Y_OFFSET)*X_MAX;
        end else if (ypos >= SCORE_Y_OFFSET && ypos < (SCORE_Y_HEIGHT + SCORE_Y_OFFSET) && xpos >= SCORE_X_OFFSET && xpos < (SCORE_X_WIDTH+SCORE_X_OFFSET)) begin          // score area
            ram0_addr = SCORE_ADDR0 + xpos + (ypos-SCORE_Y_OFFSET)*SCORE_X_WIDTH;
        end else if (ypos >= LIVES_Y_OFFSET && ypos < (LIVES_Y_HEIGHT + LIVES_Y_OFFSET) && xpos >= LIVES_X_OFFSET && xpos < (LIVES_X_WIDTH+LIVES_X_OFFSET)) begin          // lives area
            ram0_addr = SCORE_ADDR0 + 448 + xpos + (ypos-LIVES_Y_OFFSET)*LIVES_X_WIDTH;
        end else begin
            ram0_addr = ADDRESS_MAX;
        end        
        ram1_addr = addrWrite;
        ram0_in = 8'hz;
        ram1_in = dataWrite;
        dataRead = ram0_out;
    end
end



endmodule

// sequential:
// WRITE dataWrite to one ram at addrRead_h, addrRead_v
// READ to dataRead from other ram at addrRead_h, addrRead_v

// combinational:
// when writeEnable is 0:
//      set ram0 to read-only
//      set ram1 to write-only
// else
//     set ram0 to write-only
//     set ram1 to read-only
