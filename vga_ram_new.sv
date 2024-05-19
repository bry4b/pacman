// because on-chip RAM is not large enough, we cannot load the entire screen 
// elected to cut off 3*8 rows of pixels from the top (YOFFSET)

module vga_ram (
    input clk, 

    input [15:0] addrWrite,
    input [9:0] addrRead_h, 
    input [9:0] addrRead_v,
    input [7:0] dataWrite, 
	 
	output reg writeEnable,

    output reg [7:0] dataRead
);

// reg writeEnable; // HIGH when writing to ram1

reg [15:0] ram1_addr;
reg [15:0] ram2_addr;
reg [7:0] ram1_in;
reg [7:0] ram1_out;
reg [7:0] ram2_in; 
reg [7:0] ram2_out;

ram_ip PING(ram1_addr, clk, ram1_in, writeEnable, ram1_out);
ram_ip PONG(ram2_addr, clk, ram2_in, ~writeEnable, ram2_out);

localparam HPIXELS = 640; 
localparam VPIXELS = 480;

initial begin
    writeEnable = 0;
end

always @(posedge clk) begin
    // writeEnable <= writeEnable_d;

    if (addrRead_h == 0 && addrRead_v == 0) begin // finished drawing last frame
        writeEnable <= ~writeEnable;
    end

end

// 
// CALCULATION OF XPOS, YPOS 
reg [8:0] xpos;
reg [8:0] ypos;
localparam XMAX = 240;      // horizontal pixels (480/2)
localparam YMAX = 320;      // vertical pixels (640/2)
localparam YOFFSET = 24;    // vertical RAM offset (3 tiles * 8)
localparam ADDRESS_MAX = 65535;
always_comb begin
    if (addrRead_h < 'd640 && addrRead_v < 'd480) begin
        // xpos = XMAX - 1 - vc_in / 3;
        xpos = XMAX - 1'b1 - (addrRead_v >> 1'b1);
        ypos = addrRead_h >> 1'b1;
    end else if (addrRead_v < 'd480) begin
        // xpos = XMAX - 1 - vc_in / 3;
        xpos = XMAX - 1'b1 - (addrRead_v >> 1'b1);
        ypos = YMAX - 1'b1;
    end else begin 
        xpos = 0;
        ypos = 0;
    end
end

always_comb begin
    // idk what goes here
    if (writeEnable) begin
        ram1_addr = addrWrite;
        if (ypos > (YOFFSET-1) && ypos < (264+YOFFSET)) begin
            ram2_addr = xpos*264 + (ypos-YOFFSET);
        end else begin
            ram2_addr = ADDRESS_MAX;
        end        
        ram1_in = dataWrite;
        ram2_in = 8'hz;
        dataRead = ram2_out;
    end else begin
        if (ypos > (YOFFSET-1) && ypos < (264+YOFFSET)) begin
            ram1_addr = xpos*264 + (ypos-YOFFSET);
        end else begin
            ram1_addr = ADDRESS_MAX;
        end        
        ram2_addr = addrWrite;
        ram1_in = 8'hz;
        ram2_in = dataWrite;
        dataRead = ram1_out;
    end
end



endmodule

// sequential:
// WRITE dataWrite to one ram at addrRead_h, addrRead_v
// READ to dataRead from other ram at addrRead_h, addrRead_v

// combinational:
// when writeEnable is 0:
//      set ram1 to read-only
//      set ram2 to write-only
// else
//     set ram1 to write-only
//     set ram2 to read-only
