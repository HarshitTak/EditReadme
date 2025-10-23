module cordic (
  input [15:0] x_real, x_imag,
  input enable,
  output reg [15:0] angle,
  output reg ready
);
  reg [23:0] x_temp, y_temp, x_temp1, adjust_x, adjust_y;
  reg [19:0] angle1, pi, look_up[15:0];
  reg xr_sign, xi_sign;
  integer i, d;

  // Preload lookup table for arctangent values (static, like a ROM)
  initial begin
    look_up[0]  = 20'b00001100100100010000;
    look_up[1]  = 20'b00000111011010110010;
    look_up[2]  = 20'b00000011111010110111;
    look_up[3]  = 20'b00000001111111010110;
    look_up[4]  = 20'b00000000111111111011;
    look_up[5]  = 20'b00000000011111111111;
    look_up[6]  = 20'b00000000010000000000;
    look_up[7]  = 20'b00000000001000000000;
    look_up[8]  = 20'b00000000000100000000;
    look_up[9]  = 20'b00000000000010000000;
    look_up[10] = 20'b00000000000001000000;
    look_up[11] = 20'b00000000000000100000;
    look_up[12] = 20'b00000000000000010000;
    look_up[13] = 20'b00000000000000001000;
    look_up[14] = 20'b00000000000000000100;
    look_up[15] = 20'b00000000000000000010;
    pi = 20'b00110010010000111111;
  end

  always @(*) begin
    if (enable) begin
      // Start computation when enable is high
      ready = 0;  // Disable ready while computation is happening
      angle = 16'd0;
      xr_sign = x_real[15];
      xi_sign = x_imag[15];

      x_temp = xr_sign ? {-x_real, 8'h00} : {x_real, 8'h00};
      y_temp = {x_imag, 8'h00};
      angle1 = 0;

      for (i = 0; i < 16; i = i + 1) begin
        case ({y_temp[23], x_temp[23]})
          2'b00: begin adjust_x = 0; adjust_y = 0; d = 1; end
          2'b01: begin adjust_x = ~(24'hFFFFFF >> i); adjust_y = 0; d = 1; end
          2'b10: begin adjust_x = 0; adjust_y = ~(24'hFFFFFF >> i); d = -1; end
          2'b11: begin adjust_x = ~(24'hFFFFFF >> i); adjust_y = ~(24'hFFFFFF >> i); d = -1; end
        endcase
//        $display("y_temp = %f\tx_temp = %f\tangle1 = %f\ti = %d\td = %d",
//             $signed(y_temp) / 65536.0,   // Converting to floating point
//             $signed(x_temp) / 65536.0,   // Converting to floating point
//             $signed(angle1) / 65536.0,   // Converting to floating point
//             i, d);
        x_temp1 = x_temp + d * ((y_temp >> i) | adjust_y);
        y_temp  = y_temp - d * ((x_temp >> i) | adjust_x);
        x_temp  = x_temp1;
        angle1  = angle1 + d * look_up[i];
      end

      // Quadrant adjustment
      case ({xr_sign, xi_sign})
        2'b00: angle1 = angle1;                  // Q1
        2'b01: angle1 = pi + pi + angle1;        // Q4
        2'b10,
        2'b11: angle1 = pi - angle1;             // Q2/Q3
      endcase

      angle1 = angle1 >> 4;                      // Normalize angle
      angle = angle1[19:4];                      // Final output
      ready = 1;  // Set ready to 1 once the computation is complete
    end
  end
endmodule
