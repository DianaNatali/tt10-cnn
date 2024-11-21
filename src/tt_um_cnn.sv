`ifdef COCOTB_SIM
  `include "../src/parameters.svh"
`else
  `include "parameters.svh"
`endif


module tt_um_cnn (
    input logic clk_i,
    input logic nreset_i,
    input logic start_cnn_i,  
    input logic px_rdy_i,
    input logic [PIXEL_WIDTH_OUT-1:0] in_px_sobel_i,
    input logic matrix_3x3 kernel_i,  
    input logic kernel_valid_i,  
    output logic [BITS_Q4_6-1:0] out_px_o[15:0],
    output logic px_rdy_o,
    output logic kernels_ready_o 
);

    matrix_3x3 kernel_values [15:0];  
    logic [3:0] kernel_counter;

    always_ff @(posedge clk_i or negedge nreset_i) begin
        if (!nreset_i) begin
            integer i, j, k;
            for (i = 0; i < 16; i = i + 1) begin
                kernel_values[i] <= 'b0;
            end
            kernel_counter <= 0;  
        end else if (kernel_valid_i && kernel_counter < 16) begin
            kernel_values[kernel_counter] <= kernel_i; 
            kernel_counter <= kernel_counter + 1;
        end else begin
            kernel_counter <= 0;  
        end
    end

    assign kernels_ready_o = (kernel_counter == 4'd15);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_conv
            conv_control conv_inst (
                .clk_i(clk_i),
                .nreset_i(nreset_i),
                .kernel_i(kernel_values[i]),  // Se pasa el i-ésimo kernel
                .start_cnn_i(start_cnn_i && kernels_ready_o),  // Control de inicio para cada convolución
                .px_rdy_i(px_rdy_i),
                .in_px_sobel_i(in_px_sobel_i),
                .out_px_o(out_px_o[i]),  // Resultado de la convolución
                .px_rdy_o(px_rdy_o)   // Señal de listo por cada instancia
            );
        end
    endgenerate

endmodule
