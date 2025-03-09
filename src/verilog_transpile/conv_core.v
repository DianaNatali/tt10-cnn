module conv_core (
	input_data,
	kernel,
	out_conv_o
);
	localparam PIXEL_WIDTH_OUT = 8;
	input wire [71:0] input_data;
	input wire [71:0] kernel;
	localparam BITS_Q4_6 = 11;
	output wire [10:0] out_conv_o;
	wire [10:0] conv_result;
	localparam FRAC_BITS = 6;
	assign conv_result = ((((((((($signed(input_data[71-:8]) * $signed(kernel[71-:8])) >> FRAC_BITS) + (($signed(input_data[63-:8]) * $signed(kernel[63-:8])) >> FRAC_BITS)) + (($signed(input_data[55-:PIXEL_WIDTH_OUT]) * $signed(kernel[55-:PIXEL_WIDTH_OUT])) >> FRAC_BITS)) + (($signed(input_data[47-:8]) * $signed(kernel[47-:8])) >> FRAC_BITS)) + (($signed(input_data[39-:8]) * $signed(kernel[39-:8])) >> FRAC_BITS)) + (($signed(input_data[31-:PIXEL_WIDTH_OUT]) * $signed(kernel[31-:PIXEL_WIDTH_OUT])) >> FRAC_BITS)) + (($signed(input_data[23-:8]) * $signed(kernel[23-:8])) >> FRAC_BITS)) + (($signed(input_data[15-:8]) * $signed(kernel[15-:8])) >> FRAC_BITS)) + (($signed(input_data[7-:PIXEL_WIDTH_OUT]) * $signed(kernel[7-:PIXEL_WIDTH_OUT])) >> FRAC_BITS);
	assign out_conv_o = (conv_result[10] == 1'b1 ? {BITS_Q4_6 {1'b0}} : conv_result);
endmodule
