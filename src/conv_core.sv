module conv_core(
  input matrix_3x3 input_data,                          // Input 3x3 pixel matrix in Q1.6
  input matrix_3x3 kernel,                              // Input Kernel 3x3 in Q1.6
  output [BITS_Q4_6-1:0] out_conv_o                     // Output 11 bits in Q4.6 + sign
);

  assign out_conv_o = 
      ((input_data.vector0.p0 * kernel.vector0.p0) >> FRAC_BITS) +
      ((input_data.vector0.p1 * kernel.vector0.p1) >> FRAC_BITS) + 
      ((input_data.vector0.p2 * kernel.vector0.p2) >> FRAC_BITS) +
      ((input_data.vector1.p0 * kernel.vector1.p0) >> FRAC_BITS) +
      ((input_data.vector1.p1 * kernel.vector1.p1) >> FRAC_BITS) + 
      ((input_data.vector1.p2 * kernel.vector1.p2) >> FRAC_BITS) +
      ((input_data.vector2.p0 * kernel.vector2.p0) >> FRAC_BITS) +
      ((input_data.vector2.p1 * kernel.vector2.p1) >> FRAC_BITS) + 
      ((input_data.vector2.p2 * kernel.vector2.p2) >> FRAC_BITS);

endmodule
