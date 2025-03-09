`ifdef COCOTB_SIM
  `include "../src/parameters.svh"
`else
  `include "parameters.svh"
`endif


`ifndef CONV_CORE_INCLUDED
`define CONV_CORE_INCLUDED

module conv_core(
  input matrix_3x3_8bits input_data,                    // Input 3x3 pixel matrix in Q1.6
  input matrix_3x3_8bits kernel,                        // Input Kernel 3x3 in Q1.6
  output [BITS_Q4_6-1:0] out_conv_o                     // Output 11 bits in Q4.6 + sign
);

  wire [BITS_Q4_6-1:0] conv_result;

  assign conv_result = 
      ((input_data.vector0.p0 * kernel.vector0.p0) >> FRAC_BITS) +
      ((input_data.vector0.p1 * kernel.vector0.p1) >> FRAC_BITS) + 
      ((input_data.vector0.p2 * kernel.vector0.p2) >> FRAC_BITS) +
      ((input_data.vector1.p0 * kernel.vector1.p0) >> FRAC_BITS) +
      ((input_data.vector1.p1 * kernel.vector1.p1) >> FRAC_BITS) + 
      ((input_data.vector1.p2 * kernel.vector1.p2) >> FRAC_BITS) +
      ((input_data.vector2.p0 * kernel.vector2.p0) >> FRAC_BITS) +
      ((input_data.vector2.p1 * kernel.vector2.p1) >> FRAC_BITS) + 
      ((input_data.vector2.p2 * kernel.vector2.p2) >> FRAC_BITS);


  // ReLU
  assign out_conv_o = (conv_result[BITS_Q4_6-1] == 1'b1) ? {BITS_Q4_6{1'b0}} : conv_result;

endmodule
`endif