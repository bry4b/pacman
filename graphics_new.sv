module graphics_new (
    input clk, 
    input rst, 
    input btn,

    input [9:0] hc_in,
    input [9:0] vc_in,

    // input writeEnable_in,

    // input [9:0] xpos, 
    // input [9:0] ypos,

    input [9:0] switches, // testing outputs
    input [9:0] pacman_xloc,
    input [9:0] pacman_yloc,    // testing module connections

    input [7:0] maze_color,

    output reg [7:0] dataRead

);

reg [9:0] xpos;
reg [9:0] ypos;


// 
// COLOR DEFINITIONS
localparam RED  = 8'b11100000;
localparam PNK  = 8'b11101111;
localparam CYN  = 8'b00011111;
localparam ORG  = 8'b11110100;
localparam YLW  = 8'b11111100;
localparam WHT  = 8'b11111111;
localparam CRM  = 8'b11111110;
localparam BLU  = 8'b00000011;
localparam BLK  = 8'b00000000; 

//
// GHOST INSTANTIATION
wire [9:0] blinky_xloc;
wire [9:0] blinky_yloc;
wire [1:0] blinky_dir;
wire [1:0] blinky_mode;
wire [9:0] blinky_address;
wire [2:0] blinky_pixel;
wire [7:0] blinky_color;

wire [9:0] pinky_xloc;
wire [9:0] pinky_yloc;
wire [1:0] pinky_dir;
wire [1:0] pinky_mode;
wire [9:0] pinky_address;
wire [2:0] pinky_pixel;
wire [7:0] pinky_color;

wire [9:0] inky_xloc;
wire [9:0] inky_yloc;
wire [1:0] inky_dir;
wire [1:0] inky_mode;
wire [9:0] inky_address;
wire [2:0] inky_pixel;
wire [7:0] inky_color;

wire [9:0] clyde_xloc;
wire [9:0] clyde_yloc;
wire [1:0] clyde_dir;
wire [1:0] clyde_mode;
wire [9:0] clyde_address;
wire [2:0] clyde_pixel;
wire [7:0] clyde_color;

wire ghost_animation;

graphics_ghost_LUT GLUT (blinky_address, pinky_address, inky_address, clyde_address, blinky_pixel, pinky_pixel, inky_pixel, clyde_pixel);
graphics_ghost BLINKY   (xpos, ypos, blinky_xloc,   blinky_yloc,    2'b00, blinky_dir,  blinky_mode,   ghost_animation, blinky_pixel,  blinky_address, blinky_color);
graphics_ghost PINKY    (xpos, ypos, pinky_xloc,    pinky_yloc,     2'b01, pinky_dir,   pinky_mode,    ghost_animation, pinky_pixel,   pinky_address,  pinky_color);
graphics_ghost INKY     (xpos, ypos, inky_xloc,     inky_yloc,      2'b10, inky_dir,    inky_mode,     ghost_animation, inky_pixel,    inky_address,   inky_color);
graphics_ghost CLYDE    (xpos, ypos, clyde_xloc,    clyde_yloc,     2'b11, clyde_dir,   clyde_mode,    ghost_animation, clyde_pixel,   clyde_address,  clyde_color);

// 
// GHOST STATES (HARDCODED)
// assign blinky_xloc = switches[9:6] << 3;
// assign blinky_yloc = switches[5:3] << 3;
// TODO: assign ghost states to subvectors of blinky_state_current etc.
assign blinky_xloc = 'd119;
assign blinky_yloc = 'd132;
assign blinky_dir = switches[2:1];
assign blinky_mode = switches[0] << 1;

assign pinky_xloc = 'd103;
assign pinky_yloc = 'd154;
assign pinky_dir = switches[2:1];
assign pinky_mode = switches[0] << 1;

assign inky_xloc = 'd119;
assign inky_yloc = 'd154;
assign inky_dir = switches[2:1];
assign inky_mode = switches[0] << 1;

assign clyde_xloc = 'd135;
assign clyde_yloc = 'd154;
assign clyde_dir = switches[2:1];
assign clyde_mode = switches[0] << 1;

assign ghost_animation = ~btn;

// 
// PACMAN INSTANTIATION
// wire [8:0] pacman_xloc = 'd119 + (switches[9:7] << 2);
// wire [8:0] pacman_yloc = 'd228 + (switches[6:4] << 2);
wire [1:0] pacman_dir = switches[1:0];
wire pacman_alive = 1'b1;
wire [1:0] pacman_animation = switches[3:2];
wire [7:0] pacman_color;

graphics_pacman PACMAN  (xpos, ypos, pacman_xloc,   pacman_yloc,    pacman_dir,     pacman_alive,   pacman_animation,   pacman_color);

//
// LOGIC FOR SPRITE HIERARCHY
// allows sprites to show through "below" other sprites 
reg [7:0] color;
always_comb begin
    // instantiate blinky, pinky, etc. with like 'ghost1color', 'ghost2color', etc. for outputs instead of just 'color' (so they're split on different wires)
    // in comb block determine which wire (ghost1color, ghost2color, etc) has priority, and set that to drive color
    //      red > pink > blue > orange

    if (blinky_color != BLK) begin
        color = blinky_color;
    end else if (pinky_color != BLK) begin
        color = pinky_color;
    end else if (inky_color != BLK) begin
        color = inky_color;
    end else if (clyde_color != BLK) begin
        color = clyde_color;
    end else if (pacman_color != BLK) begin
        color = pacman_color;
    end else if (maze_color != BLK) begin
        color = maze_color;
    end else begin
        color = BLK;
    end
end

// 
// NEW RAM ADDRESSING IMPLEMENTATION
reg [26:0] pacman_state_prev;
reg [26:0] pacman_state_curr;
reg [26:0] blinky_state_prev;
reg [26:0] blinky_state_curr;

// reg writeEnable;
// reg writeEnable_d;


reg draw_old;   // HIGH when drawing over old location of sprite
reg draw_done;  // HIGH when all draws are done
reg new_frame;  // HIGH when a new frame is being drawn

reg [7:0] pixel_count; 
reg [7:0] pixel_count_d; 

reg [2:0] sprite_num;
reg [2:0] sprite_num_d;

initial begin
    xpos = 0;
    ypos = 0;
    pacman_state_prev = 0; 
    pacman_state_curr = 0; 
    blinky_state_prev = 0; 
    blinky_state_curr = 0; 
    // writeEnable = 0;   
    // writeEnable_d = 0;
    pixel_count = 0;
    pixel_count_d = 0;
    draw_old = 1;
    draw_done = 1;
    new_frame = 0;
    sprite_num <= 0;
    sprite_num_d <= 0;
end

always @(posedge clk) begin
    pixel_count <= pixel_count_d;

    if (hc_in == 0 && vc_in == 0) begin         // prev frame done drawing, update memory with current state & switch rams if needed
        pacman_state_curr <= {pacman_xloc, pacman_yloc, pacman_dir, pacman_alive, pacman_animation};
        blinky_state_curr <= {blinky_xloc, blinky_yloc, blinky_dir, blinky_mode, ghost_animation};
        pixel_count <= 0;
        new_frame <= 0;
        sprite_num <= 3'b010;
    end else begin
        sprite_num <= sprite_num_d;
    end

    // if (pacman_state_curr != pacman_state_prev) begin      // update xpos, ypos and iterate through area bounded by sprite in new and old position
    //     draw_done <= 0;
    //     new_frame <= 1;
    //     pixel_count_d <= pixel_count + 1'b1;
    //     if (draw_old) begin
    //         xpos <= pacman_state_prev [22:14] - 7 + (pixel_count % 16);
    //         ypos <= pacman_state_prev [13:5] - 7 + (pixel_count >> 4);
    //         if (pixel_count == 255) begin       // update memory of previous state when done drawing sprite
    //             pixel_count <= 0;
    //             draw_old <= 0;
    //         end
    //     end else begin
    //         xpos <= pacman_state_curr [22:14] - 7 + (pixel_count % 16);
    //         ypos <= pacman_state_curr [13:5] - 7 + (pixel_count >> 4);
    //         if (pixel_count == 255) begin       // update memory of previous state when done drawing new sprite
    //             pacman_state_prev <= pacman_state_curr;
    //             pixel_count <= 0;
    //             draw_old <= 1;
    //         end
    //     end
    // end else if (blinky_state_curr != blinky_state_prev) begin
    //     draw_done <= 0;
    //     new_frame <= 1;
    //     pixel_count_d <= pixel_count + 1;
    //     if (draw_old) begin
    //         xpos <= blinky_state_prev [22:14] - 7 + (pixel_count % 16);
    //         ypos <= blinky_state_prev [13:5] - 7 + (pixel_count >> 4);
    //         if (pixel_count == 255) begin       // update memory of previous state when done drawing sprite
    //             pixel_count <= 0;
    //             draw_old <= 0;
    //         end
    //     end else begin
    //         xpos <= blinky_state_curr [22:14] - 7 + (pixel_count % 16);
    //         ypos <= blinky_state_curr [13:5] - 7 + (pixel_count >> 4);
    //         if (pixel_count == 255) begin       // update memory of previous state when done drawing new sprite
    //             blinky_state_prev <= blinky_state_curr;
    //             pixel_count <= 0;
    //             draw_old <= 1;
    //         end
    //     end
    // end else begin
    //     draw_done <= 1;
    // end

    // jank BUT WORKS   
    // writeEnable_d <= writeEnable_in;
    // writeEnable <= writeEnable_d;
end

always_comb begin
    pixel_count_d = pixel_count + 'b1;

    case (sprite_num) 
        3'b000: begin   // done drawing
            xpos = 0;
            ypos = 0;
            pixel_count_d = 0;
            sprite_num_d = 0;
        end

        3'b010: begin   // pacman old location
            xpos = pacman_state_prev [26:15] - 'd7 + (pixel_count % 'd16);
            ypos = pacman_state_prev [14:5]  - 'd7 + (pixel_count >> 'd4);
            if (pixel_count < 256) begin
                pixel_count_d = pixel_count + 'b1;
                sprite_num_d = 3'b010;
            end else begin  // sprite location scan complete, go next
                pixel_count_d = 0;
                sprite_num_d = 3'b011;
            end 
        end

        3'b011: begin   // pacman new location
            xpos = pacman_state_curr [26:15] - 'd7 + (pixel_count % 'd16);
            ypos = pacman_state_curr [14:5]  - 'd7 + (pixel_count >> 'd4);
            if (pixel_count < 256) begin
                pixel_count_d = pixel_count + 'b1;
                sprite_num_d = 3'b011;
            end else begin 
                pixel_count_d = 0;
                sprite_num_d = 3'b100;
            end 
        end

        default: begin
            xpos = 0;
            ypos = 0;
            pixel_count_d = 0;
            sprite_num_d = 0;
        end

    endcase
end


//  
// RAM ADDRESS CALCULATION
// only loads tiles 3-36 into ping-pong RAM due to space constraints 
localparam XMAX = 240;      // horizontal pixels (480/2)
localparam YMAX = 320;      // vertical pixels (640/2)
localparam YOFFSET = 24;    // vertical RAM offset (3 tiles * 8)
localparam ADDRESS_MAX = 65535;
reg [15:0] write_address;
always_comb begin
    if (pacman_state_curr != pacman_state_prev || blinky_state_curr != blinky_state_prev) begin
        write_address = (XMAX-xpos)*264 + (ypos-YOFFSET);
    end else begin
        write_address = ADDRESS_MAX;
    end
    // if (ypos > (YOFFSET-1) && ypos < (264+YOFFSET)) begin
    //     address = xpos*264 + (ypos-YOFFSET);
    // end else begin
    //     address = ADDRESS_MAX;
    // end
end

// 
// NEW RAM HANDLING
// will only flip RAMs if a unique frame is needed

reg write_ram1;

reg [15:0] ram1_addr;
reg [15:0] ram2_addr;
reg [7:0] ram1_in;
reg [7:0] ram1_out;
reg [7:0] ram2_in; 
reg [7:0] ram2_out;

ram_ip PING(ram1_addr, clk, ram1_in, write_ram1, ram1_out);
ram_ip PONG(ram2_addr, clk, ram2_in, ~write_ram1, ram2_out);

localparam HPIXELS = 640; 
localparam VPIXELS = 480;

initial begin
    write_ram1 = 0;
end

always @(posedge clk) begin
    if (hc_in == 0 && vc_in == 0 && draw_done && new_frame) begin // finished drawing last frame
        write_ram1 <= ~write_ram1;
    end
end

reg [8:0] xpos_read;
reg [8:0] ypos_read;
always_comb begin
    if (hc_in < 640 && vc_in < 480) begin
        xpos_read = XMAX - 1'b1 - (vc_in >> 1'd1);
        ypos_read = hc_in / 2;
    end else if (vc_in < 480) begin
        xpos_read = XMAX - 1'b1 - (vc_in >> 2'd2);
        ypos_read = YMAX - 1'b1;
    end else begin 
        xpos_read = 0;
        ypos_read = 0;
    end
end

always_comb begin
    if (write_ram1) begin
        ram1_addr = write_address;
        if (ypos_read > (YOFFSET-1) && ypos_read < (264+YOFFSET)) begin
            ram2_addr = xpos_read*264 + (ypos_read-YOFFSET);
        end else begin
            ram2_addr = ADDRESS_MAX;
        end        
        ram1_in = color;
        ram2_in = 8'hz;
        dataRead = ram2_out;
    end else begin
        if (ypos_read > (YOFFSET-1) && ypos_read < (264+YOFFSET)) begin
            ram1_addr = xpos_read*264 + (ypos_read-YOFFSET);
        end else begin
            ram1_addr = ADDRESS_MAX;
        end        
        ram2_addr = write_address;
        ram1_in = 8'hz;
        ram2_in = color;
        dataRead = ram1_out;
    end
end
endmodule
