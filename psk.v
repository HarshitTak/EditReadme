module psk (
  input [5:0] n_points,
  input [15:0] x_real, x_imag,
  output reg [5:0] index
);
  localparam PI = 16'd804;  // pi ≈ 3.1416 * 256

  reg [15:0] reset_angle, dividend;
  wire [15:0] angle;
  wire cor_ready;

  // Instantiate the combinational CORDIC block
  cordic c1 (
    .angle(angle),
    .ready(cor_ready),
    .x_real(x_real),
    .x_imag(x_imag),
    .enable(1'b1)  // Always enabled for combinational logic
  );

  always @(*) begin
    // Compute reset_angle based on constellation size
    reset_angle = (PI >> 2) - (
      (n_points == 6'd4)  ? 16'd201 :
      (n_points == 6'd8)  ? 16'd100 :
      (n_points == 6'd12) ? 16'd67  :
      (n_points == 6'd16) ? 16'd50  : 16'd0
    );

    // Calculate dividend using wraparound logic
    if (cor_ready) begin
      if (angle < reset_angle)
        dividend = angle - reset_angle + (PI << 1);  // angle + 2π wraparound
      else
        dividend = angle - reset_angle;

      case (n_points)
        6'd4: begin
          if      (dividend < 16'd402)   index = 6'd0;
          else if (dividend < 16'd804)   index = 6'd1;
          else if (dividend < 16'd1206)  index = 6'd2;
          else                           index = 6'd3;
        end

        6'd8: begin
          if      (dividend < 16'd201)   index = 6'd0;
          else if (dividend < 16'd402)   index = 6'd1;
          else if (dividend < 16'd603)   index = 6'd2;
          else if (dividend < 16'd804)   index = 6'd3;
          else if (dividend < 16'd1005)  index = 6'd4;
          else if (dividend < 16'd1206)  index = 6'd5;
          else if (dividend < 16'd1407)  index = 6'd6;
          else                           index = 6'd7;
        end

        6'd12: begin
          if      (dividend < 16'd134)   index = 6'd0;
          else if (dividend < 16'd268)   index = 6'd1;
          else if (dividend < 16'd402)   index = 6'd2;
          else if (dividend < 16'd536)   index = 6'd3;
          else if (dividend < 16'd670)   index = 6'd4;
          else if (dividend < 16'd804)   index = 6'd5;
          else if (dividend < 16'd938)   index = 6'd6;
          else if (dividend < 16'd1072)  index = 6'd7;
          else if (dividend < 16'd1206)  index = 6'd8;
          else if (dividend < 16'd1340)  index = 6'd9;
          else if (dividend < 16'd1474)  index = 6'd10;
          else                           index = 6'd11;
        end

        6'd16: begin
          if      (dividend < 16'd100)   index = 6'd0;
          else if (dividend < 16'd201)   index = 6'd1;
          else if (dividend < 16'd301)   index = 6'd2;
          else if (dividend < 16'd402)   index = 6'd3;
          else if (dividend < 16'd502)   index = 6'd4;
          else if (dividend < 16'd603)   index = 6'd5;
          else if (dividend < 16'd703)   index = 6'd6;
          else if (dividend < 16'd804)   index = 6'd7;
          else if (dividend < 16'd904)   index = 6'd8;
          else if (dividend < 16'd1005)  index = 6'd9;
          else if (dividend < 16'd1105)  index = 6'd10;
          else if (dividend < 16'd1206)  index = 6'd11;
          else if (dividend < 16'd1306)  index = 6'd12;
          else if (dividend < 16'd1407)  index = 6'd13;
          else if (dividend < 16'd1507)  index = 6'd14;
          else                           index = 6'd15;
        end

        default: index = 6'd0;
      endcase
    end
  end
endmodule
