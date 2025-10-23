`timescale 1ns / 1ps

module demapper #(
  parameter MAX_BITS = 5 // Max bits per symbol (e.g., 32-APSK)
)(
  input clk,
  input enable,
  input [15:0] x_real,
  input [15:0] x_imag,
  input [3:0]  coding_rate,  // 0: '1', 1: '2/3', ..., 6: '9/10'
  output reg [MAX_BITS-1:0] bits
);

  // Gray code tables
  reg [1:0] gray_qpsk [0:3];
  reg [2:0] gray_8psk [0:7];
  reg [3:0] gray_16apsk [0:15];
  reg [4:0] gray_32apsk [0:31];

  reg [15:0] abs_x, abs_y, max, min, magnitude;
  reg [5:0]  points;
  reg [1:0]  region;
  reg [5:0]  i;

  wire [5:0] psk_index;

  // External CORDIC-based angle-to-index mapper
  psk psk_inst (
    .n_points(points),
    .x_real(x_real),
    .x_imag(x_imag),
    .index(psk_index)
  );

  // Combinational Logic
  always @(posedge clk) begin
    // Default
    if(enable) begin
        bits = 0;
        i = psk_index;
    
        // Calculate abs and approximate magnitude
        abs_x = x_real[15] ? (~x_real + 1) : x_real;
        abs_y = x_imag[15] ? (~x_imag + 1) : x_imag;
    
        if (abs_x > abs_y) begin
          max = abs_x;
          min = abs_y;
        end else begin
          max = abs_y;
          min = abs_x;
        end
    
        magnitude = max + (min >> 2) + (min >> 3) + (min >> 4)
                        - (min >> 6) - (min >> 7);
//        $display("magnitude = %f",magnitude);
        // Demapping logic
        case (MAX_BITS)
          3'd2: begin // QPSK
            points = 6'd4;
            if (i >= 4) i = 0;
            bits = gray_qpsk[i];
          end
    
          3'd3: begin // 8-PSK
            points = 6'd8;
            if (i >= 8) i = 0;
            bits = gray_8psk[i];
          end
    
          3'd4: begin // 16-APSK
            $display("%d\t%d",apsk_16_threshold(coding_rate),psk_index);
            if (magnitude < apsk_16_threshold(coding_rate)) begin
              points = 6'd4;
              if (i >= 4) i = 0;
              bits = gray_16apsk[i];
            end else begin
              points = 6'd12;
              if (i >= 12) i = 0;
              bits = gray_16apsk[i + 4];
            end
          end
    
          3'd5: begin // 32-APSK
            region = apsk_32_region(magnitude, coding_rate);
            case (region)
              2'd0: begin points = 6'd4;  if (i >= 4)  i = 0; bits = gray_32apsk[i]; end
              2'd1: begin points = 6'd12; if (i >= 12) i = 0; bits = gray_32apsk[i + 4]; end
              2'd2: begin points = 6'd16; if (i >= 16) i = 0; bits = gray_32apsk[i + 16]; end
              default: bits = 0;
            endcase
          end
    
          default: bits = 0;
        endcase
    end
    else bits = 'bz;
  end

  // Thresholds for 16-APSK
  function [15:0] apsk_16_threshold;
    input [3:0] rate;
    begin
      case (rate)
        4'd1: apsk_16_threshold = 16'd169;
        4'd2: apsk_16_threshold = 16'd173;
        4'd3: apsk_16_threshold = 16'd174;
        4'd4: apsk_16_threshold = 16'd175;
        4'd5: apsk_16_threshold = 16'd177;
        4'd6: apsk_16_threshold = 16'd178;
        default: apsk_16_threshold = 16'd173;
      endcase
    end
  endfunction

  // Region classification for 32-APSK
  function [1:0] apsk_32_region;
    input [15:0] mag;
    input [3:0]  rate;
    reg [15:0] t1, t2;
    begin
      case (rate)
        4'd2: begin t1 = 16'd54; t2 = 16'd173; end
        4'd3: begin t1 = 16'd57; t2 = 16'd175; end
        4'd4: begin t1 = 16'd59; t2 = 16'd176; end
        4'd5: begin t1 = 16'd62; t2 = 16'd178; end
        4'd6: begin t1 = 16'd63; t2 = 16'd179; end
        default: begin t1 = 16'd54; t2 = 16'd173; end
      endcase

      if (mag < t1)
        apsk_32_region = 2'd0;
      else if (mag < t2)
        apsk_32_region = 2'd1;
      else
        apsk_32_region = 2'd2;
    end
  endfunction

  // Gray code initialization
  initial begin
    gray_qpsk[0] = 2'b00; gray_qpsk[1] = 2'b01; gray_qpsk[2] = 2'b11; gray_qpsk[3] = 2'b10;

    gray_8psk[0] = 3'b000; gray_8psk[1] = 3'b100; gray_8psk[2] = 3'b110; gray_8psk[3] = 3'b010;
    gray_8psk[4] = 3'b011; gray_8psk[5] = 3'b111; gray_8psk[6] = 3'b101; gray_8psk[7] = 3'b001;

    // Gray for 16APSK (example layout)
    gray_16apsk[0]  = 4'b1100; // 12
    gray_16apsk[1]  = 4'b1110; // 14
    gray_16apsk[2]  = 4'b1111; // 15
    gray_16apsk[3]  = 4'b1101; // 13
    gray_16apsk[4]  = 4'b0000; // 0
    gray_16apsk[5]  = 4'b1000; // 8
    gray_16apsk[6]  = 4'b1010; // 10
    gray_16apsk[7]  = 4'b0010; // 2
    gray_16apsk[8]  = 4'b0110; // 6
    gray_16apsk[9]  = 4'b0111; // 7
    gray_16apsk[10] = 4'b0011; // 3
    gray_16apsk[11] = 4'b1011; // 11
    gray_16apsk[12] = 4'b1001; // 9
    gray_16apsk[13] = 4'b0001; // 1
    gray_16apsk[14] = 4'b0101; // 5
    gray_16apsk[15] = 4'b0100; // 4

    // Gray for 32APSK
    gray_32apsk[0]  = 5'b10001; gray_32apsk[1]  = 5'b10101;
    gray_32apsk[2]  = 5'b10111; gray_32apsk[3]  = 5'b10011;
    gray_32apsk[4]  = 5'b00000; gray_32apsk[5]  = 5'b00001;
    gray_32apsk[6]  = 5'b00101; gray_32apsk[7]  = 5'b00100;
    gray_32apsk[8]  = 5'b10100; gray_32apsk[9]  = 5'b10110;
    gray_32apsk[10] = 5'b00110; gray_32apsk[11] = 5'b00111;
    gray_32apsk[12] = 5'b00011; gray_32apsk[13] = 5'b00010;
    gray_32apsk[14] = 5'b10010; gray_32apsk[15] = 5'b10000;
    gray_32apsk[16] = 5'b11001; gray_32apsk[17] = 5'b01001;
    gray_32apsk[18] = 5'b01101; gray_32apsk[19] = 5'b11101;
    gray_32apsk[20] = 5'b01100; gray_32apsk[21] = 5'b11100;
    gray_32apsk[22] = 5'b11110; gray_32apsk[23] = 5'b01110;
    gray_32apsk[24] = 5'b11111; gray_32apsk[25] = 5'b01111;
    gray_32apsk[26] = 5'b01011; gray_32apsk[27] = 5'b11011;
    gray_32apsk[28] = 5'b01010; gray_32apsk[29] = 5'b11010;
    gray_32apsk[30] = 5'b11000; gray_32apsk[31] = 5'b01000;
  end

endmodule
