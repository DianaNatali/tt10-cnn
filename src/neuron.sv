`ifdef COCOTB_SIM
  `include "../src/parameters.svh"
`else
  `include "parameters.svh"
  `include "conv_control.sv"
  `include "conv_core.sv"
`endif

module neuron (
    input vector_3_8bits input_data,  
    input vector_3_8bits weights,     
    input [PIXEL_WIDTH_OUT-1:0] bias,           
    output [PIXEL_WIDTH_OUT-1:0] output_data         
);
    reg [15:0] sum;  //To-do

    always @(*) begin
        sum = (input_data[0] * weights[0]) + (input_data[1] * weights[1]) + (input_data[2] * weights[2]) + sesgo;
    end

    // ReLU
    assign output_data = (sum[15] == 1'b1) ? 8'b0 : sum[7:0];
endmodule