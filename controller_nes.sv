module controller_nes (
    input clk,  // 6 us pulse
    input start,
    input data_in,
    output reg latch_out,
    output reg pulse_out,
    output reg [0:7] buttons_pressed // A, B, Select, Start, Up, Down, Left, Right
);

/* PINOUT
            +----> Power  (blue)
            |
    5 +---------+  7
    | x  x  o   \
    | o  o  o  o |
    4 +------------+ 1
      |  |  |  |
      |  |  |  +-> Ground (green) 
      |  |  +----> Pulse  (orange)
      |  +-------> Latch  (yellow)
      +----------> Data   (red) 
*/

reg [4:0] counter; 
reg [4:0] counter_d;
reg [1:0] start_sr;
reg pulse_out_d;

initial begin
    counter = 'b0;
    start_sr = 'b00;
end

always @(posedge clk) begin
    counter <= counter_d; 
    pulse_out <= pulse_out_d;

    start_sr <= {start_sr[0], start};
    if (counter < 'd18) begin
        buttons_pressed [counter >> 1] <= ~data_in;
    end

end

always_comb begin
    if (start_sr == 2'b01 && counter == 'd18) begin
        counter_d = 1'b0;
    end else if (counter < 'd18) begin
        counter_d = counter + 1'b1;
    end else begin
        counter_d = 'd18;
    end

    if (counter == 1'b0 || counter == 1'b1) begin
        latch_out = 1'b1;
        pulse_out_d = 1'b0;
    end else if (counter > 'd1 && counter < 'd18) begin
        latch_out = 1'b0;
        pulse_out_d = ~pulse_out;
    end else begin
        latch_out = 1'b0;
        pulse_out_d = 1'b0;
    end
end

endmodule