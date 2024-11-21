`ifndef __CONSTANTS_SOBEL__
`define __CONSTANTS_SOBEL__

localparam MAX_PIXEL_BITS = 24;              
localparam PIXEL_WIDTH_OUT = 8;
localparam SOBEL_COUNTER_MAX_BITS = 3;                              //Counter for 3x3 matrix of pixels to convolve with kernel
localparam MAX_GRADIENT_WIDTH = $clog2((1 << PIXEL_WIDTH_OUT)*3);   //Max value of gradient could be a sum of three max values of 2^(PIXEL WIDTH) bits
localparam MAX_PIXEL_VAL = 1<< PIXEL_WIDTH_OUT;                     //Binarization max value
localparam MAX_GRADIENT_SUM_WIDTH = $clog2((1 << MAX_GRADIENT_WIDTH)*2);    
localparam MAX_RESOLUTION_BITS = 24;
localparam ZERO_PAD_WIDTH = MAX_PIXEL_BITS - PIXEL_WIDTH_OUT;
localparam FRAC_BITS = 6;
localparam BITS_Q4_6 = 11;

    typedef struct packed {
        logic signed [PIXEL_WIDTH_OUT-1:0] p0;
        logic signed [PIXEL_WIDTH_OUT-1:0] p1;
        logic signed [PIXEL_WIDTH_OUT-1:0] p2;
    } vector_3;
    

    typedef struct packed {
        vector_3 vector0;
        vector_3 vector1;
        vector_3 vector2;
    } matrix_3x3;

`endif
