/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

`ifdef COCOTB_SIM
  `include "../src/parameters.svh"
`else
  `include "parameters.svh"
`endif

module tt_um_cnn (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    assign uio_oe = 8'b00000000; 
    assign uio_out = '0;

    logic nreset_async_i;
    assign nreset_async_i = rst_n;

     //SPI interface
    logic spi_sck_i;
    logic spi_sdi_i;
    logic spi_cs_i;
    logic spi_sdo_o;
    assign spi_sck_i = ui_in[0];
    assign spi_cs_i = ui_in[1];
    assign spi_sdi_i = ui_in[2];
    assign uo_out[0] = spi_sdo_o;

    logic in_px_rdy;
    logic out_px_rdy;
    logic kernel_valid;
    logic kernel_rdy;

    spi_dep_async_nreset_synchronizer nreset_sync0 (
      .clk_i(clk),
      .async_nreset_i(nreset_async_i),
      .tied_value_i(1'b1),
      .nreset_o(nreset_i)
    );

    logic [MAX_PIXEL_BITS-1:0] input_pixel;
    logic [MAX_PIXEL_BITS-1:0] output_data;

    spi_control spi0 (
      .clk_i(clk),
      .nreset_i(nreset_i),
      .spi_sck_i(spi_sck_i),
      .spi_sdi_i(spi_sdi_i),
      .spi_cs_i(spi_cs_i),
      .spi_sdo_o(spi_sdo_o),
      .px_rdy_o_spi_i(out_px_rdy),
      .px_rdy_i_spi_o(in_px_rdy),
      .input_px_gray_o(input_pixel),
      .output_px_sobel_i(output_data)
    );

    top_cnn top_cnn0 (
      .clk_i(clk),
      .nreset_i(nreset_i),
      .start_cnn_i(start_sobel_i),
      .px_rdy_i(in_px_rdy),
      .in_px_sobel_i(input_pixel),
      .kernel_valid_i(kernel_valid),
      .px_rdy_o(out_px_rdy),
      .kernels_ready_o(kernel_rdy)
    );


  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule
