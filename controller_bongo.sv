module controller_bongo (
    input clk, 
    input start,
    output reg [0:15] buttons_out,
    output reg [7:0] joystick_xout,
    output reg [7:0] joystick_yout,
    output reg [7:0] cstick_xout,
    output reg [7:0] cstick_yout,
    output reg [7:0] lbtn_out,
    output reg [7:0] rbtn_out,
    inout data // assign within always block
);

/* PINOUT
          +-------> 5V      (white)
          |  +----> Data    (red)      
          |  |  +-> Ground  (blue)
          |  |  |
         +---x---+        7 (Ground)
    1  /  o  o  o  \      3
    4 |   o  x  o   |     6
       \-----------/  
          |     |
          |     +-> 3V3     (green)
          +-------> Ground  (black)

    blue -> GND
    black -> GND
    red -> DATA -> Arduino IO6
    green -> 3V3 (4th one from the left bc the other ones are fucking brokEn)
    pull up DATA to 3v3
*/

logic [0:24] bitStream [0:2] =  '{
    25'b0000000010000000000000000,
    25'b0100000110000000000000000,
    25'b0100000000000011000000001 
};   

logic [6:0] index, index_d;
logic [1:0] counter, counter_d;

logic [1:0] start_sr;

logic [1:0] state, state_d;

    
initial begin
    state = 0;
    index = 0;
    counter = 0;
    start_sr = 2'b00;
end

always_comb begin
    case (state)
        'b00: begin     // IDLE STATE
            index_d = 0;
            counter_d = 0;
            data = 1'bz;
            if (start_sr == 2'b01) begin
                state_d = 'b01;
            end else begin
                state_d = 'b00;
            end
        end

        'b01: begin     // POLL CONTROLLER
            counter_d = counter + 'b1;

            if (index == 'd24 && counter == 'd3) begin
                state_d = 'b10;
                index_d = 'b0;
                data = 'bz;
            end else begin
                state_d = 'b01;
                if (counter == 'b0) begin
                    data = 'b0;
                    index_d = index;
                end else if (counter == 'd3) begin
                    data = 'b1;
                    index_d = index + 'b1; 
                end else begin
                    data = bitStream[2][index];
                    index_d = index;
                end
            end
        end

        'b10: begin     // RECEIVE CONTROLLER DATA
            counter_d = counter + 'b1;
            data = 'bz;

            if (index == 'd64 && counter == 'd3) begin
                state_d = 'b00;
                index_d = 'b0;
            end else begin
                state_d = 'b10;
                if (counter == 'd3) begin
                    index_d = index + 'b1;
                end else begin
                    index_d = index;
                end
            end
        end
    endcase
end

always @(posedge clk) begin
    start_sr <= {start_sr[0], start};

    index <= index_d;
    counter <= counter_d;
    if (state_d == 'b10) begin
        if (~data) begin
            state <= state_d;
        end 
    end else begin
        state <= state_d;
    end

    if (state == 'b10 && counter == 'd0) begin
        if (index < 'd16) begin
            buttons_out[index] <= data;
        end else if (index < 'd24) begin
            joystick_xout['d23 - index] <= data;
        end else if (index < 'd32) begin
            joystick_yout['d31 - index] <= data;
        end else if (index < 'd40) begin
            cstick_xout['d39 - index] <= data;
        end else if (index < 'd48) begin
            cstick_yout['d47 - index] <= data;
        end else if (index < 'd56) begin
            lbtn_out['d55 - index] <= data;
        end else if (index < 'd64) begin
            rbtn_out['d63 - index] <= data;
        end                
    end
end

endmodule