// Code your design here
module pl_header_generator (
  clk,
  en,
  b0_b7,
  final_pl_header_real,
  final_pl_header_imag,
  pl_header_ready
);
  
  parameter [0:25] sof=26'b01100011010010111010000010;
  parameter [0:63] scrseq=64'b0111000110011101100000111100100101010011010000100010110111111010;
  
  //Input variables
  input wire en,clk;
  input wire [0:6] b0_b7;
    
  //Output variables
  output reg [0:15] final_pl_header_real;
  output reg [0:15] final_pl_header_imag;
  output reg pl_header_ready;
  
  //Declaring variables
  reg [0:89] PL_header_bits;
  reg [0:63] output1;
  reg [0:31]output_bits;
  integer temp_int,i=0,j;
  
  //fixed_point_representation
  reg [0:15] floating_point_binary_pos=16'b0000_0000_1011_0101;
  reg [0:15] floating_point_binary_neg=16'b1111_1111_0100_1011;
 

  always @(posedge clk)  begin
  if (en==1)begin
    if (i==0) begin
        j=0;
        PL_header_bits=89'b0;
        pl_header_ready=0;
        output_bits[0]  = b0_b7[5];
        output_bits[1]  = b0_b7[0] ^ b0_b7[5];
        output_bits[2]  = b0_b7[1] ^ b0_b7[5];
        output_bits[3]  = b0_b7[0] ^ b0_b7[1] ^ b0_b7[5];
        output_bits[4]  = b0_b7[2] ^ b0_b7[5];
        output_bits[5]  = b0_b7[0] ^ b0_b7[2] ^ b0_b7[5];
        output_bits[6]  = b0_b7[1] ^ b0_b7[2] ^ b0_b7[5];
        output_bits[7]  = b0_b7[0] ^ b0_b7[1] ^ b0_b7[2] ^ b0_b7[5];
        output_bits[8]  = b0_b7[3] ^ b0_b7[5];
        output_bits[9]  = b0_b7[0] ^ b0_b7[3] ^ b0_b7[5];
        output_bits[10] = b0_b7[1] ^ b0_b7[3] ^ b0_b7[5];
        output_bits[11] = b0_b7[0] ^ b0_b7[1] ^ b0_b7[3] ^ b0_b7[5];
        output_bits[12] = b0_b7[2] ^ b0_b7[3] ^ b0_b7[5];
        output_bits[13] = b0_b7[0] ^ b0_b7[2] ^ b0_b7[3] ^ b0_b7[5];
        output_bits[14] = b0_b7[1] ^ b0_b7[2] ^ b0_b7[3] ^ b0_b7[5];
        output_bits[15] = b0_b7[0] ^ b0_b7[1] ^ b0_b7[2] ^ b0_b7[3] ^ b0_b7[5];
        output_bits[16] = b0_b7[4] ^ b0_b7[5];
        output_bits[17] = b0_b7[0] ^ b0_b7[4] ^ b0_b7[5];
        output_bits[18] = b0_b7[1] ^ b0_b7[4] ^ b0_b7[5];
        output_bits[19] = b0_b7[0] ^ b0_b7[1] ^ b0_b7[4] ^ b0_b7[5];
        output_bits[20] = b0_b7[2] ^ b0_b7[4] ^ b0_b7[5];
        output_bits[21] = b0_b7[0] ^ b0_b7[2] ^ b0_b7[4] ^ b0_b7[5];
        output_bits[22] = b0_b7[1] ^ b0_b7[2] ^ b0_b7[4] ^ b0_b7[5];
        output_bits[23] = b0_b7[0] ^ b0_b7[1] ^ b0_b7[2] ^ b0_b7[4] ^ b0_b7[5];
        output_bits[24] = b0_b7[3] ^ b0_b7[4] ^ b0_b7[5];
        output_bits[25] = b0_b7[0] ^ b0_b7[3] ^ b0_b7[4] ^ b0_b7[5];
        output_bits[26] = b0_b7[1] ^ b0_b7[3] ^ b0_b7[4] ^ b0_b7[5];
        output_bits[27] = b0_b7[0] ^ b0_b7[1] ^ b0_b7[3] ^ b0_b7[4] ^ b0_b7[5];
        output_bits[28] = b0_b7[2] ^ b0_b7[3] ^ b0_b7[4] ^ b0_b7[5];
        output_bits[29] = b0_b7[0] ^ b0_b7[2] ^ b0_b7[3] ^ b0_b7[4] ^ b0_b7[5];
        output_bits[30] = b0_b7[1] ^ b0_b7[2] ^ b0_b7[3] ^ b0_b7[4] ^ b0_b7[5];
        output_bits[31] = b0_b7[0] ^ b0_b7[1] ^ b0_b7[2] ^ b0_b7[3] ^ b0_b7[4] ^ b0_b7[5];
    end
    
    if (i<32)begin
      output1[2*i]   = output_bits[i]  ^ scrseq[2*i];
      output1[2*i+1] = output_bits[i] ^ b0_b7[6] ^ scrseq[2*i+1];
      i=i+1;
    end
  

    if (i==32 & j<90)begin
        PL_header_bits={sof, output1}; 
        temp_int=PL_header_bits[j];
        temp_int=(1 - 2*temp_int);
        
        if (j%2==0)begin
          if (temp_int>0)begin
            final_pl_header_real=floating_point_binary_pos;
            final_pl_header_imag=floating_point_binary_pos;
          end
          else begin
            final_pl_header_real=floating_point_binary_neg;
            final_pl_header_imag=floating_point_binary_neg;
          end
        end
        else begin
          if (temp_int>0)begin
            final_pl_header_real=floating_point_binary_neg;
            final_pl_header_imag=floating_point_binary_pos;
          end
          else begin
            final_pl_header_real=floating_point_binary_pos;
            final_pl_header_imag=floating_point_binary_neg;
          end
        end
        j=j+1;
    end
    
    if (j==90)begin
      pl_header_ready=1;
      i=0;
      j=0;
    end
  end
  end
endmodule



