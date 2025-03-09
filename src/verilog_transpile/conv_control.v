module conv_control (
	clk_i,
	nreset_i,
	kernel_i,
	start_cnn_i,
	px_rdy_i,
	in_value_i,
	out_px_o,
	px_rdy_o
);
	reg _sv2v_0;
	input wire clk_i;
	input wire nreset_i;
	localparam PIXEL_WIDTH_OUT = 8;
	input wire [71:0] kernel_i;
	input wire start_cnn_i;
	input wire px_rdy_i;
	input wire [7:0] in_value_i;
	localparam BITS_Q4_6 = 11;
	output wire [10:0] out_px_o;
	output reg px_rdy_o;
	localparam MATRIX_COUNTER_MAX_BITS = 3;
	reg [MATRIX_COUNTER_MAX_BITS:0] counter_conv;
	localparam MAX_RESOLUTION_BITS = 24;
	reg [23:0] counter_pixels;
	reg px_ready;
	reg [71:0] matrix_in_values;
	wire [10:0] out_conv_core;
	reg [10:0] out_conv;
	reg [2:0] fsm_state;
	reg [2:0] next;
	conv_core conv1(
		.input_data(matrix_in_values),
		.kernel(kernel_i),
		.out_conv_o(out_conv_core)
	);
	always @(posedge clk_i or negedge nreset_i)
		if (!nreset_i)
			fsm_state <= 3'd0;
		else
			fsm_state <= next;
	always @(*) begin
		if (_sv2v_0)
			;
		case (fsm_state)
			3'd0:
				if (start_cnn_i)
					next = 3'd1;
				else
					next = 3'd0;
			3'd1:
				if (counter_pixels == 1)
					next = 3'd2;
				else
					next = 3'd1;
			3'd2:
				if (start_cnn_i == 0)
					next = 3'd1;
				else
					next = 3'd2;
			default: next = 3'd0;
		endcase
	end
	always @(posedge clk_i or negedge nreset_i)
		if (!nreset_i) begin
			counter_conv <= 'b0;
			counter_pixels <= 'b0;
			px_ready <= 'b0;
			matrix_in_values <= 'b0;
		end
		else
			case (next)
				3'd0: begin
					px_ready <= 'b0;
					counter_pixels <= 'b0;
					counter_conv <= 'b0;
				end
				3'd1: begin
					px_ready <= 'b0;
					if (px_rdy_i) begin
						case (counter_conv)
							0: matrix_in_values[71-:8] <= in_value_i;
							1: matrix_in_values[63-:8] <= in_value_i;
							2: matrix_in_values[55-:PIXEL_WIDTH_OUT] <= in_value_i;
							3: matrix_in_values[47-:8] <= in_value_i;
							4: matrix_in_values[39-:8] <= in_value_i;
							5: matrix_in_values[31-:PIXEL_WIDTH_OUT] <= in_value_i;
							6: matrix_in_values[23-:8] <= in_value_i;
							7: matrix_in_values[15-:8] <= in_value_i;
							8: matrix_in_values[7-:PIXEL_WIDTH_OUT] <= in_value_i;
						endcase
						counter_conv <= counter_conv + 1;
						if (counter_conv == 8) begin
							counter_pixels <= counter_pixels + 1;
							counter_conv <= 'b0;
							px_ready <= 'b1;
						end
					end
				end
				3'd2: begin
					px_ready <= 'b0;
					if (px_rdy_i) begin
						case (counter_conv)
							0: begin
								matrix_in_values[71-:24] <= matrix_in_values[47-:24];
								matrix_in_values[47-:24] <= matrix_in_values[23-:24];
								matrix_in_values[23-:8] <= in_value_i;
							end
							1: matrix_in_values[15-:8] <= in_value_i;
							2: matrix_in_values[7-:PIXEL_WIDTH_OUT] <= in_value_i;
						endcase
						counter_conv <= counter_conv + 1;
						if (counter_conv == 2) begin
							counter_pixels <= counter_pixels + 1;
							counter_conv <= 'b0;
							px_ready <= 'b1;
						end
					end
				end
				default: begin
					px_ready <= 'b0;
					counter_pixels <= 'b0;
					counter_conv <= 'b0;
				end
			endcase
	always @(posedge clk_i or negedge nreset_i)
		if (!nreset_i) begin
			out_conv <= 1'sb0;
			px_rdy_o <= 1'sb0;
		end
		else begin
			px_rdy_o <= 1'sb0;
			if (px_ready) begin
				out_conv <= out_conv_core;
				px_rdy_o <= px_ready;
			end
		end
	assign out_px_o = out_conv;
	initial _sv2v_0 = 0;
endmodule
